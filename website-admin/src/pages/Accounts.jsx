import { useEffect, useMemo, useState } from "react";
import { accountAPI } from "../app/api";

const emptyForm = {
  fullname: "",
  email: "",
  phone: "",
  role: "end_user",
  password: "",
  avatar_url: "",
};

const roleLabels = {
  admin: "Admin",
  end_user: "Khách hàng",
  mechanic_user: "Thợ",
};

const Accounts = () => {
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [search, setSearch] = useState("");
  const [searching, setSearching] = useState(false);

  useEffect(() => {
    fetchAccounts();
  }, []);

  const fetchAccounts = async () => {
    setLoading(true);
    setError("");
    try {
      const data = await accountAPI.list();
      setAccounts(data || []);
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể tải danh sách tài khoản");
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async (e) => {
    e.preventDefault();
    if (!search.trim()) {
      fetchAccounts();
      return;
    }
    setSearching(true);
    setError("");
    try {
      const data = await accountAPI.search(search.trim());
      setAccounts(data || []);
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể tìm kiếm tài khoản");
    } finally {
      setSearching(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const buildPayload = () => {
    const payload = {
      fullname: form.fullname.trim(),
      email: form.email.trim(),
      phone: form.phone.trim(),
      role: form.role,
      avatar_url: form.avatar_url.trim() || undefined,
    };
    if (form.password.trim()) {
      payload.password_hash = form.password.trim();
    }
    return payload;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError("");
    try {
      const payload = buildPayload();
      if (!editingId && !payload.password_hash) {
        setSaving(false);
        setError("Vui lòng nhập mật khẩu cho tài khoản mới.");
        return;
      }

      if (editingId) {
        await accountAPI.update(editingId, payload);
      } else {
        await accountAPI.create(payload);
      }
      setForm(emptyForm);
      setEditingId(null);
      fetchAccounts();
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể lưu tài khoản");
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (acc) => {
    setEditingId(acc._id);
    setForm({
      fullname: acc.fullname || "",
      email: acc.email || "",
      phone: acc.phone || "",
      role: acc.role || "end_user",
      password: "",
      avatar_url: acc.avatar_url || "",
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleDelete = async (id) => {
    const confirm = window.confirm("Bạn chắc chắn muốn xoá tài khoản này?");
    if (!confirm) return;
    setError("");
    try {
      await accountAPI.remove(id);
      fetchAccounts();
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể xoá tài khoản");
    }
  };

  const sortedAccounts = useMemo(() => {
    return [...accounts].sort(
      (a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0)
    );
  }, [accounts]);

  const title = editingId ? "Cập nhật tài khoản" : "Thêm tài khoản";

  return (
    <div className="container-fluid">
      <div className="row g-4">
        <div className="col-lg-4">
          <div className="card border-0 shadow-sm rounded-4">
            <div className="card-body">
              <div className="d-flex align-items-center mb-3">
                <div className="form-accent me-2" />
                <div>
                  <p className="text-uppercase text-danger small fw-semibold mb-0">
                    {title}
                  </p>
                  <h5 className="fw-bold mb-0">Tài khoản</h5>
                </div>
              </div>
              {error && (
                <div className="alert alert-danger py-2">{error}</div>
              )}
              <form className="row g-3" onSubmit={handleSubmit}>
                <div className="col-12">
                  <label className="form-label">Họ tên</label>
                  <input
                    type="text"
                    className="form-control"
                    name="fullname"
                    value={form.fullname}
                    onChange={handleChange}
                    required
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Email</label>
                  <input
                    type="email"
                    className="form-control"
                    name="email"
                    value={form.email}
                    onChange={handleChange}
                    required
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Số điện thoại</label>
                  <input
                    type="tel"
                    className="form-control"
                    name="phone"
                    value={form.phone}
                    onChange={handleChange}
                    required
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Vai trò</label>
                  <select
                    className="form-select"
                    name="role"
                    value={form.role}
                    onChange={handleChange}
                  >
                    <option value="admin">Admin</option>
                    <option value="end_user">Khách hàng</option>
                    <option value="mechanic_user">Thợ</option>
                  </select>
                </div>
                <div className="col-12">
                  <label className="form-label">
                    Mật khẩu {editingId ? "(để trống nếu không đổi)" : ""}
                  </label>
                  <input
                    type="password"
                    className="form-control"
                    name="password"
                    value={form.password}
                    onChange={handleChange}
                    required={!editingId}
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Avatar URL (tuỳ chọn)</label>
                  <input
                    type="text"
                    className="form-control"
                    name="avatar_url"
                    value={form.avatar_url}
                    onChange={handleChange}
                    placeholder="https://example.com/avatar.png"
                  />
                </div>
                <div className="col-12 d-flex gap-2">
                  <button
                    type="submit"
                    className="btn btn-danger px-3"
                    disabled={saving}
                  >
                    {saving ? "Đang lưu..." : editingId ? "Cập nhật" : "Thêm mới"}
                  </button>
                  {editingId && (
                    <button
                      type="button"
                      className="btn btn-outline-secondary"
                      onClick={() => {
                        setEditingId(null);
                        setForm(emptyForm);
                      }}
                    >
                      Hủy
                    </button>
                  )}
                </div>
              </form>
            </div>
          </div>
        </div>

        <div className="col-lg-8">
          <div className="card border-0 shadow-sm rounded-4">
            <div className="card-body">
              <div className="d-flex align-items-center justify-content-between mb-3">
                <h5 className="fw-bold mb-0 text-danger">Danh sách tài khoản</h5>
                <div className="d-flex gap-2">
                  <form className="d-flex gap-2" onSubmit={handleSearch}>
                    <input
                      type="text"
                      className="form-control form-control-sm"
                      placeholder="Tìm theo tên, email, SĐT"
                      value={search}
                      onChange={(e) => setSearch(e.target.value)}
                      style={{ minWidth: 220 }}
                    />
                    <button
                      className="btn btn-danger btn-sm"
                      type="submit"
                      disabled={searching}
                    >
                      {searching ? "Đang tìm..." : "Tìm"}
                    </button>
                  </form>
                  <button
                    className="btn btn-outline-danger btn-sm"
                    onClick={() => {
                      setSearch("");
                      fetchAccounts();
                    }}
                    disabled={loading}
                  >
                    {loading ? "Đang tải..." : "Tải lại"}
                  </button>
                </div>
              </div>
              <div className="table-responsive">
                <table className="table align-middle">
                  <thead>
                    <tr className="text-muted small">
                      <th>#</th>
                      <th>Họ tên</th>
                      <th>Email</th>
                      <th>Điện thoại</th>
                      <th>Vai trò</th>
                      <th className="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    {loading && (
                      <tr>
                        <td colSpan="6" className="text-center py-4">
                          Đang tải...
                        </td>
                      </tr>
                    )}
                    {!loading && sortedAccounts.length === 0 && (
                      <tr>
                        <td colSpan="6" className="text-center py-4 text-muted">
                          Chưa có tài khoản.
                        </td>
                      </tr>
                    )}
                    {!loading &&
                      sortedAccounts.map((acc, idx) => (
                        <tr key={acc._id || idx}>
                          <td>{idx + 1}</td>
                          <td className="fw-semibold">{acc.fullname}</td>
                          <td>{acc.email}</td>
                          <td>{acc.phone}</td>
                          <td>
                            <span className="badge text-bg-light border border-danger text-danger">
                              {roleLabels[acc.role] || acc.role}
                            </span>
                          </td>
                          <td className="text-end">
                            <div className="btn-group btn-group-sm">
                              <button
                                className="btn btn-outline-secondary"
                                onClick={() => handleEdit(acc)}
                              >
                                Sửa
                              </button>
                              <button
                                className="btn btn-outline-danger"
                                onClick={() => handleDelete(acc._id)}
                              >
                                Xoá
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Accounts;
