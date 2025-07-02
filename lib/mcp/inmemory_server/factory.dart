import '../inmemory/memory_server.dart';
import 'math.dart';
import 'artifact_instructions.dart';
import 'package:logging/logging.dart';

class MemoryServerFactory {
  static MemoryServer? createMemoryServer(String command) {
    Logger.root.info('createMemoryServer command: $command');
    switch (command) {
      case 'artifact_instructions':
        return ArtifactServer();
      case 'math':
        return MathServer();
      default:
        return null;
    }
  }
}
