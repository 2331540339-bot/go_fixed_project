import {Link} from 'react-router-dom';
import { serviceAPI } from '../app/api';
import { useEffect, useState } from 'react';
function Services(){
    const [services, setServices] = useState([]);
    const [err, setErr] = useState(null);
    const [loading, setLoading] = useState(true);
    const [count, setCount] = useState(1);
    const [serviceID, setServiceID] = useState("")
    const handleCount = (count) => {
        if(count<= services.length){
            setCount(count + 1);
        }
    }

    const loadServices = async(e) => {
        serviceAPI()
        .then((res) => {
            setServices(res);
        })
        .catch((err) => {
            console.log(err);
            setErr(err);
        })
        .finally(() => setLoading(false))
    }
    
    useEffect(() => {
        loadServices();
    }, []);

    if(err){
        return <p className="text-center text-n-700">{err}</p>;
    }

    if(loading){
        return <p className="text-center text-n-700">Đang tải dịch vụ...</p>;
    }


    return(
        
        <section className="w-100vh bg-n-700">
            <h1 className="flex items-center justify-center w-full text-5xl font-extrabold font-grostek bg-p-500 text-n-50 h-[10%]">Services</h1>

            <div className="grid grid-cols-1 gap-10 px-10 md:grid-cols-3 py-15">{services.map((service) => (
                <div key={service._id} className={`w-full px-8 py-4 bg-n-50 rounded-4xl hover:-translate-y-2`}>
                    <h1 className="mb-2 text-4xl font-extrabold font-grostek text-p-500">{service.name}</h1>
                    <p className="w-[80%] text-md font-light font-grostek text-n-700 mb-2">Dắt bộ hết hơi, vì cái bánh xì hết hơi. Sử dụng dịch vụ GoFix bơm ngay OXI  </p>
                    <div className="flex items-center justify-between">
                        <h2 className="text-2xl font-extrabold font-grostek text-n-700">Chỉ từ <span className="text-p-500">{service.base_price}</span></h2>
                        <Link to={service._id} state={{service}} className="flex items-center justify-around px-2 py-1 rounded-full cursor-pointer bg-p-500 hover:bg-p-100"
                        >
                            <h2 className="text-xl font-extrabold font-grostek text-n-50 hover:text-p-500">Đặt Ngay</h2>
                            <h1 className="font-extrabold text-center rounded-4xl bg-n-50"></h1>
                        </Link>
                    </div>  

                </div>
            ))}        
            </div>
        </section>
    )
}export default Services


