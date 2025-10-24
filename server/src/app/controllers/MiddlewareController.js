const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const { response } = require('express');
dotenv.config();
const services= require('../models/Service');
const Service = require('../models/Service');

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
    }

}
module.exports = middlewareController;




