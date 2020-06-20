import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {

     static List<String> migrations = [
          '''
          create table table_name (
               id integer primary key autoincrement,
               name text
          )
          ''',

          ''' 
          alter table table_name 
          add column image_path text;
          ''',
     ];


     static migrate(Database db, int oldVersion, int newVersion) async {
          if (newVersion == 0) return;

          for (var i = oldVersion; i <= newVersion - 1; i++) {
               await db.execute(migrations[i]);
          }
     }

     static Future<Database> open() async {
          final databasesPath = await getDatabasesPath();
          final path = join(databasesPath, 'base.sqlite');

          return await openDatabase(path,
               version: migrations.length,
               onCreate: (Database db, int version) async {
                    migrate(db, 0, version);
               },
               onUpgrade: (Database db, int oldVersion, int newVersion) async {
                    migrate(db, oldVersion, newVersion);
               });
     }
}
