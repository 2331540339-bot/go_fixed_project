import { useEffect, useMemo, useState } from "react";
import { orderAPI } from "../app/api";

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    setLoading(true);
    setError("");
    try {
      const data = await orderAPI.list();
      setOrders(data || []);
    } catch (err) {
      setError(err?.response?.data?.message || "Không thể tải đơn hàng");
    } finally {
      setLoading(false);
    }
  };

  const sortedOrders = useMemo(() => {
    return [...orders].sort(
      (a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0)
    );
  }, [orders]);

  return (
    <div className="container-fluid">
      <div className="card border-0 shadow-sm rounded-4">
        <div className="card-body">
          <div className="d-flex align-items-center justify-content-between mb-3">
            <h5 className="fw-bold mb-0 text-danger">Tất cả đơn hàng</h5>
            <button
              className="btn btn-outline-danger btn-sm"
              onClick={fetchOrders}
              disabled={loading}
            >
              {loading ? "Đang tải..." : "Tải lại"}
            </button>
          </div>
          {error && <div className="alert alert-danger py-2">{error}</div>}
          <div className="table-responsive">
            <table className="table align-middle">
              <thead>
                <tr className="text-muted small">
                  <th>#</th>
                  <th>Mã đơn</th>
                  <th>Người dùng</th>
                  <th>Tổng tiền</th>
                  <th>Thanh toán</th>
                  <th>Ngày tạo</th>
                  <th>Địa chỉ giao</th>
                </tr>
              </thead>
              <tbody>
                {loading && (
                  <tr>
                    <td colSpan="7" className="text-center py-4">
                      Đang tải...
                    </td>
                  </tr>
                )}
                {!loading && sortedOrders.length === 0 && (
                  <tr>
                    <td colSpan="7" className="text-center py-4 text-muted">
                      Chưa có đơn hàng.
                    </td>
                  </tr>
                )}
                {!loading &&
                  sortedOrders.map((order, idx) => (
                    <tr key={order._id || idx}>
                      <td>{idx + 1}</td>
                      <td className="fw-semibold text-truncate" style={{ maxWidth: 140 }}>
                        {order._id}
                      </td>
                      <td className="text-truncate" style={{ maxWidth: 140 }}>
                        {order.user_id}
                      </td>
                      <td>{order.total_price?.toLocaleString()} đ</td>
                      <td>{order.payment_method || "—"}</td>
                      <td>
                        {order.createdAt
                          ? new Date(order.createdAt).toLocaleString()
                          : "—"}
                      </td>
                      <td className="text-truncate" style={{ maxWidth: 180 }}>
                        {order.shipping_address || "—"}
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Orders;
