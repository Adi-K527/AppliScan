const express = require('express');
const pg = require('pg');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());



const client = new pg.Client({
  connectionString: 'postgresql://postgres.tybdfyuymvpnxnmobbht:Appliscan123@aws-0-us-east-1.pooler.supabase.com:5432/postgres'
})
client.connect()
.then(() => console.log('Connected to the database'))
.catch((err) => console.error('Database connection error', err.stack));
//end point
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

// get req
app.get('/users', async (req, res) => {
  try {
    const result = await client.query('SELECT * FROM users ORDER BY id ASC');
    return res.status(200).json({ users: result.rows });
  } catch (err) {
    console.error('Error retrieving users:', err);
    return res.status(500).json({ error: 'Database error.' });
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
