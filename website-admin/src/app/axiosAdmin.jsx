import axios from "axios";

const axiosAdmin = axios.create({
    baseURL: "http://localhost:8000",
    headers: {
        "Content-Type": "application/json",
    },
});

axiosAdmin.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem("token");
        if (token) {
            config.headers.token = `Bearer ${token}`;
        };
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

axiosAdmin.interceptors.response.use(
    (response) => {
        return response;
    },
    (error) => {
        if (error.response && error.response.status === 401 || error.response.status === 403) {
            console.error("Lỗi xác thực Admin:", error.response.data.err);
            

            alert("Bạn không có quyền truy cập tính năng này!");

        }
        return Promise.reject(error);
    }
);

export default axiosAdmin;
