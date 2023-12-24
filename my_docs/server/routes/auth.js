const express = require('express');
const mongoose = require('mongoose');
const jwt=require('jsonwebtoken');
const User = require('../models/user');
const auth = require('../middlewares/auth');


const authRouter = express.Router();

authRouter.post("/api/signup", async (req, res) => {
    try {
        const { name, email, profilePic } = req.body;

        let user = await User.findOne({ email: email });

        if (!user) {
            // user = new User({
            //     email: email,
            //     name: name,
            //     profilePic: profilePic
            // });

            // This code below works same as the above code.

            user= new User({
                email,
                name,
                profilePic,
            });

            user = await user.save();
        }
        // If user already exist then we don't need to do anything.
        // we just return the data to our client side.

        // Generate a token and send to the client side.

        const token = jwt.sign({id: user._id},"passwordKey");
        console.log(token);
        res.json({user , token});
        // thee above line is simillar to  res.json({user : user});
    } catch (err) {
        console.log(err);
        res.status(500).json({error : err.message});
    }
});

authRouter.get("/",auth, async (req, res) => {
    console.log(req.user);

    const user = await User.findById(req.user);

    res.json({user , token:req.token});
});


module.exports = authRouter;