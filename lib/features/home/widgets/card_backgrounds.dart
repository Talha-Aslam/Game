import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  MAFIA AT CITY — Calling Card Background Collection  (20 styles)
//  Every card is animated + textured. Use [cardStyleId] to pick one.
//
//  cc1  — Phantom Signal        cyberpunk purple scan-line sweep
//  cc2  — Obsidian Don          heavy black-gold embossed luxury
//  cc3  — Blood Contract        dark crimson radial burn + vein texture
//  cc4  — Neon Underworld       electric teal grid with neon pulse
//  cc5  — Ash & Ember           smouldering orange ember glow drift
//  cc6  — Chrome Syndicate      chrome metallic diagonal sheen shimmer
//  cc7  — Void Protocol         deep-space void with star-particle field
//  cc8  — Toxic Ledger          acid-green data rain streaks
//  cc9  — Gilded Throne         animated three-stop gold shimmer sweep
//  cc10 — Shadow Masquerade     violet gothic shimmer + corner filigree
//  cc11 — Ice Cartel            cold frost shatter diagonal prism
//  cc12 — Infernal Blueprint    hellfire red with scan-line grid overlay
//  cc13 — Digital Specter       matrix code cascade rain (green on black)
//  cc14 — Nocturne Silk         indigo-midnight satin diagonal sheen
//  cc15 — Wraith Glass          ghost-white breath on dark glass
//  cc16 — Crimson Frequency     heartbeat EKG line across deep red
//  cc17 — Copper Baron          aged copper verdigris texture pulse
//  cc18 — Eclipse Sovereign     solar-eclipse radial corona slow burn
//  cc19 — Storm Circuit         lightning-arc diagonal electric sweep
//  cc20 — Onyx Serpent          animated snake-scale hex mosaic (dark iridescent)
// ═══════════════════════════════════════════════════════════════════════════════

class PremiumCardBackground extends StatelessWidget {
  final Widget child;
  final String? cardStyleId;
  final double borderRadius;

  const PremiumCardBackground({
    super.key,
    required this.child,
    this.cardStyleId,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (cardStyleId) {
      case 'cc1':  return _PhantomSignalCard(br: borderRadius, child: child);
      case 'cc2':  return _ObsidianDonCard(br: borderRadius, child: child);
      case 'cc3':  return _BloodContractCard(br: borderRadius, child: child);
      case 'cc4':  return _NeonUnderworldCard(br: borderRadius, child: child);
      case 'cc5':  return _AshEmberCard(br: borderRadius, child: child);
      case 'cc6':  return _ChromeSyndicateCard(br: borderRadius, child: child);
      case 'cc7':  return _VoidProtocolCard(br: borderRadius, child: child);
      case 'cc8':  return _ToxicLedgerCard(br: borderRadius, child: child);
      case 'cc9':  return _GildedThroneCard(br: borderRadius, child: child);
      case 'cc10': return _ShadowMasqueradeCard(br: borderRadius, child: child);
      case 'cc11': return _IceCartelCard(br: borderRadius, child: child);
      case 'cc12': return _InfernalBlueprintCard(br: borderRadius, child: child);
      case 'cc13': return _DigitalSpecterCard(br: borderRadius, child: child);
      case 'cc14': return _NocturneSilkCard(br: borderRadius, child: child);
      case 'cc15': return _WraithGlassCard(br: borderRadius, child: child);
      case 'cc16': return _CrimsonFrequencyCard(br: borderRadius, child: child);
      case 'cc17': return _CopperBaronCard(br: borderRadius, child: child);
      case 'cc18': return _EclipseSovereignCard(br: borderRadius, child: child);
      case 'cc19': return _StormCircuitCard(br: borderRadius, child: child);
      case 'cc20': return _OnyxSerpentCard(br: borderRadius, child: child);
      default:
        return Container(
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED BASE: clips child to rounded rect and stacks layers
// ─────────────────────────────────────────────────────────────────────────────
class _CardBase extends StatelessWidget {
  final double br;
  final Widget child;
  final List<Widget> layers; // bottom → top, all IgnorePointer except child

  const _CardBase({required this.br, required this.child, required this.layers});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(br),
      child: Stack(children: [
        ...layers.map((l) => Positioned.fill(child: IgnorePointer(child: l))),
        child,
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC1 — PHANTOM SIGNAL
// Cyberpunk purple base; a bright magenta scan-line sweeps top→bottom on loop.
// ─────────────────────────────────────────────────────────────────────────────
class _PhantomSignalCard extends StatefulWidget {
  final Widget child; final double br;
  const _PhantomSignalCard({required this.child, required this.br});
  @override State<_PhantomSignalCard> createState() => _PhantomSignalCardState();
}
class _PhantomSignalCardState extends State<_PhantomSignalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      // Base gradient
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1A0030), Color(0xFF2E0857), Color(0xFF0D001A)],
      ))),
      // Scan-line texture (thin horizontal lines)
      CustomPaint(painter: _ScanLinePainter(color: const Color(0xFFBF00FF).withValues(alpha: 0.07))),
      // Circuit grid faint
      CustomPaint(painter: _GridPainter(color: const Color(0xFF7700CC).withValues(alpha: 0.12), spacing: 28)),
      // Animated sweep
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _SweepLinePainter(progress: _ctrl.value, color: const Color(0xFFFF00FF)))
      ),
      // Border glow
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFFBF00FF).withValues(alpha: 0.55), width: 1.2),
        boxShadow: [BoxShadow(color: const Color(0xFFBF00FF).withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 1)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC2 — OBSIDIAN DON
// Black base, three-stop gold diagonal shimmer sweeps slowly across the card.
// ─────────────────────────────────────────────────────────────────────────────
class _ObsidianDonCard extends StatefulWidget {
  final Widget child; final double br;
  const _ObsidianDonCard({required this.child, required this.br});
  @override State<_ObsidianDonCard> createState() => _ObsidianDonCardState();
}
class _ObsidianDonCardState extends State<_ObsidianDonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 5), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF0A0A0A), Color(0xFF1A1400), Color(0xFF0A0A0A)],
      ))),
      // Embossed diagonal texture
      CustomPaint(painter: _DiagonalHatchPainter(color: const Color(0xFFD4AF37).withValues(alpha: 0.04), spacing: 18)),
      // Gold shimmer sweep
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _DiagonalSweepPainter(progress: _ctrl.value, color: const Color(0xFFFFE878)))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), blurRadius: 14)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC3 — BLOOD CONTRACT
// Deep crimson radial gradient; dark vein-crack texture; pulsing red edge glow.
// ─────────────────────────────────────────────────────────────────────────────
class _BloodContractCard extends StatefulWidget {
  final Widget child; final double br;
  const _BloodContractCard({required this.child, required this.br});
  @override State<_BloodContractCard> createState() => _BloodContractCardState();
}
class _BloodContractCardState extends State<_BloodContractCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 900), vsync: this)..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _pulse, builder: (_, __) {
      final v = _pulse.value;
      return _CardBase(br: widget.br, child: widget.child, layers: [
        Container(decoration: const BoxDecoration(gradient: RadialGradient(
          center: Alignment.center, radius: 1.2,
          colors: [Color(0xFF3D0000), Color(0xFF1A0000), Color(0xFF0A0000)],
        ))),
        CustomPaint(painter: _VeinCrackPainter(color: const Color(0xFF8B0000).withValues(alpha: 0.25))),
        // Pulsing edge burn
        Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.br),
          gradient: RadialGradient(
            center: Alignment.center, radius: 0.9,
            colors: [Colors.transparent, const Color(0xFF8B0000).withValues(alpha: 0.1 + v * 0.35)],
          ),
        )),
        Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.br),
          border: Border.all(color: const Color(0xFFFF2200).withValues(alpha: 0.2 + v * 0.45), width: 1.2),
          boxShadow: [BoxShadow(color: const Color(0xFF8B0000).withValues(alpha: 0.25 + v * 0.3), blurRadius: 16)],
        )),
      ]);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC4 — NEON UNDERWORLD
