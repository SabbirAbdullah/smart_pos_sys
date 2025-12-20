import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pos/views/pos_terminal_view.dart';
import '../presentation/pos/widgets/checkout_page_view.dart';



final GoRouter  router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, state) => const PosTerminalPage()),

    GoRoute(path: '/checkout', builder: (ctx, state) {
      final extra = state.extra;
      return CheckoutPage(cartItems: extra as List<Map<String, dynamic>>? ?? []);
    }),
  ],
);