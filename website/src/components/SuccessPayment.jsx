import { useMemo } from "react";
import { useLocation, useNavigate } from "react-router-dom";

const formatCurrency = (value) =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    maximumFractionDigits: 0,
  }).format(value || 0);

export default function SuccessPayment() {
  const location = useLocation();
  const navigate = useNavigate();

  const params = useMemo(() => new URLSearchParams(location.search), [location]);
  const responseCode = params.get("vnp_ResponseCode");
  const amount = Number(params.get("vnp_Amount") || 0) / 100;
  const orderId = params.get("vnp_TxnRef") || params.get("orderId");

  const isSuccess = responseCode === "00";
  const statusText = isSuccess
    ? "Thanh toán thành công"
    : "Thanh toán chưa hoàn tất";

  const detailMessage = (() => {
    if (isSuccess) return "Cảm ơn bạn đã tin tưởng Go Fixed. Đơn hàng của bạn đang được xử lý.";
    if (responseCode === "24") return "Bạn đã hủy giao dịch. Nếu cần, hãy thử thanh toán lại.";
    if (responseCode === "97") return "Sai checksum hoặc tham số không hợp lệ.";
    if (responseCode) return `Mã phản hồi VNPAY: ${responseCode}`;
    return "Không tìm thấy thông tin giao dịch.";
  })();

  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-10 bg-gradient-to-b from-p-50 via-white to-n-50">
      <div className="w-full max-w-3xl bg-white rounded-3xl shadow-xl border border-n-100 overflow-hidden">
        <div className="relative h-32 bg-gradient-to-r from-p-500 via-p-400 to-p-600">
          <div className="absolute inset-0 opacity-40 bg-[radial-gradient(circle_at_20%_20%,rgba(255,255,255,0.4),transparent_35%),radial-gradient(circle_at_80%_0%,rgba(255,255,255,0.35),transparent_30%)]" />
          <div className="relative flex items-center gap-3 px-8 h-full">
            <div
              className={`h-14 w-14 rounded-2xl flex items-center justify-center text-2xl font-bold ${
                isSuccess ? "bg-white/90 text-p-600" : "bg-white/80 text-amber-600"
              }`}
            >
              {isSuccess ? "✓" : "!"}
            </div>
            <div className="text-white">
              <p className="text-sm uppercase tracking-widest opacity-80">
                VNPay
              </p>
              <h1 className="text-2xl font-semibold">{statusText}</h1>
            </div>
          </div>
        </div>

        <div className="p-8 space-y-6">
          <p className="text-base text-n-700 leading-relaxed">{detailMessage}</p>

          <div className="grid gap-4 sm:grid-cols-3">
            <div className="p-4 rounded-2xl bg-n-50 border border-n-100">
              <p className="text-xs uppercase tracking-[0.08em] text-n-500">
                Mã đơn hàng
              </p>
              <p className="mt-1 text-lg font-semibold text-n-800">
                {orderId || "Không rõ"}
              </p>
            </div>
            <div className="p-4 rounded-2xl bg-n-50 border border-n-100">
              <p className="text-xs uppercase tracking-[0.08em] text-n-500">
                Số tiền
              </p>
              <p className="mt-1 text-lg font-semibold text-p-600">
                {amount > 0 ? formatCurrency(amount) : "—"}
              </p>
            </div>
            <div className="p-4 rounded-2xl bg-n-50 border border-n-100">
              <p className="text-xs uppercase tracking-[0.08em] text-n-500">
                Thời gian
              </p>
              <p className="mt-1 text-lg font-semibold text-n-800">
                {new Date().toLocaleString("vi-VN")}
              </p>
            </div>
          </div>

          <div className="p-4 rounded-2xl border border-dashed border-p-200 bg-p-50/50">
            <p className="text-sm text-p-800 font-semibold mb-1">
              Lưu ý về đơn hàng
            </p>
            <p className="text-sm text-n-700">
              Nếu bạn đã thanh toán thành công nhưng chưa thấy cập nhật, vui lòng
              giữ trang này mở và kiểm tra email / lịch sử đơn hàng sau vài phút.
            </p>
          </div>

          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex flex-wrap gap-3">
              <button
                onClick={() => navigate("/")}
                className="px-5 py-3 rounded-xl border border-n-200 text-n-700 font-semibold hover:border-p-300 hover:text-p-600 transition"
              >
                Quay về trang chủ
              </button>
              <button
                onClick={() => navigate("/order")}
                className="px-5 py-3 rounded-xl bg-p-500 text-white font-semibold shadow-md hover:bg-p-600 transition"
              >
                Xem đơn hàng
              </button>
            </div>

            <button
              onClick={() => navigate(0)}
              className="text-sm font-medium text-p-600 hover:text-p-700"
            >
              Làm mới trạng thái
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