// Dark teal base; animated glowing dot-grid with colour-cycling pulse nodes.
// ─────────────────────────────────────────────────────────────────────────────
class _NeonUnderworldCard extends StatefulWidget {
  final Widget child; final double br;
  const _NeonUnderworldCard({required this.child, required this.br});
  @override State<_NeonUnderworldCard> createState() => _NeonUnderworldCardState();
}
class _NeonUnderworldCardState extends State<_NeonUnderworldCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.bottomLeft, end: Alignment.topRight,
        colors: [Color(0xFF001A1A), Color(0xFF003333), Color(0xFF001010)],
      ))),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _PulsingDotGridPainter(progress: _ctrl.value, baseColor: const Color(0xFF00FFCC)))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFF00FFCC).withValues(alpha: 0.45), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFF00FFCC).withValues(alpha: 0.15), blurRadius: 12)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC5 — ASH & EMBER
// Near-black surface; slow-drifting ember particles float upward.
// ─────────────────────────────────────────────────────────────────────────────
class _AshEmberCard extends StatefulWidget {
  final Widget child; final double br;
  const _AshEmberCard({required this.child, required this.br});
  @override State<_AshEmberCard> createState() => _AshEmberCardState();
}
class _AshEmberCardState extends State<_AshEmberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 6), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0603), Color(0xFF1A0A00), Color(0xFF250E00)],
      ))),
      CustomPaint(painter: _AshTexturePainter()),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _EmberParticlePainter(progress: _ctrl.value))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xFFFF4400)], stops: [0.7, 1.0],
        ),
      )),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFFFF6600).withValues(alpha: 0.4), width: 1.2),
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC6 — CHROME SYNDICATE
// Silver-grey metallic base; bright specular highlight sweeps diagonally fast.
// ─────────────────────────────────────────────────────────────────────────────
class _ChromeSyndicateCard extends StatefulWidget {
  final Widget child; final double br;
  const _ChromeSyndicateCard({required this.child, required this.br});
  @override State<_ChromeSyndicateCard> createState() => _ChromeSyndicateCardState();
}
class _ChromeSyndicateCardState extends State<_ChromeSyndicateCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1C1C1C), Color(0xFF3A3A3A), Color(0xFF111111)],
      ))),
      CustomPaint(painter: _DiagonalHatchPainter(color: Colors.white.withValues(alpha: 0.03), spacing: 12)),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _ChromeSpecularPainter(progress: _ctrl.value))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.07), blurRadius: 8)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC7 — VOID PROTOCOL
