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
        // console.log(id)
        // console.log(title)
        let document = await Document.findByIdAndUpdate( id , { title });
        // console.log(document);
        res.json(document);
    } catch (e) {
        console.log(e.message);
        res.status(500).json({error : e.message});
    }
});

documentRouter.get('/docs/:id', auth , async (req, res)=>{
    try {

        // console.log("hello");
        // console.log(req.params.id);
        const document = await Document.findById(req.params.id);
        // console.log(document);
        
        res.json(document);
    } catch (e) {
        console.log(e.message);
        res.status(500).json({error : e.message});
    }
});

module.exports = documentRouter;