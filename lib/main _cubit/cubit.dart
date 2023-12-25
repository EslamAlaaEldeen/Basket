import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../shared/network/local/cache_helper.dart';
import 'states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  bool isBottomSheetShown = false;
  IconData fabicon = Icons.edit;

  void ChangeBottomSheetState({required bool isShow, required IconData icon}) {
    isBottomSheetShown = isShow;
    fabicon = icon;
    emit(AppChangeBottomSheetState());
  }

  bool isdark = false;

  void changeAppMode({bool? fromshared}) {
    if (fromshared != null) {
      isdark = fromshared;
      emit(NewsChangeModeState());
    } else {
      isdark = !isdark;
      CacheHelper.setData(key: 'isdark', value: isdark).then((value) {
        emit(NewsChangeModeState());
      });
    }
  }

  Database? database;
  List<Map> newtasks = [];
  List<Map> donetasks = [];
  List<Map> archivetasks = [];

  void CreateDataBase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
                'CREATE TABLE tasks(task_id INTEGER PRIMARY KEY ,titlee TEXT,date TEXT,time TEXT,status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('error when created table${error.toString()}');
        });
      },
      onOpen: (database) {
        getdatafromdatabase(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDataBaseState());
    });
  }

  InsertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) {
      return txn
          .rawInsert(
        'INSERT INTO tasks (title,date,time,status)VALUES("$title","$date","$time","news")',
      )
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDataBaseState());

        getdatafromdatabase(database);
      }).catchError((error) {
        print('error when insert new record ${error.toString()}');
      });
    });
  }

  void getdatafromdatabase(database) {
    newtasks = [];
    donetasks = [];
    archivetasks = [];
    emit(AppGetDataBaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      print(value);
      value.forEach((element) {
        if (element['status'] == 'news') {
          newtasks.add(element);
        } else if (element['status'] == 'done') {
          donetasks.add(element);
        } else {
          archivetasks.add(element);
        }
      });
      emit(AppGetDataBaseState());
    });
  }

  void updateData({
    required String? status,
    required int? id,
  }) async {
    database?.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      emit(AppGetDataBaseState());
      emit(AppUpdateDataBaseState());
    });
  }

  void DeleteData({
    required int? id,
  }) async {
    database?.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      emit(AppGetDataBaseState());
      emit(AppDeleteDataBaseState());
    });
  }
}
