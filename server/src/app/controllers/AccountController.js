const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class AccountController{
    //[GET] - /account/showall 
    showall(req, res){
        User.find({})
            .then(users => res.json(users))
            .catch(err => res.status(500).json({ error: err.message }))
    }

    //[POST] - /account/login 
    login(req, res){
        User.findOne({email: req.body.email})
            .then(async users => {
                if(!users){
                    return res.status(400).json({error: 'Invalid User'})
                }
                const validpassword = await bcrypt.compare(req.body.password_hash, users.password_hash);
                if(!validpassword){
                    return res.status(400).json({error:'Invalid Password'})
                }
                
                const accessToken = jwt.sign({
                        id: users.id,
                        role: users.role
                    },
                        process.env.JW_ACCESS_KEY,
                        {expiresIn: "2h"}
                );

                const {password_hash, ...others} = users._doc;
                res.status(200).json({...others, accessToken});
                
                
            })
            .catch(err => res.status(500).json({ error: err.message }))
    }

    //[POST] - /account/create 
    async create(req, res){
        const salt = await bcrypt.genSalt(10);
        const hashed = await bcrypt.hash(req.body.password_hash, salt);
        const user = await new User({
            fullname: req.body.fullname,
            email: req.body.email,
            phone: req.body.phone,
            password_hash: hashed,
        });
        await user.save()
        .then(() => res.json('Account Created'))
        .catch(err => res.status(500).json({error: err.message}))
    }

    //[DELETE] - /account/delete
    delete(req, res) {
        User.findByIdAndDelete(req.params.id)
        .then((result) => {
            if(result){
            res.status(200).json({status: "Deleted successfully"});
            }else{
                res.status(400).json({status:"Not found user"});
            }
        })
        .catch(err => res.status(500).json({error: err.message}))
    }
}

module.exports = new AccountController()