// Deep space black; procedural star-particle field slowly twinkles.
// ─────────────────────────────────────────────────────────────────────────────
class _VoidProtocolCard extends StatefulWidget {
  final Widget child; final double br;
  const _VoidProtocolCard({required this.child, required this.br});
  @override State<_VoidProtocolCard> createState() => _VoidProtocolCardState();
}
class _VoidProtocolCardState extends State<_VoidProtocolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 5), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment.center, radius: 1.4,
        colors: [Color(0xFF050010), Color(0xFF000000)],
      ))),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _StarFieldPainter(progress: _ctrl.value))
      ),
      // Nebula haze
      Container(decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment(-0.3, -0.4), radius: 0.9,
        colors: [Color(0x226600CC), Colors.transparent],
      ))),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFF6600CC).withValues(alpha: 0.4), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFF6600CC).withValues(alpha: 0.15), blurRadius: 14)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC8 — TOXIC LEDGER
// Black base; vertical acid-green streaks fall like data rain.
// ─────────────────────────────────────────────────────────────────────────────
class _ToxicLedgerCard extends StatefulWidget {
  final Widget child; final double br;
  const _ToxicLedgerCard({required this.child, required this.br});
  @override State<_ToxicLedgerCard> createState() => _ToxicLedgerCardState();
}
class _ToxicLedgerCardState extends State<_ToxicLedgerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF010801), Color(0xFF001400)],
      ))),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _DataRainPainter(progress: _ctrl.value, color: const Color(0xFF39FF14)))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFF39FF14).withValues(alpha: 0.35), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFF39FF14).withValues(alpha: 0.12), blurRadius: 10)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC9 — GILDED THRONE
// Warm black; triple-band animated gold shimmer that pans slowly left to right.
// ─────────────────────────────────────────────────────────────────────────────
class _GildedThroneCard extends StatefulWidget {
  final Widget child; final double br;
  const _GildedThroneCard({required this.child, required this.br});
  @override State<_GildedThroneCard> createState() => _GildedThroneCardState();
}
class _GildedThroneCardState extends State<_GildedThroneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF0F0B00), Color(0xFF1A1400), Color(0xFF0A0800)],
      ))),
      CustomPaint(painter: _DiagonalHatchPainter(color: const Color(0xFFD4AF37).withValues(alpha: 0.05), spacing: 22)),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _TripleBandShimmerPainter(progress: _ctrl.value, color: const Color(0xFFFFE878)))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.7), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), blurRadius: 14)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC10 — SHADOW MASQUERADE
// Dark violet; breathing shimmer + corner filigree ornaments painted in gold.
// ─────────────────────────────────────────────────────────────────────────────
class _ShadowMasqueradeCard extends StatefulWidget {
  final Widget child; final double br;
  const _ShadowMasqueradeCard({required this.child, required this.br});
  @override State<_ShadowMasqueradeCard> createState() => _ShadowMasqueradeCardState();
}
class _ShadowMasqueradeCardState extends State<_ShadowMasqueradeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _breath;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat(reverse: true);
    _breath = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _breath, builder: (_, __) {
      final v = _breath.value;
      return _CardBase(br: widget.br, child: widget.child, layers: [
        Container(decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0D0020), Color(0xFF1A0040), Color(0xFF080010)],
        ))),
        CustomPaint(painter: _DiagonalHatchPainter(color: const Color(0xFF7B2FBE).withValues(alpha: 0.07), spacing: 20)),
        Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.br),
          gradient: RadialGradient(center: Alignment.center, radius: 1.0, colors: [
            const Color(0xFF7B2FBE).withValues(alpha: 0.08 + v * 0.18), Colors.transparent,
          ]),
        )),
        CustomPaint(painter: _FiligreePainter(alpha: 0.35 + v * 0.45)),
        Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.br),
          border: Border.all(color: const Color(0xFF9933FF).withValues(alpha: 0.3 + v * 0.4), width: 1.2),
          boxShadow: [BoxShadow(color: const Color(0xFF7B2FBE).withValues(alpha: 0.2 + v * 0.2), blurRadius: 14)],
        )),
      ]);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC11 — ICE CARTEL
// Cold midnight blue; diagonal prism refraction fracture lines shimmer.
// ─────────────────────────────────────────────────────────────────────────────
class _IceCartelCard extends StatefulWidget {
  final Widget child; final double br;
  const _IceCartelCard({required this.child, required this.br});
  @override State<_IceCartelCard> createState() => _IceCartelCardState();
}
class _IceCartelCardState extends State<_IceCartelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 5), vsync: this)..repeat(reverse: true); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topRight, end: Alignment.bottomLeft,
        colors: [Color(0xFF001833), Color(0xFF000D20), Color(0xFF001028)],
      ))),
      CustomPaint(painter: _IceFracturePainter()),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _PrismSweepPainter(progress: _ctrl.value))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFF88CCFF).withValues(alpha: 0.4), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFF0088FF).withValues(alpha: 0.15), blurRadius: 12)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC12 — INFERNAL BLUEPRINT
