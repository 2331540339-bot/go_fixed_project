import intro_img from '../assets/intro pic1.png'
function Home(){
    return(
        <>
            <div className="h-[calc(100vh-120px)] w-full bg-white relative">
                {/* Pink Glow Background */}
                <div
                    className="absolute inset-0 z-0"
                    style={{
                    backgroundImage: `
                        radial-gradient(125% 125% at 50% 10%, #ffffff 40%, #BD212F 100%)
                    `,
                    backgroundSize: "100% 100%",
                    }}
                />
                <section className="h-[calc(100vh-240px)] max-h-[1100px] w-100vh md:mx-10  flex md:items-center ">

                    <div className=" flex z-11 md:w-[calc(100%-50%)] md:justify-end  ">
                        <div className=" flex flex-col gap-5 items-center md:items-start md:mr-10 ">
                            <h2 className="text-xm  font-grostek font-medium text-n-800 uppercase tracking-wider mb-2">Không ai bị <span className="text-p-500">bỏ rơi</span> giữa dòng đời </h2>
                            <h1 className="text-8xl font-grostek font-medium text-n-800 tracking-wider">GO FIX</h1>
                            <p className="max-w-xl text-xl font-grostek font-light text-n-800 text-center md:text-start ">“Chỉ cần một chạm, mọi sự cố trên đường sẽ được giải quyết. Ứng dụng kết nối bạn với thợ sửa xe gần nhất, hỗ trợ tận nơi từ vá lốp, tiếp xăng cho đến cứu hộ vận chuyển. Nhanh chóng – Minh bạch – An toàn trên mọi hành trình.”</p>
                            <a href='#' className="bg-p-500 w-50 text-n-50 rounded-md px-8 py-4 font-grostek font-extrabold flex items-center justify-center tracking-wider hover:bg-n-100 hover:text-n-700 hover:border border-p-500 ">Rescue Now <span>&rarr;</span> </a>
                        </div>
                    </div>

                    <div className="absolute bottom-0 right-0 z-10 xl:bottom-1/2 xl:translate-y-1/2 xl:left-1/2 xl:ml-10">
                        <img src={intro_img}></img>
                    </div>
                </section>
            </div>
            
        </>
    )
} export default Home

 