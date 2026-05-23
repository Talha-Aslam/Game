import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/rank_model.dart';
import '../../../models/user_model.dart';
import '../screens/avatar_inventory_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';

class AnimatedProfileHeader extends ConsumerStatefulWidget {
  final UserModel user;
  const AnimatedProfileHeader({super.key, required this.user});

  @override
  ConsumerState<AnimatedProfileHeader> createState() => _AnimatedProfileHeaderState();
}

class _AnimatedProfileHeaderState extends ConsumerState<AnimatedProfileHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        
        // Upload image to backend
        try {
          final error = await ref.read(authProvider.notifier).uploadAvatar(pickedFile.path);
          if (error != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload: $error'), backgroundColor: AppColors.crimsonRed),
              );
            }
          }
        } catch (e) {
          debugPrint("Upload failed: $e");
        }
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Update Profile Picture',
                  style: AppTextStyles.headlineSmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.cyan),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.mintGreen,
                ),
                title: Text('Take a Photo', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.stars, color: AppColors.gold),
                title: Text('Premium Avatars', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  // Ensure routing to AvatarInventoryScreen is configured or push directly
                  // Using dynamic push as no central router might be bound to it right now
                  importInventory();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void importInventory() {
    importInventoryInternal(context);
  }

  void importInventoryInternal(BuildContext ctx) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const AvatarInventoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rank = RankModel.fromTier(widget.user.rankTier);
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Glow
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rank.glowColor.withValues(
                      alpha: 0.5 * _pulseAnimation.value,
                    ),
                    blurRadius: 40 * _pulseAnimation.value,
                    spreadRadius: 10 * _pulseAnimation.value,
                  ),
                ],
              ),
            );
          },
        ),
        // Glass Morphism underlying shape
        GestureDetector(
          onTap: _showPickerOptions,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glassBorder, width: 2),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_imageFile != null)
                      Image.file(_imageFile!, fit: BoxFit.cover)
                    else if (widget.user.avatarUrl.isNotEmpty)
                      Image.network(widget.user.avatarUrl, fit: BoxFit.cover)
                    else
                      Center(
                        child: Text(
                          widget.user.username.isNotEmpty
                              ? widget.user.username[0].toUpperCase()
                              : 'G',
                          style: TextStyle(
                            color: rank.color,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: rank.glowColor, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    // Edit Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        color: Colors.black54,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Premium Frame (Rank Color)
        IgnorePointer(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: rank.color, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
