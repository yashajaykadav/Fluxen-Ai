import '../models/document_chunk.dart';
import '../objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class VectorService {
  late final Store _store;
  late final Box<DocumentChunk> _box;

  Future<void> init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storeDir = p.join(docsDir.path, "fluxen-vector-db");

    _store = await openStore(directory: storeDir);
    _box = _store.box<DocumentChunk>();
  }

  // Store new chunks
  void saveChunks(List<DocumentChunk> chunks) {
    _box.putMany(chunks);
  }

  // Find the most relevant chunks based on a query vector
  List<DocumentChunk> searchRelevant(
    List<double> queryVector, {
    int limit = 5,
  }) {
    final query = _box
        .query(DocumentChunk_.signature.nearestNeighborsF32(queryVector, limit))
        .build();
    return query.find();
  }

  void clearAll() => _box.removeAll();
}
