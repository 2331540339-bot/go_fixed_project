import { useEffect, useState } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";

// ✅ biểu tượng marker mặc định (Leaflet v4 cần khai báo thủ công)
const defaultIcon = L.icon({
  iconUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});
L.Marker.prototype.options.icon = defaultIcon;

function UserMap() {
  const [position, setPosition] = useState(null);

  // 📍 Lấy vị trí thật của user
  useEffect(() => {
    if (!navigator.geolocation) {
      alert("Trình duyệt của bạn không hỗ trợ định vị GPS!");
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const { latitude, longitude } = pos.coords;
        setPosition([latitude, longitude]);
      },
      (err) => {
        console.error("Không thể lấy vị trí:", err);
        alert("Bạn cần cho phép truy cập vị trí!");
      }
    );
  }, []);

  if (!position) return <p className="mt-10 text-center">⏳ Đang xác định vị trí của bạn...</p>;

  return (  
    <div className="w-[50%] overflow-hidden shadow-lg h-70 rounded-xl">
      <MapContainer
        center={position}
        zoom={16}
        scrollWheelZoom={true}
        className="w-full h-full"
      >
        {/* TileLayer = nền bản đồ */}
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution="&copy; OpenStreetMap contributors"
        />

        {/* Marker người dùng */}
        <Marker position={position}>
          <Popup>Bạn đang ở đây 📍</Popup>
        </Marker>
      </MapContainer>
    </div>
  );
}

export default UserMap;