// Red-hot hell base; faint technical grid overlay; animated heat shimmer.
// ─────────────────────────────────────────────────────────────────────────────
class _InfernalBlueprintCard extends StatefulWidget {
  final Widget child; final double br;
  const _InfernalBlueprintCard({required this.child, required this.br});
  @override State<_InfernalBlueprintCard> createState() => _InfernalBlueprintCardState();
}
class _InfernalBlueprintCardState extends State<_InfernalBlueprintCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment.bottomCenter, radius: 1.3,
        colors: [Color(0xFF2A0000), Color(0xFF0A0000)],
      ))),
      CustomPaint(painter: _GridPainter(color: const Color(0xFFFF2200).withValues(alpha: 0.1), spacing: 24)),
      CustomPaint(painter: _ScanLinePainter(color: const Color(0xFFFF4400).withValues(alpha: 0.04))),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _HeatShimmerPainter(progress: _ctrl.value))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFFFF2200).withValues(alpha: 0.45), width: 1.2),
        boxShadow: [BoxShadow(color: const Color(0xFFFF2200).withValues(alpha: 0.2), blurRadius: 14)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC13 — DIGITAL SPECTER
// Matrix code rain on deep black; cascading columns of bright green chars.
// ─────────────────────────────────────────────────────────────────────────────
class _DigitalSpecterCard extends StatefulWidget {
  final Widget child; final double br;
  const _DigitalSpecterCard({required this.child, required this.br});
  @override State<_DigitalSpecterCard> createState() => _DigitalSpecterCardState();
}
class _DigitalSpecterCardState extends State<_DigitalSpecterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(color: const Color(0xFF010801)),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _MatrixRainPainter(progress: _ctrl.value))
      ),
      // Fade bottom
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0xBB010801)], stops: [0.5, 1.0],
      ))),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFF00FF41).withValues(alpha: 0.3), width: 1),
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC14 — NOCTURNE SILK
// Indigo-midnight satin; slow diagonal sheen that feels like expensive fabric.
// ─────────────────────────────────────────────────────────────────────────────
class _NocturneSilkCard extends StatefulWidget {
  final Widget child; final double br;
  const _NocturneSilkCard({required this.child, required this.br});
  @override State<_NocturneSilkCard> createState() => _NocturneSilkCardState();
}
class _NocturneSilkCardState extends State<_NocturneSilkCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 6), vsync: this)..repeat(reverse: true); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF0A0020), Color(0xFF1A0050), Color(0xFF050015)],
      ))),
      CustomPaint(painter: _SilkWeavePainter()),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _SatinSheenPainter(progress: _ctrl.value))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFF6633CC).withValues(alpha: 0.4), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFF330099).withValues(alpha: 0.2), blurRadius: 12)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC15 — WRAITH GLASS
// Frosted dark glass; ghost-white mist breathes in and out slowly.
// ─────────────────────────────────────────────────────────────────────────────
class _WraithGlassCard extends StatefulWidget {
  final Widget child; final double br;
  const _WraithGlassCard({required this.child, required this.br});
  @override State<_WraithGlassCard> createState() => _WraithGlassCardState();
}
class _WraithGlassCardState extends State<_WraithGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _breath;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(seconds: 5), vsync: this)..repeat(reverse: true);
    _breath = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _breath, builder: (_, __) {
      final v = _breath.value;
      return _CardBase(br: widget.br, child: widget.child, layers: [
        Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF0F0F0F), const Color(0xFF1E1E1E), v)!,
            Color.lerp(const Color(0xFF080808), const Color(0xFF141414), v)!,
          ],
        ))),
        Container(decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02 + v * 0.04),
        )),
        // Ghost mist orbs
        Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: Alignment(-0.4 + v * 0.3, -0.3), radius: 0.7,
          colors: [Colors.white.withValues(alpha: 0.04 + v * 0.06), Colors.transparent],
        ))),
        Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: Alignment(0.5 - v * 0.2, 0.5), radius: 0.6,
          colors: [Colors.white.withValues(alpha: 0.02 + v * 0.04), Colors.transparent],
        ))),
        Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.br),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08 + v * 0.15), width: 1),
        )),
      ]);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC16 — CRIMSON FREQUENCY
// Deep red; an animated EKG heartbeat line pulses across the card horizontally.
// ─────────────────────────────────────────────────────────────────────────────
class _CrimsonFrequencyCard extends StatefulWidget {
  final Widget child; final double br;
  const _CrimsonFrequencyCard({required this.child, required this.br});
  @override State<_CrimsonFrequencyCard> createState() => _CrimsonFrequencyCardState();
}
class _CrimsonFrequencyCardState extends State<_CrimsonFrequencyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1A0000), Color(0xFF2A0000), Color(0xFF0D0000)],
      ))),
      CustomPaint(painter: _ScanLinePainter(color: const Color(0xFF8B0000).withValues(alpha: 0.06))),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _EKGPainter(progress: _ctrl.value, color: const Color(0xFFFF2200)))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFF8B0000).withValues(alpha: 0.5), width: 1.2),
        boxShadow: [BoxShadow(color: const Color(0xFF8B0000).withValues(alpha: 0.2), blurRadius: 12)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC17 — COPPER BARON
// Aged copper verdigris; oxidised teal-brown texture slowly breathes green.
// ─────────────────────────────────────────────────────────────────────────────
class _CopperBaronCard extends StatefulWidget {
  final Widget child; final double br;
  const _CopperBaronCard({required this.child, required this.br});
  @override State<_CopperBaronCard> createState() => _CopperBaronCardState();
}
class _CopperBaronCardState extends State<_CopperBaronCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _breath;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(seconds: 5), vsync: this)..repeat(reverse: true);
    _breath = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _breath, builder: (_, __) {
      final v = _breath.value;
      return _CardBase(br: widget.br, child: widget.child, layers: [
        Container(decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A00), Color(0xFF2B1500), Color(0xFF0D0600)],
        ))),
        Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: Alignment(-0.5 + v * 0.3, -0.5 + v * 0.2), radius: 1.0,
          colors: [const Color(0xFF00554A).withValues(alpha: 0.2 + v * 0.25), Colors.transparent],
        ))),
        CustomPaint(painter: _CopperTexturePainter(progress: v)),
        Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.br),
          border: Border.all(
            color: Color.lerp(const Color(0xFFB87333), const Color(0xFF00897B), v * 0.5)!.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [BoxShadow(color: const Color(0xFF00554A).withValues(alpha: 0.12 + v * 0.15), blurRadius: 12)],
        )),
      ]);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC18 — ECLIPSE SOVEREIGN
