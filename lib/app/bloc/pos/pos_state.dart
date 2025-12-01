import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';

class POSState extends Equatable {
  final Map<String, int> scannedProducts; // sku -> qty
  final Map<String, int> productPrices; // sku -> price
  final bool isCartVisible;
  final String searchText;
  final String selectedCategory;
  final double discountValue;
  final bool isPercentage;

  const POSState({
    required this.scannedProducts,
    required this.productPrices,
    required this.isCartVisible,
    required this.searchText,
    required this.selectedCategory,
    required this.discountValue,
    required this.isPercentage,
  });

  factory POSState.initial() => const POSState(
    scannedProducts: {},
    productPrices: {},
    isCartVisible: false,
    searchText: '',
    selectedCategory: 'All',
    discountValue: 0.0,
    isPercentage: true,
  );

  int get totalPrice {
    int total = 0;
    scannedProducts.forEach((sku, qty) {
      final price = productPrices[sku] ?? 0;
      total += price * qty;
    });
    return total;
  }

  double get discountedTotal {
    double total = totalPrice.toDouble();
    if (isPercentage) {
      total -= (total * (discountValue / 100));
    } else {
      total -= discountValue;
    }
    return total.clamp(0, double.infinity);
  }

  Map<String, int> get cartItems => Map.from(scannedProducts);

  POSState copyWith({
    Map<String, int>? scannedProducts,
    Map<String, int>? productPrices,
    bool? isCartVisible,
    String? searchText,
    String? selectedCategory,
    double? discountValue,
    bool? isPercentage,
  }) {
    return POSState(
      scannedProducts: scannedProducts ?? Map.from(this.scannedProducts),
      productPrices: productPrices ?? Map.from(this.productPrices),
      isCartVisible: isCartVisible ?? this.isCartVisible,
      searchText: searchText ?? this.searchText,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      discountValue: discountValue ?? this.discountValue,
      isPercentage: isPercentage ?? this.isPercentage,
    );
  }

  @override
  List<Object?> get props => [
    scannedProducts,
    productPrices,
    isCartVisible,
    searchText,
    selectedCategory,
    discountValue,
    isPercentage,
  ];
}
