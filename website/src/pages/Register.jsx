import { useState } from "react";
import { registerAPI, loginAPI } from "../app/api";
import { Link, useNavigate } from "react-router-dom";
import logo from "../assets/logo.png";

function Register() {
  const navigate = useNavigate();

  const [form, setForm] = useState({
    fullname: "",
    email: "",
    phone: "",
    password_hash: "",
  });

  const [message, setMessage] = useState("");
  const [isSuccess, setIsSuccess] = useState(false);

  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      // === 1. Đăng ký
      await registerAPI(
        form.fullname,
        form.email,
        form.phone,
        form.password_hash,
        "end_user"
      );

      setIsSuccess(true);
      setMessage("Account Created Successfully!");

      // === 2. Tự động đăng nhập sau khi đăng ký
      const loginRes = await loginAPI(form.email, form.password_hash);

      localStorage.setItem("token", loginRes.accessToken);
      localStorage.setItem("user", JSON.stringify(loginRes));

      // === 3. Điều hướng sang trang home (hoặc dashboard)
      navigate("/");

    } catch (err) {
      setIsSuccess(false);
      setMessage(err.response?.data?.error || "Register failed");
    }
  };

  return (
    <div className="absolute inset-0 z-50 flex flex-wrap items-center justify-center bg-black/50">
      <div className="flex flex-col items-center justify-between px-6 py-4 w-130 h-auto bg-n-50 rounded-xl shadow-xl">

        <div className="flex justify-between items-center w-full mb-6">
          <div className="flex flex-col">
            <h1 className="text-5xl font-medium font-grostek text-n-700">Register</h1>
            <p className="text-sm font-light md:text-xl font-grostek text-n-700">
              Create a new account
            </p>
          </div>
          <img src={logo} className="object-contain w-[25%]" />
        </div>

        <form onSubmit={handleSubmit} className="w-full flex flex-col mb-4">

          <input
            type="text"
            name="fullname"
            placeholder="Full name"
            value={form.fullname}
            onChange={handleChange}
            className="w-full mb-4 h-[8%] rounded-xl text-sl font-light md:text-xl 
                       border border-p-600 text-n-700 px-3"
            required
          />

          <input
            type="email"
            name="email"
            placeholder="Email"
            value={form.email}
            onChange={handleChange}
            className="w-full mb-4 h-[8%] rounded-xl text-sl font-light md:text-xl 
                       border border-p-600 text-n-700 px-3"
            required
          />

          <input
            type="text"
            name="phone"
            placeholder="Phone number"
            value={form.phone}
            onChange={handleChange}
            className="w-full mb-4 h-[8%] rounded-xl text-sl font-light md:text-xl 
                       border border-p-600 text-n-700 px-3"
            required
          />

          <input
            type="password"
            name="password_hash"
            placeholder="Password"
            value={form.password_hash}
            onChange={handleChange}
            className="w-full mb-4 h-[8%] rounded-xl text-sl font-light md:text-xl 
                       border border-p-600 text-n-700 px-3"
            required
          />

          <button
            type="submit"
            className="w-full mb-5 h-[8%] rounded-xl text-sl font-light md:text-xl cursor-pointer 
                       bg-p-600 hover:bg-p-800 text-n-50 flex justify-center items-center"
          >
            Create Account
          </button>
        </form>

        {message && (
          <p
            className={`text-md mt-2 font-grostek ${
              isSuccess ? "text-green-600" : "text-red-600"
            }`}
          >
            {message}
          </p>
        )}

      </div>
    </div>
  );
}

export default Register;
