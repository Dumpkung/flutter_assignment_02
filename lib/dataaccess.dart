import 'dart:async';
import 'package:sqflite/sqflite.dart';

final String todoTable = "todo";
final String idColumn = "_id";
final String todoItemColumn = "title";
final String isDoneColumn = "done";


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
  : id = map[idColumn],
    title = map[todoItemColumn],
    done = map[isDoneColumn] == 1;  

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
      todoItemColumn: title,
      isDoneColumn: done ? 1 : 0
    };
    // Allow for auto-increment
    if (id != null) {
      map[idColumn] = id;
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

   Future open() async {

     var databasesPath = await getDatabasesPath();
    String path = "todo.db";

     _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            create table $todoTable ( 
            $idColumn integer primary key autoincrement, 
            $todoItemColumn text not null,
            $isDoneColumn integer not null)
            ''');
    });
  }

   Future<List<TodoManage>> getTodo() async {
    var data = await _db.query(todoTable);
    return data.map((d) => TodoManage.fromMap(d)).toList();
  }

   Future insertTodo(TodoManage item) {
    print(item.toMap());
    return _db.insert(todoTable, item.toMap());
  }

   Future updateTodo(TodoManage item) {
    return _db.update(todoTable, item.toMap(),
      where: "$idColumn = ?", whereArgs: [item.id]);
  }

   Future deleteTodo() {
    return _db.delete(todoTable, where: "$isDoneColumn = ?", whereArgs: [true]);
  }
}