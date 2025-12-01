import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/product_repository.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class POSBloc extends Bloc<POSEvent, POSState> {
  final ProductRepository repository = ProductRepository();

  POSBloc() : super(POSState.initial()) {
    on<LoadInitialData>(_onLoad);
    on<ToggleCartVisibility>(_onToggleCart);
    on<UpdateSearchText>(_onUpdateSearch);
    on<UpdateCategory>(_onUpdateCategory);
    on<AddOrIncrementProduct>(_onAddOrIncrement);
    on<RemoveProductEvent>(_onRemoveProduct);
    on<ChangeQuantityEvent>(_onChangeQuantity);
    on<ApplyDiscountEvent>(_onApplyDiscount);
  }

  void _onLoad(LoadInitialData event, Emitter<POSState> emit) {
    emit(state.copyWith(productPrices: {}));
  }

  void _onToggleCart(ToggleCartVisibility event, Emitter<POSState> emit) {
    emit(state.copyWith(isCartVisible: !state.isCartVisible));
  }

  void _onUpdateSearch(UpdateSearchText event, Emitter<POSState> emit) {
    emit(state.copyWith(searchText: event.text));
  }

  void _onUpdateCategory(UpdateCategory event, Emitter<POSState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onAddOrIncrement(AddOrIncrementProduct event, Emitter<POSState> emit) {
    final sku = event.sku;
    final newScanned = Map<String, int>.from(state.scannedProducts);

    // safe repo lookup
    final product = repository.getProductBySku(sku);
    if (product == null) {
      // Unknown sku — ignore or handle in UI via listener
      return;
    }

    if (newScanned.containsKey(sku)) {
      newScanned[sku] = newScanned[sku]! + 1;
      emit(state.copyWith(scannedProducts: newScanned));
      return;
    }

    // new SKU add
    newScanned[sku] = 1;
    final newPrices = Map<String, int>.from(state.productPrices);
    newPrices[sku] = product.price;
    emit(state.copyWith(scannedProducts: newScanned, productPrices: newPrices));
  }

  void _onRemoveProduct(RemoveProductEvent event, Emitter<POSState> emit) {
    final newScanned = Map<String, int>.from(state.scannedProducts);
    newScanned.remove(event.sku);
    emit(state.copyWith(scannedProducts: newScanned));
  }

  void _onChangeQuantity(ChangeQuantityEvent event, Emitter<POSState> emit) {
    final newScanned = Map<String, int>.from(state.scannedProducts);
    if (!newScanned.containsKey(event.sku)) return;
    final newQty = (newScanned[event.sku]! + event.change).clamp(1, 1000);
    newScanned[event.sku] = newQty;
    emit(state.copyWith(scannedProducts: newScanned));
  }

  void _onApplyDiscount(ApplyDiscountEvent event, Emitter<POSState> emit) {
    emit(state.copyWith(isPercentage: event.isPercentage, discountValue: event.value));
  }
}
