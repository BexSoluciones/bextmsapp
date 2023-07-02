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
      skipUpdate;
  final String? mapbox;
  final String? codeQr;
  final int? limitDaysWorks, ratio;
  final bool? blockPartial;

  const EnterpriseConfig(
      {this.id,
      this.allowInsetsBelow,
      this.allowInsetsAbove,
      this.hadTakePicture,
      this.canBlockClients,
      this.requiredArrived,
      this.canMakeHistory,
      this.fixedDeliveryDistance,
      this.hadReasonRespawn,
      this.specifiedAccountTransfer,
      this.mapbox,
      this.codeQr,
      this.blockPartial,
      this.skipUpdate,
      this.limitDaysWorks,
      this.ratio});

  factory EnterpriseConfig.fromMap(Map<String, dynamic> map) {
    return EnterpriseConfig(
      id: map['id'] != null ? map['id'] as int : null,
      allowInsetsBelow: map['allow_insets_below'] != null
          ? map['allow_insets_below'] == 1 || map['allow_insets_below']
              ? true
              : false
          : null,
      allowInsetsAbove: map['allow_insets_above'] != null
          ? map['allow_insets_above'] == 1 || map['allow_insets_above']
              ? true
              : false
          : null,
      hadTakePicture: map['had_take_picture'] != null
          ? map['had_take_picture'] == 1 || map['had_take_picture']
              ? true
              : false
          : null,
      canBlockClients: map['can_block_clients'] != null
          ? map['can_block_clients'] == 1 || map['can_block_clients']
              ? true
              : false
          : null,
      requiredArrived: map['required_arrived'] != null
          ? map['required_arrived'] == 1 || map['required_arrived']
              ? true
              : false
          : null,
      canMakeHistory: map['can_make_history'] != null
          ? map['can_make_history'] == 1 || map['can_make_history']
              ? true
              : false
          : null,
      fixedDeliveryDistance: map['fixed_delivery_distance'] != null
          ? map['fixed_delivery_distance'] == 1 ||
                  map['fixed_delivery_distance']
              ? true
              : false
          : null,
      hadReasonRespawn: map['had_reason_respawn'] != null
          ? map['had_reason_respawn'] == 1 || map['had_reason_respawn']
              ? true
              : false
          : null,
      specifiedAccountTransfer: map['specified_account_transfer'] != null
          ? map['specified_account_transfer'] == 1 ||
                  map['specified_account_transfer']
              ? true
              : false
          : null,
      mapbox: map['mapbox'] != null ? map['mapbox'] as String : null,
      codeQr: map['code_qr'] != null ? map['code_qr'] as String : null,
      blockPartial: map['block_partial'] != null
          ? map['block_partial'] == 1 || map['block_partial']
              ? true
              : false
          : null,
      skipUpdate: map['skip_update'] != null
          ? map['skip_update'] == 1 || map['skip_update']
              ? true
              : false
          : null,
      limitDaysWorks: map['limit_days_works'] != null
          ? map['limit_days_works'] as int
          : null,
      ratio: map['ratio'] != null ? map['ratio'] as int : null,
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
      'skip_update': skipUpdate,
      'limit_days_works': limitDaysWorks,
      'can_make_history': canMakeHistory,
      'had_reason_respawn': hadReasonRespawn,
      'fixed_delivery_distance': fixedDeliveryDistance,
      'ratio': ratio,
      'specified_account_transfer': specifiedAccountTransfer,
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
        skipUpdate,
        limitDaysWorks,
        ratio
      ];
}
