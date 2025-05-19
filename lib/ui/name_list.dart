// lib/ui/name_list.dart
import 'package:flutter/material.dart';

class NameList extends StatefulWidget {
  final List<String> members;
  final Map<String, List<String>> messages;
  final void Function(String name) onAddMember;
  final void Function(String name) onSelect;
  final String? selected;

  const NameList({
    super.key,
    required this.members,
    required this.messages,
    required this.onAddMember,
    required this.onSelect,
    required this.selected,
  });

  @override
  State<NameList> createState() => _NameListState();
}

class _NameListState extends State<NameList> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController newNameController = TextEditingController();

  List<String> get filteredMembers {
    final query = searchController.text.toLowerCase();
    return widget.members.where((name) => name.toLowerCase().contains(query)).toList();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Your Name'),
        content: TextField(
          controller: newNameController,
          decoration: const InputDecoration(hintText: 'Enter your first name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              widget.onAddMember(newNameController.text);
              newNameController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search names...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: filteredMembers.map((member) {
              bool hasMessage = widget.messages[member]?.isNotEmpty ?? false;
              return Card(
                child: ListTile(
                  onTap: () => widget.onSelect(member),
                  leading: Icon(
                    hasMessage ? Icons.push_pin : Icons.radio_button_unchecked,
                    color: hasMessage ? Colors.red : Colors.grey,
                  ),
                  title: Text(member),
                  selected: widget.selected == member,
                  selectedTileColor: Colors.deepPurple.withOpacity(0.1),
                ),
              );
            }).toList(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.person_add_alt_1_rounded),
          tooltip: 'Add Your Name',
          onPressed: _showAddDialog,
        ),
      ],
    );
  }
}
