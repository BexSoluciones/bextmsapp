class PermissionRepository {
  CommonData? camera;
  CommonData? location;
  CommonData? storage;

  PermissionRepository({
    this.camera,
    this.location,
    this.storage,
  });

  PermissionRepository.fromJson(Map<String, dynamic> json) {
    camera =
    json['camera'] != null ? CommonData.fromJson(json['camera']) : null;
    location =
    json['location'] != null ? CommonData.fromJson(json['location']) : null;
    storage =
    json['storage'] != null ? CommonData.fromJson(json['storage']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (camera != null) {
      data['camera'] = camera!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (storage != null) {
      data['storage'] = storage!.toJson();
    }
    return data;
  }

  PermissionRepository copyWith({
    CommonData? camera,
    CommonData? location,
    CommonData? storage,
  }) {
    return PermissionRepository(
      camera: camera ?? this.camera,
      location: location ?? this.location,
      storage: storage ?? this.storage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'camera': camera?.toMap(),
      'location': location?.toMap(),
      'storage': storage?.toMap(),
    };
  }

  factory PermissionRepository.fromMap(Map<String, dynamic> map) {
    return PermissionRepository(
      camera: CommonData.fromMap(map['camera']),
      location: CommonData.fromMap(map['location']),
      storage: CommonData.fromMap(map['storage']),
    );
  }

  @override
  String toString() => 'PermissionRepository(camera: $camera, location: $location, storage: $storage)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PermissionRepository &&
        other.camera == camera &&
        other.location == location &&
        other.storage == storage;
  }

  @override
  int get hashCode => camera.hashCode ^ location.hashCode ^ storage.hashCode;
}

class CommonData {
  String? title;
  String? icon;
  String? description;
  String? buttonText;
  String? errorMessage;

  CommonData([
    this.title,
    this.icon,
    this.description,
    this.buttonText,
    this.errorMessage
  ]);

  CommonData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    icon = json['icon'];
    description = json['description'];
    buttonText = json['buttonText'];
    errorMessage = json['errorMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['icon'] = icon;
    data['description'] = description;
    data['buttonText'] = buttonText;
    data['errorMessage'] = errorMessage;
    return data;
  }

  CommonData copyWith({
    String? title,
    String? icon,
    String? description,
    String? buttonText,
    String? errorMessage,
  }) {
    return CommonData(
      title ?? this.title,
      icon ?? this.icon,
      description ?? this.description,
      buttonText ?? this.buttonText,
      errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': icon,
      'description': description,
      'buttonText': buttonText,
      'errorMessage': errorMessage,
    };
  }

  factory CommonData.fromMap(Map<String, dynamic> map) {
    return CommonData(
      map['title'],
      map['icon'],
      map['description'],
      map['buttonText'],
      map['errorMessage'],
    );
  }

  @override
  String toString() {
    return 'CommonData(title: $title, icon: $icon, description: $description, buttonText: $buttonText, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommonData &&
        other.title == title &&
        other.icon == icon &&
        other.description == description &&
        other.buttonText == buttonText &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return title.hashCode ^
    icon.hashCode ^
    description.hashCode ^
    buttonText.hashCode ^
    errorMessage.hashCode;
  }
}