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
      duration: const Duration(milliseconds: 500), vsync: this);
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
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(_slideUp.value);
        return Transform.translate(
          offset: Offset(0, 60 * (1 - t)),
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    color: Colors.black.withValues(alpha: 0.4),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.crimsonRed.withValues(alpha: 0.15),
                        width: 0.5)),
                  ),
                  child: Row(children: [
                    // Graveyard label
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text('GRAVEYARD',
                        style: TextStyle(
                          color: AppColors.white30,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2)),
                    ),
                    Container(
                      width: 1, height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppColors.white10),
                    // Scrollable dead players
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.deadPlayers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) =>
                            _GraveyardSlot(player: widget.deadPlayers[i]),
                      ),
                    ),
                  ]),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Grayscale avatar circle with skull
        Stack(alignment: Alignment.center, children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkGrey.withValues(alpha: 0.4),
              border: Border.all(color: AppColors.white10)),
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 0.5, 0,
                ]),
                child: Text(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.white30,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
              ),
            ),
          ),
          // Skull overlay
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.crimsonRed.withValues(alpha: 0.4))),
              child: Center(
                child: Text('💀', style: TextStyle(fontSize: 8))),
            ),
          ),
        ]),
        const SizedBox(height: 3),
        // Name
        SizedBox(
          width: 44,
          child: Text(player.name,
            style: TextStyle(
              color: AppColors.white30,
              fontSize: 7,
              fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        ),
        // Role reveal (after death)
        if (player.role != null)
          Text(player.role!.displayName,
            style: TextStyle(
              color: _roleColor(player.role!).withValues(alpha: 0.4),
              fontSize: 6,
              fontWeight: FontWeight.w700)),
      ],
    );
  }

  Color _roleColor(GameRole role) {
    switch (role) {
      case GameRole.mafia: return AppColors.crimsonRed;
      case GameRole.doctor: return AppColors.mintGreen;
      case GameRole.detective: return AppColors.purpleNeon;
      case GameRole.civilian: return AppColors.cyan;
    }
  }
}
