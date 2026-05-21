import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Rotating event/promo banner carousel
class EventCarouselWidget extends StatefulWidget {
  const EventCarouselWidget({super.key});
  @override
  State<EventCarouselWidget> createState() => _EventCarouselWidgetState();
}

class _EventCarouselWidgetState extends State<EventCarouselWidget> {
  final _controller = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  static final _events = [
    _EventData('SEASON 1 BATTLE PASS', 'Unlock 50 exclusive rewards', AppColors.gold, Icons.stars),
    _EventData('SYNDICATE WARS', 'Register your family now', AppColors.crimsonRed, Icons.whatshot),
    _EventData('NEW SKINS AVAILABLE', 'Shadow Boss collection', AppColors.purpleGlow, Icons.auto_awesome),
    _EventData('DAILY LOGIN BONUS', 'Claim free rewards', AppColors.mintGreen, Icons.card_giftcard),
  ];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 56,
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemCount: _events.length,
          itemBuilder: (_, i) {
            final e = _events[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: e.color.withValues(alpha: 0.06),
                      border: Border.all(color: e.color.withValues(alpha: 0.2))),
                    child: Row(children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          color: e.color.withValues(alpha: 0.12)),
                        child: Icon(e.icon, color: e.color, size: 16)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.title, style: TextStyle(color: e.color,
                            fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          Text(e.subtitle, style: const TextStyle(
                            color: AppColors.white30, fontSize: 9)),
                        ])),
                      Icon(Icons.arrow_forward_ios, color: e.color.withValues(alpha: 0.4), size: 14),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 6),
      // Dots
      Row(mainAxisAlignment: MainAxisAlignment.center, children:
        List.generate(_events.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: _currentPage == i ? 12 : 4, height: 4,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
            color: _currentPage == i ? _events[i].color : AppColors.white10),
        )),
      ),
    ]);
  }
}

class _EventData {
  final String title, subtitle; final Color color; final IconData icon;
  _EventData(this.title, this.subtitle, this.color, this.icon);
}
