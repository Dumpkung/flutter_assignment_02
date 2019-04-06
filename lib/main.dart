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
      title: 'Todo Flutter',
      theme: new ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Todostate(title: 'Todo List'),
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
  List<TodoManager> _unCompleteItems = List();
  List<TodoManager> _completeItems = List();
  DataAccess _datamanage;
  int counttodo = 0, countcomplete = 0;

  _TodoListScreenPage() {
    _datamanage = DataAccess();
  }


  @override
  //CreateDatabase Get <> Dataaccess.dart
  initState() {
    super.initState();
    _datamanage.open().then((result) {
      _datamanage.getTodoItems().then((r) {
        for (var i = 0; i < r.length; i++) {
           (r[i].isComplete == false)?setState(() {_unCompleteItems.add(r[i]) ;}):setState(() {_completeItems.add(r[i]);});
        }
      });
    });
  }
  //AddItemTo TodoList
  void _addItemToList() async {
    _unCompleteItems = List();
    _completeItems = List();
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddItempage()));
    _datamanage.getTodoItems().then((r) {
      for (var i = 0; i < r.length; i++) {
        (r[i].isComplete == false)?setState(() { _unCompleteItems.add(r[i]);}):setState(() { _completeItems.add(r[i]);});
      }
    });
  }
  //UpdateItem in TodoList And check isComplete
  void _updateTodocheckComplete(TodoManager item, bool newStatus) {
    _unCompleteItems = List();
    _completeItems = List();
    item.isComplete = newStatus;
    _datamanage.updateTodo(item);
    _datamanage.getTodoItems().then((items) {
      for (var i = 0; i < items.length; i++) {
        (items[i].isComplete == false)?setState(() { _unCompleteItems.add(items[i]);}):setState(() { _completeItems.add(items[i]);});
      }
    });
  }
  //Delete element in TodoList
  void _deleteTodoItem() {
    _datamanage.deleteTodo();
          setState(() {
            _completeItems =List();
          });
  }

  Widget _createTodoItemWidget(TodoManager item) {
    return ListTile(
      title: Text(item.name),
      trailing: Checkbox(
        value: item.isComplete,
        onChanged: (value) => _updateTodocheckComplete(item, value),
      ),
    );
  }

  Widget _createCompleteItemWidget(TodoManager item) {
    return ListTile(
      title: Text(item.name),
      trailing: Checkbox(
        value: item.isComplete,
        onChanged: (value) => _updateTodocheckComplete(item, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // _unCompleteItems.sort();
    var todoListShow, completeListShow;
    var todoItem = _unCompleteItems.map(_createTodoItemWidget).toList();
    var completeItem =
        _completeItems.map(_createCompleteItemWidget).toList();
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
                    onPressed: _addItemToList,
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
                    onPressed: _deleteTodoItem,
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
                      if(_formKey.currentState.validate()) {
                        DataAccess().insertTodo(TodoManager(name: _tdController.text));
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