import axios from 'axios';
import axiosClient from './axiosClient';
const ACCOUNT_URL = "http://localhost:8000/account";
const SERVICE_URL = "http://localhost:8000/service";

const loginAPI = (email, password_hash) => {
    return axios
    .post(`${ACCOUNT_URL}/login`, {email, password_hash})
    .then((res) => res.data)
    .catch( err => {
        throw err;
    })
}; export {loginAPI}

const serviceAPI = () => {
    return axiosClient
    .get(`/service/get`)
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {serviceAPI}

const rescue_requestAPI = (description, location, price_estimate, idService) =>{
    return axiosClient
    .post(`service/rescue/${idService}`, {description, location, price_estimate})
    .then((res) => res.data)
    .catch(err => {
        throw err
    })
}; export {rescue_requestAPI}