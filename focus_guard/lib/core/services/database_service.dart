import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'focus_guard.db');

    return await openDatabase(
      path,
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migration for v2
          try {
            await db.execute("ALTER TABLE users ADD COLUMN email TEXT DEFAULT 'alex@focusguard.app'");
            await db.execute("ALTER TABLE users ADD COLUMN phone TEXT DEFAULT '+1 234 567 8900'");
          } catch (e) {}
        }
        if (oldVersion < 3) {
           // Migration for v3 (Strict Mode)
           try {
             await db.execute("ALTER TABLE tasks ADD COLUMN is_strict INTEGER DEFAULT 0");
           } catch (e) {}
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT,
            phone TEXT,
            level INTEGER,
            current_xp INTEGER,
            streak INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            start_time TEXT,
            end_time TEXT,
            category TEXT,
            allowed_apps TEXT,
            xp_reward INTEGER,
            is_strict INTEGER,
            status TEXT,
            is_completed INTEGER
          )
        ''');

        // Insert default user
        await db.insert('users', User(username: 'Alex').toMap());
      },
    );
  }

  Future<User?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateUserXp(int xp) async {
      final db = await database;
      // Simple increment logic for MVP
      final user = await getUser();
      if (user != null) {
          int newXp = user.currentXp + xp;
          // Level up logic (simple: every 1000 xp)
          int newLevel = (newXp / 1000).floor() + 1;
          
          await db.update('users', {
              'current_xp': newXp,
              'level': newLevel
          }, where: 'id = ?', whereArgs: [user.id]);
      }
  }
}
