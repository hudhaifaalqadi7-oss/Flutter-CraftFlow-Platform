import 'package:flutter/material.dart';
import '../../domain/entities/workshop.dart';
import 'order_form.dart';

void showOrderSheet(BuildContext context, Workshop workshop) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => FractionallySizedBox(
      heightFactor: 0.88,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(child: OrderFormPage(workshop: workshop)),
        ],
      ),
    ),
  );
}
