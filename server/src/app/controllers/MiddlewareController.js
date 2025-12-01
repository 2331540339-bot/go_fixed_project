const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
dotenv.config();
const services= require('../models/Service');

const middlewareController = {
    //verify token
    verifyToken: (req, res, next) =>{
        const token = req.headers.token;
        if(token){
            const accessToken = token.split(" ")[1];
            jwt.verify(accessToken, process.env.JW_ACCESS_KEY,(err, user)=>{
                if(err){
                    res.status(403).json({err:"Token is not valid"});
                }
                req.user = user;
                next();
            });
        }
        else{
            res.status(401).json({err: "You are not authenticated"});
        }
    },

    //verify admin token
    verifyTokenAndAdmin:(req, res, next) => {
        middlewareController.verifyToken(req, res, () => {
            if(req.user.id == req.params.id || req.user.role == "admin"){
                console.log("CODE HERE");
                next();
            }else{
                res.status(401).json({err: "You are not allowed to do"});
            }
        })
    },

    //verify services exist
    verifyService: (req, res, next) => {
        middlewareController.verifyToken(req, res, () => {
            const {id} = req.params;
            console.log("id service:",id);
            services.findById(id)
            .then(service => {
                if(service){
                    next();
                }
            })
            .catch(err => res.status(401).json({err: "Not found service",error: err.message}))
        })
    },

   verifyPayment: (req, res, next) => {
        const { amount, orderId } = req.body; 
            // VNPay return uses query params on GET, while create/confirm calls may use JSON body.
            // const payload = req.method === 'GET' ? req.query : req.body || {};
            // const { amount, orderId } = payload;

            if (!amount || !orderId) {
                return res.status(400).json({ 
                    err: "Thiếu dữ liệu cần thiết", 
                    message: "Vui lòng cung cấp 'amount' và 'orderId'." 
                });
            }
            const numericAmount = Number(amount);
            if (isNaN(numericAmount) || numericAmount <= 0) {
                return res.status(400).json({ 
                    err: "Dữ liệu không hợp lệ", 
                    message: "'amount' phải là số dương hợp lệ." 
                });
            }

            if (typeof orderId !== 'string' || orderId.trim().length === 0) {
                 return res.status(400).json({ 
                    err: "Dữ liệu không hợp lệ", 
                    message: "'orderId' không được để trống." 
                });
            }
            
            next();
    }

}
module.exports = middlewareController;



