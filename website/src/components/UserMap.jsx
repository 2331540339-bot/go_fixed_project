import { useEffect, useState } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import L from "leaflet";

const defaultIcon = L.icon({
  iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});
L.Marker.prototype.options.icon = defaultIcon;

function UserMap({ onPositionChange }) {
  const [position, setPosition] = useState(null);

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
        onPositionChange?.(coords);
      },
      (err) => {
        console.error("Không thể lấy vị trí:", err);
        alert("Bạn cần cho phép truy cập vị trí!");
      },
      { enableHighAccuracy: true, maximumAge: 0, timeout: 15000 }
    );

    return () => navigator.geolocation.clearWatch(watchId);

  }, []);

  if (!position)
    return <p className="mt-10 text-center text-n-50">Đang xác định vị trí của bạn...</p>;

  return (
    <div className="w-full overflow-hidden shadow-lg h-70 rounded-xl">
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
    </div>
  );
}

export default UserMap;