// Black; a golden solar-eclipse radial corona slowly rotates around the card centre.
// ─────────────────────────────────────────────────────────────────────────────
class _EclipseSovereignCard extends StatefulWidget {
  final Widget child; final double br;
  const _EclipseSovereignCard({required this.child, required this.br});
  @override State<_EclipseSovereignCard> createState() => _EclipseSovereignCardState();
}
class _EclipseSovereignCardState extends State<_EclipseSovereignCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 14), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: RadialGradient(
        center: Alignment.center, radius: 1.0,
        colors: [Color(0xFF0F0B00), Color(0xFF000000)],
      ))),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _EclipseCoronaPainter(progress: _ctrl.value))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), blurRadius: 14)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC19 — STORM CIRCUIT
// Charcoal base; diagonal electric arcs fire across the surface irregularly.
// ─────────────────────────────────────────────────────────────────────────────
class _StormCircuitCard extends StatefulWidget {
  final Widget child; final double br;
  const _StormCircuitCard({required this.child, required this.br});
  @override State<_StormCircuitCard> createState() => _StormCircuitCardState();
}
class _StormCircuitCardState extends State<_StormCircuitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF0D0D10), Color(0xFF1A1A20), Color(0xFF080810)],
      ))),
      CustomPaint(painter: _GridPainter(color: const Color(0xFFFFE033).withValues(alpha: 0.05), spacing: 30)),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _ElectricArcPainter(progress: _ctrl.value))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: const Color(0xFFFFE033).withValues(alpha: 0.35), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFFFFE033).withValues(alpha: 0.1), blurRadius: 10)],
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CC20 — ONYX SERPENT
// Jet black; animated iridescent snake-scale hex mosaic shimmers subtly.
// ─────────────────────────────────────────────────────────────────────────────
class _OnyxSerpentCard extends StatefulWidget {
  final Widget child; final double br;
  const _OnyxSerpentCard({required this.child, required this.br});
  @override State<_OnyxSerpentCard> createState() => _OnyxSerpentCardState();
}
class _OnyxSerpentCardState extends State<_OnyxSerpentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(duration: const Duration(seconds: 5), vsync: this)..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _CardBase(br: widget.br, child: widget.child, layers: [
      Container(color: const Color(0xFF050505)),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) =>
        CustomPaint(painter: _HexScalePainter(progress: _ctrl.value))
      ),
      Container(decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.br),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xFF220033).withValues(alpha: 0.4), blurRadius: 14)],
      )),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════

// Horizontal scan-line texture
class _ScanLinePainter extends CustomPainter {
  final Color color;
  const _ScanLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(covariant _ScanLinePainter old) => old.color != color;
}

// Orthogonal dot/line grid
class _GridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  const _GridPainter({required this.color, required this.spacing});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(covariant _GridPainter old) => false;
}

// Diagonal hatch texture
class _DiagonalHatchPainter extends CustomPainter {
  final Color color;
  final double spacing;
  const _DiagonalHatchPainter({required this.color, required this.spacing});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.8;
    for (double d = -size.height; d < size.width + size.height; d += spacing) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), paint);
    }
  }
  @override bool shouldRepaint(covariant _DiagonalHatchPainter old) => false;
}

// Horizontal scan sweep (bright line travels top→bottom)
class _SweepLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  const _SweepLinePainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, color.withValues(alpha: 0.45), Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 12, size.width, 24));
    canvas.drawRect(Rect.fromLTWH(0, y - 12, size.width, 24), paint);
  }
  @override bool shouldRepaint(covariant _SweepLinePainter old) => old.progress != old.progress;
}

// Diagonal shimmer sweep (for gold cards)
class _DiagonalSweepPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _DiagonalSweepPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final diag = size.width + size.height;
    final offset = progress * diag * 1.4 - diag * 0.2;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Colors.transparent, color.withValues(alpha: 0.25), color.withValues(alpha: 0.5),
                 color.withValues(alpha: 0.25), Colors.transparent],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(offset - 60, 0, 120, size.height));
    final path = Path()
      ..moveTo(offset - 80, 0)..lineTo(offset + 40, 0)
      ..lineTo(offset + 40 - size.height, size.height)
      ..lineTo(offset - 80 - size.height, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant _DiagonalSweepPainter old) => old.progress != old.progress;
}

// Triple-band shimmer (gilded throne)
class _TripleBandShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _TripleBandShimmerPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final offsets = [0.0, 0.33, 0.66];
    for (final base in offsets) {
      final p = (progress + base) % 1.0;
      final x = p * (size.width + 60) - 30;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.18);
      canvas.drawRect(Rect.fromLTWH(x - 10, 0, 20, size.height), paint);
    }
  }
  @override bool shouldRepaint(covariant _TripleBandShimmerPainter old) => old.progress != old.progress;
}

