import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ForwardButton extends StatelessWidget {
  final Function() ontap;
  const ForwardButton({
    super.key,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Ionicons.chevron_forward_outline),
      ),
    );
  }
}
