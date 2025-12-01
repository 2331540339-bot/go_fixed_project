import { useEffect, useState } from "react";
import { productAPI_showall, catalogAPI_showall} from "../app/api";
import { Link } from "react-router-dom";

function AllPart (){
  const [products, setProducts] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [search, setSearch] = useState("");
  const [catalogs, setCatalogs] = useState([]);
  const [selectedCatalog, setSelectedCatalog] = useState("all");
        
  useEffect(() => {
    productAPI_showall()
    .then((res) => {
        setProducts(res);
        setFiltered(res);
    })
    .catch((err) => console.log(err));
    
    catalogAPI_showall()
    .then((res) => setCatalogs(res))
    .catch((err) => console.log(err));
  }, []);

  // Lọc theo tìm kiếm + danh mục
  useEffect(() => {
    let result = [...products];

    if (search.trim()) {
      result = result.filter((p) =>
        p.product_name.toLowerCase().includes(search.toLowerCase())
      );
    }

    if (selectedCatalog !== "all") {
      
      result = products.filter((p) => p.catalog_id == selectedCatalog);
      
    }
    console.log(result)
    setFiltered(result);
  }, [search, selectedCatalog, products]);

  return (
    <section className="w-full min-h-screen px-10 py-10 bg-n-50 font-grostek">
      {/* Header */}
      <div className="flex flex-col items-center mb-10 text-center">
        <h1 className="text-3xl font-bold text-n-800">Tất cả sản phẩm</h1>
        <p className="mt-2 text-n-600">
          Khám phá kho phụ tùng chính hãng với hàng trăm sản phẩm đang có sẵn.
        </p>
      </div>

      {/* Bộ lọc */}
      <div className="flex flex-col items-center justify-between gap-4 mb-8 sm:flex-row">
        {/* Tìm kiếm */}
        <input
          type="text"
          placeholder="Tìm kiếm sản phẩm..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full px-4 py-2 text-sm border outline-none sm:w-2/4 rounded-xl border-n-300 focus:ring-2 focus:ring-p-500/40"
        />

        {/* Select danh mục */}
        <select
          className="px-4 py-2 text-sm border outline-none rounded-xl border-n-300 focus:ring-2 focus:ring-p-500/40"
          value={selectedCatalog}
          onChange={(e) => setSelectedCatalog(e.target.value)}
        >   

            <option value='all'>Tất cả sản phẩm</option>
            {catalogs.map((cate) => (
                <option value={cate._id}>{cate.catalog_name}</option>
            ))}
        </select>
      </div>

      {/* Số lượng sản phẩm */}
      <p className="mb-4 text-sm text-n-600">
        Tìm thấy <b>{filtered.length}</b> sản phẩm
      </p>

      {/* GRID SẢN PHẨM */}
      <div className="grid grid-cols-2 gap-6 md:grid-cols-3 lg:grid-cols-4">
        {filtered.map((item) => (
          <div
            key={item._id}
            className="w-full overflow-hidden transition-shadow bg-white shadow-md cursor-pointer rounded-2xl hover:shadow-lg group"
          >
            <div className="relative w-full h-40 bg-n-100">
              <img
                src={item.image[0]}
                alt={item.product_name}
                className="object-contain w-full h-full p-2 transition-transform duration-300 group-hover:scale-105"
              />

              {/* Tag HOT nếu cần */}
              {item.is_hot && (
                <span className="absolute px-2 py-1 text-xs text-white rounded-md top-2 left-2 bg-p-500">
                  Hot
                </span>
              )}
            </div>

            <div className="p-3">
              <h3 className="text-sm font-semibold text-n-700 line-clamp-2 min-h-[40px]">
                {item.product_name}
              </h3>

              <p className="mt-2 text-lg font-bold text-p-500">
                {item.price.toLocaleString("vi-VN")}₫
              </p>

              <Link to={`/genuine-part/${item._id}`}>
                <button className="w-full py-2 mt-3 text-sm font-semibold text-white transition-all duration-300 bg-p-500 rounded-xl hover:bg-p-600">
                  Xem chi tiết
                </button>
              </Link>
            </div>
          </div>
        ))}
      </div>

      {/* Nếu không có sản phẩm */}
      {filtered.length === 0 && (
        <div className="flex justify-center mt-10 text-n-600">
          Không tìm thấy sản phẩm nào phù hợp.
        </div>
      )}
    </section>
  );
}; export default AllPart
