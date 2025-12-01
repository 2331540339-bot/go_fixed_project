<<<<<<< HEAD

const {VNPay, ignoreLogger, ProductCode, VnpLocale, dateFormat} = require('vnpay');

const createVnPayQR = async (req, res) => {
    try {
        // 1. Khởi tạo VNPay
        const vnpay = new VNPay({
            tmnCode:"M1QW9H2H",
            secureSecret:"3ZX13DFLFS3EZAO2BQRZLIB7KZBPKAMM",
            testMode: true,
            hashAlgorithm: 'SHA512',
            logger: ignoreLogger,
        });

        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);

        const vnp_Params = await vnpay.buildPaymentUrl({
            vnp_Amount: 50000,// Thường phải nhân với 100 (đơn vị: xu)
            vnp_IpAddr: '127.0.0.1',
            vnp_TxnRef: "1234561" ,
            vnp_OrderInfo: "1234561",
            vnp_Command: 'pay',
            vnp_CurrCode: 'VND',
            vnp_OrderType: ProductCode.Other,
            vnp_ReturnUrl: 'http://localhost:8000/payment/check-payment-vnpay',
            vnp_Locale: VnpLocale.VN,
            vnp_CreateDate: dateFormat(new Date()),
            vnp_ExpireDate: dateFormat(tomorrow),
        });
        return res.status(201).json(vnp_Params);
    } catch (err) {
        // 5. Xử lý lỗi
        console.error("Lỗi khi tạo QR VNPAY:", err);
        res.status(500).json({ code: '99', message: err.message });
    }
};

// Xuất (export) hàm này để sử dụng trong tệp định tuyến (route)
module.exports = {
    createVnPayQR
};
=======
// const crypto = require("crypto");
// const qs = require("qs");
// const moment = require("moment");

// const VNP_TMN_CODE = "RZEQ3COE";
// const VNP_HASH_SECRET = "VJKE6FCM3H1O92P3T89SHD6F5O381QOD";
// const VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
// const RETURN_URL = "http://localhost:8000/payment/check-payment-vnpay";

// // SORT PARAM
// function sortObject(obj) {
//     const sorted = {};
//     const keys = Object.keys(obj).sort();  // chuẩn bắt buộc A-Z
//     for (const key of keys) {
//         sorted[key] = obj[key];
//     }
//     return sorted;
// }

// // FIX IP
// function getClientIp(req) {
//     let ip =
//         req.headers["x-forwarded-for"] ||
//         req.connection?.remoteAddress ||
//         req.socket?.remoteAddress ||
//         req.connection?.socket?.remoteAddress ||
//         "127.0.0.1";

//     if (ip === "::1") ip = "127.0.0.1";
//     if (ip.startsWith("::ffff:")) ip = ip.replace("::ffff:", "");

//     return ip;
// }

// class VnPayController {

//     createQR(req, res) {
//         try {
//             const ipAddr = getClientIp(req);
//             const date = moment().format("YYYYMMDDHHmmss");
//             const expire = moment().add(15, "minutes").format("YYYYMMDDHHmmss");

//             const amount = Number(req.body.amount);
//             const orderId = String(req.body.orderId);

//             let vnp_Params = {
//                 vnp_Amount: String(amount * 100),
//                 vnp_Command: "pay",
//                 vnp_CreateDate: date,
//                 vnp_CurrCode: "VND",
//                 vnp_ExpireDate: expire,
//                 vnp_IpAddr: ipAddr,
//                 vnp_Locale: "vn",
//                 vnp_OrderInfo: `Thanh toan cho ma GD ${orderId}`,
//                 vnp_OrderType: "other",
//                 vnp_ReturnUrl: RETURN_URL,
//                 vnp_TmnCode: VNP_TMN_CODE,
//                 vnp_TxnRef: orderId,
//                 vnp_Version: "2.1.0",
//             };

//             // Sort theo chuẩn VNPAY
//             vnp_Params = sortObject(vnp_Params);

//             // SIGN DATA
//             const signData = qs.stringify(vnp_Params, { encode: false });
//             const hmac = crypto.createHmac("sha512", VNP_HASH_SECRET);
//             const secureHash = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

//             vnp_Params["vnp_SecureHash"] = secureHash;

//             // URL KHÔNG ENCODE!
//             const paymentUrl = VNP_URL + "?" + qs.stringify(vnp_Params, { encode: false });

//             console.log("FINAL URL:", paymentUrl);

//             return res.json({ code: "00", paymentUrl });

//         } catch (err) {
//             console.error(err);
//             res.status(500).json({ code: "99", message: err.message });
//         }
//     }

//     checkPayment(req, res) {
//         let params = { ...req.query };
//         const secureHash = params["vnp_SecureHash"];

//         delete params["vnp_SecureHash"];
//         delete params["vnp_SecureHashType"];

//         params = sortObject(params);

//         const signData = qs.stringify(params, { encode: false });
//         const signed = crypto
//             .createHmac("sha512", VNP_HASH_SECRET)
//             .update(Buffer.from(signData, "utf-8"))
//             .digest("hex");

//         if (secureHash === signed) {
//             return res.json({
//                 code: params["vnp_ResponseCode"],
//                 message:
//                     params["vnp_ResponseCode"] === "00"
//                         ? "Thanh toán thành công"
//                         : "Thanh toán thất bại",
//             });
//         }

//         return res.json({ code: "97", message: "Sai checksum" });
//     }
// }

// module.exports = new VnPayController();
const {
  VNPay,
  ignoreLogger,
  ProductCode,
  VnpLocale,
  dateFormat,
} = require("vnpay");
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
>>>>>>> 0f3bf5a500da33f362b108c9a4db9e15e4f016a3
