import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/custom_icons.dart';
import 'package:frontend/features/shared/widgets/premium_card.dart';
import 'package:frontend/features/dashboard/presentation/widgets/digital_twin_widget.dart';
import 'package:frontend/features/dashboard/presentation/widgets/live_status_panel.dart';
import 'package:frontend/features/dashboard/presentation/widgets/ai_command_center_log.dart';
import 'package:frontend/features/simulator/presentation/widgets/scenario_dialog.dart';
import 'package:frontend/features/chatbot/presentation/widgets/chatbot_widget.dart';
import 'package:frontend/features/dashboard/presentation/widgets/navigation_provider.dart';
import 'package:frontend/features/dashboard/presentation/widgets/microgrid_map_widget.dart';
import 'package:frontend/features/dashboard/presentation/widgets/analytics_view.dart';
import 'package:frontend/features/dashboard/presentation/widgets/settings_view.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _sidebarAnimController;

  @override
  void initState() {
    super.initState();
    _sidebarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _sidebarAnimController.forward();
  }

  @override
  void dispose() {
    _sidebarAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeTabProvider);

    return Scaffold(
      body: Row(
        children: [
          // ── Enhanced Sidebar ──────────────────────────────────────────────
          Container(
            width: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.kombuGreen,
                  AppTheme.kombuGreen.withValues(alpha: 0.88),
                  AppTheme.cafeNoir.withValues(alpha: 0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cafeNoir.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 28),

                // App Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.mossGreen.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.tan.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: leafIcon(AppTheme.mossGreen, size: 30, strokeColor: AppTheme.tan),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GRID AI',
                        style: TextStyle(
                          color: AppTheme.bone.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Thin separator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 1,
                    color: AppTheme.tan.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 20),

                // Navigation Items
                _buildNavItem(ref, 0, activeTab == 0, 'Dashboard',
                    DashboardIconPainter(color: _navIconColor(activeTab == 0), isActive: activeTab == 0)),
                _buildNavItem(ref, 1, activeTab == 1, 'Map View',
                    MapIconPainter(color: _navIconColor(activeTab == 1), isActive: activeTab == 1)),
                _buildNavItem(ref, 2, activeTab == 2, 'Analytics',
                    AnalyticsIconPainter(color: _navIconColor(activeTab == 2), isActive: activeTab == 2)),
                _buildNavItem(ref, 3, activeTab == 3, 'Settings',
                    SettingsIconPainter(color: _navIconColor(activeTab == 3), isActive: activeTab == 3)),

                const Spacer(),

                // Bottom version badge
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'v2.0.0',
                    style: TextStyle(
                      color: AppTheme.tan.withValues(alpha: 0.35),
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitle(activeTab),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getSubtitle(activeTab),
                              style: TextStyle(
                                color: AppTheme.kombuGreen.withValues(alpha: 0.55),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Live status badge
                      _LiveStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: Row(
                      children: [
                        // Dynamic Tab Area
                        Expanded(
                          flex: 3,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              final curve = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOutCubic,
                              );
                              return FadeTransition(
                                opacity: curve,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.025, 0),
                                    end: Offset.zero,
                                  ).animate(curve),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildMainView(activeTab),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Telemetry & AI Command Center Panel
                        const Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Expanded(flex: 1, child: LiveStatusPanel()),
                              SizedBox(height: 20),
                              Expanded(flex: 1, child: AiCommandCenterLog()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _AnimatedFAB(
            heroTag: 'chat_btn',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const Dialog(
                  backgroundColor: Colors.transparent,
                  child: ChatbotWidget(),
                ),
              );
            },
            backgroundColor: AppTheme.kombuGreen,
            icon: const _ChatIcon(),
            label: 'Ask AI',
          ),
          const SizedBox(height: 12),
          _AnimatedFAB(
            heroTag: 'sim_btn',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ScenarioDialog(),
              );
            },
            backgroundColor: AppTheme.cafeNoir,
            icon: const _SimIcon(),
            label: 'Simulator',
          ),
        ],
      ),
    );
  }

  Color _navIconColor(bool isActive) =>
      isActive ? AppTheme.bone : AppTheme.tan.withValues(alpha: 0.55);

  Widget _buildNavItem(WidgetRef ref, int index, bool isActive, String label, CustomPainter painter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(activeTabProvider.notifier).setTab(index),
          borderRadius: BorderRadius.circular(16),
          child: Tooltip(
            message: label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.tan.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isActive
                    ? Border.all(color: AppTheme.tan.withValues(alpha: 0.25), width: 1)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 28,
                    height: 28,
                    child: CustomPaint(size: const Size(28, 28), painter: painter),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? AppTheme.bone
                          : AppTheme.tan.withValues(alpha: 0.55),
                      fontSize: 9.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle(int tabIndex) {
    switch (tabIndex) {
      case 0: return 'Mission Control';
      case 1: return 'System Schematic';
      case 2: return 'Analytics';
      case 3: return 'Settings';
      default: return 'Mission Control';
    }
  }

  String _getSubtitle(int tabIndex) {
    switch (tabIndex) {
      case 0: return 'Real-time microgrid digital twin view';
      case 1: return 'Interactive node-level system schematic map';
      case 2: return 'Historical telemetry analytics & trends';
      case 3: return 'Optimization rules & scenario controls';
      default: return '';
    }
  }

  Widget _buildMainView(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const PremiumCard(
          key: ValueKey('tab_dashboard'),
          child: DigitalTwinWidget(),
        );
      case 1:
        return const MicrogridMapWidget(key: ValueKey('tab_map'));
      case 2:
        return const AnalyticsView(key: ValueKey('tab_analytics'));
      case 3:
        return const SettingsView(key: ValueKey('tab_settings'));
      default:
        return const PremiumCard(
          key: ValueKey('tab_dashboard'),
          child: DigitalTwinWidget(),
        );
    }
  }
}

