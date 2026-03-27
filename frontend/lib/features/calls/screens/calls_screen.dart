import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/calls_provider.dart';
import '../../../data/models/call_model.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class CallsScreen extends ConsumerWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final filteredCalls = ref.watch(filteredCallsProvider);
    final currentFilter = ref.watch(callFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        isDark: isDark,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            _buildFilterTabs(ref, currentFilter, colorScheme, isDark),
            Expanded(
              child: filteredCalls.isEmpty 
                ? _buildEmptyState(currentFilter, colorScheme)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    children: [
                      GlassCard(
                        isDark: isDark,
                        padding: EdgeInsets.zero,
                        radius: 28,
                        child: Column(
                          children: List.generate(filteredCalls.length, (index) {
                            final call = filteredCalls[index];
                            return Column(
                              children: [
                                _CallTile(call: call, isDark: isDark),
                                if (index < filteredCalls.length - 1)
                                  Divider(
                                    height: 1,
                                    indent: 80,
                                    endIndent: 16,
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(WidgetRef ref, String current, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FilterTab(
            label: 'All', 
            isSelected: current == 'All', 
            onTap: () => ref.read(callFilterProvider.notifier).state = 'All',
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          const SizedBox(width: 16),
          _FilterTab(
            label: 'Missed', 
            isSelected: current == 'Missed', 
            onTap: () => ref.read(callFilterProvider.notifier).state = 'Missed',
            colorScheme: colorScheme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String filter, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_missed, size: 60, color: colorScheme.secondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            filter == 'Missed' ? 'No missed calls' : 'No calls yet',
            style: TextStyle(color: colorScheme.secondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDark;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  final CallModel call;
  final bool isDark;
  const _CallTile({required this.call, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    IconData directionIcon;
    Color directionColor;
    
    switch (call.direction) {
      case CallDirection.incoming:
        directionIcon = Icons.call_received;
        directionColor = Colors.green;
        break;
      case CallDirection.outgoing:
        directionIcon = Icons.call_made;
        directionColor = Colors.blue;
        break;
      case CallDirection.missed:
        directionIcon = Icons.call_missed;
        directionColor = Colors.red;
        break;
    }

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colorScheme.primary.withValues(alpha: 0.7), colorScheme.tertiary.withValues(alpha: 0.7)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(call.contactName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(call.contactName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(directionIcon, size: 14, color: directionColor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(call.timestamp),
                        style: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                call.type == CallType.video ? Icons.videocam : Icons.phone,
                color: colorScheme.primary,
                size: 20,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
