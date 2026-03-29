import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contact_model.dart';

final contactsProvider = StateProvider<List<ContactModel>>((ref) {
  return [];
});

final contactsSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredContactsProvider = Provider<List<ContactModel>>((ref) {
  final contacts = ref.watch(contactsProvider);
  final query = ref.watch(contactsSearchQueryProvider).toLowerCase();
  
  if (query.isEmpty) return contacts;
  
  return contacts.where((c) => 
    c.name.toLowerCase().contains(query) || 
    c.mobile.replaceAll(' ', '').contains(query)
  ).toList();
});

final selectedContactsProvider = StateProvider<Set<String>>((ref) => {});
