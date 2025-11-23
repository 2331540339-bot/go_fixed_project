import React, { useEffect, useState } from "react";
import { useParams, useLocation, useNavigate } from "react-router-dom";
import { productAPI_detail, cartAPI_add, catalogAPI_showall} from "../app/api";
import Checkout from "../components/Checkout";
function DetailPart() {
    const { id } = useParams();
    const { state } = useLocation();
    const navigate = useNavigate();
    const [data, setData] = useState(state?.product || null);
    const [activeImage, setActiveImage] = useState("");
    const [quantity, setQuantity] = useState(1);
    const [formattedPrice, setFormattedPrice] = useState("");
    const [loading, setLoading] = useState(!state?.product);
    const [catalog, setCatalog] = useState([]);
    const loadAPI = async () => {
        try {
            const res = await productAPI_detail(id);
            setData(res);
            setActiveImage(res.image?.[0]);
            setFormattedPrice(res.price.toLocaleString("vi-VN") + "₫");
        } catch (err) {
            console.log(err.message);
        } finally {
            setLoading(false);
        }

        
    };

    useEffect(() => {
        if (!state?.product) {
            loadAPI();
        } else {

            setActiveImage(state.product.image[0]);
            setFormattedPrice(
                state.product.price.toLocaleString("vi-VN") + "₫"
            );
        }
    }, [id, state]);

    if (loading || !data) {
        return (
            <div className="w-full py-10 text-center font-grostek text-n-700">
                Đang tải sản phẩm...
            </div>
        );
    }

    const handleAddToCart = () => {
        cartAPI_add(data._id, quantity)
        .then((res) => alert(`Thêm sản phẩm ${data.product_name} vào giỏ hàng thành công`))
        .catch((err) => console.log("Thêm vào giỏ hàng thất bại:", err))
    };

    const handleOrderNow = () => {
        navigate(`/checkout/${data._id}/${quantity}`);
    };

    const handleChangeQuantity = (type) => {
        setQuantity((prev) => {
            if (type === "inc") return prev + 1;
            if (type === "dec") return prev > 1 ? prev - 1 : 1;
            return prev;
        });
    };

    return (
        <div className="w-full min-h-screen bg-n-50">
            <div className="max-w-6xl px-4 py-8 mx-auto lg:px-0">

                <div className="mb-4 text-sm text-n-500 font-grostek">
                    <span className="cursor-pointer hover:text-p-500">Trang chủ</span>
                    <span className="mx-2">/</span>
                    <span className="cursor-pointer hover:text-p-500">
                        {data.catalog_id || "Danh mục"}
                    </span>
                    <span className="mx-2">/</span>
                    <span className="text-n-700">{data.product_name}</span>
                </div>

                <div className="grid gap-8 lg:grid-cols-2">
                    <div className="space-y-4">
                        <div className="relative w-full overflow-hidden bg-n-100 rounded-3xl h-80">
                            <img
                                src={activeImage}
                                alt={data.product_name}
                                className="object-contain w-full h-full p-4 transition duration-300 transform hover:scale-105"
                            />
                            <span className="absolute px-3 py-1 text-xs font-semibold text-white rounded-full top-4 left-4 bg-p-500">
                                Bán chạy
                            </span>
                        </div>

                        <div className="flex gap-3">
                            {data.image?.map((img, index) => (
                                <button
                                    key={index}
                                    onClick={() => setActiveImage(img)}
                                    className={`w-20 h-20 rounded-2xl border-2 overflow-hidden bg-n-100 flex items-center justify-center transition
                                    ${
                                        activeImage === img
                                            ? "border-p-500 shadow-md"
                                            : "border-transparent hover:border-n-200"
                                    }`}
                                >
                                    <img
                                        src={img}
                                        alt={`thumb-${index}`}
                                        className="object-contain w-full h-full p-1"
                                    />
                                </button>
                            ))}
                        </div>
                    </div>

                    <div className="flex flex-col justify-between">
                        <div>

                            <div className="flex items-center justify-between mb-2">
                                <span className="px-3 py-1 text-xs font-semibold rounded-full bg-p-50 text-p-600 font-grostek">
                                    {data.catalog_name || "Phụ tùng"}
                                </span>

                                <div className="flex items-center gap-1 text-sm text-n-600">
                                    <span className="text-p-500">★</span>
                                    <span>{data.rating || 4.5}</span>
                                    <span className="text-n-500">
                                        ({data.reviews_count || 0} đánh giá)
                                    </span>
                                </div>
                            </div>

                            <h1 className="mb-2 text-2xl font-semibold text-n-800 font-grostek">
                                {data.product_name}
                            </h1>

                            <div className="flex items-center gap-2 mb-4 text-sm">
                                <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
                                <span className="text-emerald-600 font-grostek">
                                    Còn hàng ({data.quantity} sản phẩm)
                                </span>
                            </div>

                            <div className="flex items-end gap-3 mb-4">
                                <span className="text-3xl font-bold text-p-500 font-grostek">
                                    {formattedPrice}
                                </span>
                                <span className="text-sm line-through text-n-500">
                                    {(data.price * 1.1).toLocaleString("vi-VN")}₫
                                </span>
                                <span className="px-2 py-1 text-xs font-semibold text-white rounded-full bg-p-500">
                                    -10%
                                </span>
                            </div>

                            <div className="flex items-center gap-4 mb-6">
                                <span className="text-sm font-medium text-n-700 font-grostek">
                                    Số lượng:
                                </span>
                                <div className="flex items-center gap-2">
                                    <button
                                        onClick={() => handleChangeQuantity("dec")}
                                        className="flex items-center justify-center w-8 h-8 text-lg border rounded-full text-n-700 border-n-200 hover:bg-n-100"
                                    >
                                        –
                                    </button>
                                    <span className="w-10 text-base font-semibold text-center text-n-800">
                                        {quantity}
                                    </span>
                                    <button
                                        onClick={() => handleChangeQuantity("inc")}
                                        className="flex items-center justify-center w-8 h-8 text-lg border rounded-full text-n-700 border-n-200 hover:bg-n-100"
                                    >
                                        +
                                    </button>
                                </div>
                            </div>

                            <div className="flex flex-col gap-3 mb-6 sm:flex-row">
                                <button
                                    onClick={handleOrderNow}
                                    className="flex-1 py-3 text-sm font-semibold text-white transition-all shadow-md rounded-2xl bg-p-500 hover:bg-p-600 hover:shadow-lg font-grostek"
                                >
                                    Đặt hàng ngay
                                </button>

                                <button
                                    onClick={handleAddToCart}
                                    className="flex-1 py-3 text-sm font-semibold transition-all border rounded-2xl border-p-500 text-p-500 hover:bg-p-50 font-grostek"
                                >
                                    Thêm vào giỏ hàng
                                </button>
                            </div>

                            <div className="grid gap-3 text-sm text-n-600 sm:grid-cols-3">
                                <div className="flex items-start gap-2">
                                    <span className="text-p-500">✓</span>
                                    <span>Hỗ trợ lắp đặt tại garage đối tác GoFix.</span>
                                </div>
                                <div className="flex items-start gap-2">
                                    <span className="text-p-500">✓</span>
                                    <span>Thanh toán khi nhận hàng (COD).</span>
                                </div>
                                <div className="flex items-start gap-2">
                                    <span className="text-p-500">✓</span>
                                    <span>Đổi trả trong 7 ngày nếu lỗi từ nhà sản xuất.</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="grid gap-8 mt-10 lg:grid-cols-3">
                    <div className="p-5 bg-white shadow-sm rounded-3xl lg:col-span-2">
                        <h2 className="mb-3 text-lg font-semibold text-n-800 font-grostek">
                            Mô tả sản phẩm
                        </h2>
                        <p className="text-sm leading-relaxed text-n-600">
                            {data.description}
                        </p>

                        <h3 className="mt-6 mb-2 text-sm font-semibold text-n-700 font-grostek">
                            Thông số kỹ thuật
                        </h3>
                        <div className="grid grid-cols-1 gap-2 text-sm sm:grid-cols-2">
                            {data.specs?.map((spec, idx) => (
                                <div
                                    key={idx}
                                    className="flex justify-between p-2 rounded-xl bg-n-100"
                                >
                                    <span className="text-n-600">{spec.label}</span>
                                    <span className="font-medium text-n-800">{spec.value}</span>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className="p-5 bg-white shadow-sm rounded-3xl">
                        <h2 className="mb-3 text-lg font-semibold text-n-800 font-grostek">
                            Đánh giá & nhận xét
                        </h2>

                        <div className="flex items-center gap-3 mb-4">
                            <div className="text-3xl font-bold text-p-500">
                                {data.rating || 4.5}
                            </div>
                            <div className="flex flex-col">
                                <div className="flex items-center gap-1 text-p-500">
                                    {Array.from({ length: 5 }).map((_, index) => (
                                        <span key={index}>
                                            {index < Math.round(data.rating || 4.5) ? "★" : "☆"}
                                        </span>
                                    ))}
                                </div>
                                <span className="text-xs text-n-500">
                                    {data.reviews_count || 0} lượt đánh giá
                                </span>
                            </div>
                        </div>

                        <div className="p-3 mb-3 rounded-2xl bg-n-50">
                            <p className="mb-2 text-xs font-medium text-n-700">
                                Chia sẻ cảm nhận của bạn:
                            </p>
                            <textarea
                                className="w-full p-2 text-sm border rounded-xl border-n-200 focus:outline-none focus:ring-2 focus:ring-p-500/40"
                                rows={3}
                                placeholder="Đánh giá chất lượng sản phẩm, trải nghiệm lắp đặt, dịch vụ giao hàng..."
                            ></textarea>
                            <button className="w-full py-2 mt-2 text-xs font-semibold text-white transition rounded-xl bg-p-500 hover:bg-p-600">
                                Gửi đánh giá
                            </button>
                        </div>

                        <div className="space-y-3 text-sm">
                            <div className="p-3 rounded-2xl bg-n-50">
                                <div className="flex items-center justify-between mb-1">
                                    <span className="font-semibold text-n-800">Nguyễn Văn A</span>
                                    <span className="text-xs text-n-500">2 ngày trước</span>
                                </div>
                                <div className="text-xs text-p-500">★★★★★</div>
                                <p className="mt-1 text-xs text-n-600">
                                    Phuộc lắp lên xe chạy êm thấy rõ, vào ổ gà đỡ xóc hơn nhiều.
                                    Ship nhanh, đóng gói kỹ.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="mt-10">
                    <h2 className="mb-3 text-lg font-semibold text-n-800 font-grostek">
                        Sản phẩm liên quan
                    </h2>
                    <p className="text-sm text-n-500">
                    </p>
                </div>
            </div>
        </div>
    );
}

export default DetailPart;
