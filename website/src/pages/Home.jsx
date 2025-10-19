import intro_img from '../assets/intro pic1.png'
function Home(){
    return(
        <>
            <section className="h-[calc(screen-98px)] w-full flex items-center justify-center md:px-10 gap-x-70    ">

                <div className="flex flex-col gap-5">
                    <h2 className="text-xm font-grostek font-medium text-n-800 uppercase tracking-wider mb-2">Không ai bị <span className="text-p-500">bỏ rơi</span> giữa dòng đời </h2>
                    <h1 className="text-8xl font-grostek font-medium text-n-800">GO FIX</h1>
                    <p className="max-w-xl text-xl font-grostek font-light text-n-800">“Chỉ cần một chạm, mọi sự cố trên đường sẽ được giải quyết. Ứng dụng kết nối bạn với thợ sửa xe gần nhất, hỗ trợ tận nơi từ vá lốp, tiếp xăng cho đến cứu hộ vận chuyển. Nhanh chóng – Minh bạch – An toàn trên mọi hành trình.”</p>
                     <a href='#' className="bg-p-500 w-50 text-n-50 rounded-md px-8 py-4 font-grostek font-extrabold flex items-center justify-center tracking-wider hover:bg-n-100 hover:text-n-700 hover:border border-p-500 ">Rescue Now <span>&rarr;</span> </a>

                </div>

                <div className="flex flex-col">
                    <img src={intro_img}></img>
                </div>
            </section>
        </>
    )
} export default Home