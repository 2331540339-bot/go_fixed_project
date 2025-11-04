const accountRouter = require('./account')
const serviceRouter = require('./service')

function route(app){
    app.use('/account', accountRouter)
    app.use('/service', serviceRouter)
}

module.exports = route  