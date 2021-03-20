import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_with_sqflite/helpers/database_helper.dart';
import 'package:todo_app_with_sqflite/models/task_model.dart';

class AddNewTaskScreen extends StatefulWidget {
  final Task task;
  final Function updateTaskList;

  const AddNewTaskScreen({Key key, this.task, this.updateTaskList})
      : super(key: key);
  @override
  _AddNewTaskScreenState createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final _fromKey = GlobalKey<FormState>();
  String _title = '';
  String _prioriry;
  DateTime _date = DateTime.now();

  TextEditingController _dateController = TextEditingController();
  final DateFormat formattedDate = DateFormat('MMM dd, yyyy');
  final List<String> periorities = ['Low', 'Medium', 'High'];

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = formattedDate.format(date);
    }
  }

  void _submit() {
    if (_fromKey.currentState.validate()) {
      _fromKey.currentState.save();
      print('$_title ,$_prioriry ,$_date ');

      Task task = new Task(title: _title, date: _date, priority: _prioriry);

      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
        print('operation is done');
      } else {
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }
      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  void initState() {
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _prioriry = widget.task.priority;
    }

    _dateController.text = formattedDate.format(_date);
  }

  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        height: MediaQuery.of(context).size.height * 0.7,
        width: double.infinity,
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(top: 120, right: 20, left: 20),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 30.0,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    widget.task == null ? 'Add Task' : 'Update Task',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Form(
                    key: _fromKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => input.trim().isEmpty
                                ? 'please enter a task title '
                                : null,
                            onSaved: (input) => _title = input,
                            initialValue: _title,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            readOnly: true,
                            onTap: _handleDatePicker,
                            controller: _dateController,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: DropdownButtonFormField(
                            isDense: true,
                            items: periorities.map((String periority) {
                              return DropdownMenuItem(
                                value: periority,
                                child: Text(
                                  periority,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: Icon(Icons.arrow_drop_down_circle),
                            iconSize: 22,
                            iconEnabledColor: Colors.green,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Periority',
                              labelStyle: TextStyle(fontSize: 18.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (input) => _prioriry == null
                                ? 'please select task periority '
                                : null,
                            onChanged: (value) {
                              setState(() {
                                _prioriry = value;
                              });
                            },
                            value: _prioriry,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15.0),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: TextButton(
                            child: Text(
                              widget.task == null ? "Add" : 'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                            onPressed: _submit,
                          ),
                        ),
                        widget.task == null
                            ? SizedBox.shrink()
                            : Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  color: Colors.red,
                                ),
                                child: FlatButton(
                                  onPressed: _delete,
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
