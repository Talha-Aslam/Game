import 'package:flutter/material.dart';
import '../../../models/family_model.dart';

/// Colored role badge
class FamilyRoleBadge extends StatelessWidget {
  final FamilyRole role;
  final double fontSize;
  const FamilyRoleBadge({super.key, required this.role, this.fontSize = 9});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: role.color.withValues(alpha: 0.15),
        border: Border.all(color: role.color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(role.icon, color: role.color, size: fontSize + 2),
        const SizedBox(width: 3),
        Text(role.displayName, style: TextStyle(
          color: role.color, fontSize: fontSize, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
