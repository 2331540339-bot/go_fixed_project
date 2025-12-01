const Dashboard = () => {
  return (
    <div className="container-fluid">
      <div className="row g-3 mb-4">
        <div className="col-md-4">
          <div className="stat-card shadow-sm rounded-4 p-3">
            <div className="text-muted small">Tổng sản phẩm</div>
            <div className="display-6 fw-bold text-danger">—</div>
            <div className="text-muted small">Cập nhật nhanh khi đồng bộ API.</div>
          </div>
        </div>
        <div className="col-md-4">
          <div className="stat-card shadow-sm rounded-4 p-3">
            <div className="text-muted small">Đơn hàng hôm nay</div>
            <div className="display-6 fw-bold text-danger">—</div>
            <div className="text-muted small">Tùy chỉnh thêm nếu backend sẵn.</div>
          </div>
        </div>
        <div className="col-md-4">
          <div className="stat-card shadow-sm rounded-4 p-3">
            <div className="text-muted small">Doanh thu</div>
            <div className="display-6 fw-bold text-danger">—</div>
            <div className="text-muted small">Thêm API để hiển thị số liệu.</div>
          </div>
        </div>
      </div>
      <div className="p-4 bg-white shadow-sm rounded-4 border border-danger-subtle">
        <h4 className="fw-bold text-danger mb-2">Chào mừng trở lại</h4>
        <p className="mb-0">
          Đây là giao diện admin.
        </p>
      </div>
    </div>
  );
};

export default Dashboard;
