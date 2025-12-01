import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:posmart/app/views/cart_items_view.dart';
import '../bloc/pos/pos_bloc.dart';
import '../bloc/pos/pos_event.dart';
import '../bloc/pos/pos_state.dart';
import '../core/constants.dart';
import '../core/utilis.dart';
import '../repositories/product_repository.dart';
import '../widgets/product_card.dart';
import '../widgets/checkout_page_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/total_summary_card.dart';

class PosTerminalPage extends StatelessWidget {
  const PosTerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<POSBloc>();

    return BlocListener<POSBloc, POSState>(
      listener: (context, state) {
        // example: show simple feedback using ScaffoldMessenger if last action needed notification
      },
      child: Scaffold(
        backgroundColor: AppColors.appBarColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          scrolledUnderElevation: 0,
          toolbarHeight: 50,
          title: const Text('Pos Terminal',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _SearchAndScanRow(),
            ),
          ),
        ),
        body: Column(
          children: [
            _CategoryFilter(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: BlocBuilder<POSBloc, POSState>(builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation);
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                    child: state.isCartVisible ? _CartView(state: state) : _GridView(state: state),
                  );
                }),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BottomBar(),
      ),
    );
  }
}

/// --- Sub-widgets below (extracted to keep file tidy) ---

class _SearchAndScanRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<POSBloc>();
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<POSBloc, POSState>(builder: (context, state) {
            return Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
              child: TextField(
                onChanged: (v) => bloc.add(UpdateSearchText(v)),
                cursorColor: AppColors.appColor,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Color(0xff868686)),
                  hintText: 'Search product here. . .',
                  border: InputBorder.none,
                ),
              ),
            );
          }),
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
          onPressed: () async {
            final ok = await requestCameraPermission(context);
            if (!ok) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _QRScannerDialog(),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<POSBloc>();
    final categories = ['All', 'Bags', 'Electronics'];
    return SizedBox(
      height: 60,
      child: BlocBuilder<POSBloc, POSState>(builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final selected = state.selectedCategory == category;
              return GestureDetector(
                onTap: () => bloc.add(UpdateCategory(category)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: selected ? AppColors.appColor : Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Text(category, style: TextStyle(color: selected ? Colors.white : Colors.black)),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}

class _GridView extends StatelessWidget {
  final POSState state;
  const _GridView({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<POSBloc>();
    // sample items - move to repo in real app
    final allItems = [
      {"sku": "sku_macbook", "imageUrl": 'assets/box.png', "name": "Apple MacBook Pro 16", "category": "Electronics", "price": 300},
      {"sku": "sku_watch", "imageUrl": 'assets/box.png', "name": "Smart Watch", "category": "Electronics", "price": 300},
      {"sku": "sku_bag", "imageUrl": 'assets/box.png', "name": "Leather Bag", "category": "Bags", "price": 200},
    ];

    final filtered = state.selectedCategory == 'All' ? allItems : allItems.where((i) => i['category'] == state.selectedCategory).toList();

    // also apply search filter
    final search = state.searchText.toLowerCase();
    final finalList = (search.isEmpty) ? filtered : filtered.where((i) => (i['name'] as String).toLowerCase().contains(search)).toList();

    return GridView.builder(
      key: const ValueKey('GridView'),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6),
      itemCount: finalList.length,
      itemBuilder: (context, index) {
        final item = finalList[index];
        return ProductGridItem(
          item: item,
          onTap: () {
            bloc.add(AddOrIncrementProduct(item['sku'] as String));
            // show bottom sheet quickly to preview
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showCartBottomSheet(context);
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
          },
        );
      },
    );
  }
}

class _CartView extends StatelessWidget {
  final POSState state;
  const _CartView({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<POSBloc>();
    return Column(
      key: const ValueKey('CartView'),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text('Cart Items (${state.scannedProducts.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: ListView(
            children: state.scannedProducts.entries.map((entry) {
              final sku = entry.key;
              final qty = entry.value;
              final pricePerItem = state.productPrices[sku] ?? 300;
              return Dismissible(
                key: Key(sku),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  bloc.add(RemoveProductEvent(sku));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed')));
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: CartItemTile(
                  sku: sku,
                  productName: sku,
                  quantity: qty,
                  price: pricePerItem * qty,
                  onAdd: () => bloc.add(ChangeQuantityEvent(sku, 1)),
                  onRemove: () => bloc.add(ChangeQuantityEvent(sku, -1)),
                  onDelete: () {
                    bloc.add(RemoveProductEvent(sku));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted')));
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<POSBloc>();
    return BlocBuilder<POSBloc, POSState>(builder: (context, state) {
      return BottomAppBar(
        color: AppColors.appColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => bloc.add(ToggleCartVisibility()),
                child: Row(
                  children: [
                    Icon(state.isCartVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('${state.scannedProducts.length} Items', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Total', style: TextStyle(color: Colors.white70)),
                Text('${state.totalPrice} BDT', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              ElevatedButton(
                onPressed: () {
                  // prepare cart details and navigate to checkout
                  final cart = state.scannedProducts.entries.map((e) => {'sku': e.key, 'quantity': e.value, 'price': state.productPrices[e.key] ?? 300}).toList();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>  CheckoutPage(cartItems: cart),
                  ),);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text('Checkout', style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
      );
    });
  }
}

/// QR Scanner Dialog widget
class _QRScannerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<POSBloc>();
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final b in barcodes) {
                if (b.rawValue != null) {
                  bloc.add(AddOrIncrementProduct(b.rawValue!));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR added')));
                  break;
                }
              }
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
          ),
        ],
      ),
    );
  }
}

void _showCartBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return BlocBuilder<POSBloc, POSState>(builder: (context, state) {
            final bloc = context.read<POSBloc>();
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(width: 60, height: 6, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(3))),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: state.scannedProducts.length,
                      itemBuilder: (context, index) {
                        final entry = state.scannedProducts.entries.elementAt(index);
                        final sku = entry.key;
                        final qty = entry.value;
                        final pricePerItem = state.productPrices[sku] ?? 300;
                        return CartItemTile(
                          sku: sku,
                          productName: sku,
                          price: pricePerItem * qty,
                          quantity: qty,
                          onAdd: () => bloc.add(ChangeQuantityEvent(sku, 1)),
                          onRemove: () => bloc.add(ChangeQuantityEvent(sku, -1)),
                          onDelete: () => bloc.add(RemoveProductEvent(sku)),
                        );
                      },
                    ),
                  ),
                  TotalSummaryCard(total: context.read<POSBloc>().state.discountedTotal),
                ],
              ),
            );
          });
        },
      );
    },
  );
}
