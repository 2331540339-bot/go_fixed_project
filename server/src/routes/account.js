const express = require('express')
const router = express.Router();
const accountController = require('../app/controllers/AccountController')
const middlewareController = require('../app/controllers/MiddlewareController')

router.get('/showall', middlewareController.verifyTokenAndAdmin,  accountController.showall)
router.get('/detail/:id', middlewareController.verifyTokenAndAdmin, accountController.detail)
router.get('/search', middlewareController.verifyTokenAndAdmin, accountController.search)
router.post('/login', accountController.login)
router.post('/create', accountController.create)
router.patch('/update/:id', middlewareController.verifyTokenAndAdmin, accountController.update)
router.delete('/delete/:id', middlewareController.verifyTokenAndAdmin , accountController.delete)

module.exports = router;
