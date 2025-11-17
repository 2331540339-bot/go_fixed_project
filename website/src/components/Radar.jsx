import { useEffect } from "react";

function Radar(){
    useEffect(() => {
        const beam = document.getElementById("radar-beam");
        let angle = 0;
        
        const rotate = () => {
            angle += 2;
            beam.style.transform = `rotate(${angle}deg)`;
            requestAnimationFrame(rotate);
        }

        rotate(); 
    }, [])
    return(
        <div className="w-full h-[calc(100vh-120px)] bg-black flex flex-col justify-center items-center">
            <h1 className="w-full h-[10%] text-5xl font-bold flex justify-center text-n-50 font-grostek items-center">Đang Tìm Kiếm Thợ Gần Bạn Nhất</h1>
            <div className="flex items-center justify-center w-full mt-10 ">
                <div className="relative flex items-center justify-center overflow-hidden border-4 rounded-full border-p-500 w-80 h-80">
                    <div className="absolute w-64 h-64 border-2 rounded-full border-p-500"></div>
                    <div className="absolute border-2 rounded-full w-44 h-44 border-p-500"></div>
                    <div className="absolute w-24 h-24 border-2 rounded-full border-p-500"></div>

                    <div className="absolute w-full h-full" id="radar-beam" style={{background: "conic-gradient(from 0deg, rgba(255, 0, 0, 0.4), rgba(255,0,0,0) 40%)",}}>
                        
                    </div>
                </div>
            </div>
            <p className="w-full h-[10%] text-md font-light flex justify-center text-n-50 font-grostek items-center">Yên tâm nhé, GOFIX sẽ nhanh chóng tới và cứu rỗi cuộc đời bạn !</p>
        </div>
    );
}export default Radar