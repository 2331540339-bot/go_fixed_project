// src/components/LoginModal.jsx
import React from "react";
import { loginAPI } from "../app/api";
import { useState } from "react";
import logo from "../assets/logo.png";
import apple_icon from "../assets/apple_icon.png";
import google_icon from "../assets/google_icon.png";

function LoginModal({ onClose }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [err, setErr] = useState("");
  const handleLogin = async(e) => {
    e.preventDefault(); // Ngăn reload trang
    
    loginAPI(email, password)
    .then((res) => {
      console.log("Login successfully");
      localStorage.setItem("token", res.accessToken);
      onClose();
    })
    .catch(err => {
      console.log(err.response.data.error);
      setErr(err.response.data.error);
    })};
  
  return (
    <div className="absolute inset-0 z-50 flex flex-wrap items-center justify-center bg-black/50">
      
      <div className="flex flex-col items-center justify-between px-4 py-2 w-130 h-180 bg-n-50 rounded-xl">
        <button 
          className="flex justify-end w-full mb-5 text-3xl font-bold cursor-pointer text-n-700"
          onClick={onClose}
          >
            X 
        </button>

        <div className="flex h-[30%] justify-between mb-5">
          <div className="flex flex-col justify-end">
            <h1 className="text-6xl font-medium font-grostek text-n-700">Welcome!</h1>
            <p className="text-sm font-light md:text-2xl font-grostek text-n-700">Sign in with another site</p>
          </div>
          <img src={logo} className="object-contain w-[35%]"/>
        </div>

        <button 
          className="w-full mb-5 h-[8%] rounded-xl text-sl font-light md:text-xl cursor-pointer bg-p-600 text-n-50 flex justify-center items-center"
          ><img src={google_icon} className="h-[70%] mr-5"/>
            Sign in with Google
        </button>

        <button className="w-full mb-5 h-[8%] rounded-xl text-sl font-light md:text-xl cursor-pointer bg-p-600 text-n-50 flex justify-center items-center"
        ><img src={apple_icon} className="object-contain h-[70%] mr-5"/>
            Sign in with Apple
        </button>

        <div className="h-[1px] bg-n-800 w-full mb-5"></div>
        
        <input type="email" placeholder="Email" value={email} className="w-full mb-5 h-[8%] rounded-xl text-sl font-light md:text-xl border border-p-600 text-n-700 px-2 flex justify-center items-center"
         onChange={(e) => setEmail(e.target.value)}
         required/>
        <input type="password" placeholder="Password" value={password} className="w-full mb-5 h-[8%] rounded-xl text-sl font-light md:text-xl border border-p-600 text-n-700 px-2 flex justify-center items-center"
         onChange={(e) => setPassword(e.target.value)}
         required/>

        <p className="text-sm font-light md:text-md font-grostek text-p-700">{err}</p>
        <button 
          className="w-full mb-5 h-[8%] rounded-xl text-sl font-light md:text-xl cursor-pointer bg-p-600 hover:bg-p-800 text-n-50 flex justify-center items-center"
          onClick={handleLogin}
          >Sign In
        </button>

        <p className="text-sm font-light md:text-md font-grostek text-n-700">Did you get account ? <span className="font-bold">Register Here</span></p>
      </div>
    </div>
  );
}

export default LoginModal;
