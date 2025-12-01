import { useEffect, useMemo, useState } from "react";
import { orderAPI, productAPI } from "../app/api";
import { Line } from "react-chartjs-2";
import {
  CategoryScale,
  Chart as ChartJS,
  Legend,
  LinearScale,
  LineElement,
  PointElement,
  Title,
  Tooltip,
} from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const Dashboard = () => {
  const [productCount, setProductCount] = useState(0);
  const [todayOrders, setTodayOrders] = useState(0);
  const [todayRevenue, setTodayRevenue] = useState(0);
  const [monthlyRevenue, setMonthlyRevenue] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    setLoading(true);
    setError("");
    try {
      const [products, orders] = await Promise.all([
        productAPI.list(),
        orderAPI.list(),
      ]);
      setProductCount(products?.length || 0);

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const filteredOrders = (orders || []).filter((o) => {
        const created = o.createdAt ? new Date(o.createdAt) : null;
        return created && created >= today;
      });
      setTodayOrders(filteredOrders.length);

      const revenue = filteredOrders.reduce(
        (sum, o) => sum + (o.total_price || 0),
        0
      );
      setTodayRevenue(revenue);

      // Doanh thu theo ngày trong tháng hiện tại
      const now = new Date();
      const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
      const revenueByDay = {};
      (orders || []).forEach((o) => {
        if (!o.createdAt) return;
        const created = new Date(o.createdAt);
        if (created.getMonth() !== now.getMonth() || created.getFullYear() !== now.getFullYear()) return;
        const day = created.getDate();
        revenueByDay[day] = (revenueByDay[day] || 0) + (o.total_price || 0);
      });
      const daysInMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
      const revenueSeries = Array.from({ length: daysInMonth }, (_, i) => ({
        day: i + 1,
        value: revenueByDay[i + 1] || 0,
      }));
      setMonthlyRevenue(revenueSeries);
    } catch (err) {
      setError(
        err?.response?.data?.message ||
          err?.response?.data?.error ||
          "Không thể tải số liệu"
      );
    } finally {
      setLoading(false);
    }
  };

  const cards = useMemo(
    () => [
      {
        title: "Tổng sản phẩm",
        value: productCount.toLocaleString(),
        note: "Từ danh sách sản phẩm",
      },
      {
        title: "Đơn hàng hôm nay",
        value: todayOrders.toLocaleString(),
        note: "Tính theo ngày hiện tại",
      },
      {
        title: "Doanh thu",
        value: todayRevenue.toLocaleString() + " đ",
        note: "Tổng tiền đơn hôm nay",
      },
    ],
    [productCount, todayOrders, todayRevenue]
  );

  const chartData = useMemo(() => {
    const labels = monthlyRevenue.map((item) => `Ngày ${item.day}`);
    const data = monthlyRevenue.map((item) => item.value);
    return {
      labels,
      datasets: [
        {
          label: "Doanh thu (đ)",
          data,
          borderColor: "#d90429",
          backgroundColor: "rgba(217,4,41,0.12)",
          tension: 0.3,
          pointRadius: 3,
          fill: true,
        },
      ],
    };
  }, [monthlyRevenue]);

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: {
          label: (ctx) => `${ctx.parsed.y.toLocaleString()} đ`,
        },
      },
    },
    scales: {
      x: {
        ticks: { maxRotation: 0, minRotation: 0, color: "#666" },
        grid: { display: false },
      },
      y: {
        ticks: {
          color: "#666",
          callback: (val) => `${Number(val).toLocaleString()} đ`,
        },
        grid: { color: "rgba(0,0,0,0.04)" },
      },
    },
  };

  return (
    <div className="container-fluid">
      <div className="d-flex align-items-center justify-content-between mb-3">
        <div>
          <h4 className="fw-bold text-danger mb-0">Tổng quan</h4>
          <small className="text-muted">
            Cập nhật từ dữ liệu sản phẩm và đơn hàng.
          </small>
        </div>
        <button
          className="btn btn-outline-danger btn-sm"
          onClick={loadStats}
          disabled={loading}
        >
          {loading ? "Đang tải..." : "Tải lại"}
        </button>
      </div>

      {error && <div className="alert alert-danger py-2">{error}</div>}

      <div className="row g-3 mb-4">
        {cards.map((card) => (
          <div className="col-md-4" key={card.title}>
            <div className="stat-card shadow-sm rounded-4 p-3">
              <div className="text-muted small">{card.title}</div>
              <div className="display-6 fw-bold text-danger">{card.value}</div>
              <div className="text-muted small">{card.note}</div>
            </div>
          </div>
        ))}
      </div>
      <div className="p-4 bg-white shadow-sm rounded-4 border border-danger-subtle">
        <div className="d-flex align-items-center justify-content-between mb-3">
          <div>
            <h5 className="fw-bold text-danger mb-0">Doanh thu trong tháng</h5>
            <small className="text-muted">Tổng hợp theo ngày</small>
          </div>
        </div>
        {monthlyRevenue.length === 0 ? (
          <p className="text-muted mb-0">Chưa có dữ liệu doanh thu tháng này.</p>
        ) : (
          <div style={{ height: 320 }}>
            <Line data={chartData} options={chartOptions} />
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
