import 'dart:convert';

import '../../utils/constants/strings.dart';

class PermissionRepository {
  bool? isDenied;
  bool? isGranted;
  bool? isPermanentlyDenied;
  bool? isUnknown;
  bool? isReRequesting;
  String? buttonText;
  String? displayTitle;
  String? displayMessage;

  PermissionRepository({
    this.isDenied,
    this.isGranted,
    this.isPermanentlyDenied,
    this.isUnknown,
    this.isReRequesting,
    this.buttonText,
    this.displayTitle,
    this.displayMessage,
  });

  PermissionRepository.granted()
      : isDenied = false,
        isGranted = true,
        isPermanentlyDenied = false,
        isUnknown = false,
        isReRequesting = false,
        buttonText = buttonTextSuccess,
        displayMessage = displayMessageSuccess,
        displayTitle = titleDefault;

  PermissionRepository.denied()
      : isDenied = true,
        isGranted = false,
        isPermanentlyDenied = false,
        isUnknown = false,
        isReRequesting = false,
        buttonText = buttonTextDefault,
        displayMessage =
            displayMessageDenied,
        displayTitle = titleDefault;

  PermissionRepository.permanentlyDenied()
      : isDenied = false,
        isGranted = false,
        isPermanentlyDenied = true,
        isUnknown = false,
        isReRequesting = false,
        buttonText = buttonTextPermanentlyDenied,
        displayMessage =
            displayMessagePermanentlyDenied,
        displayTitle = titleDefault;

  PermissionRepository.unknown()
      : isDenied = false,
        isGranted = false,
        isPermanentlyDenied = false,
        isUnknown = true,
        isReRequesting = false,
        buttonText = buttonTextDefault,
        displayMessage =displayMessageDefault,
        displayTitle = titleDefault;

  PermissionRepository.waiting()
      : isDenied = false,
        isGranted = false,
        isPermanentlyDenied = false,
        isUnknown = false,
        isReRequesting = false,
        buttonText = buttonTextDefault,
        displayMessage =displayMessageDefault,
        displayTitle = titleDefault;

  PermissionRepository.reRequesting()
      : isDenied = false,
        isGranted = false,
        isPermanentlyDenied = false,
        isUnknown = false,
        isReRequesting = true,
        buttonText = buttonTextDefault,
        displayMessage =displayMessageDefault,
        displayTitle = titleDefault;

  @override
  String toString() {
    return 'PermissionRepository(isDenied: $isDenied, isGranted: $isGranted, isPermanentlyDenied: $isPermanentlyDenied, isUnknown: $isUnknown, isReRequesting: $isReRequesting, buttonText: $buttonText, displayTitle: $displayTitle, displayMessage: $displayMessage)';
  }

  PermissionRepository copyWith({
    bool? isDenied,
    bool? isGranted,
    bool? isPermanentlyDenied,
    bool? isUnknown,
    bool? isReRequesting,
    String? buttonText,
    String? displayTitle,
    String? displayMessage,
  }) {
    return PermissionRepository(
      isDenied: isDenied ?? this.isDenied,
      isGranted: isGranted ?? this.isGranted,
      isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
      isUnknown: isUnknown ?? this.isUnknown,
      isReRequesting: isReRequesting ?? this.isReRequesting,
      buttonText: buttonText ?? this.buttonText,
      displayTitle: displayTitle ?? this.displayTitle,
      displayMessage: displayMessage ?? this.displayMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PermissionRepository &&
        other.isDenied == isDenied &&
        other.isGranted == isGranted &&
        other.isPermanentlyDenied == isPermanentlyDenied &&
        other.isUnknown == isUnknown &&
        other.isReRequesting == isReRequesting &&
        other.buttonText == buttonText &&
        other.displayTitle == displayTitle &&
        other.displayMessage == displayMessage;
  }

  @override
  int get hashCode {
    return isDenied.hashCode ^
    isGranted.hashCode ^
    isPermanentlyDenied.hashCode ^
    isUnknown.hashCode ^
    isReRequesting.hashCode ^
    buttonText.hashCode ^
    displayTitle.hashCode ^
    displayMessage.hashCode;
  }

  Map<String, dynamic> toMap() {
    return {
      'isDenied': isDenied,
      'isGranted': isGranted,
      'isPermanentlyDenied': isPermanentlyDenied,
      'isUnknown': isUnknown,
      'isReRequesting': isReRequesting,
      'buttonText': buttonText,
      'displayTitle': displayTitle,
      'displayMessage': displayMessage,
    };
  }

  factory PermissionRepository.fromMap(Map<String, dynamic> map) {
    return PermissionRepository(
      isDenied: map['isDenied'],
      isGranted: map['isGranted'],
      isPermanentlyDenied: map['isPermanentlyDenied'],
      isUnknown: map['isUnknown'],
      isReRequesting: map['isReRequesting'],
      buttonText: map['buttonText'],
      displayTitle: map['displayTitle'],
      displayMessage: map['displayMessage'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PermissionRepository.fromJson(String source) =>
      PermissionRepository.fromMap(json.decode(source));
}