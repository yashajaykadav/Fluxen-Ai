import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../objectbox.g.dart';

class ObjectBoxService {
  static late final Store store;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, "fluxen-chat-db");

    store = await openStore(directory: path);
  }
}
