import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class UserIdCardWidget extends StatelessWidget {
  final String userId;
  const UserIdCardWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.glassBackgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, color: AppColors.cyan, size: 20),
              const SizedBox(width: 8),
              Text(
                userId.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: userId));
                  final messenger = ScaffoldMessenger.of(context);
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('ID copied to clipboard!'),
                        duration: Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                child: const Icon(
                  Icons.copy,
                  color: AppColors.white50,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
