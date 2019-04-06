import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// final String tableTodo = "todo";
// final String columnId = "_id";
// final String columnTitle = "title";
// final String columnDone = "done";


class TodoManager extends Comparable {
  int id;
  final String name;
  bool isComplete;

  TodoManager({this.name, this.isComplete = false});
  
  //map
  TodoManager.fromMap(Map<String, dynamic> map)
  : id = map["id"],
    name = map["name"],
    isComplete = map["isComplete"] == 1;  

  //compare
  @override
  int compareTo(other) {
    if (this.isComplete && !other.isComplete) {
      return 1;
    } else if (!this.isComplete && other.isComplete) {
      return -1;
    } else {
      return this.id.compareTo(other.id);
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "name": name,
      "isComplete": isComplete ? 1 : 0
    };
    // Allow for auto-increment
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }
}

final String todoTable = "TodoItems";

class DataAccess {
  static final DataAccess _dataManager = DataAccess._internal();
  Database _db;

  factory DataAccess() {
    return _dataManager;
  }

  DataAccess._internal();
// Future<Database> get database async {
//     if (_database != null) return _database;
//     _database = await createDatabase();
//     return _database;
//   }
//   createDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     //"ReactiveTodo.db is our database instance name
//     String path = join(documentsDirectory.path, "ReactiveTodo.db");
//     var database = await openDatabase(path,
//         version: 1, onCreate: initDB, onUpgrade: onUpgrade);
//     return database;
//   }

  //opendatabase
  Future open() async {

    var databasesPath = await getDatabasesPath();
    String path = databasesPath + "\todo.db";

    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            create table $todoTable ( 
            id integer primary key autoincrement, 
            description text not null,
            isComplete integer not null)
            ''');
    });
  }
  //getdata
  Future<List<TodoManager>> getTodoItems() async {
    var dataget = await _db.query(todoTable);
    var result = dataget.map((d) => TodoManager.fromMap(d)).toList();
    return result;
  }
  //insertdata
  Future insertTodo(TodoManager item) {
    var datainsert = _db.insert(todoTable, item.toMap());
    return datainsert;
  }
  //updatedata
  Future updateTodo(TodoManager item) {
    var dataupdate = _db.update(todoTable, item.toMap(),
      where: "id = ?", whereArgs: [item.id]);
    return dataupdate;
  }
  
  //deletedata
  Future deleteTodo() {
    return _db.delete(todoTable, where: "isComplete = ?", whereArgs: [true]);
  }
  // //Adds new Todo records
  // Future<int> createTodo(Todo todo) async {
  //   final db = await dbProvider.database;
  //   var result = db.insert(todoTABLE, todo.toDatabaseJson());
  //   return result;
  // }

  // //Get All Todo items
  // //Searches if query string was passed
  // Future<List<Todo>> getTodos({List<String> columns, String query}) async {
  //   final db = await dbProvider.database;

  //   List<Map<String, dynamic>> result;
  //   if (query != null) {
  //     if (query.isNotEmpty)
  //       result = await db.query(todoTABLE,
  //           columns: columns,
  //           where: 'description LIKE ?',
  //           whereArgs: ["%$query%"]);
  //   } else {
  //     result = await db.query(todoTABLE, columns: columns);
  //   }

  //   List<Todo> todos = result.isNotEmpty
  //       ? result.map((item) => Todo.fromDatabaseJson(item)).toList()
  //       : [];
  //   return todos;
  // }

  // //Update Todo record
  // Future<int> updateTodo(Todo todo) async {
  //   final db = await dbProvider.database;

  //   var result = await db.update(todoTABLE, todo.toDatabaseJson(),
  //       where: "id = ?", whereArgs: [todo.id]);

  //   return result;
  // }

  // //Delete Todo records
  // Future<int> deleteTodo(int id) async {
  //   final db = await dbProvider.database;
  //   var result = await db.delete(todoTABLE, where: 'id = ?', whereArgs: [id]);

  //   return result;
  // }

  // //We are not going to use this in the demo
  // Future deleteAllTodos() async {
  //   final db = await dbProvider.database;
  //   var result = await db.delete(
  //     todoTABLE,
  //   );

  //   return result;
  // }
}
