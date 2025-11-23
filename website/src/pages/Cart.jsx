import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { cartAPI_get, cartAPI_delete, cartAPI_update } from "../app/api";
import Checkout_Cart from "../components/Checkout_Cart";
export default function Cart() {
    const navigate = useNavigate();
    const [cartItems, setCartItems] = useState([]);
    const [checkItems, setCheckItems] = useState([]);
    const [checkOut, setCheckOut] = useState(false);
    useEffect(() => {
        cartAPI_get()
        .then((res) => {
            setCartItems(res.cart.cart_items);
            console.log(res.cart.cart_items);
        })
        .catch((err) => console.log(err))
       
    }, []);

    const hanldeChecked = (item) => {
        setCheckItems((prev) => 
            prev.includes(item)
            ?
            prev.filter((item) => item !== item)
            :
            [...prev, item]
        );
    }
    const subtotal = cartItems.reduce(
        (acc, item) => acc + item.price * item.quantity,
        0
    );

    const updateQuantity = async(id, type) => {
        console.log("ID sản phẩm:", id);
        setCartItems((prev) =>
            prev.map((item) =>
                item.product_id._id === id
                    ? {
                          ...item,
                          quantity:
                              type === "inc"
                                  ?
                                  item.quantity + 1
                                  : 
                                  Math.max(1, item.quantity - 1)
                      }
                    : item
            )

        );
        
        const found = cartItems.find(item => item.product_id._id === id);
        if(!found){
            return
        };
        
        const new_quantity = type === 'inc'? found.quantity + 1 : found.quantity-1;
        if(new_quantity < 1){return console.log("Số lượng sản phẩm không thể nhỏ hơn 1")}
        cartAPI_update(id, new_quantity)
        .then((res) => console.log(res))
        .catch((err) => console.log(err));
    };


    const removeItem = (id) => {
        console.log("ID sản phẩm:", id);
        setCartItems((prev) => prev.filter((item) => item.product_id._id !== id));
        const found  = cartItems.find((item) => item.product_id._id === id);
        if(!found){return};
        cartAPI_delete(id)
        .then((res) => console.log(res))
        .catch((err) => console.log(err));
    };

    const handleCheckout = () => {
        if(checkItems.length === 0){
            return alert("Vui lòng chọn sản phẩm cần thanh toán");
        }
        setCheckOut(true);
        
    };

    return (
        <div className="flex justify-center w-full min-h-screen py-10 bg-n-50 font-grostek">
            {checkOut? <Checkout_Cart checkedList = {checkItems}/>:
                <div className="w-full max-w-5xl p-6 bg-white shadow-lg rounded-3xl">

                    <h1 className="mb-6 text-2xl font-bold text-n-800">
                        Giỏ hàng của bạn
                    </h1>

                    {cartItems.length === 0 && (
                        <p className="py-10 text-center text-n-600">
                            Giỏ hàng đang trống.
                        </p>
                    )}

                    {cartItems.length > 0 && (
                        <div className="grid gap-6 lg:grid-cols-3">

                            <div className="space-y-4 lg:col-span-2">
                                {cartItems.map((item) => (
                                    <div
                                        key={item.product_id._id}
                                        className="flex gap-4 p-4 transition shadow-sm bg-n-50 rounded-2xl hover:shadow-md"
                                    >
                                        <input type="checkbox" className="accent-p-50" onClick={() => hanldeChecked(item)}/>
                                        <img
                                            src={item.product_id.image[0]}
                                            alt={item.product_id.product_name}
                                            className="object-contain w-24 h-24 bg-n-100 rounded-xl"
                                        />

    
                                        <div className="flex flex-col justify-between flex-1">
                                            <div>
                                                <h3 className="font-semibold text-n-800">
                                                    {item.product_id.product_name}
                                                </h3>
                                                <p className="mt-1 text-lg font-bold text-p-500">
                                                    {item.price.toLocaleString("vi-VN")}₫
                                                </p>
                                            </div>


                                            <div className="flex items-center gap-3 mt-2">
                                                <button
                                                    className="flex items-center justify-center w-8 h-8 border rounded-full bg-n-100 border-n-200 hover:bg-n-200"
                                                    onClick={() => updateQuantity(item.product_id._id, "dec")}
                                                >
                                                    –
                                                </button>

                                                <span className="w-10 font-semibold text-center">
                                                    {item.quantity}
                                                </span>

                                                <button
                                                    className="flex items-center justify-center w-8 h-8 border rounded-full bg-n-100 border-n-200 hover:bg-n-200"
                                                    onClick={() => updateQuantity(item.product_id._id, "inc")}
                                                >
                                                    +
                                                </button>
                                                <button
                                                    onClick={() => removeItem(item.product_id._id)}
                                                    className="ml-auto text-sm text-red-500 hover:text-red-700"
                                                >
                                                    Xoá
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>


                            <div className="p-5 shadow-md bg-n-50 h-fit rounded-2xl">
                                <h2 className="mb-3 text-lg font-semibold text-n-800">
                                    Tóm tắt đơn hàng
                                </h2>

                                <div className="flex justify-between mb-2 text-sm text-n-600">
                                    <span>Tạm tính</span>
                                    <span>{subtotal.toLocaleString("vi-VN")}₫</span>
                                </div>

                                <div className="flex justify-between mb-2 text-sm text-n-600">
                                    <span>Phí vận chuyển</span>
                                    <span>0₫</span>
                                </div>

                                <hr className="my-3" />

                                <div className="flex justify-between text-lg font-bold text-p-600">
                                    <span>Tổng cộng</span>
                                    <span>{subtotal.toLocaleString("vi-VN")}₫</span>
                                </div>

                                <button
                                    onClick={handleCheckout}
                                    className="w-full py-3 mt-5 font-semibold text-white transition shadow-md bg-p-500 rounded-xl hover:bg-p-600"
                                >
                                    Tiến hành thanh toán
                                </button>
                            </div>
                        </div>
                    )}
                </div>
            }
        </div>
    );
}