// ── Live badge ────────────────────────────────────────────────────────────────
class _LiveStatusBadge extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LiveStatusBadge> createState() => _LiveStatusBadgeState();
}

class _LiveStatusBadgeState extends ConsumerState<_LiveStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.mossGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.mossGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.mossGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mossGreen.withValues(alpha: 0.6 * _pulseCtrl.value),
                      blurRadius: 8 * _pulseCtrl.value,
                      spreadRadius: 2 * _pulseCtrl.value,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE DATA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.kombuGreen,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Custom FAB ────────────────────────────────────────────────────────────────
class _AnimatedFAB extends StatefulWidget {
  final String heroTag;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget icon;
  final String label;

  const _AnimatedFAB({
    required this.heroTag,
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.label,
  });

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor.withValues(alpha: _hovered ? 0.4 : 0.2),
              blurRadius: _hovered ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: widget.heroTag,
          onPressed: widget.onPressed,
          backgroundColor: _hovered
              ? widget.backgroundColor.withValues(alpha: 0.92)
              : widget.backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          icon: widget.icon,
          label: Text(widget.label,
              style: const TextStyle(
                  color: AppTheme.bone,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ),
    );
  }
}

// Small icon widgets for FABs
class _ChatIcon extends StatelessWidget {
  const _ChatIcon();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _ChatIconPainter()),
    );
  }
}

class _ChatIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppTheme.bone
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final fp = Paint()..color = AppTheme.bone.withValues(alpha: 0.15)..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.78),
      const Radius.circular(5),
    );
    canvas.drawRRect(rect, fp);
    canvas.drawRRect(rect, p);

    // tail
    final tail = Path()
      ..moveTo(size.width * 0.25, size.height * 0.78)
      ..lineTo(size.width * 0.2, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.78);
    canvas.drawPath(tail, p..style = PaintingStyle.stroke);

    // dots
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
          Offset(size.width * (0.28 + i * 0.22), size.height * 0.38),
          2,
          Paint()..color = AppTheme.bone..style = PaintingStyle.fill);
    }
  }

  @override bool shouldRepaint(_) => false;
}

class _SimIcon extends StatelessWidget {
  const _SimIcon();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _SimIconPainter()),
    );
  }
}

class _SimIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppTheme.bone
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final fp = Paint()..color = AppTheme.bone.withValues(alpha: 0.2)..style = PaintingStyle.fill;

    // Flask shape
    final path = Path()
      ..moveTo(size.width * 0.38, 0)
      ..lineTo(size.width * 0.62, 0)
      ..lineTo(size.width * 0.62, size.height * 0.45)
      ..lineTo(size.width * 0.9, size.height * 0.92)
      ..arcTo(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.7, size.width * 0.9, size.height * 0.35),
        0, 3.14159, false)
      ..lineTo(size.width * 0.38, size.height * 0.45)
      ..close();
    canvas.drawPath(path, fp);
    canvas.drawPath(path, p);

    // Bubble in flask
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.77),
        size.width * 0.1, Paint()..color = AppTheme.bone..style = PaintingStyle.fill);
  }

  @override bool shouldRepaint(_) => false;
}
