import 'transaction.dart';

const String tableSummaries = 'summaries';

class SummaryFields {
  static final List<String> values = [
    id,
    workId,
    orderNumber,
    type,
    coditem,
    codbar,
    nameItem,
    image,
    amount,
    cant,
    unitOfMeasurement,
    nameOfMeasurement,
    grandTotal,
    grandTotalCopy,
    price,
    typeOfCharge,
    codeWarehouse,
    operativeCenter,
    costCenter,
    manufacturingBatch,
    typeItem,
    typeTransaction,
    evidences,
    minus,
    status,
    idPacking,
    packing,
    expedition,
    createdAt,
    updatedAt
  ];

  static const String id = 'id';
  static const String workId = 'work_id';
  static const String orderNumber = 'order_number';
  static const String type = 'type';
  static const String coditem = 'coditem';
  static const String codbar = 'codbar';
  static const String nameItem = 'name_item';
  static const String image = 'image';
  static const String amount = 'amount';
  static const String cant = 'cant';
  static const String unitOfMeasurement = 'unit_of_measurement';
  static const String nameOfMeasurement = 'name_of_measurement';
  static const String grandTotal = 'grand_total';
  static const String grandTotalCopy = 'grand_total_copy';
  static const String price = 'price';
  static const String typeOfCharge = 'type_of_charge';
  static const String codeWarehouse = 'code_warehouse';
  static const String operativeCenter = 'operative_center';
  static const String costCenter = 'cost_center';
  static const String manufacturingBatch = 'manufacturing_batch';
  static const String typeItem = 'type_item';
  static const String typeTransaction = 'type_transaction';
  static const String minus = 'minus';
  static const String status = 'status';
  static const String idPacking = 'id_packing';
  static const String packing = 'packing';
  static const String expedition = 'expedition';
  static const String evidences = 'evidencia';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class Summary {
  Summary(
      { required this.id,
        required this.workId,
        required this.orderNumber,
        this.type,
        required this.coditem,
        this.codbar,
        required this.nameItem,
        this.image,
        required this.amount,
        required this.cant,
        required this.unitOfMeasurement,
        this.nameOfMeasurement,
        required this.grandTotal,
        this.grandTotalCopy,
        required this.price,
        this.typeOfCharge,
        this.codeWarehouse,
        this.operativeCenter,
        this.costCenter,
        this.manufacturingBatch,
        required this.typeItem,
        required this.typeTransaction,
        this.evidences,
        this.count,
        required this.minus,
        this.status,
        this.transaction,
        this.loading,
        this.idPacking,
        this.packing,
        this.expedition,
        this.createdAt,
        this.updatedAt,
        this.validate
      });

  Summary copy({
    int? id,
  }) =>
      Summary(
          id: id ?? this.id,
          workId: workId,
          orderNumber: orderNumber,
          type: type ?? type,
          coditem: coditem,
          codbar: codbar ?? codbar,
          nameItem: nameItem,
          image: image ?? image,
          amount: amount,
          cant: cant,
          unitOfMeasurement: unitOfMeasurement,
          nameOfMeasurement: nameOfMeasurement,
          grandTotal: grandTotal,
          grandTotalCopy: grandTotalCopy,
          price: price,
          typeOfCharge: typeOfCharge ?? typeOfCharge,
          codeWarehouse: codeWarehouse ?? codeWarehouse,
          operativeCenter: operativeCenter ?? operativeCenter,
          costCenter: costCenter ?? costCenter,
          manufacturingBatch: manufacturingBatch ?? manufacturingBatch,
          typeItem: typeItem,
          typeTransaction: typeTransaction,
          evidences: evidences ?? evidences,
          count: count ?? 0,
          minus: minus,
          status: status,
          idPacking: idPacking,
          packing: packing,
          expedition: expedition,
          createdAt: createdAt,
          updatedAt: updatedAt,
          validate:validate
      );

  // ignore: sort_constructors_first
  Summary.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workId = json['work_id'];
    orderNumber = json['order_number'];
    type = json['type'];
    coditem = json['coditem'];
    codbar = json['codbar'];
    nameItem = json['name_item'];
    image = json['image'];
    amount = json['amount'];
    cant = json['cant'].toDouble();
    unitOfMeasurement = json['unit_of_measurement'];
    nameOfMeasurement = json['name_of_measurement'];
    grandTotal = (json['grand_total'] is int)
        ? json['grand_total'].toDouble()
        : json['grand_total'];
    grandTotalCopy = json['grand_total_copy'];
    price = (json['price'] is int) ? json['price'].toDouble() : json['price'];
    typeOfCharge = json['type_of_charge'];
    codeWarehouse = json['code_warehouse'];
    operativeCenter = json['operative_center'];
    costCenter = json['cost_center'];
    manufacturingBatch = json['manufacturing_batch'];
    typeItem = json['type_item'];
    typeTransaction = json['type_transaction'];
    evidences = json['evidencia'];
    count = json['count'];
    minus = json['minus'];
    status = json['status'];
    transaction = json['is_transaction'] != null ? Transaction.fromJson(json['is_transaction']) : null;
    idPacking = json['id_packing'];
    packing = json['packing'];
    expedition = json['expedition'];
    createdAt = json['created_at'] ?? 'no-fecha';
    updatedAt = json['updated_at'] ?? 'no-fecha';
    validate = json['validate'];
    hasTransaction = json['has_transaction'];
  }

  late int id;
  late int workId;
  late String orderNumber;
  String? type;
  late String coditem;
  String? codbar;
  late String nameItem;
  String? image;
  late String amount;
  late double cant;
  late String unitOfMeasurement;
  String? nameOfMeasurement;
  late double grandTotal;
  double? grandTotalCopy;
  late double price;
  String? typeOfCharge;
  String? codeWarehouse;
  String? operativeCenter;
  String? costCenter;
  String? manufacturingBatch;
  late String typeItem;
  late String typeTransaction;
  String? evidences;
  int? count;
  late int minus;
  String? status;
  String? idPacking;
  String? expedition;
  String? packing;
  Transaction? transaction;
  bool? loading = false;
  String? createdAt;
  String? updatedAt;
  int? validate;
  int? hasTransaction;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['work_id'] = workId;
    data['order_number'] = orderNumber;
    data['type'] = type;
    data['coditem'] = coditem;
    data['codbar'] = codbar;
    data['name_item'] = nameItem;
    data['image'] = image;
    data['amount'] = amount;
    data['cant'] = cant;
    data['unit_of_measurement'] = unitOfMeasurement;
    data['name_of_measurement'] = nameOfMeasurement;
    data['grand_total'] = grandTotal;
    data['grand_total_copy'] = grandTotalCopy;
    data['price'] = price;
    data['type_of_charge'] = typeOfCharge;
    data['code_warehouse'] = codeWarehouse;
    data['operative_center'] = operativeCenter;
    data['cost_center'] = costCenter;
    data['manufacturing_batch'] = manufacturingBatch;
    data['type_item'] = typeItem;
    data['type_transaction'] = typeTransaction;
    data['evidencia'] = evidences;
    data['minus'] = minus;
    data['status'] = status;
    data['id_packing'] = idPacking;
    data['packing'] = packing;
    data['expedition'] = expedition;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


