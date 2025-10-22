const express = require('express')
const app = express()
const port = 8000
const cors = require('cors');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');
const dotenv = require('dotenv');

//env config
dotenv.config();
//Parse Json
app.use(express.json()); 

//Cookie-Paser
app.use(cookieParser());

//Create Cors
const corsOptions = {
  origin: true, //Active All Domain Can Access
  credentials: true,
  methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
  allowedHeaders: ['Content-Type','Authorization'],
};
app.use(cors(corsOptions));
app.options(/.*/, cors(corsOptions));  

//Tracking
app.use(morgan('dev'));

//connect to db
const db = require('./config/db');
db.connect();

//Route Init
const route = require('./routes');
route(app);

app.get('/', (req, res) => (res.send("Server Okay Not Like You")));

app.listen(port, () => console.log(`App Listening At http://localhost:${port}`));