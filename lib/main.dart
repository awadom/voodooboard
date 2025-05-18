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
    'Alice Zephyr',
    'Bob Yarrow',
    'Charlie Xander',
    'Dana Willow',
    'Eli Vega'
  ];
  final Map<String, List<String>> messages = HashMap();
  String? selectedMember;
  final TextEditingController messageController = TextEditingController();

  void addMessage(String member, String msg) {
    if (!messages.containsKey(member)) {
      messages[member] = [];
    }
    setState(() {
      messages[member]!.add(msg);
    });
    messageController.clear();
  }

  void toggleMember(String member) {
    setState(() {
      selectedMember = member;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔮 Voodoo Board'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Member list with pins
          Expanded(
            flex: 2,
            child: ListView(
              padding: EdgeInsets.all(12),
              children: members.map((member) {
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
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView(
                            children: (messages[selectedMember] ?? [])
                                .map((msg) => Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(msg),
                                      ),
                                    ))
                                .toList(),
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
