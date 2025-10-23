const {default: mongoose} = require('mongoose');
const schema = mongoose.Schema;

const RescueRequest = new schema(
    {
        user_id:{
            type: String,
            required: true
        },
        mechanic_id:{
            type: String,
            require: true,
            default:"finding"
        },
        service_id:{
            type: String,
            require: true
        },
        description:{
            type: String
        },
        status:{
            type: String,
            require: true,
            enum:['pending', 'accepted', 'accepted', 'completed', 'cancelled'],
            default: "pending"
        },
        loctation:{
            text:{
                type: String,
                require:true
            },
            coordinates:{
                type: [Number],
                default: [0,0]
            }
        },
        price_estimate:{
            type: Number,
            require: true
        },
        payment_status:{
            type: String,
            require: true,
            defalt: 'unpaid'
        }
    },{
        timestamps:true
    }

)
module.exports = mongoose.model('RescueRequest', RescueRequest);

