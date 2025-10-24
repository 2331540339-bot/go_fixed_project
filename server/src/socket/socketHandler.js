function socketInit(io){
    //Function handler
    io.on('connection', (socket) =>{
;
        socket.on('subcribe_mechanic', (mechanicID) => {
            socket.join('Mechanics');
            socket.emit('result_subcribe', {
                message: 'You are online now',
            })
        });
    })

};
module.exports = socketInit;