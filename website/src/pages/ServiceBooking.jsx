import { redirect, useLocation, useNavigate  } from "react-router-dom"
import { useState, useCallback } from "react";
import {rescue_requestAPI} from '../app/api'
import {jwtDecode} from "jwt-decode";
import {socket} from "../app/socket.js";
import UploadImage from '../components/UploadImage'
import UserMap from "../components/UserMap";
import FindingMechanic from "../components/FindingMechanic";

function ServiceBooking(){
    const [description, setDescription] = useState("");
    const [position, setPosition] = useState(null);
    const [finding, setFinding] = useState(false);
    const storedService = localStorage.getItem("selectedService")
    const service = storedService ? JSON.parse(storedService) : null ;
    const token = localStorage.getItem("token");
    const decoded = jwtDecode(token);
    const userID = decoded.id
    console.log(userID);

    if (!service) return <p>Không tìm thấy dịch vụ.</p>;

    const handlePosition = useCallback((pos) => {
        setPosition(pos);
        console.log(pos)
        console.log("Nhận position từ UserMap:", pos);
    },[]) 
    const rescueRequest = () => {
        const location = {
            type: "Point",
            coordinates: [position[1], position[0]], // [lng, lat]
        };
        
        rescue_requestAPI(description, location, 50000, service._id)
        .then((res) => {
            if(res.message == 'Đang tìm thợ'){
                socket.emit("subscribe_user", userID);
                setFinding(true);
            }
            else{console.log(res.message)};
        })
        .catch((err) => console.log(err))
    }
    return(
        <>
            <div>
                {finding?<FindingMechanic/>:
                
                    <section className="flex items-center w-full py-5 bg-black justify-evenly h-200">
                        <div className="w-[42%] h-full overflow-x-clip flex flex-col ">
                            <div className="flex w-full">
                                <h2 className="w-full text-5xl font-bold font-grostek text-n-50"> GOFIX</h2>
                                <h1 className="w-full text-5xl font-bold text-end font-grostek text-p-500">VÁ LỐP</h1>
                            </div>

                            <div className="w-full font-bold text-9xl font-grostek text-n-50"> CHECKOUT</div>

                            <div className="flex-1 px-8 py-4 bg-n-700 rounded-2xl">
                                <h1 className="w-full mb-4 text-4xl font-bold font-grostek text-n-50">CONTACT</h1>
                                <input type="text" placeholder="PhoneNo" className="w-full pl-4 mb-4 border h-15 border-n-600 text-n-50 rounded-2xl"/>

                                <h1 className="mb-4 text-4xl font-bold w- full font-grostek text-n-50">ADDRESS</h1>
                                <input type="email" placeholder="Full Name" className="w-full pl-4 mb-4 border h-15 border-n-600 text-n-50 rounded-2xl"/>
                                <div className="grid w-full grid-cols-3 mb-4 justify-items-center ">
                                    <select name='city' className="pl-4 w-[80%] border h-15 border-n-600 text-n-50 rounded-2xl justify-self-start">
                                        <option value="volvo" className="text-n-800">City</option>
                                        <option value="saab"  className="text-n-800">Saab</option>
                                        <option value="mercedes"  className="text-n-800">Mercedes</option>
                                        <option value="audi"  className="text-n-800">Audi</option>
                                    </select>

                                    <select name='district' className="pl-4 w-[80%] border h-15 border-n-600 text-n-50 rounded-2xl">
                                        <option value="volvo" className="text-n-800">District</option>
                                        <option value="saab"  className="text-n-800">Saab</option>
                                        <option value="mercedes"  className="text-n-800">Mercedes</option>
                                        <option value="audi"  className="text-n-800">Audi</option>
                                    </select>

                                    <select name='ward' className="pl-4 border w-[80%] h-15 border-n-600 text-n-50 rounded-2xl justify-self-end">
                                        <option value="volvo" className="text-n-800">Ward</option>
                                        <option value="saab"  className="text-n-800">Saab</option>
                                        <option value="mercedes"  className="text-n-800">Mercedes</option>
                                        <option value="audi"  className="text-n-800">Audi</option>
                                    </select>
                                    
                                    
                                </div>
                                <input type="text" placeholder="Detail Address" className="w-full pl-4 mb-4 border h-15 border-n-600 text-n-50 rounded-2xl"/>
                                <input type="text" onChange={(e) => setDescription(e.target.value)} value={description} placeholder="Description" className="w-full pl-4 mb-4 border h-15 border-n-600 text-n-50 rounded-2xl"/>
                            </div>
                            
                        </div>

                        <div className="w-[50%] h-full ">
                            <div className="flex items-end justify-between w-full h-40 mb-8 ">
                                <p className="w-[40%] border-t-5 border-p-500 font-grostek font-light text-n-50 text-xl ">Rescue Information</p>
                                <p className="w-[40%] border-t-5 border-n-700 font-grostek font-light text-n-200 text-xl ">Finding Mechanic</p>
                            </div>

                            <div className="flex justify-between">
                                <h1 className="w-full mb-4 text-5xl font-bold font-grostek text-n-50">Upload Image</h1>
                                <h1 className="w-full mb-4 text-5xl font-bold font-grostek text-n-50">Map Location</h1>
                            </div>
                            
                            <div className="flex justify-between">
                                <UploadImage />
                                <UserMap onPositionChange={handlePosition}/>
                            </div>

                            <div className="flex justify-end w-full mt-10"> 
                                <button type="submit" onClick={() => rescueRequest()} className="px-5 py-4 text-n-50 bg-p-500 rounded-2xl"> Finding Rescue Now</button> 
                            </div>
                        </div>
                    </section>
                }
            </div>

        </>
    )
}export default ServiceBooking