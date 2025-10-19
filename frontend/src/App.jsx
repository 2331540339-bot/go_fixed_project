import { Outlet } from "react-router-dom";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";

export default function App() {
  return (
    <>
      
      <div className="min-h-dvh flex flex-col bg-gray-50">
          <Navbar />
          <main className="container mx-auto max-w-6xl px-4 py-6 flex-1">
            <Outlet />
          </main>
          <Footer />
      </div>
    </>
  );
}
