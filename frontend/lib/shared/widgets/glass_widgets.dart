import 'dart:ui';
import 'package:flutter/material.dart';

// ─── Gradient Background Wrapper ───────────────────────────────────────────────
class GlassBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final List<Color>? customColors;

  const GlassBackground({
    super.key,
    required this.child,
    required this.isDark,
    this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = customColors ??
        (isDark
            ? [const Color(0xFF000000), const Color(0xFF080808), const Color(0xFF121212)]
            : [const Color(0xFFE8F4FD), const Color(0xFFF0E8FD), const Color(0xFFE8FDF4)]);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),
        // Decorative blobs - Slightly more subtle for true black mode
        Positioned(top: -80, right: -80,
          child: _Blob(color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.25), size: 260)),
        Positioned(bottom: 80, left: -100,
          child: _Blob(color: cs.tertiary.withValues(alpha: isDark ? 0.12 : 0.2), size: 300)),
        Positioned(top: 250, left: 50,
          child: _Blob(color: cs.secondary.withValues(alpha: isDark ? 0.08 : 0.12), size: 160)),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }
}

// ─── Frosted Glass Card ────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? tint;

  const GlassCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.radius = 20,
    this.onTap,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    // True black glassmorphism uses a dark container with low opacity or subtle white overlay
    final bg = tint ??
        (isDark 
            ? Colors.black.withValues(alpha: 0.45) // Deeper black for "black glass"
            : Colors.white.withValues(alpha: 0.58));
    
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08) // More subtle border for black mode
        : Colors.white.withValues(alpha: 0.85);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: border, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Glass AppBar ─────────────────────────────────────────────────────────────
PreferredSizeWidget glassAppBar({
  required String title,
  required bool isDark,
  List<Widget>? actions,
  Widget? leading,
  TextStyle? titleStyle,
  double elevation = 0,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          title: Text(title, style: titleStyle ?? const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: isDark
              ? Colors.black.withValues(alpha: 0.4) // Black glass for AppBar
              : Colors.white.withValues(alpha: 0.55),
          elevation: elevation,
          leading: leading,
          actions: actions,
        ),
      ),
    ),
  );
}

// ─── Glass Icon Badge ─────────────────────────────────────────────────────────
class GlassIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  final double size;

  const GlassIconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.isDark,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

// ─── Glass ListTile ────────────────────────────────────────────────────────────
class GlassTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  const GlassTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            GlassIconBadge(icon: icon, color: iconColor, isDark: isDark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!, style: TextStyle(color: cs.secondary, fontSize: 12)),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: cs.secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────
class GlassSectionHeader extends StatelessWidget {
  final String title;
  const GlassSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: cs.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
