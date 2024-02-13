part of 'collection_bloc.dart';

abstract class CollectionEvent {}

class CollectionLoading extends CollectionEvent {
  final int workId;
  final String orderNumber;
  CollectionLoading({required this.workId, required this.orderNumber});
}

class CollectionNavigate extends CollectionEvent {
  final String route;
  final dynamic arguments;
  CollectionNavigate({ required this.route, required this.arguments });
}

class CollectionBack extends CollectionEvent {}

class CollectionPaymentEfectyChanged extends CollectionEvent {
  final String value;
  CollectionPaymentEfectyChanged({required this.value});
}

class CollectionPaymentTransferChanged extends CollectionEvent {
  final String value;
  CollectionPaymentTransferChanged({required this.value});
}

class CollectionButtonPressed extends CollectionEvent {
  final InventoryArgument arguments;
  CollectionButtonPressed({ required this.arguments });
}

class CollectionConfirmTransaction extends CollectionEvent {
  final InventoryArgument arguments;
  CollectionConfirmTransaction({ required this.arguments });
}
