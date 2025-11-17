import icon_not_accepted from "../assets/icon_not_accepted.gif"
function Not_AcceptedRescue(){
    return(
        <>
            <div className="w-full h-[calc(100vh-120px)] bg-black flex flex-col justify-center items-center overflow-clip">
                <h1 className="text-4xl font-bold text-n-50 font-grostek">Hiện tại các thợ chưa thể nhận đơn của bạn, vui lòng thử lại sau vài phút ...</h1>
                <img src={icon_not_accepted} className="rounded-4xl"></img>
            </div>
        </>
    )
}; export default Not_AcceptedRescue    