const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
dotenv.config();
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
    }
}
module.exports = middlewareController;



const jwt = require('jsonwebtoken');

const middlewareController1 = {
    //verify token
    verifyToken1(req,res,next){
        const token = req.headers.token;
        if(token){
            const accessToken = token.split(" ")[1];
            if(accessToken){
                const verify = jwt.verify(accessToken, process.env.JW_ACCESS_KEY, (err, user) =>{
                    if(err){
                        res.status(403).json({err: "Invalid token"});
                    }
                    req.user = user;
                    next();
                });
            }else{
                res.status(401).json({err:"You r not authenticated"});
            }
        }
    }
}