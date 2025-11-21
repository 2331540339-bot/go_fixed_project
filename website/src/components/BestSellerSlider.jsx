import { useRef } from "react";
import {Link, useNavigate} from "react-router-dom"
import DetailPart from "../pages/DetailPart";
export default function BestSellerSlider({ products }) {
    const navigate = useNavigate();
    const sliderRef = useRef(null);

    const nextSlide = () => {
        sliderRef.current.scrollBy({ left: 260, behavior: "smooth" });
    };

    const prevSlide = () => {
        sliderRef.current.scrollBy({ left: -260, behavior: "smooth" });
    };

    const detailPart = (product) => {
        navigate(`/genuine-part/${product._id}`);
    }

    return (
        <div className="relative w-full">

            <div
                ref={sliderRef}
                className="flex gap-4 overflow-x-auto scroll-smooth no-scrollbar"
            >
                {products.map((product) => (
                    <div
                        key={product._id}
                        className="w-[240px] flex-shrink-0 bg-n-50 rounded-2xl shadow-md overflow-hidden 
                                   hover:shadow-lg transition duration-300 cursor-pointer group font-grostek"
                    >
                        <div className="relative w-full h-40 bg-n-100">
                            <img
                                src={product.image[0]}
                                alt={product.product_name}
                                className="object-contain w-full h-full p-2 transition duration-300 group-hover:scale-105"
                            />

                            <span className="absolute px-2 py-1 text-xs text-white rounded-md top-2 left-2 bg-p-500">
                                Bán chạy
                            </span>
                        </div>

                        <div className="p-3">
                            <h3 className="text-sm font-semibold text-n-700 line-clamp-2">
                                {product.product_name}
                            </h3>

                            <p className="mt-2 text-lg font-bold text-p-500">
                                {product.price.toLocaleString()}₫
                            </p>

                            <button className="w-full py-2 mt-3 text-sm font-semibold text-white transition bg-p-500 rounded-xl hover:bg-p-600">
                                <Link onClick={() => detailPart(product)}>Chi tiết sản phẩm</Link>
                            </button>
                        </div>
                    </div>
                ))}
            </div>


            <button
                onClick={prevSlide}
                className="absolute top-[50%] left-0 -translate-y-1/2 bg-n-50 shadow-md 
                           p-2 rounded-full w-10 hover:bg-p-500 hover:text-n-50 transition hidden md:block"
            >
                ‹
            </button>

            <button
                onClick={nextSlide}
                className="absolute top-[50%] right-0 -translate-y-1/2  bg-n-50 shadow-md 
                           p-2 rounded-full w-10 hover:bg-p-500 hover:text-n-50 transition hidden md:block"
            >
                ›
            </button>

        </div>
    );
}
