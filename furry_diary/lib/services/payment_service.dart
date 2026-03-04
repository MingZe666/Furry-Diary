import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentService {
  PaymentService(this._dio, this._iap);

  final Dio _dio;
  final InAppPurchase _iap;

  Future<void> createOrder(String provider, int amount) async {
    await _dio.post('/api/v1/payment/order',
        data: {'provider': provider, 'amount': amount});
  }

  Future<void> verifyApplePurchase(PurchaseDetails details) async {
    await _dio.post('/api/v1/payment/verify/apple',
        data: {'receipt': details.verificationData.serverVerificationData});
  }

  Future<void> payWithWeChat() async {
    await createOrder('wechat', 1999);
  }

  Future<void> payWithAliPay() async {
    await createOrder('alipay', 1999);
  }
}
