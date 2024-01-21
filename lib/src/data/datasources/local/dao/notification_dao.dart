part of '../app_database.dart';

class NotificationDao {
  final AppDatabase _appDatabase;

  NotificationDao(this._appDatabase);

  List<PushNotification> parseNotifications(
      List<Map<String, dynamic>> notificationsList) {
    final notifications = <PushNotification>[];

    for (var currentNotification in notificationsList) {
      final notification = PushNotification.fromJson(currentNotification);
      notifications.add(notification);
    }

    return notifications;
  }

  //INSERT METHODS
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await _appDatabase.streamDatabase;
    try {
      return db!.insert(table, row);
    } catch (error, stackTrace) {
      //await helperFunctions.handleException(error, stackTrace);
      return 0;
    }
  }

  Future<List<PushNotification>> getNotifications() async {
    final db = await _appDatabase.streamDatabase;
    final notificationsList = await db!.query(tableNotifications);
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

  Future<int> deleteNotificationsByDays() async {
    final db = await _appDatabase.streamDatabase;
    var today = DateTime.now();
    var limitDaysWork = _storageService.getInt('limit_days_works') ?? 3;
    var datesToValidate = today.subtract(Duration(days: limitDaysWork));
    List<Map<String, dynamic>> NotificationsToDelete;

    var formattedToday = DateTime(today.year, today.month, today.day);
    var formattedDatesToValidate = DateTime(
        datesToValidate.year, datesToValidate.month, datesToValidate.day);
    var formattedTodayStr = formattedToday.toIso8601String().split('T')[0];
    var formattedDatesToValidateStr =
        formattedDatesToValidate.toIso8601String().split('T')[0];

    NotificationsToDelete = await db!.query(
      tableNotifications,
      where: 'substr(date, 1, 10) <= ?',
      whereArgs: [formattedDatesToValidateStr],
    );

    for (var task in NotificationsToDelete) {
      var createdAt = DateTime.parse(task['date']);
      var differenceInDays = formattedToday.difference(createdAt).inDays;
      if (differenceInDays > limitDaysWork) {
        await db.delete(
          tableNotifications,
          where: 'id = ?',
          whereArgs: [task['id']],
        );
      }
    }

    return db.delete(
      tableNotifications,
      where: 'substr(date, 1, 10) <= ?',
      whereArgs: [formattedDatesToValidateStr],
    );
  }
}
