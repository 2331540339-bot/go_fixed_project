import { useParams, useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import {
  productAPI_detail,
  orderAPI_create,
  paymentVnPayAPI,
} from "../app/api";
export default function Checkout() {
  const { productId, quantity: quantityParam } = useParams();
  const quantity = Number(quantityParam || 1);
  const navigate = useNavigate();
  const [product, setProduct] = useState();
  const [items, setItems] = useState([]);
  const [shippingAddress, setShippingAddress] = useState("");
  const [paymentMethod, setPaymentMethod] = useState("cod");
  const [totalPrice, setTotalPrice] = useState("");
  const loadProduct = () => {
    productAPI_detail(productId)
      .then((res) => setProduct(res))
      .catch((err) => console.log(err));
  };

  useEffect(() => {
    loadProduct();
  }, []);

  useEffect(() => {
    if (product) {
      setTotalPrice(product.price * quantity);
      const item = {
        product_id: product._id,
        quantity: quantity,
        price: product.price,
      };
      setItems([item]);
    }
  }, [product, quantity]);

  if (!product) {
    return (
      <div className="w-full py-10 text-center text-n-700 font-grostek">
        Không có sản phẩm để thanh toán!
      </div>
    );
  }

  const handleConfirmOrder = async () => {
    if (!shippingAddress.trim()) {
      alert("Vui lòng nhập địa chỉ giao hàng!");
      return;
    }

    // orderAPI_create(items,paymentMethod, shippingAddress)
    // .then((res) => alert("Tạo đơn thành công"))
    // .catch((err) => console.log("Tạo đơn thất bại", err.message))
    try {
      const orderResponse = await orderAPI_create(
        items,
        paymentMethod,
        shippingAddress
      );
      // Mongoose có thể trả về _id hoặc id
      const orderId = orderResponse?.order?._id || orderResponse?.order?.id;
      if (!orderId) {
        throw new Error("Không nhận được ID đơn hàng từ server.");
      }
      
      // Chỉ gọi VNPay cho các phương thức thanh toán online (không phải COD)
      if (paymentMethod !== "cod") {
        const paymentResponse = await paymentVnPayAPI(Number(totalPrice), orderId);

        const paymentUrl = paymentResponse?.paymentUrl;

        if (paymentUrl && typeof paymentUrl === "string") {
          window.location.href = paymentUrl;
        } else {
          alert("Lỗi: Không nhận được URL thanh toán từ máy chủ.");
        }
      } else {
        // COD - không cần thanh toán online
        alert("Đặt hàng thành công! Đơn hàng sẽ được giao và thanh toán khi nhận hàng.");
        navigate("/");
      }
    } catch (err) {
      console.error("Lỗi:", err);
      alert(`Thao tác thất bại: ${err.message}`);
    }
  };

  return (
    <div className="flex justify-center w-full min-h-screen py-10 bg-n-50">
      <div className="w-full max-w-4xl p-6 bg-white shadow-md rounded-3xl font-grostek">
        <h1 className="mb-6 text-2xl font-bold text-n-800">
          Xác nhận đơn hàng
        </h1>

        <div className="grid gap-6 lg:grid-cols-3">
          <div className="p-5 lg:col-span-2 bg-n-50 rounded-2xl">
            <h2 className="mb-4 text-lg font-semibold text-n-700">Sản phẩm</h2>

            <div className="flex items-start gap-4">
              <img
                src={product.image[0]}
                alt={product.product_name}
                className="object-contain p-2 w-28 h-28 rounded-xl bg-n-100"
              />

              <div className="flex flex-col justify-between flex-1">
                <div>
                  <h3 className="text-base font-semibold text-n-800">
                    {product.product_name}
                  </h3>

                  <p className="mt-1 text-sm text-n-600">
                    Số lượng: <b>{quantity}</b>
                  </p>
                </div>

                <p className="mt-1 text-lg font-bold text-p-500">
                  {totalPrice.toLocaleString("vi-VN")}₫
                </p>
              </div>
            </div>

            <div className="mt-6">
              <h2 className="mb-2 text-lg font-semibold text-n-700">
                Địa chỉ giao hàng
              </h2>

              <textarea
                placeholder="Nhập địa chỉ giao hàng..."
                value={shippingAddress}
                onChange={(e) => setShippingAddress(e.target.value)}
                className="w-full p-3 text-sm border outline-none border-n-200 rounded-xl focus:ring-2 focus:ring-p-500/40"
                rows="3"
              ></textarea>
            </div>

            <div className="mt-6">
              <h2 className="mb-2 text-lg font-semibold text-n-700">
                Phương thức thanh toán
              </h2>

              <div className="flex flex-col gap-2">
                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="radio"
                    name="payment"
                    value="cod"
                    checked={paymentMethod === "cod"}
                    onChange={(e) => setPaymentMethod(e.target.value)}
                    className="w-4 h-4"
                  />
                  <span>Thanh toán khi nhận hàng (COD)</span>
                </label>

                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="radio"
                    name="payment"
                    value="momo"
                    onChange={(e) => setPaymentMethod(e.target.value)}
                    className="w-4 h-4"
                  />
                  <span>Ví MoMo</span>
                </label>

                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="radio"
                    name="payment"
                    value="banking"
                    onChange={(e) => setPaymentMethod(e.target.value)}
                    className="w-4 h-4"
                  />
                  <span>Chuyển khoản ngân hàng</span>
                </label>
              </div>
            </div>
          </div>

          <div className="p-5 bg-n-50 rounded-2xl h-fit">
            <h2 className="mb-3 text-lg font-semibold text-n-700">
              Tóm tắt đơn hàng
            </h2>

            <div className="flex justify-between mb-2 text-sm text-n-600">
              <span>Tạm tính</span>
              <span>{product.price.toLocaleString("vi-VN")}₫</span>
            </div>

            <div className="flex justify-between mb-2 text-sm text-n-600">
              <span>Số lượng</span>
              <span>{quantity}</span>
            </div>

            <div className="flex justify-between mb-2 text-sm text-n-600">
              <span>Phí vận chuyển</span>
              <span>0₫</span>
            </div>

            <hr className="my-3" />

            <div className="flex justify-between text-lg font-bold text-p-600">
              <span>Tổng cộng</span>
              <span>{totalPrice.toLocaleString("vi-VN")}₫</span>
            </div>

            <button
              onClick={handleConfirmOrder}
              className="w-full py-3 mt-5 text-sm font-semibold text-white transition shadow-md rounded-xl bg-p-500 hover:bg-p-600"
            >
              Xác nhận đặt hàng
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
