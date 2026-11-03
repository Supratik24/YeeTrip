import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Animated splash and brand entrance screen.
///
/// Features a choreographed entrance animation revealing the cyan YeeTrip mark,
/// wordmark typography, tagline, and offline-first Indian travel badge,
/// before smoothly transitioning to the trip list screen.
class AnimatedSplashScreen extends StatefulWidget {
  final Duration autoNavigateDelay;
  final VoidCallback? onComplete;

  const AnimatedSplashScreen({
    super.key,
    this.autoNavigateDelay = const Duration(milliseconds: 2200),
    this.onComplete,
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markScale;
  late final Animation<double> _markRotate;
  late final Animation<double> _wordmarkFade;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _badgeFade;
  Timer? _navTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Phase 1: Mark bounces and scales in with a slight rotational flourish
    _markScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );

    _markRotate = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // Phase 2: Wordmark slides in from left and fades in
    _wordmarkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.70, curve: Curves.easeOut),
      ),
    );

    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    // Phase 3: Tagline reveals
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.85, curve: Curves.easeIn),
      ),
    );

    // Phase 4: Feature badges reveal
    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Auto-navigate after delay
    if (widget.autoNavigateDelay > Duration.zero) {
      _navTimer = Timer(widget.autoNavigateDelay, _navigateNext);
    }
  }

  void _navigateNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _navTimer?.cancel();

    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final wordmarkAsset = isDark
        ? 'assets/images/wordmark_dark.png'
        : 'assets/images/wordmark_transparent.png';

    return Scaffold(
      body: GestureDetector(
        key: const Key('splash_gesture_detector'),
        behavior: HitTestBehavior.opaque,
        onTap: _navigateNext,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFF8FAFC),
                      const Color(0xFFEDF7F6),
                      const Color(0xFFF8FAFC),
                    ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Skip Button in top corner
                Positioned(
                  top: 16,
                  right: 16,
                  child: TextButton(
                    key: const Key('skip_splash_btn'),
                    onPressed: _navigateNext,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Skip'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
                  ),
                ),

                // Main Animated Logo & Branding Center
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Animated Cyan Mark / Wallet Icon
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _markRotate.value,
                                child: Transform.scale(
                                  scale: _markScale.value,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              key: const Key('splash_logo_mark'),
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                                    blurRadius: 28,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(
                                'assets/images/logo_mark.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Image.asset(
                                  'assets/images/logo_transparent.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.wallet_rounded,
                                    color: Color(0xFF00C2E0),
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 2. Animated Wordmark Typography ("eeTrip")
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _wordmarkFade,
                                child: SlideTransition(
                                  position: _wordmarkSlide,
                                  child: child,
                                ),
                              );
                            },
                            child: Image.asset(
                              wordmarkAsset,
                              key: const Key('splash_wordmark_image'),
                              height: 52,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Text(
                                'YeeTrip',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 3. Animated Tagline
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Text(
                              'Smart Group Travel & Expense Splitting',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 4. Feature Badges (100% Offline • Integer Paise ₹ • Split & Settle)
                          FadeTransition(
                            opacity: _badgeFade,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildBadge(
                                  icon: Icons.offline_pin_rounded,
                                  label: '100% Offline',
                                  isDark: isDark,
                                ),
                                _buildBadge(
                                  icon: Icons.currency_rupee,
                                  label: 'Zero Float Errors',
                                  isDark: isDark,
                                ),
                                _buildBadge(
                                  icon: Icons.handshake_outlined,
                                  label: 'Min Settlements',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Pulse Indicator
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FadeTransition(
                      opacity: _badgeFade,
                      child: SizedBox(
                        width: 36,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2E0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFF00C2E0).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFF00C2E0).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF00A2C2)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
