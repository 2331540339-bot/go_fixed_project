# 🔍 Hướng dẫn Debug tính năng tìm kiếm địa chỉ

## 🚨 Vấn đề: Không hiện gợi ý khi tìm kiếm

### ✅ **Các file đã tạo:**

1. **`mobile/lib/data/model/vietnam_address.dart`** - Models cho địa chỉ
2. **`mobile/lib/data/remote/vietnam_address_api.dart`** - API service
3. **`mobile/lib/data/remote/geocoding_api.dart`** - Geocoding service
4. **`mobile/lib/presentation/widgets/address_search_field.dart`** - Widget tìm kiếm

### 🔧 **Cách debug:**

#### **Bước 1: Kiểm tra Console Logs**
Khi gõ vào ô tìm kiếm, kiểm tra console logs:
```
Performing search for: Hà Nội
Searching for: Hà Nội
Response status: 200
Response body: [...]
Found 1 results
Search results: 1 items
```

#### **Bước 2: Kiểm tra Network Requests**
Mở Developer Tools và kiểm tra Network tab:
- URL: `https://provinces.open-api.vn/api/v1/p/search/?q=Hà%20Nội`
- Status: 200
- Response: JSON array với kết quả

#### **Bước 3: Test API trực tiếp**
Mở browser và truy cập:
```
https://provinces.open-api.vn/api/v1/p/search/?q=Hà Nội
```

### 🐛 **Các lỗi có thể gặp:**

#### **1. API không trả về kết quả:**
- **Triệu chứng**: Console log "Found 0 results"
- **Nguyên nhân**: API endpoint không đúng hoặc query không hợp lệ
- **Giải pháp**: Kiểm tra URL và query parameters

#### **2. Network error:**
- **Triệu chứng**: Console log "Search error: ..."
- **Nguyên nhân**: Không có internet hoặc API bị chặn
- **Giải pháp**: Kiểm tra kết nối internet

#### **3. UI không hiển thị:**
- **Triệu chứng**: Có kết quả nhưng không hiện gợi ý
- **Nguyên nhân**: `_showResults = false` hoặc `_searchResults.isEmpty`
- **Giải pháp**: Kiểm tra state management

### 🔍 **Debug Steps:**

#### **Step 1: Kiểm tra API hoạt động**
```dart
// Thêm vào _performSearch method
debugPrint('API URL: https://provinces.open-api.vn/api/v1/p/search/?q=${Uri.encodeComponent(query)}');
```

#### **Step 2: Kiểm tra State**
```dart
// Thêm vào _performSearch method
debugPrint('_showResults: $_showResults');
debugPrint('_searchResults.length: ${_searchResults.length}');
```

#### **Step 3: Kiểm tra UI Build**
```dart
// Thêm vào build method
debugPrint('Building with _showResults: $_showResults, _searchResults: ${_searchResults.length}');
```

### 🚀 **Test Cases:**

#### **Test 1: Tìm kiếm cơ bản**
- Gõ: "Hà Nội"
- Kỳ vọng: Hiện "Thành phố Hà Nội"

#### **Test 2: Tìm kiếm một phần**
- Gõ: "Hà"
- Kỳ vọng: Hiện các tỉnh có chứa "Hà"

#### **Test 3: Tìm kiếm không có kết quả**
- Gõ: "xyz123"
- Kỳ vọng: Không hiện gợi ý

### 📱 **Cách test:**

1. **Chạy app**: `flutter run`
2. **Mở màn hình Location**
3. **Gõ vào ô tìm kiếm**: "Hà Nội"
4. **Kiểm tra console logs**
5. **Kiểm tra UI có hiện gợi ý không**

### 🆘 **Nếu vẫn không hoạt động:**

#### **Option 1: Kiểm tra Internet**
- Đảm bảo có kết nối internet
- Thử truy cập API trực tiếp trong browser

#### **Option 2: Kiểm tra API Key**
- API provinces không cần key
- Chỉ cần internet connection

#### **Option 3: Kiểm tra Code**
- Đảm bảo tất cả imports đúng
- Kiểm tra không có lỗi compile

### 📊 **Expected Behavior:**

1. **Gõ text** → Loading spinner hiện
2. **API response** → Gợi ý hiện trong dropdown
3. **Chọn gợi ý** → Text field cập nhật, dropdown ẩn
4. **Clear text** → Dropdown ẩn

**Nếu vẫn không hoạt động, hãy kiểm tra console logs và cho tôi biết lỗi cụ thể!**
