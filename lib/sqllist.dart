import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBPrinterManager {
  Database _datebase;

  Future openDB() async {
    if (_datebase == null) {
      _datebase = await openDatabase(
          join(await getDatabasesPath(), "printer.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE printer(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,address TEXT,ip TEXT,lic TEXT,url TEXT)");
      });
    }
  }

  Future<int> insertprinter(Printer printer) async {
    await openDB();
    return await _datebase.insert('printer', printer.toMap());
  }

  Future<List<Printer>> getprinterList() async {
    await openDB();
    final List<Map<String, dynamic>> maps = await _datebase.query('printer');

    return List.generate(maps.length, (index) {
      return Printer(
          id: maps[index]['id'],
          name: maps[index]['name'],
          address: maps[index]['address'],
          ip: maps[index]['ip'],
          lic: maps[index]['lic'],
          url: maps[index]['url'],
          
          );
    });
  }

  // Future<int> updateStudent(Printer printer) async {
  //   await openDB();
  //   return await _datebase.update('printer', printer.toMap(),
  //       where: 'id=?', whereArgs: [printer.id]);
  // }

  Future<void> deleteprinter(int id) async {
    await openDB();
    await _datebase.delete("printer", where: "id = ? ", whereArgs: [id]);
  }
}

class Printer {
  int id;
  String name;
  String address;
  String ip;
  String lic;
  String url;
  Printer({ @required this.name, @required this.address,this.id,this.ip,this.lic,this.url});
  Map<String, dynamic> toMap() {
    return {'name': name, 'address': address,'ip':ip,'lic':lic,'url':url};
  }
}