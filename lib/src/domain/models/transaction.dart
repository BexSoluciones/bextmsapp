import 'dart:convert';
import 'payment.dart';

const String tableTransactions = 'transactions';

class TransactionFields {
  static final List<String> values = [
    id,
    workId,
    summaryId,
    workcode,
    orderNumber,
    status,
    codmotvis,
    reason,
    payments,
    delivery,
    file,
    images,
    observation,
    operativeCenter,
    start,
    end,
    latitude,
    longitude
  ];

  static const String id = 'id';
  static const String workId = 'work_id';
  static const String summaryId = 'summary_id';
  static const String workcode = 'workcode';
  static const String orderNumber = 'order_number';
  static const String status = 'status';
  static const String codmotvis = 'codmotvis';
  static const String reason = 'reason';
  static const String payments = 'payments';
  static const String delivery = 'delivery';
  static const String images = 'images';
  static const String file = 'file';
  static const String firm = 'firm';
  static const String observation = 'observation';
  static const String operativeCenter = 'operative_center';
  static const String start = 'start';
  static const String end = 'end';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String historyId = 'history_id';
}

class Transaction {
  Transaction(
      {this.id,
      required this.workId,
      this.summaryId,
      this.orderNumber,
      this.workcode,
      required this.status,
      this.codmotvis,
      this.reason,
      this.payments,
      this.images,
      this.observation,
      this.delivery,
      this.file,
      this.firm,
      this.operativeCenter,
      this.start,
      this.end,
      this.latitude,
      this.longitude,
      this.historyId});

  Transaction copy({
    int? id,
  }) =>
      Transaction(
          id: id ?? this.id,
          workId: workId,
          summaryId: summaryId,
          orderNumber: orderNumber,
          workcode: workcode,
          status: status,
          codmotvis: codmotvis,
          reason: reason,
          payments: payments,
          images: images,
          observation: observation,
          delivery: delivery,
          operativeCenter: operativeCenter,
          file: file,
          firm: firm,
          start: start,
          end: end,
          historyId: historyId);

  int? id;
  late int workId;
  int? summaryId;
  String? orderNumber;
  String? workcode;
  late String status;
  String? codmotvis;
  String? reason;
  List<Payment>? payments;
  String? delivery;
  String? observation;
  String? file;
  String? firm;
  String? start;
  String? end;
  String? operativeCenter;
  String? latitude;
  String? longitude;
  int? historyId;
  List<String>? images;

  // ignore: sort_constructors_first
  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workId = json['work_id'];
    summaryId = json['summary_id'];
    workcode = json['workcode'];
    orderNumber = json['order_number'];
    status = json['status'];
    codmotvis = json['codmotvis'];
    reason = json['reason'];
    if (json['payments'] != null) {
      payments = [];
      if (json['payments'] is String && json['payments'] != 'null') {
        jsonDecode(json['payments'])
            .forEach((payment) => payments?.add(Payment.fromJson(payment)));
      } else if (json['payments'] is List) {
        json['payments']
            .forEach((payment) => payments?.add(Payment.fromJson(payment)));
      }
    } else {
      payments = [];
    }
    if (json['images'] != null) {
      images = [];
      if (json['images'] is String) {
        jsonDecode(json['images']).forEach((image) => image);
      } else {
        json['images'].forEach((image) => image);
      }
    } else {
      images = [];
    }
    observation = json['observation'];
    delivery = json['delivery'];
    file = json['file'];
    firm = json['firm'];
    operativeCenter = json['operative_center'];
    start = json['start'];
    end = json['end'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    historyId = json['history_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['work_id'] = workId;
    data['summary_id'] = summaryId;
    data['workcode'] = workcode;
    data['order_number'] = orderNumber;
    data['status'] = status;
    data['codmotvis'] = codmotvis;
    data['reason'] = reason;
    data['payments'] =
        payments != null ? jsonEncode(payments!) : jsonEncode([]);
    data['delivery'] = delivery;
    data['file'] = file;
    data['firm'] = firm;
    data['images'] = images != null ? jsonEncode(images!) : jsonEncode([]);
    data['observation'] = observation;
    data['operative_center'] = operativeCenter;
    data['start'] = start;
    data['end'] = end;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['history_id'] = historyId;
    return data;
  }
}
