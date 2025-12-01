import { useEffect, useMemo, useState } from "react";
import { productAPI } from "../app/api";

const emptyForm = {
  product_name: "",
  price: "",
  quantity: "",
  catalog_id: "",
  image: "",
  description: "",
};

const Products = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    setLoading(true);
    setError("");
    try {
      const data = await productAPI.list();
      setProducts(data || []);
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể tải danh sách sản phẩm");
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
      product_name: form.product_name.trim(),
      price: Number(form.price),
      quantity: Number(form.quantity),
      catalog_id: form.catalog_id.trim(),
      description: form.description.trim(),
    };

    if (form.image.trim()) {
      payload.image = form.image
        .split(",")
        .map((item) => item.trim())
        .filter(Boolean);
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
        await productAPI.update(editingId, payload);
      } else {
        await productAPI.create(payload);
      }
      setForm(emptyForm);
      setEditingId(null);
      fetchProducts();
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể lưu sản phẩm");
    } finally {
      setSaving(false);
    }
  };

  const handleEdit = (product) => {
    const catalogValue =
      typeof product.catalog_id === "object"
        ? product.catalog_id?._id || product.catalog_id?.id || ""
        : product.catalog_id || "";

    setEditingId(product._id);
    setForm({
      product_name: product.product_name || "",
      price: product.price || "",
      quantity: product.quantity || "",
      catalog_id: catalogValue,
      image: Array.isArray(product.image) ? product.image.join(", ") : "",
      description: product.description || "",
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleDelete = async (id) => {
    const confirm = window.confirm("Bạn có chắc muốn xoá sản phẩm này?");
    if (!confirm) return;
    setError("");
    try {
      await productAPI.remove(id);
      fetchProducts();
    } catch (err) {
      setError(err?.response?.data?.error || "Không thể xoá sản phẩm");
    }
  };

  const title = editingId ? "Cập nhật sản phẩm" : "Thêm sản phẩm mới";

  const sortedProducts = useMemo(() => {
    return [...products].sort(
      (a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0)
    );
  }, [products]);

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
                  <h5 className="fw-bold mb-0">Sản phẩm</h5>
                </div>
              </div>
              {error && (
                <div className="alert alert-danger py-2">{error}</div>
              )}
              <form className="row g-3" onSubmit={handleSubmit}>
                <div className="col-12">
                  <label className="form-label">Tên sản phẩm</label>
                  <input
                    type="text"
                    className="form-control"
                    name="product_name"
                    value={form.product_name}
                    onChange={handleChange}
                    required
                  />
                </div>
                <div className="col-6">
                  <label className="form-label">Giá</label>
                  <input
                    type="number"
                    className="form-control"
                    name="price"
                    value={form.price}
                    onChange={handleChange}
                    required
                    min="0"
                  />
                </div>
                <div className="col-6">
                  <label className="form-label">Số lượng</label>
                  <input
                    type="number"
                    className="form-control"
                    name="quantity"
                    value={form.quantity}
                    onChange={handleChange}
                    required
                    min="0"
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Catalog ID</label>
                  <input
                    type="text"
                    className="form-control"
                    name="catalog_id"
                    value={form.catalog_id}
                    onChange={handleChange}
                    placeholder="Nhập ID danh mục từ server"
                    required
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Hình ảnh (ngăn cách dấu ,)</label>
                  <input
                    type="text"
                    className="form-control"
                    name="image"
                    value={form.image}
                    onChange={handleChange}
                    placeholder="https://example.com/img-1, https://example.com/img-2"
                  />
                </div>
                <div className="col-12">
                  <label className="form-label">Mô tả</label>
                  <textarea
                    className="form-control"
                    name="description"
                    rows="3"
                    value={form.description}
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
                <h5 className="fw-bold mb-0 text-danger">Danh sách sản phẩm</h5>
                <button
                  className="btn btn-outline-danger btn-sm"
                  onClick={fetchProducts}
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
                      <th>Giá</th>
                      <th>SL</th>
                      <th>Catalog</th>
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
                    {!loading && sortedProducts.length === 0 && (
                      <tr>
                        <td colSpan="6" className="text-center py-4 text-muted">
                          Chưa có sản phẩm.
                        </td>
                      </tr>
                    )}
                    {!loading &&
                      sortedProducts.map((product, idx) => (
                        <tr key={product._id || idx}>
                          <td>{idx + 1}</td>
                          <td className="fw-semibold">{product.product_name}</td>
                          <td>{product.price?.toLocaleString()} đ</td>
                          <td>{product.quantity}</td>
                          <td className="text-truncate" style={{ maxWidth: 120 }}>
                            {typeof product.catalog_id === "object"
                              ? product.catalog_id?._id || product.catalog_id?.id
                              : product.catalog_id}
                          </td>
                          <td className="text-end">
                            <div className="btn-group btn-group-sm">
                              <button
                                className="btn btn-outline-secondary"
                                onClick={() => handleEdit(product)}
                              >
                                Sửa
                              </button>
                              <button
                                className="btn btn-outline-danger"
                                onClick={() => handleDelete(product._id)}
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

export default Products;
