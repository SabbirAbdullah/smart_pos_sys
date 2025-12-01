class Product {
  final String sku; // use qrCode as sku
  final String name;
  final int price; // using int BDT like original
  final String imageUrl;


  Product({
    required this.sku,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}