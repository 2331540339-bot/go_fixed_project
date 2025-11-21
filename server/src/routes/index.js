const accountRouter = require('./account')
const serviceRouter = require('./service')
const bannerRouter = require('./banner.route')
const commerceRouter = require('./commerce')
const cartRouter = require('./cart')
const orderRouter = require('./order')
function route(app){
    app.use('/account', accountRouter)
    app.use('/service', serviceRouter)
    app.use('/banners', bannerRouter)
    app.use('/commerce', commerceRouter)
    app.use('/cart', cartRouter)
    app.use('/order', orderRouter)
}

module.exports = route  