import 'dart:async';
import 'package:sqflite/sqflite.dart';

final String todoTable = "todo";
final String idtodo = "_id";
final String itemtodo = "title";
final String iscompletetodo = "done";


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
  : id = map[idtodo],
    title = map[itemtodo],
    done = map[iscompletetodo] == 1;  

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
      itemtodo: title,
      iscompletetodo: done ? 1 : 0
    };
    // Allow for auto-increment
    if (id != null) {
      map[idtodo] = id;
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
            $idtodo integer primary key autoincrement, 
            $itemtodo text not null,
            $iscompletetodo integer not null)
            ''');
    });
  }

   Future<List<TodoManage>> getTodo() async {
    var data = await _db.query(todoTable);
    var result = data.map((d) => TodoManage.fromMap(d)).toList();
    return result;
  }
// Future<List<Todo>> getAllTodos() async {
//     var todo = await db.query(tableTodo,
//     where: '$columnDone = 0');
//     return todo.map((f) => Todo.formMap(f)).toList();
//   }

//   Future<List<Todo>> getAllDoneTodos() async{
//     var todo = await db.query(tableTodo,
//     where: '$columnDone = 1');
//     return todo.map((f) => Todo.formMap(f)).toList();
//   }

   Future insertTodo(TodoManage item) {
    print(item.toMap());
    var data = _db.insert(todoTable, item.toMap());
    return data;
  }

   Future updateTodo(TodoManage item) {
    var data = _db.update(todoTable, item.toMap(),
      where: "$idtodo = ?", whereArgs: [item.id]);
    return data;
  }

   Future deleteTodo() {
    return _db.delete(todoTable, where: "$iscompletetodo = ?", whereArgs: [true]);
  }
}