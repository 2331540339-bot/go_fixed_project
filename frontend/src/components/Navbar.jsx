import { Link, NavLink } from "react-router-dom";


export default function Navbar() {
  return (
    <>
      <header className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b">
        <div className="container mx-auto max-w-6xl px-4 h-16 flex items-center justify-between">
          <Link to="/" className="font-bold text-xl text-brand-600">
            GoFix<span className="text-brand-500">.Web</span>
          </Link>
          <nav className="flex gap-6">
            <NavLink
              to="/"
              end
              className={({ isActive }) =>
                isActive ? "text-brand-600 font-medium" : "text-gray-600 hover:text-brand-600"
              }
            >
              Home
            </NavLink>
            <NavLink
              to="/services"
              className={({ isActive }) =>
                isActive ? "text-brand-600 font-medium" : "text-p-600 hover:text-brand-600"
              }
            >
              Services
            </NavLink>
            <NavLink
              to="/login"
              className={({ isActive }) =>
                isActive ? "text-brand-600 font-medium" : "text-p-600 hover:text-brand-600"
              }
            >
              Login
            </NavLink>
          </nav>
        </div>
      </header>
    </>
    
  );
}
