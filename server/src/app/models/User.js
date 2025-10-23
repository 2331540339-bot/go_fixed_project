const { default: mongoose } = require('mongoose')
const Schema = mongoose.Schema
const ObjectID = Schema.ObjectId

const User = new Schema({
    fullname:{
        type: String,
        required: true
    },
    email:{
        type: String,
        required: true,
        unique: true,
        lowercase: true
    },
    phone: {
        type: String,
        required: true,
        unique: true
    },
    password_hash:{
        type: String,
        required: true
    },
    avatar_url:{
        type: String,
        default: 'https://marketplace.canva.com/Dz63E/MAF4KJDz63E/1/tl/canva-user-icon-MAF4KJDz63E.png'
    },
    role:{
        type: String,
        enum: ['admin', 'end_user', 'mechanic_user'],
        required: true,
        default: 'end_user'
    },
    // Using for Mechanic Role
    status:{
        type: String,
        enum:['online', 'offline'],
        default: 'offline'
    },
    location:{
        text: {
            type: String,
            require: true
        },
        coordinates:{
            type: [Number],
            default:[0,0]
        }
    },
    services_available:{
        type: [String],
        default: []
    },
    average_rating:{
        type: Number,
        default: 0
    },
    total_jobs:{
        type: Number,
        default: 0
    }
},{
    timestamps: true
})

User.index({location:'2dsphere'})
module.exports = mongoose.model('User', User)