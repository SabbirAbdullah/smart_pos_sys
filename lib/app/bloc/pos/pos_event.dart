import 'package:equatable/equatable.dart';



import 'package:equatable/equatable.dart';

abstract class POSEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInitialData extends POSEvent {}

class ToggleCartVisibility extends POSEvent {}

class UpdateSearchText extends POSEvent {
  final String text;
  UpdateSearchText(this.text);
  @override
  List<Object?> get props => [text];
}

class UpdateCategory extends POSEvent {
  final String category;
  UpdateCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class AddOrIncrementProduct extends POSEvent {
  final String sku;
  AddOrIncrementProduct(this.sku);
  @override
  List<Object?> get props => [sku];
}

class RemoveProductEvent extends POSEvent {
  final String sku;
  RemoveProductEvent(this.sku);
  @override
  List<Object?> get props => [sku];
}

class ChangeQuantityEvent extends POSEvent {
  final String sku;
  final int change; // +1 or -1
  ChangeQuantityEvent(this.sku, this.change);
  @override
  List<Object?> get props => [sku, change];
}

class ApplyDiscountEvent extends POSEvent {
  final bool isPercentage;
  final double value;
  ApplyDiscountEvent(this.isPercentage, this.value);
  @override
  List<Object?> get props => [isPercentage, value];
}
