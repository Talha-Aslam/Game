import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/social/party_model.dart';

/// Animated slide-in popup for incoming party invites
class PartyInvitePopup extends StatefulWidget {
  final PartyInviteModel invite;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onDismiss;

  const PartyInvitePopup({
    super.key,
    required this.invite,
    required this.onAccept,
    required this.onReject,
    this.onDismiss,
  });

  @override
  State<PartyInvitePopup> createState() => _PartyInvitePopupState();
}

class _PartyInvitePopupState extends State<PartyInvitePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    // Auto-dismiss after 30s
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface.withValues(alpha: 0.95),
            border: Border.all(
              color: AppColors.cyan.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.15),
                blurRadius: 25,
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.groups,
                      color: AppColors.cyan,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Party Invite',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.cyan,
                          ),
                        ),
                        Text(
                          '${widget.invite.fromUser.username} invited you',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onReject();
                      _dismiss();
                    },
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white30,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Party info
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.white05,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoPill(
                      label: 'Mode',
                      value: widget.invite.gameMode.toUpperCase(),
                      color: widget.invite.gameMode == 'ranked'
                          ? AppColors.gold
                          : AppColors.cyan,
                    ),
                    _InfoPill(
                      label: 'Players',
                      value:
                          '${widget.invite.currentPartySize}/${widget.invite.maxPartySize}',
                      color: AppColors.mintGreen,
                    ),
                    if (widget.invite.fromUser.rankTier > 0)
                      _InfoPill(
                        label: 'Rank',
                        value: widget.invite.fromUser.rankName,
                        color: AppColors.purpleGlow,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        widget.onReject();
                        _dismiss();
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white05,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Center(
                          child: Text(
                            'Decline',
                            style: TextStyle(
                              color: AppColors.white50,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        widget.onAccept();
                        _dismiss();
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [AppColors.cyan, AppColors.cyanDeep],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'JOIN PARTY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white30,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
