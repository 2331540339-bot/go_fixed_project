const RescueRequest = require('../models/RescueRequest');
const User = require('../models/User');
class RequestRescueController{
    getRescuing(req, res){
        const {requestID} = req.body;
        RescueRequest.findById(requestID)
        .then(async(request) => {
            if(!request){
                return res.status(400).json({error:'Không tìm thấy đơn cứu hộ'});
            }
            const mechanic = await User.findById(request.mechanic_id);
            console.log(mechanic);
            const requestObject = request.toObject();
            requestObject['mechanic_name'] = mechanic.fullname;
            requestObject['mechanic_phone'] = mechanic.phone;
            requestObject['mechanic_avatar'] = mechanic.avatar_url;
            return res.status(200).json(requestObject);
        })
        .catch((err) => {
            return res.status(500).json(err);
        });
        
    }
}
module.exports = new RequestRescueController()
    