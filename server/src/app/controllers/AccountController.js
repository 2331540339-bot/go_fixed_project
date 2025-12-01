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

    //[GET] - /account/detail/:id
    async detail(req, res){
        try {
            const user = await User.findById(req.params.id).select("-password_hash");
            if(!user){
                return res.status(404).json({error: 'User not found'});
            }
            return res.status(200).json(user);
        } catch (err) {
            return res.status(500).json({ error: err.message });
        }
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

    //[GET] - /account/search?q=
    async search(req, res){
        try {
            const { q } = req.query;
            if(!q || q.trim() === ""){
                return res.status(400).json({error: 'Thiếu từ khoá tìm kiếm'});
            }
            const keyword = q.trim();
            const regex = new RegExp(keyword, 'i');
            const users = await User.find({
                $or: [
                    { fullname: regex },
                    { email: regex },
                    { phone: regex }
                ]
            }).select("-password_hash");
            return res.status(200).json(users);
        } catch (err) {
            return res.status(500).json({error: err.message});
        }
    }

    //[PATCH] - /account/update/:id
    async update(req, res){
        try {
            const { fullname, email, phone, password_hash, avatar_url, role, status, services_available, location } = req.body;
            const updateData = {};
            if(fullname !== undefined) updateData.fullname = fullname;
            if(email !== undefined) updateData.email = email;
            if(phone !== undefined) updateData.phone = phone;
            if(avatar_url !== undefined) updateData.avatar_url = avatar_url;
            if(role !== undefined) updateData.role = role;
            if(status !== undefined) updateData.status = status;
            if(services_available !== undefined) updateData.services_available = services_available;
            if(location !== undefined) updateData.location = location;

            if(password_hash){
                const salt = await bcrypt.genSalt(10);
                updateData.password_hash = await bcrypt.hash(password_hash, salt);
            }

            const updatedUser = await User.findByIdAndUpdate(
                req.params.id,
                {$set: updateData},
                {new: true, runValidators: true, select: "-password_hash"}
            );

            if(!updatedUser){
                return res.status(404).json({error: 'User not found'});
            }

            return res.status(200).json({message: 'Updated successfully', user: updatedUser});
        } catch (err) {
            return res.status(500).json({ error: err.message });
        }
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
