import { useEffect, useState } from "react";
import React from "react";
import { MapContainer, TileLayer, Marker, Popup, Polyline } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";


const userIcon = L.icon({
  iconUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});
L.Marker.prototype.options.icon = userIcon;

const mechanicIcon = new L.Icon({
  iconUrl:
    "https://static.vecteezy.com/system/resources/thumbnails/060/281/745/small_2x/fire-truck-3d-icon-red-fire-truck-3d-icon-png.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});


function AcceptedMap({userPosition, mechanicPosition}) {
  const [routeCoords , setRouteCoords] = useState([]);
  
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
  useEffect(() => {
    if (mechanicPosition && userPosition) {
         getRoute(mechanicPosition, userPosition);
    }
  }, [mechanicPosition]);

  if (!userPosition) return <p className="mt-10 text-center text-n-50">Đang xác định vị trí của bạn...</p>;

  return (  
    <div className="w-full overflow-hidden shadow-lg h-70 rounded-xl">
      <MapContainer
        center={userPosition}
        zoom={16}
        scrollWheelZoom={true}
        className="w-full h-full"
      >

        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution="&copy; OpenStreetMap contributors"
        />

        <Marker position={userPosition}>
          <Popup>Người dùng đang ở đây</Popup>
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
  );
}

export default AcceptedMap;
