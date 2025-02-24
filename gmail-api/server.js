import express from 'express';
import querystring from 'querystring';
import jwt from 'jsonwebtoken';
import cookieParser from 'cookie-parser';
import cors from 'cors';
import fetch from 'node-fetch';
import env from 'dotenv';
import cron from 'node-cron'
import AWSResourceHandler from './AWSResourceHandler.js';

const app = express();
env.config()
const PORT = process.env.PORT || 3000

const awsClient = new AWSResourceHandler()

// 1. localhost:3000/
// 2. Google auth redirect
// 3. User gives consent
// 4. Redirect to REDIRECT_URI: auth/google 
// 5. Fetch google api token 
// 6. Retrieve google user info 
// 7. Convert to cookie with jwt
// 8. Access gmail api passing in jwt encrypted user info

// CLIENT_ID and CLIENT_SECRET defined in gcp project
const CLIENT_ID     = process.env.CLIENT_ID
const CLIENT_SECRET = process.env.CLIENT_SECRET
const JWT_SECRET    = process.env.JWT_SECRET
const SCOPES        = process.env.SCOPES.split(" ") // services we want access to

// callback uri that oauth server sends responses to
const REDIRECT_URI = process.env.REDIRECT_URI

app.use(cors({credentials: true}))
app.use(cookieParser())

app.get('/', (req, res) => {
    // OAuth: allows users to grant third-party apps access to their info on other websites without sharing passwords
    const apiurl  = "https://accounts.google.com/o/oauth2/v2/auth"
    const options = {
        redirect_uri:  REDIRECT_URI,
        client_id:     CLIENT_ID,
        access_type:   "offline",
        response_type: "code",
        prompt:        "consent",
        scope:         SCOPES.join(" ")
    }
    // querystring adds the parameters in the url itself rather than the body
    res.redirect(`${apiurl}?${querystring.stringify(options)}`)
})


app.get("/auth/google", async (req, res) => {
    const values = {
        code:          req.query.code,
        client_id:     CLIENT_ID,
        client_secret: CLIENT_SECRET,
        redirect_uri:  REDIRECT_URI,
        grant_type:    "authorization_code",
    }

    // Fetch oauth token that we use to make the api calls
    const authRes = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams(values),
    })
    const { id_token, access_token, refresh_token } = await authRes.json()

    // Get google user info by making call to userinfo google api using the access token we just got
    const googleUserRes = await fetch(`https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=${access_token}`, {
        method: "GET",    
        headers: {
            Authorization: `Bearer ${id_token}`,
        },
    })
    const googleUser = await googleUserRes.json()

    // Encode user info with jwt
    const jwt_token = jwt.sign({access_token, id_token, refresh_token, id: googleUser.id}, JWT_SECRET)
    await awsClient.insert(googleUser.id, jwt_token)
})


const getEmailBody = (emailData) => {
    if (emailData.payload) {
        if (emailData.payload.parts) {
            for (let part of emailData.payload.parts) {
                if (part.mimeType === "text/plain") {
                    return Buffer.from(part.body.data, "base64").toString("utf-8");
                }
            }
        }
    
        if (emailData.payload.body && emailData.payload.body.data) {
            return Buffer.from(emailData.payload.body.data, "base64").toString("utf-8");
        }
    }
    return "No body content found";
}

app.get("/emails", async (req, res) => {
  // validate oauth token is present in jwt cookie
  const auth_data = await awsClient.read()
  for (let i = 0; i < auth_data.length; i++) {
    const authCreds = jwt.verify(auth_data[i].EmailToken, JWT_SECRET)

    // Get emails from 30 mins ago
    const thirtyMinutesAgo = Math.floor((Date.now() - 30 * 60 * 1000) / 1000);
    const emailRes = await fetch('https://gmail.googleapis.com/gmail/v1/users/' + authCreds.id + '/messages?q=after:' + thirtyMinutesAgo, {
        method: "GET",
        headers: {
        Authorization: `Bearer ${authCreds.access_token}`,
        Accept: 'application/json'
        },
    })
    const data = await emailRes.json()

    if (!data.messages) {
        continue
    }

    // Use the id's of the emails from the previous call to get a portion of the body of the emails
    const emails = [];
    for (let i = 0; i < data.messages.length; i++) {
        const res = await fetch(`https://gmail.googleapis.com/gmail/v1/users/${authCreds.id}/messages/${data.messages[i].id}?format=full`, {
        method: "GET",
        headers: {
            Authorization: `Bearer ${authCreds.access_token}`,
            Accept: "application/json",
        },
        });
    
        const emailData = await res.json();  
        const body = getEmailBody(emailData);
        emails.push({'id': authCreds.id, 'body': body});
    }
    
    console.log(emails)
    awsClient.firehosePUT(emails)
  }
})


const refreshAccessToken = async (refreshToken) => {
    const values = {
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        refresh_token: refreshToken,
        grant_type: 'refresh_token',
    };

    try {
        const authRes = await fetch("https://oauth2.googleapis.com/token", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: new URLSearchParams(values),
        });

        const { access_token } = await authRes.json();
        return access_token
    } catch (error) {
        console.error('Error refreshing access token:', error);
        return error
    }
}


cron.schedule('*/1 * * * *', async () => {
    const data = await awsClient.read()
    
    for (let i = 0; i < data.length; i++) {
        const authCreds    = jwt.verify(data[i].EmailToken, JWT_SECRET)
        let newAccessToken = await refreshAccessToken(authCreds.refresh_token)

        const tokenContent = {
            access_token: newAccessToken,
            refresh_token: authCreds.refresh_token,
            id_token: authCreds.id_token,
            id: authCreds.id
        }

        const jwt_token = jwt.sign(tokenContent, JWT_SECRET)
        await awsClient.insert(data[i].UserId, jwt_token)
    }
})


app.listen(PORT, () => {console.log(`Server is running on http://localhost:${PORT}`)})