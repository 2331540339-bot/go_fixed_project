const crypto = require("crypto");
const qs = require("qs");
const moment = require("moment");

const VNP_TMN_CODE = "RZEQ3COE";
const VNP_HASH_SECRET = "VJKE6FCM3H1O92P3T89SHD6F5O381QOD";
const VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
const RETURN_URL = "http://localhost:8000/payment/check-payment-vnpay";

// SORT PARAM
function sortObject(obj) {
    const sorted = {};
    const keys = Object.keys(obj).sort();  // chuẩn bắt buộc A-Z
    for (const key of keys) {
        sorted[key] = obj[key];
    }
    return sorted;
}

// FIX IP
function getClientIp(req) {
    let ip =
        req.headers["x-forwarded-for"] ||
        req.connection?.remoteAddress ||
        req.socket?.remoteAddress ||
        req.connection?.socket?.remoteAddress ||
        "127.0.0.1";

    if (ip === "::1") ip = "127.0.0.1";
    if (ip.startsWith("::ffff:")) ip = ip.replace("::ffff:", "");

    return ip;
}

class VnPayController {

    createQR(req, res) {
        try {
            const ipAddr = getClientIp(req);
            const date = moment().format("YYYYMMDDHHmmss");
            const expire = moment().add(15, "minutes").format("YYYYMMDDHHmmss");

            const amount = Number(req.body.amount);
            const orderId = String(req.body.orderId);

            let vnp_Params = {
                vnp_Amount: String(amount * 100),
                vnp_Command: "pay",
                vnp_CreateDate: date,
                vnp_CurrCode: "VND",
                vnp_ExpireDate: expire,
                vnp_IpAddr: ipAddr,
                vnp_Locale: "vn",
                vnp_OrderInfo: `Thanh toan cho ma GD ${orderId}`,
                vnp_OrderType: "other",
                vnp_ReturnUrl: RETURN_URL,
                vnp_TmnCode: VNP_TMN_CODE,
                vnp_TxnRef: orderId,
                vnp_Version: "2.1.0",
            };

            // Sort theo chuẩn VNPAY
            vnp_Params = sortObject(vnp_Params);

            // SIGN DATA
            const signData = qs.stringify(vnp_Params, { encode: false });
            const hmac = crypto.createHmac("sha512", VNP_HASH_SECRET);
            const secureHash = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

            vnp_Params["vnp_SecureHash"] = secureHash;

            // URL KHÔNG ENCODE!
            const paymentUrl = VNP_URL + "?" + qs.stringify(vnp_Params, { encode: false });

            console.log("FINAL URL:", paymentUrl);

            return res.json({ code: "00", paymentUrl });

        } catch (err) {
            console.error(err);
            res.status(500).json({ code: "99", message: err.message });
        }
    }

    checkPayment(req, res) {
        let params = { ...req.query };
        const secureHash = params["vnp_SecureHash"];

        delete params["vnp_SecureHash"];
        delete params["vnp_SecureHashType"];

        params = sortObject(params);

        const signData = qs.stringify(params, { encode: false });
        const signed = crypto
            .createHmac("sha512", VNP_HASH_SECRET)
            .update(Buffer.from(signData, "utf-8"))
            .digest("hex");

        if (secureHash === signed) {
            return res.json({
                code: params["vnp_ResponseCode"],
                message:
                    params["vnp_ResponseCode"] === "00"
                        ? "Thanh toán thành công"
                        : "Thanh toán thất bại",
            });
        }

        return res.json({ code: "97", message: "Sai checksum" });
    }
}

module.exports = new VnPayController();
