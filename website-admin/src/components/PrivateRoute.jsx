import { Navigate, Outlet, useLocation } from "react-router-dom";

const PrivateRoute = () => {
  const token = typeof window !== "undefined" ? localStorage.getItem("token") : null;
  const location = useLocation();

  if (!token) {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }

  return <Outlet />;
};

export default PrivateRoute;
