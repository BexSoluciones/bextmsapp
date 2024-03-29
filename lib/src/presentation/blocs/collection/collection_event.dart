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
  CollectionNavigate({required this.route, required this.arguments});
}

class CollectionBack extends CollectionEvent {}

class CollectionOpenModal extends CollectionEvent {}

class CollectionCloseModal extends CollectionEvent {}

class CollectionPaymentEfectyChanged extends CollectionEvent {
  final String value;
  CollectionPaymentEfectyChanged({required this.value});
}

class CollectionPaymentEfectyClear extends CollectionEvent {}

class CollectionPaymentTransferChanged extends CollectionEvent {
  final String value;
  CollectionPaymentTransferChanged({required this.value});
}

class CollectionPaymentTransferClear extends CollectionEvent {}

class CollectionPaymentMultiTransferChanged extends CollectionEvent {
  final String value;
  CollectionPaymentMultiTransferChanged({required this.value});
}

class CollectionPaymentDateChanged extends CollectionEvent {
  final String value;
  CollectionPaymentDateChanged({required this.value});
}

class CollectionPaymentAccountChanged extends CollectionEvent {
  final Account value;
  CollectionPaymentAccountChanged({required this.value});
}

class CollectionButtonPressed extends CollectionEvent {
  final InventoryArgument arguments;
  CollectionButtonPressed({required this.arguments});
}

class CollectionConfirmTransaction extends CollectionEvent {
  final InventoryArgument arguments;
  CollectionConfirmTransaction({required this.arguments});
}

class CollectionAddOrUpdatePayment extends CollectionEvent {
  final int? index;
  CollectionAddOrUpdatePayment({required this.index});
}

class CollectionEditPaymentWithAccount extends CollectionEvent {
  final int index;
  CollectionEditPaymentWithAccount({required this.index});
}

class CollectionRemovePayment extends CollectionEvent {
  final AccountPayment payment;
  final double value;
  CollectionRemovePayment({required this.payment, required this.value});
}

class CollectionError extends CollectionEvent {
  CollectionError();
}
