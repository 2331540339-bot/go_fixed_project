import { useEffect, useState } from "react";
import { serviceAPI } from "../app/api";

export default function RescueIncomingRequest({ request, onAccept, onReject }) {
  if (!request) {
    return (
      <div className="p-6 text-center text-n-600 font-grostek">
        Không có yêu cầu cứu hộ nào.
      </div>
    );
  }

  const [services, setServices] = useState([]);

  const loadAPI = () => {
    serviceAPI()
    .then((res) => setServices(res))
    .catch((err) => console.log(err));
  };

  const getInformation = () => {
    if(services.length != 0){
      const service = services.find((service) => service._id === request.service_id);
      console.log("Lấy ra service", request.service_id);
      request['service_name'] = service.name;
    }
    
  }
  useEffect(() => {
    loadAPI(),
    getInformation()
  },[])
  return (
    <div className="w-full max-w-2xl p-6 mx-auto bg-white border shadow-xl rounded-3xl border-n-100 font-grostek">
      
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-2xl font-bold text-n-800">
          🚨 Yêu cầu cứu hộ mới
        </h2>
        <span className="px-3 py-1 text-sm font-semibold text-white rounded-lg bg-p-500">
          {request.status.toUpperCase()}
        </span>
      </div>

      {/* Body */}
      <div className="space-y-4">

        {/* Service ID */}
        <div>
          <p className="text-sm text-n-500">Dịch vụ</p>
          <p className="font-semibold text-n-800">{request.service_name}</p>
        </div>

        {/* Description */}
        <div>
          <p className="text-sm text-n-500">Mô tả</p>
          <p className="font-semibold text-n-800">{request.description}</p>
        </div>

        {/* Price */}
        <div>
          <p className="text-sm text-n-500">Giá dự kiến</p>
          <p className="text-xl font-bold text-p-600">
            {request.price_estimate.toLocaleString("vi-VN")}₫
          </p>
        </div>

        {/* Location */}
        <div>
          <p className="text-sm text-n-500">Vị trí khách hàng</p>
          <p className="font-semibold text-n-800">
            Lat: {request.location?.coordinates?.[1]} <br />
            Lng: {request.location?.coordinates?.[0]}
          </p>
        </div>

        {/* Time */}
        <div>
          <p className="text-sm text-n-500">Thời gian yêu cầu</p>
          <p className="font-semibold text-n-800">
            {new Date(request.createdAt).toLocaleString("vi-VN")}
          </p>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex justify-between gap-4 mt-6">
        <button
          onClick={() => onReject && onReject(request._id)}
          className="flex-1 py-3 font-semibold transition border text-n-700 border-n-300 rounded-xl hover:bg-n-100"
        >
          Từ chối
        </button>

        <button
          onClick={() => onAccept && onAccept(request._id)}
          className="flex-1 py-3 font-semibold text-white transition bg-p-500 rounded-xl hover:bg-p-600"
        >
          Chấp nhận cứu hộ
        </button>
      </div>
    </div>
  );
}
