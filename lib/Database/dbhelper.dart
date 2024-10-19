import 'package:monsiegesocial/models/user.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

class DbHelper {
  static const int version = 1;
  static const databasename = "monsiegesocial.db";
  static const String dbTable = "user";
  static const String userId = "userId";
  static const String userFirstname = "userFirstname";
  static const String userLastname = "userLastname";
  static const String userEmail = "userEmail";
  static const String userToken = "userToken";

  Future<Database> initialise() async {
    final _db = await openDatabase(join(await getDatabasesPath(), databasename),
        version: version, onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE $dbTable ($userId int PRIMARY KEY,$userFirstname TEXT,$userLastname TEXT,$userEmail TEXT,$userToken TEXT)");
    });
    return _db;
  }

  Future<String> saveData(User user) async {
    final dbclient = await initialise();
    int? result = await dbclient.insert(dbTable, user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (result > 0) {
      return "success";
    } else {
      return "error";
    }
  }

  Future<List<User>> getdata() async {
    final dbclient = await initialise();

    final List<Map<String, dynamic>> maps = await dbclient.query(dbTable);

    return List.generate(maps.length, (i) {
      return User(
        userId: maps[i]['userId'],
        userFirstname: maps[i]['userFirstname'],
        userLastname: maps[i]['userLastname'],
        userEmail: maps[i]['userEmail'],
        userToken: maps[i]['userToken'],
      );
    });
  }

  Future<void> updateData(User user) async {
    final dbclient = await initialise();
    await dbclient.update(
      dbTable,
      user.toMap(),
      where: 'userId = ?',
      whereArgs: [user.userId],
    );
  }

  Future<void> deleteData(String userToken) async {
    final dbclient = await initialise();

    await dbclient.delete(
      dbTable,
      where: 'userToken = ?',
      whereArgs: [userToken],
    );
  }
}
