import React, { useState, useEffect } from "react";

function OrderPage() {
    // Dữ liệu cứng (mock)
    const [orders, setOrders] = useState([]);

    useEffect(() => {
        const mockOrders = [
            {
                _id: "ORDER123456",
                status: "completed",
                createdAt: "2025-02-01T10:30:00",
                total_price: 650000,
                items: [
                    {
                        product_id: {
                            product_name: "Phuộc YSS G-Series",
                            image: ["https://via.placeholder.com/80"]
                        },
                        quantity: 1,
                        price: 550000
                    },
                    {
                        product_id: {
                            product_name: "Dầu nhớt Repsol 10W40",
                            image: ["https://via.placeholder.com/80"]
                        },
                        quantity: 1,
                        price: 100000
                    }
                ]
            },
            {
                _id: "ORDER789012",
                status: "shipping",
                createdAt: "2025-02-05T14:10:00",
                total_price: 300000,
                items: [
                    {
                        product_id: {
                            product_name: "Lọc gió BRT",
                            image: ["https://via.placeholder.com/80"]
                        },
                        quantity: 1,
                        price: 150000
                    },
                    {
                        product_id: {
                            product_name: "Bu-gi NGK Iridium",
                            image: ["https://via.placeholder.com/80"]
                        },
                        quantity: 1,
                        price: 150000
                    }
                ]
            }
        ];

        setOrders(mockOrders);
    }, []);

    const statusColor = {
        pending: "bg-yellow-100 text-yellow-700",
        paid: "bg-blue-100 text-blue-700",
        shipping: "bg-indigo-100 text-indigo-700",
        completed: "bg-green-100 text-green-700",
        canceled: "bg-red-100 text-red-700",
    };

    return (
        <div className="w-full min-h-screen bg-n-50 py-8 px-4">
            <div className="max-w-4xl mx-auto">

                <h1 className="text-2xl font-semibold text-n-800 mb-5 font-grostek">
                    Đơn hàng của tôi
                </h1>

                {orders.length === 0 && (
                    <p className="text-center text-n-500 mt-12">
                        Bạn chưa có đơn hàng nào.
                    </p>
                )}

                <div className="space-y-4">
                    {orders.map((order) => (
                        <div
                            key={order._id}
                            className="p-5 bg-white rounded-2xl shadow-sm border border-n-100"
                        >
                            {/* Header đơn */}
                            <div className="flex justify-between items-center mb-3">
                                <span className="text-sm text-n-600">
                                    Mã đơn:{" "}
                                    <span className="font-semibold text-n-800">
                                        {order._id}
                                    </span>
                                </span>

                                <span
                                    className={`px-3 py-1 text-xs font-semibold rounded-full ${
                                        statusColor[order.status]
                                    }`}
                                >
                                    {order.status.toUpperCase()}
                                </span>
                            </div>

                            {/* Items */}
                            <div className="space-y-3">
                                {order.items.map((item, idx) => (
                                    <div
                                        key={idx}
                                        className="flex items-center justify-between bg-n-50 p-3 rounded-xl"
                                    >
                                        <div className="flex items-center gap-3">
                                            <img
                                                src={item.product_id.image[0]}
                                                className="w-16 h-16 rounded-xl object-cover border"
                                                alt={item.product_id.product_name}
                                            />

                                            <div>
                                                <p className="font-semibold text-n-800 text-sm">
                                                    {item.product_id.product_name}
                                                </p>
                                                <p className="text-xs text-n-500">
                                                    SL: {item.quantity}
                                                </p>
                                            </div>
                                        </div>

                                        <p className="font-semibold text-n-700">
                                            {(item.price * item.quantity).toLocaleString("vi-VN")}₫
                                        </p>
                                    </div>
                                ))}
                            </div>

                            {/* Footer */}
                            <div className="border-t border-n-100 mt-4 pt-3 flex justify-between items-center">
                                <p className="text-xs text-n-500">
                                    Ngày đặt:{" "}
                                    {new Date(order.createdAt).toLocaleDateString("vi-VN")}
                                </p>

                                <p className="text-base font-bold text-p-500">
                                    Tổng tiền: {order.total_price.toLocaleString("vi-VN")}₫
                                </p>
                            </div>
                        </div>
                    ))}
                </div>

            </div>
        </div>
    );
}

export default OrderPage;
