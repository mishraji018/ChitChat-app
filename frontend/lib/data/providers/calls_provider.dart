import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_model.dart';

final callsProvider = StateProvider<List<CallModel>>((ref) {
  return [];
});



final callFilterProvider = StateProvider<String>((ref) => 'All');

final filteredCallsProvider = Provider<List<CallModel>>((ref) {
  final calls = ref.watch(callsProvider);
  final filter = ref.watch(callFilterProvider);
  
  if (filter == 'All') return calls;
  return calls.where((c) => c.direction == CallDirection.missed).toList();
});
