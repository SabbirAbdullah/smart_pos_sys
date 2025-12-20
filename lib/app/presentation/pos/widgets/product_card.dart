import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants.dart';



class ProductGridItem extends StatelessWidget {
  final Map item;
  final VoidCallback onTap;
  const ProductGridItem({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(item['imageUrl'] as String, fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          Text(item['name'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
          Text("${item['price']} BDT", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ElevatedButton(onPressed: onTap,style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.appBarColor)), child: const Text('Add',style: TextStyle(color: Colors.white),)),
        ],
      ),
    );
  }
}
