import { useEffect, useMemo, useState } from "react";
import { bannerAPI } from "../app/api";

const emptyForm = {
  hinh_anh: "",
  link: "",
  mo_ta: "",
};

const Banners = () => {
  const [banners, setBanners] = useState([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);

  useEffect(() => {
    fetchBanners();
  }, []);

  const fetchBanners = async () => {
    setLoading(true);
    setError("");
    try {
      const data = await bannerAPI.list();
      setBanners(data || []);
    } catch (err) {
      setError(err?.response?.data?.message || "Không thể tải banner");
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError("");
    try {
      if (editingId) {
        await bannerAPI.update(editingId, form);
      } else {
        await bannerAPI.create(form);
      }
      setForm(emptyForm);
      setEditingId(null);
      fetchBanners();
    } catch (err) {
      setError(err?.response?.data?.message || "Không thể lưu banner");
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (banner) => {
    setEditingId(banner._id);
    setForm({
      hinh_anh: banner.hinh_anh || "",
      link: banner.link || "",
      mo_ta: banner.mo_ta || "",
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleDelete = async (id) => {
    const confirm = window.confirm("Bạn chắc chắn muốn xoá banner này?");
    if (!confirm) return;
    setError("");
    try {
      await bannerAPI.remove(id);
      fetchBanners();
    } catch (err) {
      setError(err?.response?.data?.message || "Không thể xoá banner");
    }
  };

  const sortedBanners = useMemo(() => {
    return [...banners].sort(
      (a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0)
    );
  }, [banners]);

  const title = editingId ? "Cập nhật banner" : "Thêm banner";

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
                  <h5 className="fw-bold mb-0">Banner</h5>
                </div>
              </div>
              {error && <div className="alert alert-danger py-2">{error}</div>}
              <form className="row g-3" onSubmit={handleSubmit}>
                <div className="col-12">
                  <label className="form-label">Hình ảnh (URL)</label>
                  <input
                    type="text"
                    className="form-control"
                    name="hinh_anh"
                    value={form.hinh_anh}
                    onChange={handleChange}
                    required
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Liên kết</label>
                  <input
                    type="text"
                    className="form-control"
                    name="link"
                    value={form.link}
                    onChange={handleChange}
                    placeholder="https://example.com"
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Mô tả</label>
                  <textarea
                    className="form-control"
                    name="mo_ta"
                    rows="2"
                    value={form.mo_ta}
                    onChange={handleChange}
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
                <h5 className="fw-bold mb-0 text-danger">Danh sách banner</h5>
                <button
                  className="btn btn-outline-danger btn-sm"
                  onClick={fetchBanners}
                  disabled={loading}
                >
                  {loading ? "Đang tải..." : "Tải lại"}
                </button>
              </div>
              <div className="table-responsive">
                <table className="table align-middle">
                  <thead>
                    <tr className="text-muted small">
                      <th>#</th>
                      <th>Hình</th>
                      <th>Link</th>
                      <th>Mô tả</th>
                      <th className="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    {loading && (
                      <tr>
                        <td colSpan="5" className="text-center py-4">
                          Đang tải...
                        </td>
                      </tr>
                    )}
                    {!loading && sortedBanners.length === 0 && (
                      <tr>
                        <td colSpan="5" className="text-center py-4 text-muted">
                          Chưa có banner.
                        </td>
                      </tr>
                    )}
                    {!loading &&
                      sortedBanners.map((banner, idx) => (
                        <tr key={banner._id || idx}>
                          <td>{idx + 1}</td>
                          <td>
                            {banner.hinh_anh ? (
                              <img
                                src={banner.hinh_anh}
                                alt="banner"
                                style={{ width: 70, height: 40, objectFit: "cover", borderRadius: 8 }}
                              />
                            ) : (
                              <span className="text-muted">—</span>
                            )}
                          </td>
                          <td className="text-truncate" style={{ maxWidth: 160 }}>
                            {banner.link || "—"}
                          </td>
                          <td className="text-truncate" style={{ maxWidth: 180 }}>
                            {banner.mo_ta || "—"}
                          </td>
                          <td className="text-end">
                            <div className="btn-group btn-group-sm">
                              <button
                                className="btn btn-outline-secondary"
                                onClick={() => handleEdit(banner)}
                              >
                                Sửa
                              </button>
                              <button
                                className="btn btn-outline-danger"
                                onClick={() => handleDelete(banner._id)}
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

export default Banners;
