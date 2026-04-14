import 'package:objectbox/objectbox.dart';

@Entity()
class DocumentChunk {
  @Id()
  int id = 0;

  String text;
  String fileName;
  
  // This stores the embedding (the numerical representation)
  // Ensure the dimension matches your embedding model (e.g., 1536 for OpenAI)
  @HnswIndex(dimensions: 1536) 
  @Property(type: PropertyType.floatVector)
  List<double>? signature;

  DocumentChunk({
    required this.text,
    required this.fileName,
    this.signature,
  });
}