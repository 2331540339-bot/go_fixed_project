# 🔍 Hướng dẫn sử dụng tính năng tìm kiếm địa chỉ Việt Nam

## ✅ Đã hoàn thiện tính năng search địa chỉ!

### 🚀 **Tính năng mới:**

1. **Tìm kiếm địa chỉ Việt Nam** sử dụng API [provinces.open-api.vn](https://provinces.open-api.vn/)
2. **Autocomplete** với danh sách gợi ý
3. **Geocoding** chuyển đổi địa chỉ thành tọa độ
4. **Cập nhật map** tự động khi chọn địa chỉ
5. **UI thân thiện** với loading và thông báo

## 📁 **Files đã tạo:**

### 1. **Models** (`mobile/lib/data/models/vietnam_address.dart`):
- `VietnamAddress` - Model cho tỉnh thành
- `District` - Model cho quận/huyện  
- `Ward` - Model cho phường/xã
- `SearchResult` - Model cho kết quả tìm kiếm

### 2. **Services**:
- `VietnamAddressService` - Gọi API provinces
- `GeocodingService` - Chuyển đổi địa chỉ ↔ tọa độ

### 3. **Widgets**:
- `AddressSearchField` - Widget tìm kiếm với autocomplete

## 🎯 **Cách sử dụng:**

### **Bước 1: Tìm kiếm địa chỉ**
1. Nhập tên tỉnh/thành phố vào ô search
2. Chọn từ danh sách gợi ý hiện ra
3. Hệ thống sẽ tự động tìm tọa độ

### **Bước 2: Xem kết quả**
1. Địa chỉ đã chọn hiển thị trong box màu xanh
2. Map tự động cập nhật với route mới
3. Route từ vị trí hiện tại đến địa chỉ đã chọn

## 🔧 **API Endpoints sử dụng:**

### **Vietnam Address API** ([provinces.open-api.vn](https://provinces.open-api.vn/)):
- `GET /api/v1/?depth=1` - Lấy danh sách tỉnh thành
- `GET /api/v1/p/search/?q={query}` - Tìm kiếm tỉnh thành
- `GET /api/v1/p/{code}?depth=2` - Lấy quận/huyện của tỉnh

### **Google Geocoding API**:
- `GET /maps/api/geocoding/json` - Chuyển đổi địa chỉ thành tọa độ
- `GET /maps/api/geocoding/json` - Chuyển đổi tọa độ thành địa chỉ

## 📱 **UI Components:**

### **AddressSearchField**:
- **Autocomplete**: Danh sách gợi ý khi gõ
- **Loading**: Spinner khi đang tìm kiếm
- **Clear**: Nút xóa để reset
- **Debounce**: Tìm kiếm sau 300ms khi ngừng gõ

### **Location Indicator**:
- **Selected Address**: Hiển thị địa chỉ đã chọn
- **Visual Feedback**: Box màu xanh với icon
- **Real-time Update**: Cập nhật ngay khi chọn

## 🎨 **User Experience:**

### **Tìm kiếm:**
1. Gõ tên tỉnh/thành phố
2. Chọn từ danh sách gợi ý
3. Loading dialog hiển thị
4. Map cập nhật với route mới

### **Error Handling:**
- **Không tìm thấy tọa độ**: Snackbar màu đỏ
- **Lỗi API**: Thông báo lỗi chi tiết
- **Network timeout**: Xử lý timeout

## 🔍 **Debug:**

### **Console Logs:**
- `Search error: ...` - Lỗi tìm kiếm
- `Geocoding error: ...` - Lỗi chuyển đổi tọa độ
- `Map error: ...` - Lỗi map

### **Network Requests:**
- `GET https://provinces.open-api.vn/api/v1/p/search/?q=...`
- `GET https://maps.googleapis.com/maps/api/geocoding/json?...`

## 🚀 **Tính năng nâng cao:**

### **Có thể mở rộng:**
1. **Tìm kiếm quận/huyện**: Thêm dropdown chọn quận/huyện
2. **Tìm kiếm phường/xã**: Thêm dropdown chọn phường/xã
3. **Lịch sử tìm kiếm**: Lưu các địa chỉ đã tìm
4. **Favorites**: Đánh dấu địa chỉ yêu thích

### **Performance:**
- **Debounce**: Tránh gọi API quá nhiều
- **Caching**: Cache kết quả tìm kiếm
- **Loading States**: UI feedback tốt

## 🎉 **Kết quả:**

App hiện tại có tính năng tìm kiếm địa chỉ Việt Nam hoàn chỉnh:
- ✅ Tìm kiếm với autocomplete
- ✅ Chuyển đổi địa chỉ thành tọa độ
- ✅ Cập nhật map tự động
- ✅ UI/UX thân thiện
- ✅ Error handling tốt

**Người dùng có thể tìm kiếm bất kỳ tỉnh/thành phố nào ở Việt Nam và xem route trên map!**
