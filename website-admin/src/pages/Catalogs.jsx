import { useEffect, useMemo, useState } from "react";
import { catalogAPI } from "../app/api";

const emptyForm = {
  catalog_name: "",
  image: "",
};

const Catalogs = () => {
  const [catalogs, setCatalogs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);

  useEffect(() => {
    fetchCatalogs();
  }, []);

  const fetchCatalogs = async () => {
    setLoading(true);
    setError("");
    try {
      const data = await catalogAPI.list();
      setCatalogs(data || []);
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể tải danh mục");
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const buildPayload = () => {
    const payload = {
      catalog_name: form.catalog_name.trim(),
    };
    if (form.image.trim()) {
      payload.image = form.image.trim();
    }
    return payload;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError("");
    try {
      const payload = buildPayload();
      if (editingId) {
        await catalogAPI.update(editingId, payload);
      } else {
        await catalogAPI.create(payload);
      }
      setForm(emptyForm);
      setEditingId(null);
      fetchCatalogs();
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể lưu danh mục");
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (catalog) => {
    setEditingId(catalog._id);
    setForm({
      catalog_name: catalog.catalog_name || "",
      image: catalog.image || "",
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleDelete = async (id) => {
    const confirm = window.confirm("Bạn chắc chắn muốn xoá danh mục này?");
    if (!confirm) return;
    setError("");
    try {
      await catalogAPI.remove(id);
      fetchCatalogs();
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể xoá danh mục");
    }
  };

  const sortedCatalogs = useMemo(() => {
    return [...catalogs].sort(
      (a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0)
    );
  }, [catalogs]);

  const title = editingId ? "Cập nhật danh mục" : "Thêm danh mục";

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
                  <h5 className="fw-bold mb-0">Danh mục</h5>
                </div>
              </div>
              {error && (
                <div className="alert alert-danger py-2">{error}</div>
              )}
              <form className="row g-3" onSubmit={handleSubmit}>
                <div className="col-12">
                  <label className="form-label">Tên danh mục</label>
                  <input
                    type="text"
                    className="form-control"
                    name="catalog_name"
                    value={form.catalog_name}
                    onChange={handleChange}
                    required
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Ảnh (URL)</label>
                  <input
                    type="text"
                    className="form-control"
                    name="image"
                    value={form.image}
                    onChange={handleChange}
                    placeholder="https://example.com/catalog.png"
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
                <h5 className="fw-bold mb-0 text-danger">Danh sách danh mục</h5>
                <button
                  className="btn btn-outline-danger btn-sm"
                  onClick={fetchCatalogs}
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
                      <th>Tên</th>
                      <th>Ảnh</th>
                      <th className="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    {loading && (
                      <tr>
                        <td colSpan="4" className="text-center py-4">
                          Đang tải...
                        </td>
                      </tr>
                    )}
                    {!loading && sortedCatalogs.length === 0 && (
                      <tr>
                        <td colSpan="4" className="text-center py-4 text-muted">
                          Chưa có danh mục.
                        </td>
                      </tr>
                    )}
                    {!loading &&
                      sortedCatalogs.map((cat, idx) => (
                        <tr key={cat._id || idx}>
                          <td>{idx + 1}</td>
                          <td className="fw-semibold">{cat.catalog_name}</td>
                          <td>
                            {cat.image ? (
                              <img
                                src={cat.image}
                                alt={cat.catalog_name}
                                style={{ width: 48, height: 48, objectFit: "cover", borderRadius: 10 }}
                                onError={(e) => {
                                  e.target.onerror = null;
                                  e.target.src =
                                    "https://www.redpepperdigital.net/wp-content/uploads/2025/05/Catalog-integration-icon.png";
                                }}
                              />
                            ) : (
                              <span className="text-muted">—</span>
                            )}
                          </td>
                          <td className="text-end">
                            <div className="btn-group btn-group-sm">
                              <button
                                className="btn btn-outline-secondary"
                                onClick={() => handleEdit(cat)}
                              >
                                Sửa
                              </button>
                              <button
                                className="btn btn-outline-danger"
                                onClick={() => handleDelete(cat._id)}
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

export default Catalogs;