// Pulsing dot grid (neon underworld)
class _PulsingDotGridPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  const _PulsingDotGridPainter({required this.progress, required this.baseColor});
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 26.0;
    final rng = Random(42);
    int col = 0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      int row = 0;
      for (double y = spacing / 2; y < size.height; y += spacing) {
        final phase = rng.nextDouble();
        final lit = sin((progress + phase) * 2 * pi) > 0.4;
        final alpha = lit ? 0.6 : 0.08;
        final radius = lit ? 2.0 : 1.2;
        canvas.drawCircle(Offset(x, y), radius,
            Paint()..color = baseColor.withValues(alpha: alpha));
        row++;
      }
      col++;
    }
  }
  @override bool shouldRepaint(covariant _PulsingDotGridPainter old) => old.progress != old.progress;
}

// Ember particle float (ash & ember)
class _EmberParticlePainter extends CustomPainter {
  final double progress;
  const _EmberParticlePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(7);
    for (int i = 0; i < 28; i++) {
      final baseX = rng.nextDouble() * size.width;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble();
      final t = (progress * speed + phase) % 1.0;
      final y = size.height * (1.0 - t);
      final drift = sin((progress * 2 + phase) * 2 * pi) * 12;
      final x = baseX + drift;
      final alpha = (sin(t * pi)).clamp(0.0, 1.0) * 0.8;
      final r = 1.0 + rng.nextDouble() * 2;
      canvas.drawCircle(
        Offset(x, y), r,
        Paint()..color = Color.lerp(const Color(0xFFFF4400), const Color(0xFFFFCC00), rng.nextDouble())!.withValues(alpha: alpha),
      );
    }
  }
  @override bool shouldRepaint(covariant _EmberParticlePainter old) => old.progress != old.progress;
}

// Ash texture (static random noise dots)
class _AshTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(99);
    for (int i = 0; i < 200; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 1.2,
        Paint()..color = Colors.white.withValues(alpha: rng.nextDouble() * 0.08),
      );
    }
  }
  @override bool shouldRepaint(CustomPainter old) => false;
}

// Chrome specular highlight
class _ChromeSpecularPainter extends CustomPainter {
  final double progress;
  const _ChromeSpecularPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final x = progress * size.width;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.08), Colors.transparent],
        stops: const [0.0, 0.4, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(x - 40, 0, 80, size.height));
    final path = Path()
      ..moveTo(x - 60, 0)..lineTo(x + 20, 0)
      ..lineTo(x + 20 - size.height * 0.5, size.height)
      ..lineTo(x - 60 - size.height * 0.5, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant _ChromeSpecularPainter old) => old.progress != old.progress;
}

// Star field twinkle
class _StarFieldPainter extends CustomPainter {
  final double progress;
  const _StarFieldPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final phase = rng.nextDouble();
      final brightness = (sin((progress + phase) * 2 * pi) * 0.5 + 0.5);
      final r = 0.5 + rng.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), r,
          Paint()..color = Colors.white.withValues(alpha: 0.1 + brightness * 0.7));
    }
  }
  @override bool shouldRepaint(covariant _StarFieldPainter old) => old.progress != old.progress;
}

// Data rain streaks (vertical)
class _DataRainPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _DataRainPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(13);
    const cols = 12;
    for (int i = 0; i < cols; i++) {
      final x = (i / cols) * size.width + rng.nextDouble() * (size.width / cols);
      final phase = rng.nextDouble();
      final speed = 0.5 + rng.nextDouble() * 0.5;
      final t = (progress * speed + phase) % 1.0;
      final y = t * size.height;
      final len = 20.0 + rng.nextDouble() * 40;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, color.withValues(alpha: 0.8), Colors.transparent],
        ).createShader(Rect.fromLTWH(x - 1, y - len, 2, len * 2));
      canvas.drawRect(Rect.fromLTWH(x - 0.8, y - len, 1.6, len), paint);
    }
  }
  @override bool shouldRepaint(covariant _DataRainPainter old) => old.progress != old.progress;
}

// Vein crack texture (blood contract)
class _VeinCrackPainter extends CustomPainter {
  final Color color;
  const _VeinCrackPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1..style = PaintingStyle.stroke;
    final rng = Random(5);
    void drawCrack(Offset start, double angle, int depth) {
      if (depth <= 0) return;
      final len = 20.0 + rng.nextDouble() * 30;
      final end = Offset(start.dx + cos(angle) * len, start.dy + sin(angle) * len);
      canvas.drawLine(start, end, paint);
      if (rng.nextDouble() > 0.4) drawCrack(end, angle + 0.5 + rng.nextDouble() * 0.8, depth - 1);
      if (rng.nextDouble() > 0.6) drawCrack(end, angle - 0.5 - rng.nextDouble() * 0.6, depth - 1);
    }
    drawCrack(Offset(size.width * 0.2, size.height * 0.1), pi / 4, 5);
    drawCrack(Offset(size.width * 0.8, size.height * 0.85), pi + pi / 5, 4);
    drawCrack(Offset(size.width * 0.5, size.height * 0.4), -pi / 3, 3);
  }
  @override bool shouldRepaint(covariant _VeinCrackPainter old) => false;
}

// Ice fracture lines (static)
class _IceFracturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 0.8;
    final rng = Random(21);
    for (int i = 0; i < 8; i++) {
      final x1 = rng.nextDouble() * size.width;
      final y1 = rng.nextDouble() * size.height;
      final x2 = x1 + (rng.nextDouble() - 0.5) * 80;
      final y2 = y1 + (rng.nextDouble() - 0.5) * 80;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
  @override bool shouldRepaint(CustomPainter old) => false;
}

