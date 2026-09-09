import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/registration_cart.dart';
import '../utils/build_counter.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    BuildCounter.cartBadge++;
    return Selector<RegistrationCart, int>(
      selector: (_, cart) => cart.totalPlaces,
      builder: (context, totalPlaces, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Badge(
                label: Text('$totalPlaces'),
                isLabelVisible: totalPlaces > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        );
      },
    );
  }
}
