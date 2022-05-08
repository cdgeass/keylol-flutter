import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String ddl =
    "CREATE TABLE history (tid TEXT PRIMARY KEY, fid TEXT, author_id TEXT, author TEXT, subject TEXT, dateline TEXT)";

class HistoryRepository {
  late final Future<Database> _database;

  Future<void> initial() async {
    _database = openDatabase(
      join(await getDatabasesPath(), 'keylol_f.db'),
      onCreate: (db, version) => db.execute(ddl),
      version: 1,
    );
  }

  Future<void> insertHistory(Thread thread) async {
    final db = await _database;

    await db.insert(
      'history',
      {
        'tid': thread.tid,
        'fid': thread.fid,
        'author_id': thread.authorId,
        'author': thread.author,
        'subject': thread.subject,
        'dateline': thread.dateline
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Thread>> histories({String? text}) async {
    final db = await _database;

    final list = await db.query(
      'history',
      where: text != null ? 'subject LIKE ?' : null,
      whereArgs: text != null ? ['%$text%'] : null,
      orderBy: 'rowId DESC',
    );

    return List.generate(
      list.length,
      (index) => Thread.fromJson({
        'tid': list[index]['tid'],
        'fid': list[index]['fid'],
        'authorid': list[index]['author_id'],
        'author': list[index]['author'],
        'subject': list[index]['subject'],
        'dateline': list[index]['dateline']
      }),
    );
  }
}
