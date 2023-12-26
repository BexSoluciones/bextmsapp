import 'package:equatable/equatable.dart';

class EnterpriseConfig extends Equatable {
  final int? id;
  final bool? allowInsetsBelow,
      allowInsetsAbove,
      hadTakePicture,
      canBlockClients,
      requiredArrived,
      canMakeHistory,
      fixedDeliveryDistance,
      hadReasonRespawn,
      specifiedAccountTransfer,
      skipUpdate,
      multipleAccounts;
  final String? mapbox;
  final String? codeQr;
  final int? limitDaysWorks, ratio, distance;
  final bool? blockPartial, blockReject;
  final bool? backgroundLocation;

  const EnterpriseConfig({
    this.id,
    this.allowInsetsBelow,
    this.allowInsetsAbove,
    this.hadTakePicture,
    this.canBlockClients,
    this.requiredArrived,
    this.canMakeHistory,
    this.fixedDeliveryDistance,
    this.hadReasonRespawn,
    this.specifiedAccountTransfer,
    this.blockReject,
    this.mapbox,
    this.codeQr,
    this.blockPartial,
    this.skipUpdate,
    this.limitDaysWorks,
    this.ratio,
    this.multipleAccounts,
    this.backgroundLocation,
    this.distance,
  });

  factory EnterpriseConfig.fromMap(Map<String, dynamic> map) {
    return EnterpriseConfig(
      id: map['id'] != null ? map['id'] as int : null,
      allowInsetsBelow: map['allow_insets_below'] != null
          ? map['allow_insets_below'] is int
              ? map['allow_insets_below'] == 1
                  ? true
                  : false
              : map['allow_insets_below']
          : null,
      allowInsetsAbove: map['allow_insets_above'] != null
          ? map['allow_insets_above'] is int
              ? map['allow_insets_above'] == 1
                  ? true
                  : false
              : map['allow_insets_above']
          : null,
      hadTakePicture: map['had_take_picture'] != null
          ? map['had_take_picture'] is int
              ? map['had_take_picture'] == 1
                  ? true
                  : false
              : map['had_take_picture']
          : null,
      canBlockClients: map['can_block_clients'] != null
          ? map['can_block_clients'] is int
              ? map['can_block_clients'] == 1
                  ? true
                  : false
              : map['can_block_clients']
          : null,
      requiredArrived: map['required_arrived'] != null
          ? map['required_arrived'] is int
              ? map['required_arrived'] == 1
                  ? true
                  : false
              : map['required_arrived']
          : null,
      canMakeHistory: map['can_make_history'] != null
          ? map['can_make_history'] is int
              ? map['can_make_history'] == 1
                  ? true
                  : false
              : map['can_make_history']
          : null,
      fixedDeliveryDistance: map['fixed_delivery_distance'] != null
          ? map['fixed_delivery_distance'] is int
              ? map['fixed_delivery_distance'] == 1
                  ? true
                  : false
              : map['fixed_delivery_distance']
          : null,
      hadReasonRespawn: map['had_reason_respawn'] != null
          ? map['had_reason_respawn'] is int
              ? map['had_reason_respawn'] == 1
                  ? true
                  : false
              : map['had_reason_respawn']
          : null,
      specifiedAccountTransfer: map['specified_account_transfer'] != null
          ? map['specified_account_transfer'] is int
              ? map['specified_account_transfer'] == 1
                  ? true
                  : false
              : map['specified_account_transfer']
          : null,
      multipleAccounts: map['multiple_accounts'] != null
          ? map['multiple_accounts'] is int
              ? map['multiple_accounts'] == 1
                  ? true
                  : false
              : map['multiple_accounts']
          : null,
      mapbox: map['mapbox'] != null ? map['mapbox'] as String : null,
      codeQr: map['code_qr'] != null ? map['code_qr'] as String : null,
      blockPartial: map['block_partial'] != null
          ? map['block_partial'] is int
              ? map['block_partial'] == 1
                  ? true
                  : false
              : map['block_partial']
          : null,
      blockReject: map['block_reject'] != null
          ? map['block_reject'] is int
              ? map['block_reject'] == 1
                  ? true
                  : false
              : map['block_reject']
          : null,
      skipUpdate: map['skip_update'] != null
          ? map['skip_update'] is int
              ? map['skip_update'] == 1
                  ? true
                  : false
              : map['skip_update']
          : null,
      limitDaysWorks: map['limit_days_works'] != null
          ? map['limit_days_works'] as int
          : null,
      ratio: map['ratio'] != null ? map['ratio'] as int : null,
      backgroundLocation: map['background_location'] != null
          ? map['background_location'] is int
              ? map['background_location'] == 1
                  ? true
                  : false
              : map['background_location']
          : null,
      distance: map['distance'] != null ? map['distance'] as int : null,
    );
  }

  Map toMap() {
    return {
      'id': id,
      'allow_insets_below': allowInsetsBelow,
      'allow_insets_above': allowInsetsAbove,
      'had_take_picture': hadTakePicture,
      'can_block_clients': canBlockClients,
      'required_arrived': requiredArrived,
      'mapbox': mapbox,
      'code_qr': codeQr,
      'block_partial': blockPartial,
      'block_reject': blockReject,
      'skip_update': skipUpdate,
      'limit_days_works': limitDaysWorks,
      'can_make_history': canMakeHistory,
      'had_reason_respawn': hadReasonRespawn,
      'fixed_delivery_distance': fixedDeliveryDistance,
      'ratio': ratio,
      'distance': distance,
      'specified_account_transfer': specifiedAccountTransfer,
      'background_location': backgroundLocation,
      'multiple_accounts': multipleAccounts
    };
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        id,
        allowInsetsBelow,
        allowInsetsAbove,
        hadTakePicture,
        canBlockClients,
        requiredArrived,
        canMakeHistory,
        fixedDeliveryDistance,
        hadReasonRespawn,
        specifiedAccountTransfer,
        mapbox,
        codeQr,
        blockPartial,
        blockReject,
        skipUpdate,
        limitDaysWorks,
        ratio,
        distance,
        backgroundLocation,
        multipleAccounts
      ];
}
