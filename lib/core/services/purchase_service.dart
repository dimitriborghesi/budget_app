import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> products = [];

  final String productId = "premium_monthly";

  /// 🔥 INIT
  Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    final response =
        await _iap.queryProductDetails({productId});

    products = response.productDetails;

    _subscription = _iap.purchaseStream.listen(
      _listenToPurchaseUpdated,
    );
  }

  /// 🔥 ACHAT
  Future<void> buy() async {
    if (products.isEmpty) return;

    final purchaseParam = PurchaseParam(
      productDetails: products.first,
    );

    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 🔥 CALLBACK
  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        print("✅ Achat réussi");
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}