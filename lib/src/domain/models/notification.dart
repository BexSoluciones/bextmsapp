const String tableNotifications = 'notifications';


class NotificationFields {
  static final List<String> values = [
    id_from_server,
    title,
    body,
    date,
    with_click_action,
    read_at,
    content,
    type,
    from,
    to,
  ];

  static const String id = 'id';
  static const  String id_from_server = 'id_from_server';
  static const  String title = 'title';
  static const  String body = 'body';
  static const  String date = 'date';
  static const  String with_click_action = 'with_click_action';
  static const  String content = 'content';
  static const  String type = 'type';
  static const  String from = '_from';
  static const  String to = '_to';
  static const  String status = 'status';
  static const  String createdAt = 'created_at';
  static const  String updatedAt = 'updated_at';
  static const  String read_at = 'read_at';

}


class PushNotification {
  PushNotification({
    this.id,
    this.id_from_server,
    this.title,
    this.body,
    this.date,
    this.read_at,
    this.with_click_action,
    this.content,
    this.type,
    this.from,
    this.to,
    this.status,
    this.createdAt,
    this.updatedAt
  });

  PushNotification copy(/* {
    int? id,
  } */
      ) =>
      PushNotification(
          id_from_server: id_from_server,
          title: title,
          body: body,
          date: date,
          with_click_action: with_click_action,
          read_at: read_at,
          content: content,
          type: type,
          from: from,
          to: to,
          status: status,
          createdAt: createdAt,
          updatedAt: updatedAt);

  late int? id;
  late String? id_from_server;
  late String? title;
  late String? body;
  late String? date;
  late String? read_at;

  late String? with_click_action;
  late String? content;
  late String? type;
  late String? from;
  late String? to;
  late String? status;
  late String? createdAt;
  late String? updatedAt;

  // ignore: sort_constructors_first
  PushNotification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    id_from_server =
    (json['id_from_server'] != null) ? json['id_from_server'] : null;
    title = (json['title']) != null ? json['title'] : null;
    body = (json['body']) != null ? json['body'] : null;
    date = (json['date']) != null ? json['date'] : null;
    with_click_action =
    (json['with_click_action']) != null ? json['with_click_action'] : null;
    read_at = (json['read_at']) != null ? json['read_at'] : null;
    content = (json['content']) != null ? json['content'] : null;
    type = (json['type']) != null ? json['type'] : null;
    from = (json['_from']) != null ? json['_from'] : null;
    to = (json['_to']) != null ? json['_to'] : null;
    status = (json['status']) != null ? json['status'] : null;
    createdAt = (json['created_at']) != null ? json['created_at'] : null;
    updatedAt = (json['updated_at']) != null ? json['updated_at'] : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id_from_server'] = id_from_server;
    data['title'] = title;
    data['body'] = body;
    data['date'] = date;
    data['with_click_action'] = with_click_action;
    data['read_at'] = read_at;
    return data;
  }
}