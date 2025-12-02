import { useState } from "react"
import { rescueRequestAPI } from "../app/api"
import AcceptedMap from "./AcceptedMap";
import { useEffect } from "react";
import { socket } from '../app/socket';
import { useNavigate } from "react-router-dom";
function AcceptedRescue({requestID}){
    const[request, setRequest] = useState(null);
    const [mechanicPosition, setMechanicPosition] = useState([0,0])
    const naviagate = useNavigate();
    const loadAPI = () => {
      rescueRequestAPI(requestID)
      .then((res) => setRequest(res))
      .catch((err) => console.log(err));
    };
    const listenMechanicLocation = () => {
      socket.on('mechanic_location', (data) => {
        if(data){
          console.log("Vị trí thợ từ websocket:", data)
          setMechanicPosition(data.mechanicLocation)
        }
      });


      socket.on('finish_rescue', (data) => {
        if(data.message == "Đã hoàn thành yêu cầu cứu hộ"){
          naviagate('/')
        }
      });
    }
    useEffect(() => {
      loadAPI();
      listenMechanicLocation();
    },[])

    return(
      <>
        {request?
          <section className="flex flex-col w-full min-h-screen bg-n-800 text-n-50 font-grostek md:flex-row">

            <div className="relative flex-1 h-[60vh] md:h-screen bg-n-700 rounded-b-3xl md:rounded-none md:rounded-l-3xl overflow-hidden">
              <div className="absolute inset-0 flex items-center justify-center text-xl text-n-200">
                <AcceptedMap userPosition = {request.location.coordinates.slice().reverse()} mechanicPosition={mechanicPosition}/>
              </div>
            </div>

            <div className="flex flex-col justify-between md:w-[35%] w-full bg-n-700 px-8 py-6 rounded-t-3xl md:rounded-none md:rounded-r-3xl">
              {/* Header */}
              <div className="mb-6">
                <h1 className="text-4xl font-extrabold tracking-wider text-p-500">
                  Yêu cầu cứu hộ đã được chấp nhận
                </h1>
                <p className="text-lg text-n-200">Thợ đang trên đường đến vị trí của bạn</p>
              </div>

              {/* Mechanic info */}
              <div className="p-5 mb-6 bg-n-800 rounded-2xl">
                <h2 className="mb-4 text-2xl font-bold text-p-500">Thông tin thợ</h2>
                <div className="flex items-center gap-4">
                  <img
                    src={request.mechanic_avatar}
                    alt="Mechanic"
                    className="object-cover w-20 h-20 border-2 rounded-full border-p-500"
                  />
                  <div>
                    <h3 className="text-xl font-bold">{request.mechanic_name}</h3>
                    <p className="text-sm text-n-200">{request.mechanic_phone}</p>
                  </div>
                </div>
              </div>

              {/* Vehicle info */}
              <div className="p-5 mb-6 bg-n-800 rounded-2xl">
                <h2 className="mb-4 text-2xl font-bold text-p-500">Tình trạng xe</h2>
                <div className="flex items-center gap-4">
                  <img
                    src={request.images[0]}
                    alt="Vehicle"
                    className="object-cover w-20 h-20 border rounded-xl border-n-600"
                  />
                  <div>
                    <p className="text-lg font-medium">Mã yêu cầu cứu hộ: {request._id}</p>
                    <p className="text-sm text-n-200">Mô tả: {request.description}</p>
                    <p className="mt-1 text-sm font-bold text-p-500">Trạng thái: {request.status}</p>
                  </div>
                </div>
              </div>

              {/* Action button */}
              <div className="flex justify-end">
                <button className="px-6 py-3 font-extrabold transition bg-p-500 rounded-2xl text-n-50 hover:bg-p-300">
                  Theo dõi lộ trình →
                </button>
              </div>
            </div>
          </section>
          :
          ''
        }  
      </>
    )
}; export default AcceptedRescue