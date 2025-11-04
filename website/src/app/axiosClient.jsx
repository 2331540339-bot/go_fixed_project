import axios from "axios";

const axiosClient = axios.create({
    baseURL: "http://localhost:8000",
    headers: {
        "Content-Type":"application/json",
    },
});

axiosClient.interceptors.request.use((config) => {
    const token = localStorage.getItem("token");
    if(!token){
        console.log("Token not found");
    }
    if(token){
        config.headers.Authorization = `Baerer ${token}`;
    };
    return config;
});

export default axiosClient;