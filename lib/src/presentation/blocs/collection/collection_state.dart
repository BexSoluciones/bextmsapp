part of 'collection_bloc.dart';

enum CollectionStatus {
  initial,
  loading,
  success,
  navigate,
  back,
  error
}

enum FormSubmissionStatus {
  initial,
  submitting,
  success,
  failure,
}

class CollectionState extends Equatable {
  final CollectionStatus status;


  final double? totalSummary;
  final double? total;
  final EnterpriseConfig? enterpriseConfig;
  final Work? work;
  final String? error;
  //NORMAL TRANSACTION
  final PaymentEfecty efecty;
  final PaymentTransfer transfer;
  final PaymentDate date;
  final PaymentMultiTransfer multiTransfer;

  //ACCOUNT TRANSACTION
  final List<AccountPayment>? accounts;
  final Account? account;

  final FormSubmissionStatus formSubmissionStatus;

  const CollectionState({
    this.status = CollectionStatus.initial,
    this.totalSummary,
    this.total,
    this.enterpriseConfig,
    this.work,
    this.efecty = PaymentEfecty.empty,
    this.transfer = PaymentTransfer.empty,
    this.multiTransfer = PaymentMultiTransfer.empty,
    this.date = PaymentDate.empty,
    this.accounts,
    this.account,
    this.formSubmissionStatus = FormSubmissionStatus.initial,
    this.error
  });

  CollectionState copyWith({
    CollectionStatus? status,
    double? totalSummary,
    double? total,
    EnterpriseConfig? enterpriseConfig,
    Work? work,
    PaymentEfecty? efecty,
    PaymentTransfer? transfer,
    PaymentDate? date,
    PaymentMultiTransfer? multiTransfer,
    List<AccountPayment>? accounts,
    Account? account,
    FormSubmissionStatus? formSubmissionStatus,
    String? error
  }) =>
      CollectionState(
        status: status ?? this.status,
        totalSummary: totalSummary ?? this.totalSummary,
        total: total ?? this.total,
        enterpriseConfig: enterpriseConfig ?? this.enterpriseConfig,
        work: work ?? this.work,
        efecty: efecty ?? this.efecty,
        transfer: transfer ?? this.transfer,
        formSubmissionStatus: formSubmissionStatus ?? this.formSubmissionStatus,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [
    status,
    totalSummary,
    total,
    enterpriseConfig,
    work,
    efecty,
    transfer,
    formSubmissionStatus,
    error,
  ];

  bool isSubmitting() =>
      formSubmissionStatus == FormSubmissionStatus.submitting;

  bool isSubmissionSuccessOrFailure() =>
      formSubmissionStatus == FormSubmissionStatus.success ||
          formSubmissionStatus == FormSubmissionStatus.failure;

  bool get isValid => !efecty.hasError && !transfer.hasError;
}