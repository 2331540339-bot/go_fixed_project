import intro_img from '../assets/intro pic1.png'
function Home(){
    return(
        <>
           <section className="h-[calc(100vh-120px)] max-h-[1100px] w-100vh md:mx-10  flex md:items-center ">

                    <div className=" flex z-11 md:w-[calc(100%-50%)] md:justify-end ">
                        <div className="flex flex-col items-center gap-5 shadow-xl md:items-start md:mr-10 md:px-5 md:py-3 rounded-2xl md:hover:translate-y-1 ">
                            <h2 className="mb-2 font-medium tracking-wider uppercase text-xm font-grostek text-n-800">Không ai bị <span className="text-p-500">bỏ rơi</span> giữa dòng đời </h2>
                            <h1 className="font-medium tracking-wider text-8xl font-grostek text-n-800">GO FIX</h1>
                            <p className="max-w-xl text-xl font-light text-center font-grostek text-n-800 md:text-start ">“Chỉ cần một chạm, mọi sự cố trên đường sẽ được giải quyết. Ứng dụng kết nối bạn với thợ sửa xe gần nhất, hỗ trợ tận nơi từ vá lốp, tiếp xăng cho đến cứu hộ vận chuyển. Nhanh chóng – Minh bạch – An toàn trên mọi hành trình.”</p>
                            <a href='#' className="flex items-center justify-center px-8 py-4 font-extrabold tracking-wider rounded-md bg-p-500 w-50 text-n-50 font-grostek hover:bg-n-100 hover:text-n-700 hover:border border-p-500 ">Rescue Now <span>&rarr;</span> </a>
                        </div>
                    </div>

                    <div className="absolute bottom-0 right-0 z-10 translate-y-1 xl:bottom-1/2 xl:translate-y-1/2 xl:left-1/2 xl:ml-10 ">
                        <img src={intro_img} className='md:hover:translate-y-1'></img>
                    </div>
            </section>
        </>
    )
} export default Home

 