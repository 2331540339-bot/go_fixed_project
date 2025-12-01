import { useState, useCallback } from "react";
import { rescue_requestAPI } from '../app/api'
import { jwtDecode } from "jwt-decode";
import { socket } from "../app/socket.js";
import UploadImage from '../components/UploadImage'
import UserMap from "../components/UserMap";
import FindingMechanic from "../components/FindingMechanic";

function ServiceBooking() {

    const [description, setDescription] = useState("");
    const [phone, setPhone] = useState("");
    const [detailAddress, setDetailAddress] = useState("");
    const [images, setImages] = useState([]);
    const [position, setPosition] = useState(null);
    const [finding, setFinding] = useState(false);
    const [errors, setErrors] = useState({});
    const images1 = ["https://example.com/image1.jpg", "https://example.com/image2.jpg"];
    const storedService = localStorage.getItem("selectedService")
    const service = storedService ? JSON.parse(storedService) : null;

    const token = localStorage.getItem("token");
    const decoded = jwtDecode(token);
    const userID = decoded.id;

    const handlePosition = useCallback((pos) => {
        setPosition(pos);
        console.log("Nhận position từ UserMap:", pos);
    }, []);

    // nhận danh sách ảnh từ UploadImage
    const handleImages = (urls) => {
        setImages(urls);
        // Xóa lỗi ảnh nếu có
        if (errors.images) {
            setErrors({...errors, images: null});
        }
    };

    const rescueRequest = () => {

        if (!position) {
            return alert("Vui lòng chọn vị trí trên bản đồ!");
        }
        if (!phone.trim()) {
            return alert("Vui lòng nhập số điện thoại!");
        }
        if (!detailAddress.trim()) {
            return alert("Vui lòng nhập địa chỉ chi tiết!");
        }

        const location = {
            type: "Point",
            coordinates: [position[1], position[0]]  // [lng, lat]
        };

        rescue_requestAPI(
            description,
            images1,
            phone,
            detailAddress,
            location,
            50000,
            service._id)
            .then((res) => {
                if (res.message === 'Đang tìm thợ') {
                    socket.emit("subscribe_user", userID);
                    setFinding(true);
                }
            })
            .catch((err) => console.log(err));
    };

    if (!service) return <p>Không tìm thấy dịch vụ.</p>;

    return (
        <>
            <div>
                {finding ? (
                    <FindingMechanic />
                ) : (
                    <section className="flex items-center w-full py-5 bg-black justify-evenly h-200">
                        {/* LEFT SIDE */}
                        <div className="w-[42%] h-full overflow-x-clip flex flex-col ">

                            <div className="flex w-full">
                                <h2 className="w-full text-5xl font-bold font-grostek text-n-50">GOFIX</h2>
                                <h1 className="w-full text-5xl font-bold text-end font-grostek text-p-500">
                                    {service.name?.toUpperCase()}
                                </h1>
                            </div>

                            <div className="w-full font-bold text-9xl font-grostek text-n-50">CHECKOUT</div>

                            {/* CONTACT FORM */}
                            <div className="flex-1 px-8 py-4 bg-n-700 rounded-2xl">
                                <h1 className="w-full mb-4 text-4xl font-bold font-grostek text-n-50">
                                    CONTACT
                                </h1>

                                {/* PHONE NUMBER */}
                                <input
                                    type="text"
                                    placeholder="Phone Number"
                                    value={phone}
                                    onChange={(e) => setPhone(e.target.value)}
                                    className="w-full pl-4 mb-4 border h-15 border-n-600 text-n-50 rounded-2xl"
                                />

                                <h1 className="mb-4 text-4xl font-bold font-grostek text-n-50">
                                    ADDRESS
                                </h1>

                                {/* DETAIL ADDRESS */}
                                <input
                                    type="text"
                                    placeholder="Detail Address"
                                    value={detailAddress}
                                    onChange={(e) => setDetailAddress(e.target.value)}
                                    className="w-full pl-4 mb-4 border h-15 border-n-600 text-n-50 rounded-2xl"
                                />

                                {/* DESCRIPTION */}
                                <input
                                    type="text"
                                    placeholder="Description"
                                    value={description}
                                    onChange={(e) => setDescription(e.target.value)}
                                    className="w-full pl-4 mb-4 border h-15 border-n-600 text-n-50 rounded-2xl"
                                />
                            </div>
                        </div>

                        {/* RIGHT SIDE */}
                        <div className="w-[50%] h-full">
                            <div className="flex items-end justify-between w-full h-40 mb-8">
                                <p className="w-[40%] border-t-5 border-p-500 font-grostek font-light text-n-50 text-xl">
                                    Rescue Information
                                </p>
                                <p className="w-[40%] border-t-5 border-n-700 font-grostek font-light text-n-200 text-xl">
                                    Finding Mechanic
                                </p>
                            </div>

                            <div className="flex justify-between">
                                <h1 className="w-full mb-4 text-5xl font-bold font-grostek text-n-50">
                                    Upload Image
                                </h1>
                                <h1 className="w-full mb-4 text-5xl font-bold font-grostek text-n-50">
                                    Map Location
                                </h1>
                            </div>

                            {/* IMAGE UPLOAD + MAP */}
                            <div className="flex justify-between">
                                <UploadImage onChange={handleImages} />
                                <UserMap onPositionChange={handlePosition} />
                            </div>

                            <div className="flex justify-end w-full mt-10">
                                <button
                                    type="submit"
                                    onClick={rescueRequest}
                                    className="px-5 py-4 text-n-50 bg-p-500 rounded-2xl"
                                >
                                    Finding Rescue Now
                                </button>
                            </div>
                        </div>
                    </section>
                )}
            </div>
        </>
    );
}

export default ServiceBooking;
