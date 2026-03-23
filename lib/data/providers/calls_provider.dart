import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_model.dart';

final callsProvider = StateProvider<List<CallModel>>((ref) {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final sunday = now.subtract(Duration(days: now.weekday));
  final saturday = sunday.subtract(const Duration(days: 1));
  final monday = now.subtract(Duration(days: now.weekday - 1));

  return [
    CallModel(id: '1', contactName: 'Priya Sharma', type: CallType.voice, direction: CallDirection.incoming, timestamp: now.subtract(const Duration(hours: 2))),
    CallModel(id: '2', contactName: 'Rahul Verma', type: CallType.voice, direction: CallDirection.outgoing, timestamp: now.subtract(const Duration(hours: 3))),
    CallModel(id: '3', contactName: 'Anjali Singh', type: CallType.voice, direction: CallDirection.missed, timestamp: yesterday.subtract(const Duration(hours: 4))),
    CallModel(id: '4', contactName: 'Vikram Bhai', type: CallType.video, direction: CallDirection.incoming, timestamp: yesterday.subtract(const Duration(hours: 7))),
    CallModel(id: '5', contactName: 'Mom ❤️', type: CallType.voice, direction: CallDirection.outgoing, timestamp: yesterday.subtract(const Duration(hours: 10))),
    CallModel(id: '6', contactName: 'Riya Kapoor', type: CallType.voice, direction: CallDirection.missed, timestamp: monday.subtract(const Duration(hours: 1))),
    CallModel(id: '7', contactName: 'Arjun Dev', type: CallType.voice, direction: CallDirection.incoming, timestamp: monday.subtract(const Duration(hours: 3))),
    CallModel(id: '8', contactName: 'Tech Support', type: CallType.voice, direction: CallDirection.outgoing, timestamp: sunday.subtract(const Duration(hours: 8))),
    CallModel(id: '9', contactName: 'Neha Gupta', type: CallType.voice, direction: CallDirection.missed, timestamp: sunday.subtract(const Duration(hours: 11))),
    CallModel(id: '10', contactName: 'Karan Mehta', type: CallType.video, direction: CallDirection.incoming, timestamp: saturday.subtract(const Duration(hours: 6))),
  ];
});

final callFilterProvider = StateProvider<String>((ref) => 'All');

final filteredCallsProvider = Provider<List<CallModel>>((ref) {
  final calls = ref.watch(callsProvider);
  final filter = ref.watch(callFilterProvider);
  
  if (filter == 'All') return calls;
  return calls.where((c) => c.direction == CallDirection.missed).toList();
});
