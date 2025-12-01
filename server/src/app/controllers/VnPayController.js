
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
