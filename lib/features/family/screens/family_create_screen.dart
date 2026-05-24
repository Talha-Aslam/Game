import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../../../models/family_model.dart';

/// Multi-step family creation wizard (costs 500 coins)
class FamilyCreateScreen extends ConsumerStatefulWidget {
  const FamilyCreateScreen({super.key});
  @override
  ConsumerState<FamilyCreateScreen> createState() => _FamilyCreateScreenState();
}

class _FamilyCreateScreenState extends ConsumerState<FamilyCreateScreen> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _sloganCtrl = TextEditingController();
  FamilyPrivacy _privacy = FamilyPrivacy.approvalRequired;
  bool _creating = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _tagCtrl.dispose();
    _descCtrl.dispose(); _sloganCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
      child: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        // Header
        Row(children: [
          GestureDetector(onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white70)),
          const SizedBox(width: 16),
          Text('Create Family', style: AppTextStyles.headlineMedium),
          const Spacer(),
          Text('500 🪙', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        // Progress
        Row(children: List.generate(4, (i) => Expanded(child: Container(
          height: 3, margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
            color: i <= _step ? AppColors.purpleNeon : AppColors.white10))))),
        const SizedBox(height: 24),
        // Steps
        Expanded(child: _buildStep()),
        // Nav buttons
        Row(children: [
          if (_step > 0) Expanded(child: GestureDetector(
            onTap: () => setState(() => _step--),
            child: Container(height: 48, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: AppColors.white05,
              border: Border.all(color: AppColors.glassBorder)),
              child: const Center(child: Text('Back', style: TextStyle(color: AppColors.white70, fontWeight: FontWeight.w600)))))),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(flex: 2, child: GestureDetector(
            onTap: _step < 3 ? _nextStep : _create,
            child: Container(height: 48, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppGradients.purpleNeonGradient),
              child: Center(child: _creating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_step < 3 ? 'NEXT' : 'CREATE (500 🪙)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)))))),
        ]),
      ])))),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _nameStep();
      case 1: return _detailsStep();
      case 2: return _privacyStep();
      case 3: return _confirmStep();
      default: return const SizedBox();
    }
  }

  Widget _nameStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('FAMILY NAME', style: TextStyle(color: AppColors.white30, fontSize: 10,
      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
    const SizedBox(height: 8),
    _field(_nameCtrl, 'Enter family name'),
    const SizedBox(height: 20),
    Text('FAMILY TAG', style: TextStyle(color: AppColors.white30, fontSize: 10,
      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
    const SizedBox(height: 8),
    _field(_tagCtrl, 'e.g. COBRA (3-6 chars)'),
  ]);

  Widget _detailsStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('DESCRIPTION', style: TextStyle(color: AppColors.white30, fontSize: 10,
      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
    const SizedBox(height: 8),
    _field(_descCtrl, 'Tell others about your family', maxLines: 3),
    const SizedBox(height: 20),
    Text('SLOGAN', style: TextStyle(color: AppColors.white30, fontSize: 10,
      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
    const SizedBox(height: 8),
    _field(_sloganCtrl, 'Your family motto'),
  ]);

  Widget _privacyStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('PRIVACY SETTING', style: TextStyle(color: AppColors.white30, fontSize: 10,
      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
    const SizedBox(height: 12),
    ...FamilyPrivacy.values.map((p) => GestureDetector(
      onTap: () => setState(() => _privacy = p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14), decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _privacy == p ? AppColors.purpleNeon.withValues(alpha: 0.1) : AppColors.white05,
          border: Border.all(color: _privacy == p
              ? AppColors.purpleNeon.withValues(alpha: 0.4) : AppColors.glassBorder)),
        child: Row(children: [
          Icon(p.icon, color: _privacy == p ? AppColors.purpleGlow : AppColors.white30, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.displayName, style: TextStyle(
              color: _privacy == p ? AppColors.purpleGlow : AppColors.white70,
              fontWeight: FontWeight.w600, fontSize: 14)),
          ])),
          if (_privacy == p) const Icon(Icons.check_circle, color: AppColors.purpleGlow, size: 20),
        ]),
      ),
    )),
  ]);

  Widget _confirmStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('CONFIRM', style: TextStyle(color: AppColors.white30, fontSize: 10,
      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
    const SizedBox(height: 16),
    _confirmRow('Name', _nameCtrl.text),
    _confirmRow('Tag', '[${_tagCtrl.text}]'),
    _confirmRow('Description', _descCtrl.text),
    _confirmRow('Slogan', _sloganCtrl.text),
    _confirmRow('Privacy', _privacy.displayName),
    _confirmRow('Cost', '500 Syndicate Coins'),
  ]);

  Widget _confirmRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(label, style: AppTextStyles.labelSmall)),
      Expanded(child: Text(value.isEmpty ? '—' : value, style: AppTextStyles.labelMedium)),
    ]),
  );

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) => TextField(
    controller: ctrl, maxLines: maxLines,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: AppColors.white30),
      filled: true, fillColor: AppColors.white05,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.purpleNeon)),
    ),
  );

  void _nextStep() {
    if (_step == 0 && (_nameCtrl.text.trim().isEmpty || _tagCtrl.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Name and Tag are required'), behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _step++);
  }

  Future<void> _create() async {
    setState(() => _creating = true);
    try {
      await ref.read(familyProvider.notifier).createFamily(
        name: _nameCtrl.text.trim(), tag: _tagCtrl.text.trim(),
        description: _descCtrl.text.trim(), slogan: _sloganCtrl.text.trim(),
        privacy: _privacy,
      );
      if (mounted) {
        setState(() => _creating = false);
        context.go('/family');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _creating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.crimsonRed,
        ));
      }
    }
  }
}
