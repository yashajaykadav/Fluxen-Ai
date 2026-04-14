import 'package:objectbox/objectbox.dart';

@Entity()
class ChatSession {
  @Id()
  int id = 0;
  String title;
  DateTime timestamp;

  @Backlink('session')
  final messages = ToMany<ChatMessageEntity>();

  ChatSession({required this.title, required this.timestamp});
}

@Entity()
class ChatMessageEntity {
  @Id()
  int id = 0;
  String text;
  bool isUser;
  DateTime timestamp;

  final session = ToOne<ChatSession>();

  ChatMessageEntity({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
