import UserMap from "./UserMap"
function AcceptedRescue(){
    return(
        <>
        <section className="flex flex-col w-full min-h-screen bg-n-800 text-n-50 font-grostek md:flex-row">
      {/* MAP SECTION */}
      <div className="relative flex-1 h-[60vh] md:h-screen bg-n-700 rounded-b-3xl md:rounded-none md:rounded-l-3xl overflow-hidden">
        {/* Map placeholder */}
        <div className="absolute inset-0 flex items-center justify-center text-xl text-n-200">
          <UserMap/>
        </div>
      </div>

      {/* INFO PANEL */}
      <div className="flex flex-col justify-between md:w-[35%] w-full bg-n-700 px-8 py-6 rounded-t-3xl md:rounded-none md:rounded-r-3xl">
        {/* Header */}
        <div className="mb-6">
          <h1 className="text-4xl font-extrabold tracking-wider text-p-500">
            Rescue Accepted
          </h1>
          <p className="text-lg text-n-200">Thợ đang trên đường đến vị trí của bạn</p>
        </div>

        {/* Mechanic info */}
        <div className="p-5 mb-6 bg-n-800 rounded-2xl">
          <h2 className="mb-4 text-2xl font-bold text-p-500">Thông tin thợ</h2>
          <div className="flex items-center gap-4">
            <img
            //   src={mechanicImg}
              alt="Mechanic"
              className="object-cover w-20 h-20 border-2 rounded-full border-p-500"
            />
            <div>
              <h3 className="text-xl font-bold">Trần Minh Khôi</h3>
              <p className="text-sm text-n-200">Cách bạn ~2.3 km</p>
              <p className="text-sm text-n-200">📞 0901 234 567</p>
            </div>
          </div>
        </div>

        {/* Vehicle info */}
        <div className="p-5 mb-6 bg-n-800 rounded-2xl">
          <h2 className="mb-4 text-2xl font-bold text-p-500">Tình trạng xe</h2>
          <div className="flex items-center gap-4">
            <img
            //   src={vehicleImg}
              alt="Vehicle"
              className="object-cover w-20 h-20 border rounded-xl border-n-600"
            />
            <div>
              <p className="text-lg font-medium">Vá lốp trước bị thủng</p>
              <p className="text-sm text-n-200">Mô tả: Lốp trước xì hơi, không di chuyển được</p>
              <p className="mt-1 text-sm font-bold text-p-500">Trạng thái: Đang di chuyển đến</p>
            </div>
          </div>
        </div>

        {/* Action button */}
        <div className="flex justify-end">
          <button className="px-6 py-3 font-extrabold transition bg-p-500 rounded-2xl text-n-50 hover:bg-p-300">
            Theo dõi lộ trình →
          </button>
        </div>
      </div>
    </section>
    </>
    )
}; export default AcceptedRescue