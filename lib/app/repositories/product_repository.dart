import '../models/product_model.dart';


class ProductRepository {
// This simulates a local/product DB lookup by QR/sku
  Product getProductBySku(String sku) {
// In real app you'd fetch from DB or API. Keep default values similar to your controller.
    return Product(
      sku: sku,
      name: 'Product $sku',
      price: 300,
      imageUrl: 'assets/box.png',
    );
  }
}