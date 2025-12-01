import { Navigate, Route, Routes } from "react-router-dom";
import Dashboard from "../pages/Dashboard";
import Products from "../pages/Products";
import Accounts from "../pages/Accounts";
import Catalogs from "../pages/Catalogs";
import Orders from "../pages/Orders";
import Banners from "../pages/Banners";
import Login from "../pages/Login";
import Layout from "../components/Layout";
import PrivateRoute from "../components/PrivateRoute";

const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/" element={<Navigate to="/login" replace />} />

      <Route element={<PrivateRoute />}>
        <Route element={<Layout />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/products" element={<Products />} />
          <Route path="/catalogs" element={<Catalogs />} />
          <Route path="/accounts" element={<Accounts />} />
          <Route path="/orders" element={<Orders />} />
          <Route path="/banners" element={<Banners />} />
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
};

export default AppRoutes;
