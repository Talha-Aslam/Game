import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../../../models/family_model.dart';

/// Family settings panel — Boss/Underboss only
class FamilySettingsScreen extends ConsumerStatefulWidget {
  const FamilySettingsScreen({super.key});
  @override
  ConsumerState<FamilySettingsScreen> createState() =>
      _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends ConsumerState<FamilySettingsScreen> {
  late TextEditingController _nameCtrl, _descCtrl, _sloganCtrl, _motdCtrl;
  FamilyPrivacy? _privacy;

  @override
  void initState() {
    super.initState();
    final f = ref.read(familyProvider).family;
    _nameCtrl = TextEditingController(text: f?.name ?? '');
    _descCtrl = TextEditingController(text: f?.description ?? '');
    _sloganCtrl = TextEditingController(text: f?.slogan ?? '');
    _motdCtrl = TextEditingController(text: f?.motd ?? '');
    _privacy = f?.privacy;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _sloganCtrl.dispose();
    _motdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Family Settings',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('FAMILY NAME'),
                      _field(_nameCtrl, 'Family name'),
                      const SizedBox(height: 16),
                      _sectionLabel('DESCRIPTION'),
                      _field(_descCtrl, 'Description', maxLines: 3),
                      const SizedBox(height: 16),
                      _sectionLabel('SLOGAN'),
                      _field(_sloganCtrl, 'Motto'),
                      const SizedBox(height: 16),
                      _sectionLabel('MESSAGE OF THE DAY'),
                      _field(
                        _motdCtrl,
                        'MOTD (pinned announcement)',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _sectionLabel('PRIVACY'),
                      ...FamilyPrivacy.values.map(
                        (p) => GestureDetector(
                          onTap: () => setState(() => _privacy = p),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: _privacy == p
                                  ? AppColors.purpleNeon.withValues(alpha: 0.1)
                                  : AppColors.white05,
                              border: Border.all(
                                color: _privacy == p
                                    ? AppColors.purpleNeon.withValues(
                                        alpha: 0.4,
                                      )
                                    : AppColors.glassBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  p.icon,
                                  color: _privacy == p
                                      ? AppColors.purpleGlow
                                      : AppColors.white30,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  p.displayName,
                                  style: TextStyle(
                                    color: _privacy == p
                                        ? AppColors.purpleGlow
                                        : AppColors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                if (_privacy == p)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.purpleGlow,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Save
                      GestureDetector(
                        onTap: _save,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: AppGradients.purpleNeonGradient,
                          ),
                          child: const Center(
                            child: Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Admin links
                      _adminLink(
                        Icons.history,
                        'Audit Log',
                        () => context.push('/family/audit'),
                      ),
                      _adminLink(
                        Icons.swap_horiz,
                        'Transfer Ownership',
                        () => _transferOwnership(),
                      ),
                      _adminLink(
                        Icons.delete_forever,
                        'Delete Family',
                        () => _deleteFamily(),
                        color: AppColors.crimsonRed,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.white30,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
  );

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.white30),
          filled: true,
          fillColor: AppColors.white05,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.purpleNeon),
          ),
        ),
      );

  Widget _adminLink(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white05,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.white70, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color ?? AppColors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.white30, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(familyProvider.notifier)
        .updateSettings(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          slogan: _sloganCtrl.text.trim(),
          motd: _motdCtrl.text.trim(),
          privacy: _privacy,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  Future<void> _deleteFamily() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Family',
          style: TextStyle(color: AppColors.crimsonRed),
        ),
        content: const Text(
          'Are you sure you want to permanently delete this family? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.white50),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.crimsonRed),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref.read(familyProvider.notifier).deleteFamily();
      if (mounted) {
        context.go('/home'); // Send user back to home
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Family deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _transferOwnership() async {
    final members = ref.read(familyProvider).family?.members ?? [];
    if (members.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other members to transfer to.')),
      );
      return;
    }

    final targetId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Transfer Ownership',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: members.length,
            itemBuilder: (context, index) {
              final m = members[index];
              if (m.role == FamilyRole.boss) return const SizedBox.shrink();
              return ListTile(
                title: Text(
                  m.username,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  m.role.name,
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () => Navigator.pop(ctx, m.userId),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.white50),
            ),
          ),
        ],
      ),
    );

    if (targetId == null) return;

    try {
      await ref.read(familyProvider.notifier).transferOwnership(targetId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ownership transferred.')));
        context.pop(); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
