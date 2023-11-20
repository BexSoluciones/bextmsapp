
import 'package:sqflite/sqflite.dart';

import '../../../../domain/models/notification.dart';
import '../app_database.dart';

class NotificationDao {
  final AppDatabase _appDatabase;

  NotificationDao(this._appDatabase);

  List<PushNotification> parseNotifications(
      List<Map<String, dynamic>> notificationsList) {
    final notifications = <PushNotification>[];

    notificationsList.forEach((currentNotification) {
      final notification = PushNotification.fromJson(currentNotification);
      notifications.add(notification);
    });

    return notifications;
  }

  //INSERT METHODS
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await _appDatabase.streamDatabase;
    try {
      return db!.insert(table, row);
    } catch (error, stackTrace) {
      print('Error in insertFunction ${error.toString()}');
      //await helperFunctions.handleException(error, stackTrace);
      return 0;
    }
  }


  Future<List<PushNotification>> getNotifications() async {
    final db = await _appDatabase.streamDatabase;
    final notificationsList = await db!
        .query(tableNotifications);
    final notifications = parseNotifications(notificationsList);
    return notifications;
  }


  Future<int> updateNotification(int notificationid, String readAt) async {
    final db = await _appDatabase.streamDatabase;
    return db!.update(tableNotifications, {'read_at': readAt},
        where: 'id = ?', whereArgs: [notificationid]);
  }

  Future<int?> countAllUnreadNotifications() async {
    final db = await _appDatabase.streamDatabase;
    return Sqflite.firstIntValue(await db!.rawQuery(
        'SELECT COUNT(*) FROM $tableNotifications WHERE read_at IS NULL'));
  }

  Future<int> insertNotification(PushNotification notification) {
    return insert(tableNotifications, notification.toJson());
  }






}
