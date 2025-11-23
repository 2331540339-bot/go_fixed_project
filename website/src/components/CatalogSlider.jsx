import { useEffect, useRef, useState } from "react";
import { catalogAPI_showall } from "../app/api";
function CatalogSlider(){
    const [catalogs, setCatalogs] = useState([]);
    const sliderRef = useRef(null)
    const loadAPI = () => {
        catalogAPI_showall()
        .then((res) => setCatalogs(res))
        .catch((err) => console.log(err))
    }

    useEffect(() => {
        loadAPI()
    }, [])


    const prevSlide = () =>{
        sliderRef.current.scrollBy({left: -240, behavior: "smooth"});
    }

    const nextSlide = () => {
        sliderRef.current.scrollBy({left: 240, behavior: "smooth"});
    }

    return(
        <>
            <div className="relative w-full">
                <div
                    ref={sliderRef}
                    className="flex gap-4 overflow-x-auto scroll-smooth no-scrollbar"
                >
                    {catalogs.map((catalog) => (
                        <div  key={catalog._id} className="w-[240px] flex-shrink-0 bg-n-50 rounded-2xl shadow-md overflow-hidden 
                                   hover:shadow-lg transition duration-300 cursor-pointer group font-grostek items-center">
                             <p className="w-full text-center hover:bg-p-500 hover:text-n-50">{catalog.catalog_name}</p>
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
        </>
    )

}; export default CatalogSlider