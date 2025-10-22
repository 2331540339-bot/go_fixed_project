const mongoose = require('mongoose');
const dotenv = require('dotenv');
dotenv.config();

console.log(process.env.MONGODB_URL);
async function connect() {
    try {
        await mongoose.connect(process.env.MONGODB_URL, { serverSelectionTimeoutMS: 2000 })
        console.log('Connected Successfully', mongoose.connection.readyState)
    } catch (error) {
        console.log('Connection Failed:', error.message)
    }
}
module.exports = {connect}