import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final String todoTable = "TodoItems";
// final String tableTodo = "todo";
// final String columnId = "_id";
// final String columnName = "name";
// final String columnDone = "done";


class TodoManage extends Comparable {
  int id;
  final String title;
  bool done;
//   int id;
//   String name;
//   bool done;

//   Todo({this.id, this.name, this.done});

//   factory Todo.fromMap(Map<String, dynamic> json) => new Todo(
//         id: json[columnId],
//         name: json[columnName],
//         done: json[columnDone] == 1,
//       );

//   Map<String, dynamic> toMap() => {
//         columnName: name,
//         columnDone: done == false ? 0 : 1,
//       };
// }
  TodoManage({this.title, this.done = false});
  
  TodoManage.fromMap(Map<String, dynamic> map)
  : id = map["id"],
    title = map["name"],
    done = map["isComplete"] == 1;  

  @override
  int compareTo(other) {
    if (this.done && !other.done) {
      return 1;
    } else if (!this.done && other.done) {
      return -1;
    } else {
      return this.id.compareTo(other.id);
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "name": title,
      "isComplete": done ? 1 : 0
    };
    // Allow for auto-increment
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }
}
class TodoProvider {
  static final TodoProvider _instance = TodoProvider._internal();
  Database _db;

  factory TodoProvider() {
    return _instance;
  }

  TodoProvider._internal();
// static final TodoProvider db = TodoProvider();

//   Database _database;

//   Future<Database> get database async {
//     if (_database != null) {
//       return _database;
//     } else {
//       _database = await openDB("todo.db");
//       return _database;
//     }
//   }

//   Future openDB(String path) async {
//     return await openDatabase(path, version: 1,
//         onCreate: (Database _database, int version) async {
//       await _database.execute(
//           '''create table $tableTodo ($columnId integer primary key autoincrement, $columnName text not null,$columnDone integer not null)''');
//     });
//   }

  Future open() async {

    var databasesPath = await getDatabasesPath();
    String path = databasesPath + "\todo.db";

    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            create table $todoTable ( 
            id integer primary key autoincrement, 
            name text not null,
            isComplete integer not null)
            ''');
    });
  }

  Future insertTodo(TodoManage item) {
    return _db.insert(todoTable, item.toMap());
  }

  Future<List<TodoManage>> getTodo() async {
    final _database = await _db;
    var result = await _database.query(todoTable);

    List<TodoManage> list =
        result.isNotEmpty ? result.map((c) => TodoManage.fromMap(c)).toList() : [];
    return list;
  }

  Future<void> updateTodo(TodoManage todo) async {
    return _db.update(todoTable, todo.toMap(),
      where: "id = ?", whereArgs: [todo.id]);;
  }

  Future<void> deleteDone() async {
    final _database = await _db;
    return await _database.delete(todoTable, where: "isComplete = 1");
  }

  Future close() async => _db.close();
}