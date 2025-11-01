const accountRouter = require('./account')
const serviceRouter = require('./service')
const bannerRouter = require('./banner.route')

function route(app){
    app.use('/account', accountRouter)
    app.use('/service', serviceRouter)
    app.use('/banners', bannerRouter)
}

module.exports = route