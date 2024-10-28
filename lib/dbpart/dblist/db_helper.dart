import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  // Private constructor for singleton
  DbHelper._privateConstructor();

  // Singleton instance
  static final DbHelper _instance = DbHelper._privateConstructor();

  // Access point to the singleton instance
  static DbHelper get getInstance => _instance;

  Database? _database;

  // Column names
  static const String COLUMN_NOTE_SNO = 'S_NO';
  static const String COLUMN_NOTE_TITLE = 'title';
  static const String COLUMN_NOTE_DESC = 'desc';
  static const String COLUMN_PRIORITY = 'priority';

  // Priority Levels
  static const int HIGH_PRIORITY = 1;
  static const int MEDIUM_PRIORITY = 2;
  static const int LOW_PRIORITY = 3;

  // Database version
  static const int _dbVersion = 2;

  // Get database instance
  Future<Database> get database async {
    _database ??= await openDB();
    return _database!;
  }

  // Open or create the database
  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "TODO_List_Database.db");

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE NOTE($COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT, "
          "$COLUMN_NOTE_TITLE TEXT, $COLUMN_NOTE_DESC TEXT, $COLUMN_PRIORITY INTEGER)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE NOTE ADD COLUMN $COLUMN_PRIORITY INTEGER DEFAULT $LOW_PRIORITY");
        }
      },
    );
  }

  // Insert a new note with priority
  Future<bool> addNote({
    required String title,
    required String desc,
    required int priority,
  }) async {
    var db = await database;
    int rowsEffected = await db.insert("NOTE", {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_DESC: desc,
      COLUMN_PRIORITY: priority,
    });
    return rowsEffected > 0;
  }

  // Retrieve all notes, sorted by priority
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await database;
    return await db.query("NOTE", orderBy: "$COLUMN_PRIORITY ASC");
  }

  // Update a note with priority
  Future<bool> updateNote({
    required String title,
    required String desc,
    required int sno,
    required int priority,
  }) async {
    var db = await database;
    int rowsEffected = await db.update(
      "NOTE",
      {
        COLUMN_NOTE_TITLE: title,
        COLUMN_NOTE_DESC: desc,
        COLUMN_PRIORITY: priority,
      },
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [sno],
    );
    return rowsEffected > 0;
  }

  // Delete a note
  Future<bool> deleteNote({required int sno}) async {
    var db = await database;
    int rowsEffected = await db.delete("NOTE", where: "$COLUMN_NOTE_SNO = ?", whereArgs: [sno]);
    return rowsEffected > 0;
  }
}
