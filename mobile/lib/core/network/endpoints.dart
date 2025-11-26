import 'package:flutter/material.dart';
import 'package:mobile/config/router/app_router.dart';

class Endpoints {
  static final base = AppRouter.main_domain; 

  // user
  static final login = '$base/account/login';
  static final register = '$base/account/create';
  static final me    = '$base/account/me';

  // services
  static final services = '$base/service/get';
  static final sendRescueRequest = '$base/service/rescue/';

  // banner
  static final banners = '$base/banners/get';

  // catelog
  static final catelogs = '$base/commerce/catalog/showall';
  static final catelogDetail ='$base/commerce/catalog/detail/';

  //order
  static final createOrder = '$base/order/create';

  //payment
  static final createPayment = '$base/payment_online/create-qr';
  
  //product
  static final products = '$base/commerce/product/showall';
  static final productDetail = '$base/commerce/product/show/';


}