// Prism colour sweep (ice cartel)
class _PrismSweepPainter extends CustomPainter {
  final double progress;
  const _PrismSweepPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final x = progress * size.width;
    final paint = Paint()
      ..shader = LinearGradient(colors: [
        Colors.transparent,
        const Color(0xFF88CCFF).withValues(alpha: 0.15),
        const Color(0xFFAAFFFF).withValues(alpha: 0.2),
        const Color(0xFF88CCFF).withValues(alpha: 0.12),
        Colors.transparent,
      ]).createShader(Rect.fromLTWH(x - 30, 0, 60, size.height));
    final path = Path()
      ..moveTo(x - 50, 0)..lineTo(x + 10, 0)
      ..lineTo(x + 10 - size.height * 0.4, size.height)
      ..lineTo(x - 50 - size.height * 0.4, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant _PrismSweepPainter old) => old.progress != old.progress;
}

// Heat shimmer (infernal blueprint)
class _HeatShimmerPainter extends CustomPainter {
  final double progress;
  const _HeatShimmerPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 4; i++) {
      final y = (progress * size.height + i * size.height / 4) % size.height;
      final paint = Paint()
        ..color = const Color(0xFFFF4400).withValues(alpha: 0.06);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 3), paint);
    }
  }
  @override bool shouldRepaint(covariant _HeatShimmerPainter old) => old.progress != old.progress;
}

// Matrix rain (digital specter)
class _MatrixRainPainter extends CustomPainter {
  final double progress;
  const _MatrixRainPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    const cols = 14;
    final rng = Random(77);
    final colW = size.width / cols;
    for (int c = 0; c < cols; c++) {
      final x = c * colW + colW / 2;
      final phase = rng.nextDouble();
      final speed = 0.4 + rng.nextDouble() * 0.6;
      final t = (progress * speed + phase) % 1.0;
      final headY = t * size.height;
      const segments = 5;
      for (int s = 0; s < segments; s++) {
        final segY = headY - s * 14.0;
        final alpha = (1.0 - s / segments) * 0.8;
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, segY), width: colW * 0.6, height: 10),
          Paint()..color = const Color(0xFF00FF41).withValues(alpha: alpha * 0.3),
        );
      }
      // Bright head dot
      canvas.drawCircle(Offset(x, headY), 2,
          Paint()..color = const Color(0xFFCCFFCC).withValues(alpha: 0.7));
    }
  }
  @override bool shouldRepaint(covariant _MatrixRainPainter old) => old.progress != old.progress;
}

// Silk weave texture
class _SilkWeavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 0.5;
    const spacing = 16.0;
    for (double d = 0; d < size.width + size.height; d += spacing) {
      paint.color = const Color(0xFF6633CC).withValues(alpha: 0.05);
      canvas.drawLine(Offset(d, 0), Offset(0, d), paint);
      paint.color = const Color(0xFF9966FF).withValues(alpha: 0.03);
      canvas.drawLine(Offset(size.width - d, 0), Offset(size.width, d), paint);
    }
  }
  @override bool shouldRepaint(CustomPainter old) => false;
}

// Satin sheen (nocturne silk)
class _SatinSheenPainter extends CustomPainter {
  final double progress;
  const _SatinSheenPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width * 0.3 + progress * size.width * 1.6;
    final paint = Paint()
      ..shader = LinearGradient(colors: [
        Colors.transparent,
        const Color(0xFF9966FF).withValues(alpha: 0.1),
        Colors.white.withValues(alpha: 0.06),
        const Color(0xFF9966FF).withValues(alpha: 0.08),
        Colors.transparent,
      ]).createShader(Rect.fromLTWH(x - 50, 0, 100, size.height));
    final path = Path()
      ..moveTo(x - 70, 0)..lineTo(x + 30, 0)
      ..lineTo(x + 30 - size.height * 0.6, size.height)
      ..lineTo(x - 70 - size.height * 0.6, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant _SatinSheenPainter old) => old.progress != old.progress;
}

// EKG heartbeat line
class _EKGPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _EKGPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final midY = size.height * 0.5;
    const segCount = 5;
    final segW = size.width / segCount;
    // Scrolling offset
    final offset = -(progress * size.width);

    for (int rep = -1; rep <= segCount + 1; rep++) {
      final bx = rep * segW + offset;
      // Flat → spike → return
      final points = [
        Offset(bx, midY),
        Offset(bx + segW * 0.35, midY),
        Offset(bx + segW * 0.42, midY - size.height * 0.32),
        Offset(bx + segW * 0.47, midY + size.height * 0.22),
        Offset(bx + segW * 0.52, midY - size.height * 0.14),
        Offset(bx + segW * 0.58, midY),
        Offset(bx + segW, midY),
      ];
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }
  @override bool shouldRepaint(covariant _EKGPainter old) => old.progress != old.progress;
}

// Copper oxidised texture
class _CopperTexturePainter extends CustomPainter {
  final double progress;
  const _CopperTexturePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(33);
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 2.0 + rng.nextDouble() * 12;
      final alpha = rng.nextDouble() * 0.12 * progress;
      canvas.drawCircle(Offset(x, y), r,
          Paint()..color = const Color(0xFF00897B).withValues(alpha: alpha)..style = PaintingStyle.fill);
    }
    for (int i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        1.0 + rng.nextDouble() * 3,
        Paint()..color = const Color(0xFFB87333).withValues(alpha: 0.08 + rng.nextDouble() * 0.06),
      );
    }
  }
  @override bool shouldRepaint(covariant _CopperTexturePainter old) => old.progress != old.progress;
}

