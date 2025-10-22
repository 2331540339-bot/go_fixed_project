const express = require('express')
const router = express.Router();
const accountController = require('../app/controllers/AccountController')
const middlewareController = require('../app/controllers/MiddlewareController')
router.get('/showall', middlewareController.verifyToken,  accountController.showall)
router.post('/login', accountController.login)
router.post('/create', accountController.create)
router.delete('/delete/:id', accountController.delete)

module.exports = router;