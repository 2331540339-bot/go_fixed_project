import { Link } from "react-router-dom"
import {productAPI_showall} from '../app/api';
import banner_advertise from "../assets/banner_advertiser.png"
import banner_advertise2 from "../assets/banner_advertiser2.png"
import banner_advertise3 from "../assets/banner_advertiser3.png"
import BestSellerSlider from "../components/BestSellerSlider"
import CatalogSlider from "../components/CatalogSlider";
import { useState } from "react";
import { useEffect } from "react";
function GenuinePart(){
    const [products, setProducts] = useState([]);
    const [catalogs, setCatalogs] = useState([]);
    const [count, setCount] = useState(0);
    const loadAPIs  = async(e) => {
        productAPI_showall()
        .then((res) => {
            setProducts(res);
        })
        .catch((err) => console.log(err))

    }

    useEffect(() => {
        loadAPIs()
    },[])

    useEffect(() => {
        console.log(products)
    },[products])

    
    return(
        <section className="w-screen px-10 py-5">
            <div id="catalog">
                <CatalogSlider/>
            </div>
            <div className="flex justify-center py-4">
                <div id="adsvertiser" className="w-[20%] h-150 overflow-clip">
                    <img src={banner_advertise} className="object-contain w-full h-full" />
                </div>
                
                <div id="container" className="w-[80%]">
                    <div id="header" className="flex items-center mb-4 h-75">
                        <div id="another-catalog" className="h-full px-4 py-2 border-4 border-p-500 rounded-2xl w-[20%]">
                            <h2 className="text-xl font-semibold font-grostek" >Danh mục khác:</h2>
                            <p><Link className="font-light font-grostek">● Đồ chơi</Link></p>
                            <p><Link className="font-light font-grostek">● Đồ chơi</Link></p>
                            <p><Link className="font-light font-grostek">● Đồ chơi</Link></p>
                            <p><Link className="font-light font-grostek">● Đồ chơi</Link></p>
                        </div>

                        <div id="adsvertiser" className="h-full overflow-clip w-[50%]">
                            <img src={banner_advertise2} className="object-cover w-full h-full px-2" />
                        </div>

                        <div id="adsvertiser" className="h-full overflow-clip w-[30%]">
                            <img src={banner_advertise3} className="object-cover w-full h-full" />
                        </div>
                    </div>
                    <div id="hot-product" className="my-5">
                        <h2 className="text-2xl font-bold cursor-pointer font-grostek hover:text-p-500" >Xem tất cả sản phẩm →</h2>
                    </div>
                    <div id="best-seller"  className="my-5">
                        <h2 className="my-3 text-2xl font-bold font-grostek" >Danh mục hàng bán chạy</h2>

                        <BestSellerSlider products={products}/>

                    </div>
                    <div id="new-arrival" className="my-5">
                        <h2 className="my-3 text-2xl font-bold font-grostek" >Danh mục hàng mới cập bến</h2>
                        <div className="w-full max-w-[240px] bg-n-50 rounded-2xl shadow-md overflow-hidden 
                                        hover:shadow-lg transition-shadow duration-300 cursor-pointer 
                                        font-grostek group">

                            <div className="relative w-full h-40 bg-n-100">
                                <img 
                                    src="https://shop2banh.vn/images/thumbs/2024/07/phuoc-ohlins-ho-328-cho-honda-lead-2330-slide-products-669a178f0451e.jpeg"
                                    alt="product"
                                    className="object-contain w-full h-full p-2 transition duration-300 group-hover:scale-105"
                                />

                                <span className="absolute px-2 py-1 text-xs text-white rounded-md top-2 left-2 bg-p-500">
                                    Mới cập bến
                                </span>
                            </div>

                            <div className="p-3">
                                <h3 className="text-sm font-semibold text-n-700 line-clamp-2">
                                    Phuộc Ohlins HO-328 Cao Cấp Cho Dòng Xe Tay Ga
                                </h3>

                                <p className="mt-2 text-lg font-bold text-p-500">
                                    7.500.000₫
                                </p>

                                <button 
                                    className="w-full py-2 mt-3 text-sm font-semibold text-white transition-all duration-300 bg-p-500 rounded-xl hover:bg-p-600">
                                    Xem chi tiết
                                </button>
                            </div>
                        </div>

                    </div>

        
                </div>
            </div>
        </section>
    )
}; export default GenuinePart