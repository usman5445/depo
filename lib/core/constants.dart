import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppConstants {
  static Future<String> getDatabasePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'core', 'depo_database.db');
  }
}
