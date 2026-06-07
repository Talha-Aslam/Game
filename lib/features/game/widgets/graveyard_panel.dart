import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/player_model.dart';

/// Horizontal scrollable graveyard panel for eliminated players
class GraveyardPanel extends StatefulWidget {
  final List<PlayerModel> deadPlayers;

  const GraveyardPanel({super.key, required this.deadPlayers});

  @override
  State<GraveyardPanel> createState() => _GraveyardPanelState();
}

class _GraveyardPanelState extends State<GraveyardPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideUp;

  @override
  void initState() {
    super.initState();
    _slideUp = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.deadPlayers.isNotEmpty) _slideUp.forward();
  }

  @override
  void didUpdateWidget(GraveyardPanel old) {
    super.didUpdateWidget(old);
    if (widget.deadPlayers.isNotEmpty && old.deadPlayers.isEmpty) {
      _slideUp.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideUp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deadPlayers.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _slideUp,
      builder: (_, _) {
        final t = Curves.easeOutCubic.transform(_slideUp.value);
        return Transform.translate(
          offset: Offset(0, 60 * (1 - t)),
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 94, // Increased height to prevent text from wrapping
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    color: Colors.black.withValues(alpha: 0.5),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.crimsonRed.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.crimsonRed.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Graveyard label - wrapped to prevent breaking
                      RotatedBox(
                        quarterTurns: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.close, size: 8, color: AppColors.crimsonRed),
                              const SizedBox(width: 4),
                              Text(
                                'GRAVEYARD',
                                style: TextStyle(
                                  color: AppColors.white30,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 46,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.white10,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Scrollable dead players
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.deadPlayers.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, i) =>
                              _GraveyardSlot(player: widget.deadPlayers[i]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GraveyardSlot extends StatelessWidget {
  final PlayerModel player;
  const _GraveyardSlot({required this.player});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Grayscale avatar circle with skull
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkGrey.withValues(alpha: 0.4),
                  border: Border.all(color: AppColors.white10),
                ),
                child: Center(
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
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
                    child: Text(
                      player.name.isNotEmpty
                          ? player.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: AppColors.white30,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              // Skull overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.crimsonRed.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Text('💀', style: TextStyle(fontSize: 8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Name
          SizedBox(
            width: 48,
            child: Text(
              player.name,
              style: const TextStyle(
                color: AppColors.white50,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          // Role reveal (after death)
          if (player.role != null)
            Text(
              player.role!.displayName,
              style: TextStyle(
                color: _roleColor(player.role!).withValues(alpha: 0.4),
                fontSize: 6,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Color _roleColor(GameRole role) {
    switch (role) {
      case GameRole.mafia:
        return AppColors.crimsonRed;
      case GameRole.doctor:
        return AppColors.mintGreen;
      case GameRole.detective:
        return AppColors.purpleNeon;
      case GameRole.civilian:
        return AppColors.cyan;
    }
  }
}
