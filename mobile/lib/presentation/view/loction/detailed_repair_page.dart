import 'package:flutter/material.dart';

class DetailedRepairPage extends StatefulWidget {
  final String fullAddress;

  const DetailedRepairPage({super.key, required  this.fullAddress});

  @override
  State<DetailedRepairPage> createState() => _DetailedRepairPageState();
}

class _DetailedRepairPageState extends State<DetailedRepairPage> {
  @override
  void initState() {
    super.initState();
    // Sử dụng widget.fullAddress để truy cập địa chỉ đầy đủ
    print('Địa chỉ đầy đủ: ${widget.fullAddress}');
  }

  @override
  Widget build(BuildContext context) {
    String address = widget.fullAddress;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sửa chữa'),
      ),
      body:  Center(
        child: Text('Địa chỉ đã chọn: $address'),
      ),
    );
  }
}