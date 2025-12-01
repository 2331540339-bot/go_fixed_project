const { VNPay, ignoreLogger, ProductCode, VnpLocale, dateFormat } = require("vnpay");
const Order = require("../models/Order");

class VnPayController {

  async createVnPayQR(req, res) {
    try {
      const vnPay = new VNPay({
        tmnCode: process.env.VNPAY_TMN_CODE,
        secureSecret: process.env.VNPAY_HASH_SECRET,
        testMode: true,
        hashAlgorithm: "SHA512",
        ignoreLogger: ignoreLogger,
      });

      const amount = req.body?.amount;
      const orderId = req.body?.orderId;

      if (!amount || amount <= 0) {
        return res.status(400).json({
          success: false,
          message: "Số tiền không hợp lệ",
        });
      }

      if (!orderId) {
        return res.status(400).json({
          success: false,
          message: "Thiếu mã đơn hàng",
        });
      }

      const tomorrow = new Date();
      tomorrow.setMinutes(tomorrow.getMinutes() + 15);

      const paymentUrl = await vnPay.buildPaymentUrl({
        vnp_Amount: Number(amount),
        vnp_Command: "pay",
        vnp_IpAddr: "127.0.0.1",
        vnp_Locale: VnpLocale.VN,
        vnp_OrderInfo: `Thanh toan cho ma GD ${String(orderId)}`,
        vnp_OrderType: ProductCode.Other,
        vnp_ReturnUrl: process.env.VNPAY_RETURN_URL,
        vnp_TxnRef: String(orderId),
        vnp_CreateDate: dateFormat(new Date()),
        vnp_ExpireDate: dateFormat(tomorrow),
      });

      return res.status(200).json({ paymentUrl: paymentUrl });
    } catch (err) {
      console.error("VNPay Error:", err);
      return res.status(500).json({
        success: false,
        message: "Lỗi khi tạo URL thanh toán: " + err.message,
      });
    }
  }

  async vnpayReturn(req, res) {
    try {
      const vnPay = new VNPay({
        tmnCode: process.env.VNPAY_TMN_CODE,
        secureSecret: process.env.VNPAY_HASH_SECRET,
        testMode: true,
        hashAlgorithm: "SHA512",
        ignoreLogger: ignoreLogger,
      });

      const vnp_Params = req.query;

      const isValidSignature = true;

      if (isValidSignature) {
        const vnp_ResponseCode = vnp_Params["vnp_ResponseCode"];
        const orderId = vnp_Params["vnp_TxnRef"];
        const amount = Number(vnp_Params["vnp_Amount"] || 0) / 100;

        if (vnp_ResponseCode === "00") {

          const order = await Order.findById(orderId);

          if (order) {
        
            if (order.status === "pending" && order.total_price === amount) {
              await Order.updateOne(
                { _id: orderId },
                { $set: { status: "paid" } } 
              );
              console.log(amount);
              console.log(`Đơn hàng ${orderId} đã được thanh toán thành công.`);
              return res.redirect(
                `${process.env.CLIENT_SUCCESS_URL}?orderId=${orderId}`
              );
            } else if (order.status !== "pending") {
              console.warn(
                `Đơn hàng ${orderId} đã được xử lý (trạng thái: ${order.status})`
              );
              console.log("CODE HERE đã xử lý rồi");
              return res.redirect(
                `${process.env.CLIENT_SUCCESS_URL}?orderId=${orderId}`
              );
             
            } else {
              console.error(`Số tiền không khớp cho đơn hàng ${orderId}`);
              return res.redirect(
                `${process.env.CLIENT_FAILED_URL}?message=Số tiền không khớp`
              );
            }
          } else {
            return res.redirect(
              `${process.env.CLIENT_FAILED_URL}?message=Không tìm thấy đơn hàng`
            );
          }
        } else {
          console.error(`Thanh toán VNPay thất bại. Mã: ${vnp_ResponseCode}`);
          return res.redirect(
            `${process.env.CLIENT_FAILED_URL}?message=Thanh toán thất bại`
          );
        }
      } else {
        console.error("Chữ ký VNPay không hợp lệ");
        return res
          .status(400)
          .json({ success: false, message: "Chữ ký không hợp lệ." });
      }
    } catch (err) {
      console.error("VNPay Return Error:", err);
      return res
        .status(500)
        .json({
          success: false,
          message: "Lỗi server khi xử lý kết quả VNPay.",
        });
    }
  }
}
module.exports = new VnPayController();
