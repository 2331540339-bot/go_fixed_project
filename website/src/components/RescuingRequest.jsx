import { MapContainer, TileLayer, Marker, Popup, Polyline } from "react-leaflet";
import L from "leaflet";
import { useState, useEffect } from "react";
import { socket } from '../app/socket';
import { useNavigate } from "react-router-dom";

const userIcon = new L.Icon({
  iconUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

const mechanicIcon = new L.Icon({
  iconUrl:
    "https://static.vecteezy.com/system/resources/thumbnails/060/281/745/small_2x/fire-truck-3d-icon-red-fire-truck-3d-icon-png.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

export default function RescuingRequest({request}) {
  const naviagate  = useNavigate()
  const [mechanicPosition, setMechanicPosition] = useState([0,0]);
  const [routeCoords , setRouteCoords] = useState([]);
    useEffect(() => {
      if (!navigator.geolocation) {
        alert("Trình duyệt của bạn không hỗ trợ định vị GPS!");
        return;
      }
  
      const watchId = navigator.geolocation.watchPosition(
        (pos) => {
          const { latitude, longitude } = pos.coords;
          const coords = [latitude, longitude];
          setMechanicPosition(coords);
          
        },
        (err) => {
          console.error("Không thể lấy vị trí:", err);
          alert("Bạn cần cho phép truy cập vị trí!");
        },
        { enableHighAccuracy: true, maximumAge: 0, timeout: 15000 }
      );
  
      return () => navigator.geolocation.clearWatch(watchId);
  
    }, []);  

    const sendRescue = () => {
        socket.emit('send_location', {mechanicLocation: mechanicPosition, user_id: request.user_id});
    }
    const getRoute = async (start, end) => {
        try {
        const url = `https://router.project-osrm.org/route/v1/driving/${start[1]},${start[0]};${end[1]},${end[0]}?overview=full&geometries=geojson`;

        const response = await fetch(url);
        const json = await response.json();

        if (json.routes && json.routes.length > 0) {
            const coords = json.routes[0].geometry.coordinates.map((p) => [
            p[1],
            p[0],
            ]);
            setRouteCoords(coords);
        }
        } catch (err) {
        console.error("OSRM error:", err);
        }
    };

    const finshRescue = () => {
        console.log("Emit finish rescue")
        socket.emit('finish_rescue', {requestId: request._id});
        window.location.reload()
    }

    useEffect(() => {
        if (mechanicPosition && request.location.coordinates[1] && request.location.coordinates[0]) {
            getRoute(mechanicPosition, [request.location.coordinates[1],  request.location.coordinates[0]]);
        }
        sendRescue()
    }, [mechanicPosition, [request.location.coordinates[1] && request.location.coordinates[0]]]);
  return (
    <div className="flex flex-col w-full h-screen p-6 bg-n-50 font-grostek">

      <h1 className="mb-4 text-4xl font-bold text-center text-p-600">
        Đơn hàng đã được chấp nhận
      </h1>
      <p className="mb-8 text-center text-n-600">
        Bạn hãy di chuyển đến vị trí khách hàng và tiến hành hỗ trợ.
      </p>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">

        <div className="w-full h-[350px] rounded-2xl overflow-hidden shadow-lg border border-n-200">
          <MapContainer
            center={[request.location.coordinates[1], request.location.coordinates[0]]}
            zoom={16}
            scrollWheelZoom={true}
            className="w-full h-full"
          >
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            <Marker position={[request.location.coordinates[1], request.location.coordinates[0]]} icon={userIcon}>
              <Popup>Vị trí khách hàng</Popup>
            </Marker>
            <Marker position={mechanicPosition} icon={mechanicIcon}>
              <Popup>Vị trí thợ</Popup>
            </Marker>

            {routeCoords.length > 0 && (
              <Polyline
                positions={routeCoords}
                color="blue"
                weight={5}
               />
            )}
          </MapContainer>
        </div>

        <div className="flex flex-col gap-4 p-5 bg-white border shadow-md rounded-2xl border-n-200">

          <h2 className="text-2xl font-bold text-n-800">Thông tin khách hàng</h2>

          <div className="flex items-center justify-center w-full h-40 overflow-hidden bg-n-100 rounded-2xl">
            {request.images ? (
              <img
                src={request.images[0]}
                alt="User upload"
                className="object-cover w-full h-full"
              />
            ) : (
              <p className="text-n-500">* Khách hàng chưa cung cấp hình ảnh *</p>
            )}
          </div>

          <div className="flex flex-col gap-2 mt-2 text-n-700">
            <p>
              <span className="font-semibold">Tên khách hàng:</span>{" "}
              {request.user_id}
            </p>

            <p>
              <span className="font-semibold">Số điện thoại:</span>{" "}
              {request.phone}
            </p>

            <p>
              <span className="font-semibold">Địa chỉ:</span>{" "}
              {request.detail_address}
            </p>

            <p>
              <span className="font-semibold">Yêu cầu:</span>{" "}
              {request.description}
            </p>
          </div>

          {/* ACTION */}
          <button
            onClick={finshRescue}
            className="w-full py-3 mt-4 font-semibold text-white transition bg-p-500 rounded-xl hover:bg-p-600"
          >
            Hoàn thành cứu hộ
          </button>
        </div>
      </div>
    </div>
  );
}
