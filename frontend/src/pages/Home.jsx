import { Link } from "react-router-dom";

export default function Home() {
  return (
    <section className="grid md:grid-cols-2 gap-8 items-center">
      <div className="space-y-4">
        <h1 className="text-3xl md:text-4xl font-bold">
          Welcome to <span className="text-brand-600">GoFix</span> — Service Booking Platform
        </h1>
        <p className="text-gray-600">
          Tìm, đặt và quản lý dịch vụ sửa chữa một cách nhanh chóng. Kết nối người dùng và thợ dịch vụ.
        </p>
        <div className="flex gap-3">
          <Link to="/services" className="btn-primary">Browse Services</Link>
          <Link to="/login" className="btn border hover:bg-gray-50">Sign In</Link>
        </div>
      </div>
      <div className="card p-6">
        <img
          src="https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?q=80&w=2070&auto=format&fit=crop"
          alt="hero"
          className="rounded-xl object-cover w-full h-64"
        />
      </div>
    </section>
  );
}
