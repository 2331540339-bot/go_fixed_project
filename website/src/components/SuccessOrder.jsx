import { useLocation, useNavigate } from "react-router-dom";

const formatCurrency = (value) =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    maximumFractionDigits: 0,
  }).format(value || 0);

export default function SuccessOrder({order}) {
  const navigate = useNavigate();
  console.log(order)
  const orderId = order._id;
  const total = order.total_price;

  return (
    <div className="flex items-center justify-center min-h-screen px-4 py-10 bg-gradient-to-b from-n-50 via-white to-n-50">
      <div className="w-full max-w-3xl overflow-hidden bg-white border shadow-xl rounded-3xl border-n-100">

        <div className="relative h-32 bg-gradient-to-r from-p-700 via-p-500 to-p-300 ">
          <div className="absolute inset-0 opacity-30 bg-[radial-gradient(circle_at_20%_20%,rgba(255,255,255,0.5),transparent_35%),radial-gradient(circle_at_80%_0%,rgba(255,255,255,0.45),transparent_30%)]" />

          <div className="relative flex items-center h-full gap-3 px-8">
            <div className="flex items-center justify-center text-2xl font-bold text-green-600 h-14 w-14 rounded-2xl bg-white/90">
              📦
            </div>
            <div className="text-white">
              <p className="text-sm tracking-widest uppercase opacity-80">
                Đặt hàng thành công
              </p>
              <h1 className="text-2xl font-semibold">Chờ giao hàng</h1>
            </div>
          </div>
        </div>

        <div className="p-8 space-y-6">

          <p className="text-base leading-relaxed text-n-700">
            Cảm ơn bạn đã đặt hàng tại <b>FastFood</b>. Đơn hàng của bạn đang được xác nhận và chuẩn bị để giao.
          </p>

          <div className="grid gap-4 sm:grid-cols-3 ">
            <div className="p-4 border rounded-2xl bg-n-50 border-n-100 overflow-clip">
              <p className="text-xs uppercase tracking-[0.08em] text-n-500">
                Mã đơn hàng
              </p>
              <p className="mt-1 text-lg font-semibold text-n-800">
                {orderId || "Không rõ"}
              </p>
            </div>

            <div className="p-4 border rounded-2xl bg-n-50 border-n-100">
              <p className="text-xs uppercase tracking-[0.08em] text-n-500">
                Thời gian
              </p>
              <p className="mt-1 text-lg font-semibold text-n-800">
                {new Date().toLocaleString("vi-VN")}
              </p>
            </div>

            <div className="p-4 border rounded-2xl bg-n-50 border-n-100">
              <p className="text-xs uppercase tracking-[0.08em] text-n-500">
                Tổng tiền
              </p>
              <p className="mt-1 text-lg font-semibold text-n-800">
                {formatCurrency(total || 0)}
              </p>
            </div>
          </div>

          <div className="p-4 border border-green-200 border-dashed rounded-2xl bg-green-50/50">
            <p className="mb-1 text-sm font-semibold text-p-500">
              Thông tin giao hàng
            </p>
            <p className="text-sm text-n-700">
              Đơn hàng của bạn sẽ được giao trong thời gian sớm nhất.  
              Vui lòng chuẩn bị thanh toán khi nhận hàng (COD).
            </p>
          </div>

          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex flex-wrap gap-3">
              <button
                onClick={() => navigate("/")}
                className="px-5 py-3 font-semibold transition border rounded-xl border-n-200 text-n-700 hover:border-p-300 hover:text-p-600"
              >
                Quay về trang chủ
              </button>

              <button
                onClick={() => navigate("/order")}
                className="px-5 py-3 font-semibold text-white transition shadow-md bg-p-500 rounded-xl hover:bg-p-600"
              >
                Xem đơn hàng
              </button>
            </div>

            <button
              onClick={() => navigate(0)}
              className="text-sm font-medium text-p-600 hover:text-p-700"
            >
              Làm mới trang
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
