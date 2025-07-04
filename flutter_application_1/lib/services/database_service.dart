// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agenda.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _createDB(Database db, int version) async {
    await _createEventsTable(db);
    await _createUsersTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
    }
  }

  Future<void> _createEventsTable(Database db) async {
     await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventName TEXT NOT NULL,
        venue TEXT NOT NULL,
        address TEXT,
        dateTime TEXT NOT NULL,
        price REAL,
        status TEXT NOT NULL,
        contactName TEXT,
        contactPhone TEXT,
        notes TEXT
      )
      ''');
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  // --- MÉTODOS PARA USUÁRIOS ---

  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user..id = id;
  }

  Future<User?> getUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'email', 'password'],
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<bool> updatePassword(int userId, String newPassword) async {
    final db = await instance.database;
    final result = await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result > 0;
  }

  // --- MÉTODOS PARA EVENTOS ---

  Future<Event> createEvent(Event event) async {
    final db = await instance.database;
    final id = await db.insert('events', event.toMap());
    return event..id = id;
  }

  Future<List<Event>> readAllEvents() async {
    final db = await instance.database;
    final result = await db.query('events', orderBy: 'dateTime ASC');
    return result.map((json) => Event.fromMap(json)).toList();
  }

  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
