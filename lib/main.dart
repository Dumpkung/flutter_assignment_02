import 'package:flutter/material.dart';
import 'package:flutter_assignment_02/dataaccess.dart';



void main() => runApp(MyApp());

//HexColorClass
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

//RunApp
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      // home: MyHomePage(),
      initialRoute: "/",
      routes: {
        "/": (context) => Todostate(),
        "/add": (context) => AddItempage(),
      },
    );
  }
}

//TodoPageState
class Todostate extends StatefulWidget {
  Todostate({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TodoListScreenPage createState() => new _TodoListScreenPage();
}

class _TodoListScreenPage extends State<Todostate> {
  List<TodoManage> _unCompleteItems = List();
  List<TodoManage> _completeItems = List();
  TodoProvider _datamanage;
  int counttodo = 0, countcomplete = 0;
  bool havecount = false, havedelete = false, haveupdate = false, state = false;
  int count = 0;

  _TodoListScreenPage() {
    _datamanage =  new TodoProvider();;
  }


  @override
  //CreateDatabase Get <> Dataaccess.dart
  initState() {
    super.initState();
    _datamanage.open().then((result) {
      _datamanage.getTodo().then((r) {
        for (var i = 0; i < r.length; i++) {
           (r[i].done == false)?setState(() {_unCompleteItems.add(r[i]) ;}):setState(() {_completeItems.add(r[i]);});
        }
      });
    });
  }

  // void getTodoList() async {
  //   await db.open("todo.db");
  //   db.getAllTodos().then((todolist) {
  //     setState(() {
  //       this.todolist = todolist;
  //       this.countTodo = todolist.length;
  //     });
  //   });
  //   db.getAllDoneTodos().then((todoDoneList) {
  //     setState(() {
  //       this.todoDoneList = todoDoneList;
  //       this.countDone = todoDoneList.length;
  //     });
  //   });
  // }
  //AddItemTo TodoList

  void _addItem() async {
    _unCompleteItems = List();
    havecount = false;
    _completeItems = List();
    count = 0;
    await Navigator.pushNamed(context, "/add");
    _datamanage.getTodo().then((r) {

      //check it have space to add
      //***Not use Now***/
      for(var j = 0; j < counttodo; j++) {
        count += 1;
      }
      if(count > 0) {
        havecount = true;
      }

      //add list
      //Use//
      for (var i = 0; i < r.length; i++) {
        (r[i].done == false)?setState(() { _unCompleteItems.add(r[i]);}):setState(() { _completeItems.add(r[i]);});
      }
    });
  }
  //UpdateItem in TodoList And check done
  void _update(TodoManage item, bool newStatus) {
    _unCompleteItems = List();
    _completeItems = List();
    count = 0;
    havedelete = false;
    item.done = newStatus;
    _datamanage.updateTodo(item);
    _datamanage.getTodo().then((items) {

      //check update finish
      //***Not use Now***/
      for(var j = 0; j < countcomplete+counttodo; j++) {
        count += 1;
      }
      if(count == 0) {
        haveupdate = true;
      }

      //add list for update
      //Use//
      for (var i = 0; i < items.length; i++) {
        (items[i].done == false)?setState(() { _unCompleteItems.add(items[i]);}):setState(() { _completeItems.add(items[i]);});
      }
    });
  }

  void _delete() {

    //check it have data to delete
    //***Not use Now***/
    count = 0;
    havedelete = false;
    for(var j = 0; j < countcomplete; j++) {
        count += 1;
      }
      if(count > 0) {
        havedelete = true;
      }

      //delete item
      //Use//
    _datamanage.deleteTodo();
          setState(() {
            _completeItems =List();
          });
  }
  //Delete element in TodoList

  Widget _createuncomplete(TodoManage item) {

    //check if havecount = true its means it have list
    //***Not use Now***/
    state = false;
    if(havecount == true) {
      state = true;
    }

    //return uncomplete list
    //Use//
    return ListTile(
      title: Text(item.title),
      trailing: Checkbox(
        value: item.done,
        onChanged: (value) => _update(item, value),
      ),
    );
  }

  Widget _createallcomplete(TodoManage item) {

    //check if havecount = true its means it have list
    //***Not use Now***/
    state = false;
    if(havecount == true) {
      state = true;
    }

    //return complete list
    //Use//
    return ListTile(
      title: Text(item.title),
      trailing: Checkbox(
        value: item.done,
        onChanged: (value) => _update(item, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // _unCompleteItems.sort();
    var todoListShow, completeListShow;
    var todoItem = _unCompleteItems.map(_createuncomplete).toList();
    var completeItem =
        _completeItems.map(_createallcomplete).toList();
    if(todoItem.isEmpty){
      todoListShow = Center(
              child: Text(
                "No Data Found..",
                textAlign: TextAlign.center,
                ),
      );
    }
    else{
      todoListShow = ListView(
      children: todoItem,
    );
    }
    if(completeItem.isEmpty){
      completeListShow = Center(
              child: Text(
                "No Data Found..",
                textAlign: TextAlign.center,
                ),
      );
    }
    else{
      completeListShow = ListView(
      children: completeItem,
    );
    }
    counttodo = todoItem.length;
    countcomplete = completeItem.length;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: Container(
          color: HexColor("ffdae9"),
          child: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.format_list_bulleted),
                text: "Task",
              ),
              Tab(
                icon: Icon(Icons.done_all),
                text: "Completed",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            new Scaffold(
              appBar: AppBar(
                title: Text("Todo"),
                actions: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.add),
                    color: Colors.white,
                    onPressed: _addItem,
                  )
                ],
              ),
              body: todoListShow
            ),
            new Scaffold(
              appBar: AppBar(
                title: Text("Todo"),
                actions: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.delete),
                    color: Colors.white,
                    onPressed: _delete,
                  )
                ],
              ),
              body: completeListShow
            ),
          ],
        ),
      ),
    );
  }
}

class AddItempage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddItemState();
}

class _AddItemState extends State<AddItempage> {
  final _tdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TodoProvider dbget = TodoProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("New Subject")),
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              new Center(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Subject"),
                    controller: _tdController,
                    validator: (value) {
                        if (value.isEmpty) {
                          return "Please fill subject";
                        }
                    },
                    onSaved: (value) => print(value),
                  ), 
                ),
              new Row(children: <Widget>[
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    child: Text("Save"),
                    onPressed: () {
                       if (_formKey.currentState.validate() == false) {
                          print("Please fill Subject");
                        } else {
                          dbget.insertTodo(TodoManage(title: _tdController.text));
                          Navigator.pop(context);
                        }  
                    }
                  )
                  ),
                  ],
                ),  
              ],
            ),
          ),
        );
  }

  @override
  void dispose() {
    _tdController.dispose();
    super.dispose();
  }
}