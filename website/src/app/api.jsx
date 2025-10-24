import axios from 'axios';

const ACCOUNT_URL = "http://localhost:8000/account";

const loginAPI = (email, password_hash) => {
    return axios
    .post(`${ACCOUNT_URL}/login`, {email, password_hash})
    .then((res) => res.data)
    .catch( err => {
        throw err;
    })
}; export {loginAPI}