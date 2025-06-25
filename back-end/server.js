import express from 'express';
import pg from 'pg';
import cors from 'cors';
import jwt from 'jsonwebtoken';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';

const app = express();
const port = process.env.PORT || 3000;
dotenv.config()

app.use(express.json());
app.use(cors({credentials: true}));

const client = new pg.Client({
  connectionString: process.env.DB_URI
})
client.connect()
.then(() => console.log('Connected to the database'))
.catch((err) => console.error('Database connection error', err.stack));



// ----------------------------------------- User microservice -----------------------------------------
app.post('/signup', async (req, res) => {
  console.log(req.body)
  const { firstName, lastName, email, password } = req.body;
  
  
  if (!firstName || !lastName || !email || !password) { // check feilds
    return res.status(400).json({ error: 'All fields are required.' });
  }

  try {
    const insertQuery = `
      INSERT INTO users (first_name, last_name, email, password)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    const values = [firstName, lastName, email, password];
    const result = await client.query(insertQuery, values);

    return res.status(201).json({
      message: 'User registered successfully',
      user: result.rows[0]
    });
  } catch (err) {
    console.error('Error inserting user:', err);
    // no dups 
    if (err.code === '23505') {
      return res.status(400).json({ error: 'Email already exists.' });
    }
    return res.status(500).json({ error: 'Database error.' });
  }
});

app.post('/login', async (req, res) => {
  console.log(req.body)
  const { email, password } = req.body;

  if (!email || !password) { // check feilds
    return res.status(400).json({ error: 'All fields are required.' });
  }

  try {
    const insertQuery = `
      SELECT * FROM users WHERE email = $1 AND password = $2
    `;
    const values = [email, password];
    const result = await client.query(insertQuery, values);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    console.log(result.rows[0])
    
    const token = jwt.sign({ user_id: result.rows[0].user_id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    return res.status(201).json({
      "message": 'User Logged in',
      "token": token,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Login Failed' });
  }
});


app.get('/users', async (req, res) => {
  try {
    const result = await client.query('SELECT * FROM users ORDER BY id ASC');
    return res.status(200).json({ users: result.rows });
  } catch (err) {
    console.error('Error retrieving users:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});


const secure = async (req, res, next) => {
    if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
      const token = req.headers.authorization.split(' ')[1]

      const {user_id} = jwt.decode(token, process.env.JWT_SECRET)

      const response = await client.query(
          "SELECT user_id FROM users WHERE user_id = $1", 
          [user_id]
      )

      if (response.rows.length > 0) {
          next()
      }
      else {
          res.status(400).json({"error": "Invalid Credentials"})
      }
  }
  else {
      res.status(400).json({"error": "Invalid Credentials"})
  }
}


// ----------------------------------------- Applications microservice -----------------------------------------
app.get('/applications', secure, async (req, res) => {
  try {

    const token = req.headers.authorization.split(' ')[1]
    const {user_id} = jwt.decode(token, process.env.JWT_SECRET)

    console.log(user_id)

    const g_id_data = await client.query(
        "SELECT gid FROM users WHERE user_id = $1", 
        [user_id]
    )
    const g_id = g_id_data.rows[0].gid

    if (!g_id) {
        return res.status(200).json({ "message": 'NoPerm' });
    }

    const result = await client.query(
        "SELECT status, company FROM application WHERE gid = $1", 
        [g_id]
    );

    return res.status(200).json({ users: result.rows });
  } catch (err) {
    console.error('Error retrieving users:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

app.post('/data', async (req, res) => {
  try {
    const records = req.body;

    const statuses = {2: "Just Applied", 1: "Action Needed", 0: "Rejected"}

    if (!Array.isArray(records)) {
      return res.status(400).json({ error: 'Expected an array of records.' });
    }

    // Process each record
    for (const record of records) {
      const company_exists = await client.query(
        "SELECT company FROM application WHERE company = $1", 
        [record[3]]
      )
      if (company_exists.rows.length > 0) {
        const updateQuery = `
          UPDATE application
          SET status = $1, gid = $2
          WHERE company = $3`;
        const values = [statuses[record[0]], record[1], record[3]];
        await client.query(updateQuery, values);
      }
      else {
        const insertQuery = `
        INSERT INTO application (status, gid, company)
        VALUES ($1, $2, $3)
        RETURNING *`;

        const values = [statuses[record[0]], record[1], record[3]]; 
        await client.query(insertQuery, values);
      }
    }

    return res.status(200).json({ message: 'Data processed successfully.' });

  } catch (err) {
    console.error('Error processing data:', err);
    return res.status(500).json({ error: 'Internal server error.' });
  }
});


app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
