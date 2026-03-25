import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contact_model.dart';

final contactsProvider = StateProvider<List<ContactModel>>((ref) {
  return [
    const ContactModel(id: '1', name: 'Aarav Sharma', mobile: '+91 98765 43210', isOnline: true),
    const ContactModel(id: '2', name: 'Priya Singh', mobile: '+91 87654 32109', isOnline: false),
    const ContactModel(id: '3', name: 'Rahul Verma', mobile: '+91 76543 21098', isOnline: true),
    const ContactModel(id: '4', name: 'Anjali Gupta', mobile: '+91 65432 10987', isOnline: false),
    const ContactModel(id: '5', name: 'Vikram Bhai', mobile: '+91 54321 09876', isOnline: true),
    const ContactModel(id: '6', name: 'Neha Kapoor', mobile: '+91 43210 98765', isOnline: false),
    const ContactModel(id: '7', name: 'Arjun Dev', mobile: '+91 32109 87654', isOnline: true),
    const ContactModel(id: '8', name: 'Riya Patel', mobile: '+91 21098 76543', isOnline: false),
    const ContactModel(id: '9', name: 'Karan Mehta', mobile: '+91 10987 65432', isOnline: true),
    const ContactModel(id: '10', name: 'Sneha Joshi', mobile: '+91 09876 54321', isOnline: false),
    const ContactModel(id: '11', name: 'Amit Kumar', mobile: '+91 98765 12345', isOnline: true),
    const ContactModel(id: '12', name: 'Pooja Rao', mobile: '+91 87654 23456', isOnline: false),
    const ContactModel(id: '13', name: 'Deepak Nair', mobile: '+91 76543 34567', isOnline: true),
    const ContactModel(id: '14', name: 'Simran Kaur', mobile: '+91 65432 45678', isOnline: false),
    const ContactModel(id: '15', name: 'Rohan Mishra', mobile: '+91 54321 56789', isOnline: true),
  ];
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
