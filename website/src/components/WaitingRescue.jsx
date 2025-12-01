import UserMap from "./UserMap"
import Radar from "./Radar"
import RescueIncomingRequest from "./RescueIncomingRequest";
import { useEffect } from "react"
import { socket } from '../app/socket';
import { useState } from "react";


function WaitingRescue(){
    const [resquestIncoming, setRequestIncoming] = useState(false);
    const [resquestInfo, setResquestInfo] = useState(false);
    const [acceptStatus, setAcceptStatus] = useState(false)
    const listenRescue = () => {
        socket.on('incoming_rescue_request', (data) => {
            if(data){
                setRequestIncoming(true);
                setResquestInfo(data);
            }
        })
    }

    useEffect(() => {
        listenRescue()
    },[]);

    useEffect(() => {

        if(!resquestIncoming){
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
    
    return(
        <>

            {resquestIncoming
                ?
                <RescueIncomingRequest request = {resquestInfo} onAccept = {() => setRequestIncoming(false)} onReject = {() => setRequestIncoming(false)}/>
                :
                <div className="h-[calc(100vh-120px)] max-h-[1100px] w-100vh md:mx-10  flex md:items-center flex-col md: justify-around">
                    <h1 className="w-full text-5xl font-semibold text-center font-grostek">Chào Mừng Bạn Đã Trở Lại</h1>
                    <UserMap/>
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