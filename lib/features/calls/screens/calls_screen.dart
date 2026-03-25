import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/calls_provider.dart';
import '../../../data/models/call_model.dart';

class CallsScreen extends ConsumerWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredCalls = ref.watch(filteredCallsProvider);
    final currentFilter = ref.watch(callFilterProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Calls'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'clear') {
                ref.read(callsProvider.notifier).state = [];
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear', child: Text('Clear call log')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(ref, currentFilter, colorScheme),
          Expanded(
            child: filteredCalls.isEmpty 
              ? _buildEmptyState(currentFilter, colorScheme)
              : ListView.builder(
                  itemCount: filteredCalls.length,
                  itemBuilder: (context, index) => _CallTile(call: filteredCalls[index]),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add_call, color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildFilterTabs(WidgetRef ref, String current, ColorScheme colorScheme) {
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
          ),
          const SizedBox(width: 16),
          _FilterTab(
            label: 'Missed', 
            isSelected: current == 'Missed', 
            onTap: () => ref.read(callFilterProvider.notifier).state = 'Missed',
            colorScheme: colorScheme,
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
          Icon(Icons.phone_missed, size: 64, color: colorScheme.secondary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            filter == 'Missed' ? 'No missed calls' : 'No calls yet',
            style: TextStyle(color: colorScheme.secondary),
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

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  final CallModel call;
  const _CallTile({required this.call});

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

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        child: Text(call.contactName[0].toUpperCase(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
      ),
      title: Text(call.contactName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          Icon(directionIcon, size: 14, color: directionColor),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM d, h:mm a').format(call.timestamp),
            style: TextStyle(color: colorScheme.secondary, fontSize: 12),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          call.type == CallType.video ? Icons.videocam : Icons.phone,
          color: colorScheme.primary,
        ),
        onPressed: () {},
      ),
    );
  }
}
