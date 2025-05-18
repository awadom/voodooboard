import 'package:flutter/material.dart';
import 'dart:collection';

void main() {
  runApp(VoodooBoardApp());
}

class VoodooBoardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voodoo Board',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: Typography.whiteCupertino,
      ),
      home: VoodooBoardHomePage(),
    );
  }
}

class VoodooBoardHomePage extends StatefulWidget {
  @override
  _VoodooBoardHomePageState createState() => _VoodooBoardHomePageState();
}

class _VoodooBoardHomePageState extends State<VoodooBoardHomePage> {
  final List<String> members = [
    'Omar',
    'Mara'
  ];
  final Map<String, List<String>> messages = HashMap();
  String? selectedMember;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController newNameController = TextEditingController();

  void addMessage(String member, String msg) {
    if (!messages.containsKey(member)) {
      messages[member] = [];
    }
    setState(() {
      messages[member]!.add(msg);
    });
    messageController.clear();
  }

  void deleteMessage(String member, int index) {
    setState(() {
      messages[member]?.removeAt(index);
    });
  }

  void toggleMember(String member) {
    setState(() {
      selectedMember = member;
    });
  }

  void addMember(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (members.any((m) => m.toLowerCase() == trimmed.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name "$trimmed" already exists on the board.')),
      );
      return;
    }
    setState(() {
      members.add(trimmed);
    });
    newNameController.clear();
  }

  List<String> get filteredMembers {
    final query = searchController.text.toLowerCase();
    return members.where((name) => name.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔮 Voodoo Board'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Add Your Name',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Add Your Name'),
                  content: TextField(
                    controller: newNameController,
                    decoration: InputDecoration(hintText: 'Enter your full name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        addMember(newNameController.text);
                        Navigator.pop(context);
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Row(
        children: [
          // Member list with pins and search bar
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search names...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(12),
                    children: filteredMembers.map((member) {
                      bool hasMessage = messages[member]?.isNotEmpty ?? false;
                      return Card(
                        child: ListTile(
                          onTap: () => toggleMember(member),
                          leading: Icon(
                            hasMessage ? Icons.push_pin : Icons.radio_button_unchecked,
                            color: hasMessage ? Colors.red : Colors.grey,
                          ),
                          title: Text(member),
                          selected: selectedMember == member,
                          selectedTileColor: Colors.deepPurple.withOpacity(0.1),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Message view and compose box
          Expanded(
            flex: 3,
            child: selectedMember == null
                ? Center(
                    child: Text('Select a name to view or leave a message.',
                        style: TextStyle(fontSize: 18)),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Messages for $selectedMember',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.black)),
                        const SizedBox(height: 10),
                        Expanded (
                          child: ListView.builder(
                            itemCount: messages[selectedMember]?.length ?? 0,
                            itemBuilder: (context, index) {
                              final msg = messages[selectedMember]![index];
                              return Card(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                child: ListTile(
                                  title: Text(msg),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteMessage(selectedMember!, index),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(),
                        TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            labelText: 'Leave a message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (selectedMember != null &&
                                messageController.text.trim().isNotEmpty) {
                              addMessage(
                                  selectedMember!, messageController.text.trim());
                            }
                          },
                          icon: Icon(Icons.send),
                          label: Text('Pin Message'),
                        )
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
// This is a simple Voodoo Board app that allows users to leave messages for each other.