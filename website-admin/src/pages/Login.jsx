import { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { loginAPI } from "../app/api";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
      navigate("/dashboard", { replace: true });
    }
  }, [navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      const data = await loginAPI(email, password);
      if (!data?.accessToken) {
        setError("Không nhận được token xác thực.");
        setLoading(false);
        return;
      }
      localStorage.setItem("token", data.accessToken);
      const redirectTo = location.state?.from?.pathname || "/dashboard";
      navigate(redirectTo, { replace: true });
    } catch (err) {
      setError(err?.response?.data?.error || "Đăng nhập thất bại");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page d-flex align-items-center justify-content-center min-vh-100">
      <div className="login-card shadow-lg rounded-4 p-4 p-md-5 bg-white">
        <div className="text-center mb-4">
          <div className="login-badge mb-3">AutoCare Admin</div>
          <h3 className="fw-bold text-danger mb-1">Đăng nhập</h3>
          <p className="text-muted mb-0">Quản trị hệ thống cửa hàng</p>
        </div>

        {error && <div className="alert alert-danger py-2">{error}</div>}

        <form className="row g-3" onSubmit={handleSubmit}>
          <div className="col-12">
            <label className="form-label">Email</label>
            <input
              type="email"
              className="form-control"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoFocus
            />
          </div>
          <div className="col-12">
            <label className="form-label">Mật khẩu</label>
            <input
              type="password"
              className="form-control"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <div className="col-12">
            <button
              type="submit"
              className="btn btn-danger w-100 py-2"
              disabled={loading}
            >
              {loading ? "Đang đăng nhập..." : "Đăng nhập"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Login;
