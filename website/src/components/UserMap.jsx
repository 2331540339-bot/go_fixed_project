import { useEffect, useState } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";


const defaultIcon = L.icon({
  iconUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});
L.Marker.prototype.options.icon = defaultIcon;

function UserMap({onPositionChange}) {
  const [position, setPosition] = useState(null);
  const [positionMechanic, setPositionMechanic] = useState(null);

  useEffect(() => {
    if (!navigator.geolocation) {
      alert("Trình duyệt của bạn không hỗ trợ định vị GPS!");
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const { latitude, longitude } = pos.coords;
        const coords = [latitude, longitude];
        setPosition([latitude, longitude]);
        console.log(coords)
        if(onPositionChange) onPositionChange(coords);
      },
      (err) => {
        console.error("Không thể lấy vị trí:", err);
        alert("Bạn cần cho phép truy cập vị trí!");
      }
    );
  }, [onPositionChange]);

  if (!position) return <p className="mt-10 text-center text-n-50">Đang xác định vị trí của bạn...</p>;

  return (  
    <div className="w-full overflow-hidden shadow-lg h-70 rounded-xl">
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
          <Popup>Bạn đang ở đây</Popup>
        </Marker>

        {/* Marker mechanic */}
        {positionMechanic != null ? <Marker position={[10.825367998402108, 106.63069386043213]} className="hidden">
          <Popup>Thợ máy đang ở đây</Popup>
        </Marker>: console.log("Chưa có vị trí thợ")}
      </MapContainer>
    </div>
  );
}

export default UserMap;
