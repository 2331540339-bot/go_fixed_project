const express = require('express')
const app = express()
const port = 8000
const http = require('http');
const cors = require('cors');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');
const dotenv = require('dotenv');
const {Server} = require('socket.io');
const socketInit = require('./socket/socketHandler');
//env config
dotenv.config();
//Parse Json
app.use(express.json()); 

//Cookie-Paser
app.use(cookieParser());

//Create server
const server = http.createServer(app);

//Create websocket server
const io = new Server(server, {
  cors:{
    origin: true,
    methods: ['GET', 'POST']
  }
});

//Init socket
app.set('io',io);
socketInit(io);

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

server.listen(port, () => console.log(`App Listening At http://localhost:${port}`));