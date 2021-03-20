import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import 'addTaskScreen.dart';
import '../models/task_model.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Task>> _taskList;
  final DateFormat formattedDate = DateFormat('MMM dd, yyyy');
  var containerRadius = Radius.circular(25.0);

  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  Widget _createTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                color: Colors.grey[350],
                fontSize: 22.0,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${formattedDate.format(task.date)} - ${task.priority}',
              style: TextStyle(
                color: Colors.grey[600],
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 2.0, color: Colors.grey[700]),
                  left: BorderSide(width: 2.0, color: Colors.grey[700]),
                  right: BorderSide(width: 2.0, color: Colors.grey[700]),
                  bottom: BorderSide(width: 2.0, color: Colors.grey[700]),
                ),
              ),
              child: Checkbox(
                  onChanged: (value) {
                    task.status = value ? 1 : 0;
                    DatabaseHelper.instance.updateTask(task);
                    _updateTaskList();
                    print(value);
                  },
                  activeColor: Colors.green,
                  value: task.status == 1 ? true : false),
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddNewTaskScreen(
                    task: task,
                    updateTaskList: _updateTaskList,
                  ),
                )),
          ),
          Divider(
            color: Colors.green,
            thickness: 0.4,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backwardsCompatibility: false,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Colors.black87),
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: Text(
          'TODO App',
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
        leading: Icon(Icons.notes_rounded),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.more_horiz_sharp),
            onPressed: () {},
            color: Colors.white,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddNewTaskScreen(
                      updateTaskList: _updateTaskList,
                    ))),
        child: Icon(Icons.add),
      ),
      body: Container(
        child: FutureBuilder(
            future: _taskList,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final int completedTaskCount = snapshot.data
                  .where((Task task) => task.status == 1)
                  .toList()
                  .length;

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                itemCount: 1 + snapshot.data.length,
                itemBuilder: (BuildContext context, int i) {
                  if (i == 0) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 20.0),
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'My Tasks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40.0,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                IconButton(
                                  icon: Icon(Icons.tag_faces_outlined),
                                  onPressed: () {},
                                  iconSize: 35,
                                  color: Colors.grey[700],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              '$completedTaskCount of ${snapshot.data.length}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _createTask(snapshot.data[i - 1]);
                },
              );
            }),
      ),
    );
  }
}
