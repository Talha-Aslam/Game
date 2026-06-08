import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/player_model.dart';

/// Compact glassmorphic player card — smaller, less scaling, outer glow only
class LobbyPlayerCard extends StatefulWidget {
  final PlayerModel player;
  final bool isSelected;
  final bool isLocalPlayer;
  final bool isTied;
  final bool isFaded; // runoff non-tied dimming
  final VoidCallback? onTap;
  final String? floatingEmoji;
  final double size;

  final bool isHost;

  const LobbyPlayerCard({
    super.key,
    required this.player,
    this.isSelected = false,
    this.isLocalPlayer = false,
    this.isTied = false,
    this.isFaded = false,
    this.onTap,
    this.floatingEmoji,
    this.size = 52,
    this.isHost = false,
  });

  @override
  State<LobbyPlayerCard> createState() => _LobbyPlayerCardState();
}

class _LobbyPlayerCardState extends State<LobbyPlayerCard>
    with TickerProviderStateMixin {
  late AnimationController _float;
  late AnimationController _voicePulse;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _voicePulse = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    _voicePulse.dispose();
    super.dispose();
  }

  Color get _glowColor {
    if (!widget.player.isAlive) return Colors.transparent;
    
    // Custom border colors from equipped cosmetics
    final borderId = widget.player.equippedCosmetics['card_border']?.toString();
    if (borderId == 's1') return AppColors.crimsonRed;
    if (borderId == 's7') return const Color(0xFF00B0FF);
    if (borderId == 's8') return AppColors.gold;

    if (widget.player.isSpeaking) return widget.player.isMafia ? AppColors.purpleNeon : AppColors.gold;
    if (widget.isSelected) return AppColors.gold;
    if (widget.isLocalPlayer) return AppColors.purpleNeon;
    return AppColors.white10;
  }

  Color get _borderColor {
    if (!widget.player.isAlive) return AppColors.white10;
    if (widget.isTied) return AppColors.crimsonRed;
    
    final borderId = widget.player.equippedCosmetics['card_border']?.toString();
    if (borderId == 's1') return AppColors.crimsonRed;
    if (borderId == 's7') return const Color(0xFF00B0FF);
    if (borderId == 's8') return AppColors.gold;

    if (widget.isSelected) return AppColors.gold;
    if (widget.player.isSpeaking) return _glowColor;
    if (widget.isLocalPlayer) {
      return AppColors.purpleNeon.withValues(alpha: 0.6);
    }
    return AppColors.glassBorder;
  }

  @override
  Widget build(BuildContext context) {
    final isAlive = widget.player.isAlive;
    final isSpeaking = widget.player.isSpeaking;
    final s = widget.size;
    final borderId = widget.player.equippedCosmetics['card_border']?.toString();

    return GestureDetector(
      onTap: isAlive ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_float, _voicePulse]),
        builder: (_, _) {
          final floatY = isAlive ? sin(_float.value * pi) * 2 : 0.0;
          // Subtle scale — no more than 3% for speaking
          final speakScale = isSpeaking ? 1.0 + _voicePulse.value * 0.03 : 1.0;
          final selectScale = widget.isSelected ? 1.02 : 1.0;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: widget.isFaded ? 0.25 : (!isAlive ? 0.5 : 1.0),
            child: Transform.translate(
              offset: Offset(0, floatY),
              child: Transform.scale(
                scale: speakScale * selectScale,
                child: SizedBox(
                  width: s + 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Floating emoji
                      if (widget.floatingEmoji != null)
                        _FloatingEmojiWidget(emoji: widget.floatingEmoji!),

                      // Card stack
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Outer voice glow ring or selection ring or premium glow
                          if (isAlive && (isSpeaking || widget.isSelected || borderId != null))
                            Container(
                              width: s + 6,
                              height: s + 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _glowColor.withValues(
                                      alpha: isSpeaking ? (0.25 + _voicePulse.value * 0.2) : 0.4,
                                    ),
                                    blurRadius: isSpeaking ? (12 + _voicePulse.value * 6) : (borderId != null ? 15 : 16),
                                    spreadRadius: isSpeaking ? 1 : (borderId != null ? 2 : 2),
                                  ),
                                ],
                              ),
                            ),

                          // Glass avatar circle
                          ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                width: s,
                                height: s,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isAlive
                                      ? AppColors.white05
                                      : AppColors.darkGrey.withValues(
                                          alpha: 0.3,
                                        ),
                                  border: Border.all(
                                    color: _borderColor,
                                    width: (isSpeaking || borderId != null) ? 1.5 : 1,
                                  ),
                                  gradient: isAlive
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.glassBackground,
                                            AppColors.glassBackgroundDark,
                                          ],
                                        )
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    // Avatar Image or Letter Fallback
                                    _avatarContent(s, isAlive),

                                    // Eliminated X
                                    if (!isAlive)
                                      Center(
                                        child: Icon(
                                          Icons.close,
                                          color: AppColors.crimsonRed
                                              .withValues(alpha: 0.5),
                                          size: s * 0.35,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Voice badge — compact
                          if (isAlive)
                            Positioned(
                              bottom: -1,
                              right: 0,
                              child: _VoiceBadge(
                                voiceState: widget.player.voiceState,
                                speakColor: _glowColor,
                              ),
                            ),

                          // Rank dot
                          if (widget.player.rankTier > 0 && isAlive)
                            Positioned(
                              top: -1,
                              right: 0,
                              child: _RankDot(tier: widget.player.rankTier),
                            ),
                        ],
                      ),

                      const SizedBox(height: 2),
                      // Name
                      Text(
                        widget.player.name,
                        style: TextStyle(
                          color: isAlive
                              ? AppColors.white70
                              : AppColors.white30,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      // Family tag
                      if (widget.player.familyTag != null && isAlive)
                        Text(
                          widget.player.familyTag!,
                          style: TextStyle(
                            color: AppColors.gold.withValues(alpha: 0.4),
                            fontSize: 6,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _avatarContent(double s, bool isAlive) {
    final url = widget.player.avatarUrl;
    final resolved = url.startsWith('/')
        ? '${AppConstants.apiBaseUrl}$url'
        : url;

    if (resolved.isNotEmpty) {
      return ColorFiltered(
        colorFilter: isAlive
            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
            : const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 0.4, 0,
              ]),
        child: ClipOval(
          child: Image.network(
            resolved,
            fit: BoxFit.cover,
            width: s,
            height: s,
            errorBuilder: (c, e, st) => _buildInitials(s, isAlive),
          ),
        ),
      );
    }
    return _buildInitials(s, isAlive);
  }

  Widget _buildInitials(double size, bool isAlive) {
    final s = size;
    return Center(
      child: ColorFiltered(
        colorFilter: isAlive
            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
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
                0.4,
                0,
              ]),
        child: Text(
          widget.player.name.isNotEmpty
              ? widget.player.name[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: isAlive ? AppColors.purpleGlow : AppColors.white30,
            fontSize: s * 0.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──

class _VoiceBadge extends StatelessWidget {
  final VoiceState voiceState;
  final Color speakColor;
  const _VoiceBadge({required this.voiceState, required this.speakColor});

  @override
  Widget build(BuildContext context) {
    final isMuted = voiceState == VoiceState.muted;
    final isSpeaking = voiceState == VoiceState.speaking;
    final color = isMuted
        ? AppColors.crimsonRed
        : isSpeaking
        ? speakColor
        : AppColors.white30;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(color: color, width: 1),
        boxShadow: isSpeaking
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4)]
            : null,
      ),
      child: Icon(isMuted ? Icons.mic_off : Icons.mic, size: 7, color: color),
    );
  }
}

class _RankDot extends StatelessWidget {
  final int tier;
  const _RankDot({required this.tier});
  Color get _color {
    switch (tier) {
      case 0:
        return const Color(0xFFCD7F32);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return AppColors.gold;
      case 3:
        return AppColors.cyan;
      case 4:
        return AppColors.purpleNeon;
      default:
        return AppColors.white30;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        border: Border.all(color: _color, width: 1),
      ),
      child: Icon(Icons.shield, size: 7, color: _color),
    );
  }
}

class _FloatingEmojiWidget extends StatefulWidget {
  final String emoji;
  const _FloatingEmojiWidget({required this.emoji});
  @override
  State<_FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<_FloatingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        return Opacity(
          opacity: (1.0 - _anim.value).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -_anim.value * 25),
            child: Transform.rotate(
              angle: sin(_anim.value * pi * 2) * 0.12,
              child: Text(widget.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
        );
      },
    );
  }
}
