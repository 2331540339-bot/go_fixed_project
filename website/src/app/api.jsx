import axios from 'axios';
import axiosClient from './axiosClient';
const domain = import.meta.env.VITE_API_URL;
const ACCOUNT_URL = `${domain}/account`;
const CART_URL = `${domain}/cart`;
const CATALOG_URL = `${domain}/catalog`;
const COMMERCE_URL = `${domain}/commerce`;
const PAYMENT_URL = `${domain}/payment_online`;
const REVIEW_URL = `${domain}/review`;

const loginAPI = (email, password_hash) => {
    return axios
    .post(`${ACCOUNT_URL}/login`, {email, password_hash})
    .then((res) => res.data)
    .catch( err => {
        throw err;
    })
}; export {loginAPI}

const registerAPI = (fullname, email, phone, password_hash, role = 'end_user') => {
    return axiosClient
    .post(`${ACCOUNT_URL}/create`, {fullname, email, phone, password_hash, role})
    .then((res) => res.data)
    .catch(err => {
        throw err;
    })
}; export {registerAPI}

const serviceAPI = () => {
    return axiosClient
    .get(`/service/get`)
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {serviceAPI}

const rescue_requestAPI = (description, images,phone,detail_address, location, price_estimate, idService) =>{
    return axiosClient
    .post(`service/rescue/${idService}`, {description, images,phone,detail_address, location, price_estimate})
    .then((res) => res.data)
    .catch(err => {
        throw err
    })
}; export {rescue_requestAPI}

const catalogAPI_showall = () => {
    return axios
    .get(`${COMMERCE_URL}/catalog/showall`)
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {catalogAPI_showall}

const productAPI_showall = () => {
    return axios
    .get(`${COMMERCE_URL}/product/showall`)
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {productAPI_showall}

const productAPI_detail = (product_id) => {
    return axios
    .get(`${COMMERCE_URL}/product/detail/${product_id}`)
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {productAPI_detail}

const orderAPI_create = (items, payment_method, shipping_address) => {
    return axiosClient
    .post(`order/create/`, {items, payment_method, shipping_address})
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {orderAPI_create}

const cartAPI_add = (product_id, quantity) => {
    return axiosClient
    .post(`${CART_URL}/add`, {product_id, quantity})
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {cartAPI_add}

const cartAPI_get = () => {
    return axiosClient
    .get(`${CART_URL}/get`)
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {cartAPI_get}

const cartAPI_update = (product_id, quantity) => {
    return axiosClient
    .patch(`${CART_URL}/update`, {product_id, quantity})
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {cartAPI_update}

const cartAPI_delete = (product_id) => {
    return axiosClient
    .delete(`${CART_URL}/delete`, {data: { product_id }})
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {cartAPI_delete}

const paymentVnPayAPI = (amount, orderId) => {
    return axiosClient
    .post(`${PAYMENT_URL}/create-qr`, {amount, orderId})
    .then((res) => res.data)
    .catch((err) => {throw err})
}; export {paymentVnPayAPI}

const reviewAPI_add = (formData) =>{
    return axiosClient.post(`${REVIEW_URL}/add`, formData, {
        headers: {
            "Content-Type": "multipart/form-data"
        }
    })
    .then(res => res.data)
    .catch(err => { throw err });
}; export { reviewAPI_add };

const reviewAPI_getByProduct = (product_id) => {
    return axiosClient
        .get(`${REVIEW_URL}/product/${product_id}`)
        .then(res => res.data)
        .catch(err => { throw err });
};
export { reviewAPI_getByProduct };

