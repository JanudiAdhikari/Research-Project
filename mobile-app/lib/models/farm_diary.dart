class FarmDiary {
  final String id;
  final String title;
  final String description;
  final String activityType;
  final DateTime diaryDate;
  final String farmPlotId;
  final Weather weather;
  final Observations observations;
  final String actions;
  final Inputs inputs;
  final Location location;
  final String notes;
  final List<String> tags;
  final List<DiaryImage> images;
  final String syncStatus;
  final String? offlineSyncId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FarmDiary({
    required this.id,
    required this.title,
    required this.description,
    required this.activityType,
    required this.diaryDate,
    required this.farmPlotId,
    this.weather = const Weather(),
    this.observations = const Observations(),
    this.actions = '',
    this.inputs = const Inputs(),
    this.location = const Location(),
    this.notes = '',
    this.tags = const [],
    this.images = const [],
    this.syncStatus = 'synced',
    this.offlineSyncId,
    this.createdAt,
    this.updatedAt,
  });

  factory FarmDiary.fromJson(Map<String, dynamic> json) {
    return FarmDiary(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      activityType: json['activityType']?.toString() ?? 'other',
      diaryDate: json['diaryDate'] != null
          ? DateTime.parse(json['diaryDate'].toString())
          : DateTime.now(),
      farmPlotId: json['farmPlotId']?.toString() ?? '',
      weather: json['weather'] != null
          ? Weather.fromJson(json['weather'])
          : const Weather(),
      observations: json['observations'] != null
          ? Observations.fromJson(json['observations'])
          : const Observations(),
      actions: json['actions']?.toString() ?? '',
      inputs: json['inputs'] != null
          ? Inputs.fromJson(json['inputs'])
          : const Inputs(),
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : const Location(),
      notes: json['notes']?.toString() ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      images:
          (json['images'] as List?)
              ?.map((img) => DiaryImage.fromJson(img))
              .toList() ??
          [],
      syncStatus: json['syncStatus']?.toString() ?? 'synced',
      offlineSyncId: json['offlineSyncId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'activityType': activityType,
      'diaryDate': diaryDate.toIso8601String(),
      'farmPlotId': farmPlotId,
      'weather': weather.toJson(),
      'observations': observations.toJson(),
      'actions': actions,
      'inputs': inputs.toJson(),
      'location': location.toJson(),
      'notes': notes,
      'tags': tags,
      'images': images.map((img) => img.toJson()).toList(),
      'offlineSyncId': offlineSyncId,
    };
  }

  FarmDiary copyWith({
    String? id,
    String? title,
    String? description,
    String? activityType,
    DateTime? diaryDate,
    String? farmPlotId,
    Weather? weather,
    Observations? observations,
    String? actions,
    Inputs? inputs,
    Location? location,
    String? notes,
    List<String>? tags,
    List<DiaryImage>? images,
    String? syncStatus,
    String? offlineSyncId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmDiary(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      activityType: activityType ?? this.activityType,
      diaryDate: diaryDate ?? this.diaryDate,
      farmPlotId: farmPlotId ?? this.farmPlotId,
      weather: weather ?? this.weather,
      observations: observations ?? this.observations,
      actions: actions ?? this.actions,
      inputs: inputs ?? this.inputs,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      syncStatus: syncStatus ?? this.syncStatus,
      offlineSyncId: offlineSyncId ?? this.offlineSyncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Weather {
  final String condition;
  final double? temperature;
  final double? humidity;
  final double? rainfall;

  const Weather({
    this.condition = 'unknown',
    this.temperature,
    this.humidity,
    this.rainfall,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      condition: json['condition']?.toString() ?? 'unknown',
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      rainfall: (json['rainfall'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (rainfall != null) 'rainfall': rainfall,
    };
  }
}

class Observations {
  final String plantHealth;
  final String? diseaseSymptoms;
  final String? pestPresence;
  final String? yieldEstimate;

  const Observations({
    this.plantHealth = 'good',
    this.diseaseSymptoms,
    this.pestPresence,
    this.yieldEstimate,
  });

  factory Observations.fromJson(Map<String, dynamic> json) {
    return Observations(
      plantHealth: json['plantHealth']?.toString() ?? 'good',
      diseaseSymptoms: json['diseaseSymptoms']?.toString(),
      pestPresence: json['pestPresence']?.toString(),
      yieldEstimate: json['yieldEstimate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plantHealth': plantHealth,
      if (diseaseSymptoms != null) 'diseaseSymptoms': diseaseSymptoms,
      if (pestPresence != null) 'pestPresence': pestPresence,
      if (yieldEstimate != null) 'yieldEstimate': yieldEstimate,
    };
  }
}

class Inputs {
  final String? fertilizer;
  final String? pesticide;
  final double? waterQuantity;
  final String? otherInputs;

  const Inputs({
    this.fertilizer,
    this.pesticide,
    this.waterQuantity,
    this.otherInputs,
  });

  factory Inputs.fromJson(Map<String, dynamic> json) {
    return Inputs(
      fertilizer: json['fertilizer']?.toString(),
      pesticide: json['pesticide']?.toString(),
      waterQuantity: (json['waterQuantity'] as num?)?.toDouble(),
      otherInputs: json['otherInputs']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fertilizer != null) 'fertilizer': fertilizer,
      if (pesticide != null) 'pesticide': pesticide,
      if (waterQuantity != null) 'waterQuantity': waterQuantity,
      if (otherInputs != null) 'otherInputs': otherInputs,
    };
  }
}

class Location {
  final double? latitude;
  final double? longitude;
  final double? altitude;

  const Location({this.latitude, this.longitude, this.altitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
    };
  }
}

class DiaryImage {
  final String url;
  final String? cloudinaryId;
  final DateTime? uploadedAt;
  final String? caption;

  DiaryImage({
    required this.url,
    this.cloudinaryId,
    this.uploadedAt,
    this.caption,
  });

  factory DiaryImage.fromJson(Map<String, dynamic> json) {
    return DiaryImage(
      url: json['url']?.toString() ?? '',
      cloudinaryId: json['cloudinaryId']?.toString(),
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'].toString())
          : null,
      caption: json['caption']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (cloudinaryId != null) 'cloudinaryId': cloudinaryId,
      if (uploadedAt != null) 'uploadedAt': uploadedAt?.toIso8601String(),
      if (caption != null) 'caption': caption,
    };
  }
}