// Eclipse corona (radial rays rotating around card centre)
class _EclipseCoronaPainter extends CustomPainter {
  final double progress;
  const _EclipseCoronaPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = sqrt(cx * cx + cy * cy) * 1.05;
    final baseAngle = progress * 2 * pi;

    for (int i = 0; i < 32; i++) {
      final a = baseAngle + (i / 32) * 2 * pi;
      final rng = Random(i * 17);
      final len = maxR * (0.4 + rng.nextDouble() * 0.5);
      final alpha = 0.03 + rng.nextDouble() * 0.09;
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFFD4AF37).withValues(alpha: alpha * 1.4), Colors.transparent],
        ).createShader(Rect.fromLTWH(cx, cy, cos(a) * len, sin(a) * len))
        ..strokeWidth = 1.5 + rng.nextDouble() * 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + cos(a) * len, cy + sin(a) * len),
        paint,
      );
    }
    // Eclipse disc
    canvas.drawCircle(Offset(cx, cy), maxR * 0.25,
        Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.06));
  }
  @override bool shouldRepaint(covariant _EclipseCoronaPainter old) => old.progress != old.progress;
}

// Electric arc bolts
class _ElectricArcPainter extends CustomPainter {
  final double progress;
  const _ElectricArcPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final t = progress;
    final firing1 = t < 0.1 || (t > 0.55 && t < 0.62);
    final firing2 = (t > 0.28 && t < 0.36);

    void drawArc(bool active, int seed) {
      if (!active) return;
      final rng = Random(seed + (t * 100).toInt());
      final x1 = rng.nextDouble() * size.width;
      final y1 = rng.nextDouble() * size.height;
      final x2 = rng.nextDouble() * size.width;
      final y2 = rng.nextDouble() * size.height;
      final mid = Offset((x1 + x2) / 2 + (rng.nextDouble() - 0.5) * 30, (y1 + y2) / 2 + (rng.nextDouble() - 0.5) * 30);
      final paint = Paint()
        ..color = const Color(0xFFFFE033).withValues(alpha: 0.65)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(x1, y1)..quadraticBezierTo(mid.dx, mid.dy, x2, y2);
      canvas.drawPath(path, paint);
      // Glow
      canvas.drawPath(path,
        Paint()..color = const Color(0xFFFFE033).withValues(alpha: 0.12)..strokeWidth = 4..style = PaintingStyle.stroke);
    }

    drawArc(firing1, 11);
    drawArc(firing2, 37);
  }
  @override bool shouldRepaint(covariant _ElectricArcPainter old) => old.progress != old.progress;
}

// Snake hex scale mosaic
class _HexScalePainter extends CustomPainter {
  final double progress;
  const _HexScalePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    const r = 12.0;
    const h = r * 1.732;
    final rng = Random(55);

    double row = 0;
    while (row * h * 0.75 < size.height + h) {
      final isOdd = row.toInt() % 2 == 1;
      double col = 0;
      while (col * r * 2 < size.width + r * 2) {
        final cx = col * r * 2 + (isOdd ? r : 0) - r;
        final cy = row * h * 0.75;
        final phase = rng.nextDouble();
        final shimmer = (sin((progress + phase) * 2 * pi) * 0.5 + 0.5);
        // Iridescent palette: dark green → purple → black
        final hue = (phase * 360 + progress * 60) % 360;
        final scaleColor = HSVColor.fromAHSV(1.0, hue, 0.8, 0.2 + shimmer * 0.25).toColor();

        final path = _hexPath(Offset(cx, cy), r - 1);
        canvas.drawPath(path, Paint()..color = scaleColor..style = PaintingStyle.fill);
        canvas.drawPath(path, Paint()
          ..color = Colors.black.withValues(alpha: 0.8)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke);
        col++;
      }
      row++;
    }
  }

  Path _hexPath(Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * 2 * pi + pi / 6;
      final x = center.dx + r * cos(a);
      final y = center.dy + r * sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override bool shouldRepaint(covariant _HexScalePainter old) => old.progress != old.progress;
}

// Corner filigree ornament (shadow masquerade)
class _FiligreePainter extends CustomPainter {
  final double alpha;
  const _FiligreePainter({required this.alpha});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: alpha)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    void drawCorner(double cx, double cy, double rotAngle) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotAngle);
      // L-bracket
      canvas.drawLine(const Offset(0, 0), const Offset(14, 0), paint);
      canvas.drawLine(const Offset(0, 0), const Offset(0, 14), paint);
      // Curl
      canvas.drawArc(const Rect.fromLTWH(4, 4, 10, 10), pi, pi / 2, false, paint);
      // Dot
      canvas.drawCircle(const Offset(6, 6), 1.5, Paint()..color = const Color(0xFFD4AF37).withValues(alpha: alpha));
      canvas.restore();
    }

    drawCorner(8, 8, 0);
    drawCorner(size.width - 8, 8, pi / 2);
    drawCorner(size.width - 8, size.height - 8, pi);
    drawCorner(8, size.height - 8, -pi / 2);
  }
  @override bool shouldRepaint(covariant _FiligreePainter old) => old.alpha != alpha;
}