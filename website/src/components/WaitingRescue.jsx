import RescueIncomingRequest from "./RescueIncomingRequest";
import RescuingRequest from "./RescuingRequest";
import {useEffect } from "react"
import { socket } from '../app/socket';
import { useState } from "react";
import { jwtDecode } from "jwt-decode";
import {useNavigate} from 'react-router-dom';
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import L from "leaflet";


const defaultIcon = L.icon({
  iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});
L.Marker.prototype.options.icon = defaultIcon;




function WaitingRescue(){
    const [resquestIncoming, setRequestIncoming] = useState(false);
    const [resquestInfo, setResquestInfo] = useState(false);
    const [acceptStatus, setAcceptStatus] = useState(false);
    const [position, setPosition] = useState([0,0]);
    const naviagate = useNavigate()
    const listenRescue = () => {
        socket.on('incoming_rescue_request', (data) => {
            if(data){
                setRequestIncoming(true);
                setResquestInfo(data);
                console.log(data)
            }
        })
    }

    const acceptRescue = (request_id) => {
        const token = localStorage.getItem('token');
        const user_id = jwtDecode(token).id;
        socket.emit('accept_rescue_request', {requestId: request_id, mechanicId: user_id});
        setRequestIncoming(false);
        setAcceptStatus(true);
    }

    useEffect(() => {
        listenRescue()
        if(!resquestIncoming && !acceptStatus){
            const beam = document.getElementById("loading-beam");
            let angle = 0;
                
            const rotate = () => {
                angle += 2;
                beam.style.transform = `rotate(${angle}deg)`;
                requestAnimationFrame(rotate);
            }

            rotate(); 
        }
        
    }, [resquestIncoming])

    useEffect(() => {
        if (!navigator.geolocation) {
            alert("Trình duyệt của bạn không hỗ trợ định vị GPS!");
            return;
        }

        const watchId = navigator.geolocation.watchPosition(
        (pos) => {
            const { latitude, longitude } = pos.coords;
            const coords = [latitude, longitude];

            setPosition(coords);
        },
        (err) => {
            console.error("Không thể lấy vị trí:", err);
        },
        { enableHighAccuracy: true, maximumAge: 0, timeout: 15000 }
        );

        return () => navigator.geolocation.clearWatch(watchId);

    }, []);
    
    return(
        <>

            {resquestIncoming
                ?
                <RescueIncomingRequest request = {resquestInfo} onAccept = {acceptRescue} onReject = {() => setRequestIncoming(false)}/>
                :
                acceptStatus
                    ?
                    <RescuingRequest request = {resquestInfo}/>
                    :
                    <div className="h-[calc(100vh-120px)] max-h-[1100px] w-100vh md:mx-10  flex md:items-center flex-col md: justify-around">
                        <h1 className="w-full text-5xl font-semibold text-center font-grostek">Chào Mừng Bạn Đã Trở Lại</h1>
                        <div className="w-full overflow-hidden shadow-lg h-70 rounded-xl">
                              {position[0] != 0 && position[1]!= 0 ?
                                <MapContainer
                                center={position}
                                zoom={16}
                                scrollWheelZoom={true}
                                className="w-full h-full"
                              >
                                <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                        
                                <Marker position={position}>
                                  <Popup>Bạn đang ở đây</Popup>
                                </Marker>
                              </MapContainer>
                                :
                                <p>Đang load map</p>
                            }
                        </div>
                        <div className="flex items-center justify-around w-full">
                            <div className="flex flex-col items-center justify-center gap-2">
                                <button
                                    className="flex items-center justify-center px-8 py-4 font-extrabold tracking-wider border rounded-md border-p-500 w-100 text-n-700 font-grostek hover: hover:text-n-50 hover:bg-p-500 "
                                >Tắt trạng thái hoạt động<span>&rarr;</span> 
                                </button>   
                                <p className="font-light font-grostek">*Lưu ý: Hãy tắt hoạt động ngay khi không còn có thể</p>
                            </div>

                            <div className="flex items-center gap-2">
                                <div className="relative flex items-center justify-center w-20 h-20 overflow-hidden border-4 rounded-full border-p-500">
                                    <div id="loading-beam" className="absolute w-full h-full " style={{background: "conic-gradient(from 0deg, rgba(255, 0, 0, 0.4), rgba(255,0,0,0) 40%)",}}>
                                    </div>
                                </div>
                                <p className="font-light font-grostek">Đang tìm khách hàng gần nhất...</p>
                            </div>
                        </div>
                    </div>


                                
            }

            
        </>
        
    )
}export default WaitingRescue