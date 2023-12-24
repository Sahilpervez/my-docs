const express = require('express');
const Document = require('../models/document');
const documentRouter = express.Router();
const auth = require('../middlewares/auth');


documentRouter.post('/doc/create',auth,async (req, res) => {
    try {
        const { createdAt } = req.body ;
        let document = new Document({
            uid : req.user,
            title: 'New Untitled Document',
            createdAt,
        });

        document = await document.save();
        res.json(document);
    } catch (e) {
        res.status(500).json({error : e.message});
    }
});

documentRouter.get('/docs/me',auth,async (req,res)=>{
    try {
        let documents = await Document.find({uid : req.user});
        // console.log(documents);
        res.json(documents);
    } catch (e) {
        res.status(500).json({error: e.message});
    }
});

documentRouter.post('/docs/title',auth,async (req,res) => {
    try {
        const { id , title } = req.body;
        const document = await Document.findByIdAndUpdate(id , { title });

        res.json(document);
    } catch (e) {
        res.status(500).json({error : e.message});
    }
});

module.exports = documentRouter;