import axios from "axios";
import axiosAdmin from "./axiosAdmin";

const baseURL =
  process.env.REACT_APP_ADMIN_FE_URL ||
  process.env.ADMIN_FE_URL ||
  "http://localhost:8000";

const ACCOUNT_URL = `${baseURL}/account`;
const COMMERCE_URL = `${baseURL}/commerce`;
const PRODUCT_URL = `${COMMERCE_URL}/product`;
const CATALOG_URL = `${COMMERCE_URL}/catalog`;
const ORDER_URL = `${baseURL}/order`;
const BANNER_URL = `${baseURL}/banners`;
const ACCOUNT_ADMIN_URL = `${ACCOUNT_URL}`;


const loginAPI = (email, password_hash) => {
  return axios
    .post(`${ACCOUNT_URL}/login`, { email, password_hash })
    .then((res) => res.data)
    .catch((err) => {
      throw err;
    });
};

const productAPI = {
  list: () =>
    axiosAdmin
      .get(`${PRODUCT_URL}/showall`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  detail: (productId) =>
    axiosAdmin
      .get(`${PRODUCT_URL}/detail/${productId}`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  create: (payload) =>
    axiosAdmin
      .post(`${PRODUCT_URL}/create`, payload)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  update: (productId, payload) =>
    axiosAdmin
      .patch(`${PRODUCT_URL}/update/${productId}`, payload)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  remove: (productId) =>
    axiosAdmin
      .delete(`${PRODUCT_URL}/delete/${productId}`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
};

const accountAPI = {
  list: () =>
    axiosAdmin
      .get(`${ACCOUNT_ADMIN_URL}/showall`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  detail: (id) =>
    axiosAdmin
      .get(`${ACCOUNT_ADMIN_URL}/detail/${id}`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  create: (payload) =>
    axiosAdmin
      .post(`${ACCOUNT_ADMIN_URL}/create`, payload)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  update: (id, payload) =>
    axiosAdmin
      .patch(`${ACCOUNT_ADMIN_URL}/update/${id}`, payload)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  remove: (id) =>
    axiosAdmin
      .delete(`${ACCOUNT_ADMIN_URL}/delete/${id}`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  search: (keyword) =>
    axiosAdmin
      .get(`${ACCOUNT_ADMIN_URL}/search`, { params: { q: keyword } })
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
};

const catalogAPI = {
  list: () =>
    axiosAdmin
      .get(`${CATALOG_URL}/showall`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  detail: (id) =>
    axiosAdmin
      .get(`${CATALOG_URL}/detail/${id}`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  create: (payload) =>
    axiosAdmin
      .post(`${CATALOG_URL}/create`, payload)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  update: (id, payload) =>
    axiosAdmin
      .patch(`${CATALOG_URL}/update/${id}`, payload)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  remove: (id) =>
    axiosAdmin
      .delete(`${CATALOG_URL}/delete/${id}`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
};

const orderAPI = {
  list: () =>
    axiosAdmin
      .get(`${ORDER_URL}/all`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
};

const bannerAPI = {
  list: () =>
    axiosAdmin
      .get(`${BANNER_URL}/get`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  create: (payload) =>
    axiosAdmin
      .post(`${BANNER_URL}/add`, payload)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  update: (id, payload) =>
    axiosAdmin
      .patch(`${BANNER_URL}/update/${id}`, payload)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
  remove: (id) =>
    axiosAdmin
      .delete(`${BANNER_URL}/delete/${id}`)
      .then((res) => res.data)
      .catch((err) => {
        throw err;
      }),
};

export { loginAPI, productAPI, accountAPI, catalogAPI, orderAPI, bannerAPI };
