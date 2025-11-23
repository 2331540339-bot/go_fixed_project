const { model } = require('mongoose');
const {onlineMechanics} = require('../../socket/socketHandler');
const Service = require('../models/Service');
const RescueRequest = require('../models/RescueRequest');
const User = require('../models/User')
class ServiceController{
    //GET - /service/get
    async showall(req, res){
        try {
            const services = await Service.find()
            res.status(200).json(services);
        } catch (error) {
            res.status(500).json({ message: 'Lỗi server' });
        }
    }
    //GET - /service/add
    async add(req, res){
        try {
            const { name, base_price, icon_url } = req.body;
            const newService = new Service({
                name,
                base_price,
                icon_url,
                kind_services: 'simple_services'
            })
            const savedService = await newService.save();

            res.status(201).json(savedService);
        } catch (error) {
            console.error(error)
            res.status(500).json({ message: 'Lỗi khi tạo service' })
        }
    }
    //GET - /service/delete
    async delete(req, res){
        try {
            const { id } = req.params;
            const result = await Service.findByIdAndDelete(id)
            if (!result) {
                return res.status(404).json({ message: 'Không tìm thấy service' });
            }
            res.json({ message: 'Đã xóa thành công', result });
        } catch (error) {
            res.status(500).json({ message: 'Lỗi server' });
        }
    }


    //[POST] - /service/rescue/:id
    rescue(req, res){
        const io = req.app.get('io');
        const rescueRequest = new RescueRequest({
            user_id: req.user.id,
            service_id: req.params.id,
            description: req.body.description,
            location: req.body.location,
            price_estimate: req.body.price_estimate,
        });
        const mechanicIds = Object.keys(onlineMechanics);
        if (mechanicIds.length === 0 ){
            return res.status(200).json({message:'Không có thợ nào đang hoạt động'});
        };
        rescueRequest.save()
        .then( async() => {
            const location = rescueRequest.location;
            const sortedMechanics =  await sortMechanicByDistance(location);
            console.log("4", sortedMechanics);
            res.status(200).json({message: 'Đang tìm thợ'});
            assignMechanic(io, rescueRequest, sortedMechanics, res)
        })
        .catch(err => res.status(500).json({err : err.message}))

        //[FUNCTION] - SORT MECHANIC DISTANCE
        async function sortMechanicByDistance(location){
            console.log("5", location);
            const mechanics = await User.aggregate([
                {
                    $geoNear:{
                        near:location,
                        distanceField: "distance",
                        spherical: true
                    }
                },
                {
                    $match:{
                        role: "mechanic_user",
                        status: "online"
                    }
                }
            ])
            console.log("5", mechanics);
            return mechanics
        }


        //[FUNCTION] - ASSIGN TO MECHANIC SERIALY
        async function assignMechanic(io, rescueRequest, sortedMechanics){
            let assigned = false;
            console.log("6sortedMechanics", sortedMechanics);
            for (let item in sortedMechanics){
                if(assigned) break;
                const mechanic = sortedMechanics[item];
                console.log("6mechanic_id", mechanic._id);
                const mechanicSocketID = onlineMechanics[mechanic._id];
                console.log("6", mechanicSocketID);
                if(!mechanicSocketID) continue;

                io.to(mechanicSocketID).emit("incoming_rescue_request", rescueRequest);
                assigned = await new Promise(async(resolve) => {
                    const delay = (ms) => new Promise((res) => setTimeout(res, ms));
                    console.log("Chờ thợ nhận đơn 30s")
                    await delay(30000);
                    const rescueCheck = await RescueRequest.findById(rescueRequest._id);
                    if(rescueCheck.status == "accepted"){
                        console.log("Thợ đã nhận đơn, kết thúc tìm kiếm")
                        resolve(true);
                    }
                    resolve(false);
                });
            }
            if(!assigned){
                io.to(rescueRequest.user_id).emit("accepted-status-rescue", {message: 'Hiện tại không có thợ nào chấp nhận yêu cầu. Vui lòng thử lại sau ít phút...'})
                await RescueRequest.updateOne(
                    {
                        _id: rescueRequest._id,
                        status: 'pending'
                    },
                    {
                        $set:{status: 'not-accepted"'}
                    }
                )
            }
        }
    }


}

module.exports = new ServiceController()