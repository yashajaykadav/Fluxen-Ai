import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/chat_controller.dart';

class HistoryDrawer extends StatelessWidget {
  final VoidCallback onNewChat;

  const HistoryDrawer({super.key, required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChatController>(context);

    final sessions = controller.getAllSessions();

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(child: Text("Fluxen History")),

          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("New Chat"),
            onTap: () {
              onNewChat();
              Navigator.pop(context);
            },
          ),

          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, i) {
                final session = sessions[i];

                return ListTile(
                  title: Text(session.title),
                  subtitle: Text(session.timestamp.toString()),
                  onTap: () {
                    controller.loadSession(session);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
