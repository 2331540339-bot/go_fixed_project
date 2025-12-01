import { NavLink, Outlet, useLocation } from "react-router-dom";

const Layout = ({ children }) => {
  const { pathname } = useLocation();
  const title = pathname.includes("products")
    ? "Sản phẩm"
    : pathname.includes("accounts")
    ? "Tài khoản"
    : pathname.includes("catalogs")
    ? "Danh mục"
    : pathname.includes("orders")
    ? "Đơn hàng"
    : "Dashboard";

  return (
    <div className="admin-shell d-flex">
      <aside className="sidebar d-flex flex-column">
        <div className="brand text-white fw-bold px-3 py-3">
          <span className="brand-dot me-2">●</span>
          AutoCare Admin
        </div>
        <nav className="nav flex-column px-3">
          <NavLink end to="/dashboard" className="nav-link text-white">
            <span className="me-2">▸</span>Dashboard
          </NavLink>
           <NavLink to="/catalogs" className="nav-link text-white">
            <span className="me-2">▸</span>Danh mục
          </NavLink>
          <NavLink to="/products" className="nav-link text-white">
            <span className="me-2">▸</span>Sản phẩm
          </NavLink>
          <NavLink to="/accounts" className="nav-link text-white">
            <span className="me-2">▸</span>Tài khoản
          </NavLink>
          <NavLink to="/orders" className="nav-link text-white">
            <span className="me-2">▸</span>Đơn hàng
          </NavLink>
        </nav>
        <div className="sidebar-footer mt-auto px-3 pb-3 text-white-50 small">
          Quản trị cửa hàng
        </div>
      </aside>

      <div className="flex-grow-1 d-flex flex-column min-vh-100">
        <header className="topbar d-flex align-items-center justify-content-between px-4 py-3">
          <div>
            <span className="text-uppercase fw-semibold text-danger">{title}</span>
          </div>
          <div className="d-flex align-items-center gap-3">
            <div className="avatar-circle bg-danger text-white fw-semibold">
              AD
            </div>
          </div>
        </header>
        <main className="flex-grow-1 px-4 py-4 main-surface">
          {children || <Outlet />}
        </main>
      </div>
    </div>
  );
};

export default Layout;
