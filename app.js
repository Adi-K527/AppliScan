const express = require('express');
const app = express();
const querystring = require("querystring")
const jwt = require("jsonwebtoken")
const cookieParser = require('cookie-parser')
const cors = require("cors")
const fetch = require("node-fetch")
const env = require('dotenv')


// 1. localhost:3000/
// 2. Google auth redirect
// 3. User gives consent
// 4. Redirect to REDIRECT_URI: auth/google 
// 5. Fetch google api token 
// 6. Retrieve google user info 
// 7. Convert to cookie with jwt
// 8. Access gmail api passing in jwt encrypted user info


// CLIENT_ID and CLIENT_SECRET defined in gcp project
const CLIENT_ID = process.env.CLIENT_ID
const CLIENT_SECRET = process.env.CLIENT_SECRET
const JWT_SECRET = process.env.JWT_SECRET
const SCOPES =  process.env.SCOPES// services we want access to

// callback uri that oauth server sends responses to
const REDIRECT_URI = process.env.REDIRECT_URI


app.use(cors({credentials: true}))
app.use(cookieParser())

app.get('/', (req, res) => {
    // OAuth: allows users to grant third-party apps access to their info on other websites without sharing passwords
    const apiurl = "https://accounts.google.com/o/oauth2/v2/auth"
    const options = {
        redirect_uri: REDIRECT_URI,
        client_id: CLIENT_ID,
        access_type: "offline",
        response_type: "code",
        prompt: "consent",
        scope: SCOPES.join(" ")
    }
    // querystring adds the parameters in the url itself rather than the body
    res.redirect(`${apiurl}?${querystring.stringify(options)}`)
})


app.get("/auth/google", async (req, res) => {
    values = {
        code: req.query.code,
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        redirect_uri: REDIRECT_URI,
        grant_type: "authorization_code",
    }

    // Fetch oauth token that we use to make the api calls
    const authRes = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams(values),
    })
    const { id_token, access_token } = await authRes.json()

    // Get google user info by making call to userinfo google api using the access token we just got
    const googleUserRes = await fetch(`https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=${access_token}`, {
        method: "GET",    
        headers: {
            Authorization: `Bearer ${id_token}`,
        },
    })
    const googleUser = await googleUserRes.json()

    // Encode user info with jwt
    const jwt_token = jwt.sign({access_token, id_token, id: googleUser.id}, JWT_SECRET)
    res.cookie("auth_token", jwt_token, {
        maxAge: 900000,
        httpOnly: true,
        secure: false
    })

    res.redirect("http://localhost:3000/emails")
})


app.get("/emails", async (req, res) => {
  // validate oauth token is present in jwt cookie
  const authCreds = jwt.verify(req.cookies['auth_token'], JWT_SECRET)

  // call gmail api with the auth creds to fetch top 10 emails
  const emailRes = await fetch('https://gmail.googleapis.com/gmail/v1/users/' + authCreds.id + '/messages?maxResults=10', {
    method: "GET",
    headers: {
      Authorization: `Bearer ${authCreds.access_token}`,
      Accept: 'application/json'
    },
  })
  const data = await emailRes.json()

  // Use the id's of the emails from the previous call to get a portion of the body of the emails
  const emails = []
  for (let i = 0; i < data.messages.length; i++) {
    const res = await fetch('https://gmail.googleapis.com/gmail/v1/users/' + authCreds.id + '/messages/' + data.messages[i].id, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${authCreds.access_token}`,
        Accept: 'application/json'
      },
    })

    const snippet = await res.json()
    emails.push(snippet.snippet)
  }
  res.status(200).json({message: emails})
})

app.listen(3000, () => {console.log(`Server is running on http://localhost:3000`)});