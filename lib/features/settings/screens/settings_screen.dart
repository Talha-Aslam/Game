import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../widgets/neon_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _musicVolume = 0.5;
  double _sfxVolume = 0.8;
  double _micSensitivity = 0.5;
  bool _pushToTalk = false;
  bool _notifications = true;
  int _graphicsQuality = 2; // 0=Low, 1=Med, 2=High

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: AppColors.white70)),
                    const SizedBox(width: 16),
                    const Expanded(child: NeonText(text: 'SETTINGS', fontSize: 20, color: AppColors.white, glowRadius: 10)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _SectionHeader(title: 'AUDIO'),
                    _SliderTile(label: 'Music Volume', value: _musicVolume, color: AppColors.purpleNeon,
                      onChanged: (v) => setState(() => _musicVolume = v)),
                    _SliderTile(label: 'SFX Volume', value: _sfxVolume, color: AppColors.cyan,
                      onChanged: (v) => setState(() => _sfxVolume = v)),
                    _SliderTile(label: 'Mic Sensitivity', value: _micSensitivity, color: AppColors.mintGreen,
                      onChanged: (v) => setState(() => _micSensitivity = v)),
                    _ToggleTile(label: 'Push-to-Talk', value: _pushToTalk,
                      onChanged: (v) => setState(() => _pushToTalk = v)),

                    const SizedBox(height: 16),
                    _SectionHeader(title: 'GRAPHICS'),
                    _SegmentTile(
                      label: 'Quality',
                      options: const ['Low', 'Medium', 'High'],
                      selected: _graphicsQuality,
                      onChanged: (v) => setState(() => _graphicsQuality = v),
                    ),

                    const SizedBox(height: 16),
                    _SectionHeader(title: 'NOTIFICATIONS'),
                    _ToggleTile(label: 'Push Notifications', value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v)),

                    const SizedBox(height: 16),
                    _SectionHeader(title: 'ACCOUNT'),
                    _ActionTile(label: 'Link Google Account', icon: Icons.g_mobiledata, onTap: () {}),
                    _ActionTile(label: 'Link Apple Account', icon: Icons.apple, onTap: () {}),

                    const SizedBox(height: 32),
                    Center(child: Text('City Of Lies v1.0.0', style: AppTextStyles.labelSmall)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.white30, letterSpacing: 2)),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;
  const _SliderTile({required this.label, required this.value, required this.color, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.white05, border: Border.all(color: AppColors.glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: color, inactiveTrackColor: AppColors.white10, thumbColor: color, overlayColor: color.withValues(alpha: 0.2), trackHeight: 3),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.white05, border: Border.all(color: AppColors.glassBorder)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.purpleNeon),
        ],
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;
  const _SegmentTile({required this.label, required this.options, required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.white05, border: Border.all(color: AppColors.glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: List.generate(options.length, (i) {
              final isActive = i == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: Container(
                    margin: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isActive ? AppColors.purpleNeon.withValues(alpha: 0.15) : Colors.transparent,
                      border: Border.all(color: isActive ? AppColors.purpleNeon.withValues(alpha: 0.5) : AppColors.white10),
                    ),
                    child: Center(child: Text(options[i], style: TextStyle(color: isActive ? AppColors.purpleNeon : AppColors.white50, fontSize: 12, fontWeight: FontWeight.w600))),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionTile({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.white05, border: Border.all(color: AppColors.glassBorder)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white50, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.labelMedium),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.white30, size: 18),
          ],
        ),
      ),
    );
  }
}
