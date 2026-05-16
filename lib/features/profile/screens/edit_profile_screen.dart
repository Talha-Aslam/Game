import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _taglineCtrl;
  String? _usernameErrorText;
  bool? _usernameAvailable;
  bool _isCheckingUsername = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _taglineCtrl = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameCtrl.text.trim();
    final validationMessage = _validateUsername(username);

    setState(() {
      _usernameErrorText = validationMessage;
      _usernameAvailable = null;
    });

    if (validationMessage != null) {
      return;
    }

    setState(() => _isCheckingUsername = true);
    final isAvailable = await ref
        .read(authProvider.notifier)
        .isUsernameAvailable(username);
    if (!mounted) return;

    setState(() {
      _isCheckingUsername = false;
      _usernameAvailable = isAvailable;
      _usernameErrorText = isAvailable ? null : 'This username is already taken.';
    });
  }

  String? _validateUsername(String value) {
    if (value.isEmpty) return 'Username cannot be empty.';
    if (value.length < 3 || value.length > 20) {
      return 'Use 3 to 20 characters.';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Only letters, numbers, and underscore are allowed.';
    }
    return null;
  }

  String? _validateTagline(String value) {
    if (value.length > 120) return 'Tag line cannot exceed 120 characters.';
    return null;
  }

  Future<void> _saveChanges() async {
    final username = _usernameCtrl.text.trim();
    final tagline = _taglineCtrl.text.trim();

    final usernameValidation = _validateUsername(username);
    final taglineValidation = _validateTagline(tagline);
    if (!_formKey.currentState!.validate() ||
        usernameValidation != null ||
        taglineValidation != null) {
      setState(() {
        _usernameErrorText = usernameValidation;
      });
      return;
    }

    setState(() => _isSaving = true);
    final error = await ref.read(authProvider.notifier).updateProfileInfo(
      username: username,
      tagline: tagline,
    );
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error != null) {
      setState(() {
        _usernameErrorText = error.contains('taken') ? error : _usernameErrorText;
      });
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(milliseconds: 1600),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Info', style: AppTextStyles.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLAYER NAME', style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _usernameCtrl,
                  hint: 'Enter your username',
                  icon: Icons.person,
                  errorText: _usernameErrorText,
                  validator: (value) => _validateUsername((value ?? '').trim()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isCheckingUsername ? null : _checkUsernameAvailability,
                      icon: _isCheckingUsername
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.verified_user_outlined, size: 16),
                      label: const Text('Check availability'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.glassBackgroundDark,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_usernameAvailable == true)
                      const Text(
                        'Available',
                        style: TextStyle(color: AppColors.online),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('TAG LINE', style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _taglineCtrl,
                  hint: 'Write your tag line',
                  icon: Icons.format_quote,
                  maxLines: 3,
                  validator: (value) => _validateTagline((value ?? '').trim()),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_taglineCtrl.text.trim().length}/120',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purpleNeon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SAVE INFO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? errorText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) {
          if (controller == _taglineCtrl) {
            setState(() {});
          }
          if (controller == _usernameCtrl && _usernameErrorText != null) {
            setState(() {
              _usernameErrorText = null;
              _usernameAvailable = null;
            });
          }
        },
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          hintStyle: const TextStyle(color: AppColors.white30),
          prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.cyan) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
