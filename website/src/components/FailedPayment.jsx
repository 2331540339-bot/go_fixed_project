import { useMemo } from "react";
import { useLocation, useNavigate } from "react-router-dom";

const formatCurrency = (value) =>
  new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    maximumFractionDigits: 0,
  }).format(value || 0);

export default function FailedPayment() {
  const location = useLocation();
  const navigate = useNavigate();

  const params = useMemo(() => new URLSearchParams(location.search), [location]);
  const responseCode = params.get("vnp_ResponseCode");
  const amount = Number(params.get("vnp_Amount") || 0) / 100;
  const orderId = params.get("vnp_TxnRef") || params.get("orderId");

  const statusText = "Thanh toán thất bại";

  const detailMessage = (() => {
    if (responseCode === "24") {
      return "Bạn đã hủy giao dịch. Nếu vẫn muốn tiếp tục, hãy thử thanh toán lại.";
    }
    if (responseCode === "97") {
      return "Giao dịch không hợp lệ (sai checksum hoặc tham số). Vui lòng thử lại hoặc liên hệ hỗ trợ.";
    }
    if (responseCode) {
      return `Thanh toán không thành công. Mã phản hồi VNPAY: ${responseCode}. Vui lòng thử lại hoặc chọn phương thức khác.`;
    }
    return "Không tìm thấy thông tin giao dịch. Có thể phiên thanh toán đã hết hạn hoặc xảy ra lỗi trong quá trình xử lý.";
  })();

  const suggestionText =
    "Đừng lo, đơn hàng của bạn chưa được trừ tiền. Bạn có thể thử thanh toán lại hoặc quay về trang chủ để đặt lại nếu cần.";

  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-10 bg-gradient-to-b from-rose-50 via-white to-n-50">
      <div className="w-full max-w-3xl bg-white rounded-3xl shadow-xl border border-n-100 overflow-hidden">
        {/* Header */}
        <div className="relative h-32 bg-gradient-to-r from-rose-600 via-red-500 to-rose-700">
          <div className="absolute inset-0 opacity-40 bg-[radial-gradient(circle_at_20%_20%,rgba(255,255,255,0.35),transparent_35%),radial-gradient(circle_at_80%_0%,rgba(255,255,255,0.3),transparent_30%)]" />
          <div className="relative flex items-center gap-3 px-8 h-full">
            <div className="h-14 w-14 rounded-2xl flex items-center justify-center text-2xl font-bold bg-white/90 text-rose-600">
              ✕
            </div>
            <div className="text-white">
              <p className="text-sm uppercase tracking-widest opacity-80">
                VNPay
              </p>
              <h1 className="text-2xl font-semibold">{statusText}</h1>
            </div>
          </div>
        </div>

        {/* Body */}
        <div className="p-8 space-y-6">
          <p className="text-base text-n-700 leading-relaxed">
            {detailMessage}
          </p>

          {/* Thông tin giao dịch */}
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
              <p className="mt-1 text-lg font-semibold text-rose-600">
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

          {/* Cảnh báo & gợi ý */}
          <div className="p-4 rounded-2xl border border-dashed border-rose-200 bg-rose-50/60">
            <p className="text-sm text-rose-800 font-semibold mb-1">
              Giao dịch chưa được ghi nhận
            </p>
            <p className="text-sm text-n-700">{suggestionText}</p>
          </div>

          {/* Action buttons */}
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex flex-wrap gap-3">
              <button
                onClick={() => navigate(-1)}
                className="px-5 py-3 rounded-xl bg-rose-600 text-white font-semibold shadow-md hover:bg-rose-700 transition"
              >
                Thử thanh toán lại
              </button>
              <button
                onClick={() => navigate("/")}
                className="px-5 py-3 rounded-xl border border-n-200 text-n-700 font-semibold hover:border-rose-300 hover:text-rose-600 transition"
              >
                Quay về trang chủ
              </button>
            </div>

            <button
              onClick={() => navigate("/order")}
              className="text-sm font-medium text-rose-600 hover:text-rose-700"
            >
              Xem lịch sử / tình trạng đơn hàng
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
