import { useEffect, useState } from "react";
import { socket } from "../app/socket";
import Radar from "./Radar";
import Not_AcceptedRescue from "./Not_AcceptedRescue";
import AcceptedRescue from "./AcceptedRescue";
function FindingMechanic(){
    const [status, setStatus] = useState("");
    useEffect(() => {

        socket.on("accepted-status-rescue", (data) => {
            console.log(data.message);
            if(data.message === 'Thợ đã chấp nhận yêu cầu của bạn'){
                setStatus("accepted");
            }
            if(data.message === 'Hiện tại không có thợ nào chấp nhận yêu cầu. Vui lòng thử lại sau ít phút...'){
                setStatus("not-accepted");
            }
            
        });
        return () => {
            socket.off("accepted-status-rescue");
        }
    }, [])
    return(
            <div>
                {status === 'accepted' ?<AcceptedRescue/>: (status === 'not-accepted'? <Not_AcceptedRescue/> : <Radar/>)}
            </div>
    )
}; export default FindingMechanic