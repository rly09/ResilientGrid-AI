import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';

class ScenarioDialog extends ConsumerStatefulWidget {
  const ScenarioDialog({super.key});

  @override
  ConsumerState<ScenarioDialog> createState() => _ScenarioDialogState();
}

class _ScenarioDialogState extends ConsumerState<ScenarioDialog> {
  String? _pendingScenario;
  String? _errorMessage;

  Future<void> _triggerScenario(String scenarioName) async {
    setState(() {
      _pendingScenario = scenarioName;
      _errorMessage = null;
    });

    try {
      await runGridScenario(scenarioName);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: scenarioName == 'Normal'
                ? AppColors.success
                : (scenarioName == 'Storm' ? AppColors.warning : AppColors.error),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            content: Row(
              children: [
                Icon(
                  scenarioName == 'Normal'
                      ? Icons.check_circle_outline
                      : (scenarioName == 'Storm' ? Icons.thunderstorm_outlined : Icons.flash_off_outlined),
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Simulation engaged: $scenarioName Mode active.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _pendingScenario = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: AppTheme.bone,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.hairline,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.science_outlined,
                      color: AppColors.brandTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scenario Simulator',
                          style: AppTextStyles.titleLG.copyWith(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Simulate external events to test microgrid auto-recovery policies.',
                          style: AppTextStyles.bodySM.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Scenarios List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: AppColors.error.withValues(alpha: 0.95), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildScenarioCard(
                    title: 'Normal Operations',
                    desc: 'Restores stable utility grid connection. Grid frequency at 50Hz, voltage at 230V.',
                    scenarioName: 'Normal',
                    icon: Icons.check_circle_outline,
                    cardColor: AppColors.brandMint,
                    textColor: AppColors.ink,
                  ),
                  const SizedBox(height: 16),
                  _buildScenarioCard(
                    title: 'Storm Event',
                    desc: 'Simulates wind gusts and heavy cloud cover. Solar generation drops, wind surges.',
                    scenarioName: 'Storm',
                    icon: Icons.thunderstorm_outlined,
                    cardColor: AppColors.brandOchre,
                    textColor: AppColors.ink,
                  ),
                  const SizedBox(height: 16),
                  _buildScenarioCard(
                    title: 'Grid Outage (Failure)',
                    desc: 'Simulates utility blackout. Triggers critical alert to test automatic microgrid islanding.',
                    scenarioName: 'Grid Failure',
                    icon: Icons.flash_off_outlined,
                    cardColor: AppColors.brandPink,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
            const Divider(),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCard({
    required String title,
    required String desc,
    required String scenarioName,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
  }) {
    final isPending = _pendingScenario == scenarioName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pendingScenario != null ? null : () => _triggerScenario(scenarioName),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: textColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMD.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: AppTextStyles.bodySM.copyWith(
                        color: textColor.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isPending)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: textColor,
                    strokeWidth: 2.5,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: textColor.withValues(alpha: 0.5),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
