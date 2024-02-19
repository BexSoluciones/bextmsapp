part of 'collection_bloc.dart';

enum CollectionStatus {
  initial,
  loading,
  waiting,
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
  final double total;
  final EnterpriseConfig? enterpriseConfig;
  final Work? work;
  final String? error;
  //NORMAL TRANSACTION
  final PaymentEfecty efecty;
  final int keyEfecty;
  final PaymentTransfer transfer;
  final int keyTransfer;
  final PaymentDate date;
  final PaymentMultiTransfer multiTransfer;

  //ACCOUNT TRANSACTION
  final List<AccountPayment>? accounts;
  final PaymentAccount? account;
  final int? indexToEdit;
  final bool? isEditing;

  //FINISH TRANSACTION
  final bool validate;
  final bool isLastTransaction;

  final FormSubmissionStatus formSubmissionStatus;

  const CollectionState(
      {this.status = CollectionStatus.initial,
      this.totalSummary,
      this.total = 0,
      this.enterpriseConfig,
      this.work,
      this.efecty = PaymentEfecty.empty,
      this.keyEfecty = 0,
      this.transfer = PaymentTransfer.empty,
      this.keyTransfer = 0,
      this.multiTransfer = PaymentMultiTransfer.empty,
      this.date = PaymentDate.empty,
      this.accounts,
      this.account =  PaymentAccount.empty,
      this.indexToEdit,
      this.isEditing,
      this.validate = false,
      this.isLastTransaction = false,
      this.formSubmissionStatus = FormSubmissionStatus.initial,
      this.error});

  CollectionState copyWith(
          {CollectionStatus? status,
          double? totalSummary,
          double? total,
          EnterpriseConfig? enterpriseConfig,
          Work? work,
          PaymentEfecty? efecty,
          int? keyEfecty,
          PaymentTransfer? transfer,
          int? keyTransfer,
          PaymentDate? date,
          PaymentMultiTransfer? multiTransfer,
          List<AccountPayment>? accounts,
          PaymentAccount? account,
          int? indexToEdit,
          bool? isEditing,
          bool? validate,
          bool? isLastTransaction,
          FormSubmissionStatus? formSubmissionStatus,
          String? error}) =>
      CollectionState(
        status: status ?? this.status,
        totalSummary: totalSummary ?? this.totalSummary,
        total: total ?? this.total,
        enterpriseConfig: enterpriseConfig ?? this.enterpriseConfig,
        work: work ?? this.work,
        efecty: efecty ?? this.efecty,
        keyEfecty: keyEfecty ?? this.keyEfecty,
        transfer: transfer ?? this.transfer,
        keyTransfer: keyTransfer ?? this.keyTransfer,
        multiTransfer: multiTransfer ?? this.multiTransfer,
        date: date ?? this.date,
        accounts: accounts ?? this.accounts,
        account: account ?? this.account,
        indexToEdit: indexToEdit ?? this.indexToEdit,
        isEditing: isEditing ?? this.isEditing,
        validate: validate ?? this.validate,
        isLastTransaction: isLastTransaction ?? this.isLastTransaction,
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
        multiTransfer,
        date,
        accounts,
        account,
        validate,
        formSubmissionStatus,
        error,
      ];

  bool isSubmitting() =>
      formSubmissionStatus == FormSubmissionStatus.submitting;

  bool isSubmissionSuccessOrFailure() =>
      formSubmissionStatus == FormSubmissionStatus.success ||
      formSubmissionStatus == FormSubmissionStatus.failure;

  bool canRenderView() =>
      status == CollectionStatus.initial ||
      status == CollectionStatus.success ||
      status == CollectionStatus.navigate ||
      status == CollectionStatus.error;

  bool get isValid => !efecty.hasError && !transfer.hasError;
}
