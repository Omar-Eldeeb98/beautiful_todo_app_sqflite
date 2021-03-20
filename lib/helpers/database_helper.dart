import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();

/*     just a drawing ...........

           tasks_table
    id | title | date | priority | status
    0     ...    ...      ...         0
    1     ...    ...      ...         1
    2     ...    ...      ...         0

*/

  String tasksTable = 'task_table';
  String idCol = 'id';
  String titleCol = 'title';
  String dateCol = 'date';
  String priorityCol = 'priority';
  String statusCol = 'status';

  // to get the database
  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);

    return todoListDb;
  }

  // create our database table
  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $tasksTable($idCol INTEGER PRIMARY KEY AUTOINCREMENT, $titleCol TEXT, $dateCol TEXT , $priorityCol TEXT , $statusCol INTEGER)',
    );
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database database = await this.db;
    final List<Map<String, dynamic>> result = await database.query(tasksTable);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    return taskList;
  }

  // CRUD functions ................

  // (1) insert task /
  Future<int> insertTask(Task task) async {
    Database database = await this.db;
    final int result = await database.insert(tasksTable, task.toMap());
    return result;
  }

  // (2) update task /
  Future<int> updateTask(Task task) async {
    Database database = await this.db;
    final int result = await database.update(
      tasksTable,
      task.toMap(),
      where: '$idCol = ?',
      whereArgs: [task.id],
    );

    return result;
  }

  // (3) delete task /
  Future<int> deleteTask(int id) async {
    Database database = await this.db;
    final int result = await database.delete(
      tasksTable,
      where: '$idCol = ?',
      whereArgs: [id],
    );

    return result;
  }
}















//______________________________________________OE57_________________________________________________________//