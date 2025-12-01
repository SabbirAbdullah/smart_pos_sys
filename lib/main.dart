import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/bloc/pos/pos_bloc.dart';
import 'app/repositories/product_repository.dart';
import 'app/routes/app_router.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = ProductRepository();
    return RepositoryProvider.value(
      value: repo,
      child: BlocProvider(
        create: (_) => POSBloc(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
        ),
      ),
    );
  }
}
