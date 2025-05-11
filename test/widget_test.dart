// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:depo_management/core/app.dart';
import 'package:depo_management/core/providers.dart';

void main() {
  late Database database;

  setUpAll(() async {
    // Initialize FFI
    sqfliteFfiInit();
    // Set factory
    databaseFactory = databaseFactoryFfi;
    // Create database in memory for testing
    database = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE drivers(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, license TEXT, joinDate TEXT)',
          );
        },
      ),
    );
  });

  tearDownAll(() async {
    await database.close();
  });

  testWidgets('App should render without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('Depo Management'), findsOneWidget);
  });
}
