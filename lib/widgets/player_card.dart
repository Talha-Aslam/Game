import '../features/home/widgets/avatar_borders.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mafia_wars/models/rank_model.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/player_model.dart';

/// Circular player card with all visual states:
/// idle (floating glow), speaking (neon pulse + waveform),
/// selected vote (gold border), eliminated (grayscale + crack)
class PlayerCard extends StatefulWidget {
  final PlayerModel player;
  final bool isSelected;
  final bool isLocalPlayer;
  final VoidCallback? onTap;
  final double size;

  const PlayerCard({
    super.key,
    required this.player,
    this.isSelected = false,
    this.isLocalPlayer = false,
    this.onTap,
    this.size = 70,
  });

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _speakController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _speakController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _speakController.dispose();
    super.dispose();
  }

  Color get _glowColor {
    if (!widget.player.isAlive) return Colors.transparent;

    // Custom border colors
    final borderId = widget.player.equippedCosmetics['card_border']?.toString();
    if (borderId == 's1') return AppColors.crimsonRed;
    if (borderId == 's7') return const Color(0xFF00B0FF);
    if (borderId == 's8') return AppColors.gold;

    if (widget.isSelected) return AppColors.gold;
    if (widget.player.isSpeaking) return AppColors.cyan;
    if (widget.isLocalPlayer) return AppColors.purpleNeon;
    return AppColors.white10;
  }

  Color get _borderColor {
    if (!widget.player.isAlive) return AppColors.white10;

    final borderId = widget.player.equippedCosmetics['card_border']?.toString();
    if (borderId == 's1') return AppColors.crimsonRed;
    if (borderId == 's7') return const Color(0xFF00B0FF);
    if (borderId == 's8') return AppColors.gold;

    if (widget.isSelected) return AppColors.gold;
    if (widget.player.isSpeaking) return AppColors.cyan;
    return AppColors.glassBorder;
  }

  @override
  Widget build(BuildContext context) {
    final isAlive = widget.player.isAlive;
    final isSpeaking = widget.player.isSpeaking;

    return GestureDetector(
      onTap: isAlive ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatController,
          _pulseController,
          _speakController,
        ]),
        builder: (context, child) {
          final floatOffset = sin(_floatController.value * pi) * 3;
          final pulseScale = widget.isSelected
              ? 1.0 + (_pulseController.value * 0.05)
              : 1.0;
          final speakScale = isSpeaking
              ? 1.0 + (_speakController.value * 0.08)
              : 1.0;

          return Transform.translate(
            offset: Offset(0, isAlive ? floatOffset : 0),
            child: Transform.scale(
              scale: pulseScale * speakScale,
              child: _buildCard(isSpeaking),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(bool isSpeaking) {
    final size = widget.size;
    final isAlive = widget.player.isAlive;
    final borderId = widget.player.equippedCosmetics['card_border']?.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with glow
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isAlive
                ? [
                    BoxShadow(
                      color: _glowColor.withValues(
                        alpha: isSpeaking ? 0.6 : 0.4,
                      ),
                      blurRadius: isSpeaking
                          ? 20
                          : (borderId != null ? 15 : 10),
                      spreadRadius: isSpeaking ? 4 : (borderId != null ? 2 : 1),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Outer ring for speaking
              if (isSpeaking)
                AnimatedBuilder(
                  animation: _speakController,
                  builder: (context, _) {
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cyan.withValues(
                            alpha: 0.3 + _speakController.value * 0.4,
                          ),
                          width: 3,
                        ),
                      ),
                    );
                  },
                ),


              // Main avatar circle
              PremiumAvatarBorder(
                borderId: borderId,
                radius: size / 2,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _borderColor,
                      width: borderId != null ? 3.0 : 2.0,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isAlive
                          ? [AppColors.surfaceLight, AppColors.surface]
                          : [AppColors.darkGrey, const Color(0xFF1A1A1A)],
                    ),
                  ),
                  child: ClipOval(
                    child: ColorFiltered(
                      colorFilter: isAlive
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : const ColorFilter.matrix(<double>[
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0.5,
                              0,
                            ]),
                      child: _avatarContent(),
                    ),
                  ),
                ),
              ),

              // Voice indicator
              if (isAlive && isSpeaking)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cyan,
                      border: Border.all(color: AppColors.background, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic, size: 10, color: Colors.white),
                  ),
                ),

              // Muted indicator
              if (isAlive && widget.player.voiceState == VoiceState.muted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.crimsonRed,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.mic_off,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Eliminated X overlay
              if (!isAlive)
                Center(
                  child: Icon(
                    Icons.close,
                    color: AppColors.crimsonRed.withValues(alpha: 0.6),
                    size: size * 0.4,
                  ),
                ),

              // Rank badge
              if (widget.player.rankTier > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                      border: Border.all(
                        color: _rankColor(widget.player.rankTier),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.shield,
                      size: 10,
                      color: _rankColor(widget.player.rankTier),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Username
        SizedBox(
          width: size + 10,
          child: Text(
            widget.player.name,
            style: AppTextStyles.labelSmall.copyWith(
              color: isAlive ? AppColors.white70 : AppColors.white30,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Family tag
        if (widget.player.familyTag != null)
          Text(
            widget.player.familyTag!,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.gold.withValues(alpha: 0.6),
              fontSize: 7,
            ),
          ),
      ],
    );
  }

  Widget _avatarContent() {
    final url = widget.player.avatarUrl;
    final resolved = url.startsWith('/')
        ? '${AppConstants.apiBaseUrl}$url'
        : url;

    if (resolved.isNotEmpty) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final isAlive = widget.player.isAlive;
    return Center(
      child: Text(
        widget.player.name.isNotEmpty
            ? widget.player.name[0].toUpperCase()
            : '?',
        style: AppTextStyles.headlineLarge.copyWith(
          color: isAlive ? AppColors.purpleGlow : AppColors.white30,
          fontSize: widget.size * 0.35,
        ),
      ),
    );
  }

  Color _rankColor(int tier) {
    return RankModel.fromTier(tier).color;
  }
}
