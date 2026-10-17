// Datovy model pre odpoved z USGS Earthquake API (format GeoJSON)

double? _toDouble(dynamic v) => v == null ? null : (v as num).toDouble();
int? _toInt(dynamic v) => v == null ? null : (v as num).toInt();

class EarthquakeModel {
  String? type;
  Metadata? metadata;
  List<Feature>? features;
  List<double>? bbox;

  EarthquakeModel({this.type, this.metadata, this.features, this.bbox});

  factory EarthquakeModel.fromJson(Map<String, dynamic> json) =>
      EarthquakeModel(
        type: json['type'],
        metadata: json['metadata'] == null
            ? null
            : Metadata.fromJson(json['metadata']),
        features: json['features'] == null
            ? []
            : List<Feature>.from(
                (json['features'] as List).map((x) => Feature.fromJson(x))),
        bbox: json['bbox'] == null
            ? null
            : List<double>.from(
                (json['bbox'] as List).map((x) => (x as num).toDouble())),
      );
}

class Metadata {
  int? generated;
  String? url;
  String? title;
  int? status;
  String? api;
  int? count;

  Metadata({
    this.generated,
    this.url,
    this.title,
    this.status,
    this.api,
    this.count,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        generated: _toInt(json['generated']),
        url: json['url'],
        title: json['title'],
        status: _toInt(json['status']),
        api: json['api'],
        count: _toInt(json['count']),
      );
}

class Feature {
  String? type;
  Properties? properties;
  Geometry? geometry;
  String? id;

  Feature({this.type, this.properties, this.geometry, this.id});

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json['type'],
        properties: json['properties'] == null
            ? null
            : Properties.fromJson(json['properties']),
        geometry: json['geometry'] == null
            ? null
            : Geometry.fromJson(json['geometry']),
        id: json['id'],
      );
}

class Properties {
  double? mag;
  String? place;
  int? time;
  int? updated;
  String? url;
  String? detail;
  int? felt;
  double? cdi;
  double? mmi;
  String? alert;
  String? status;
  int? tsunami;
  int? sig;
  String? net;
  String? code;
  String? magType;
  String? type;
  String? title;

  Properties({
    this.mag,
    this.place,
    this.time,
    this.updated,
    this.url,
    this.detail,
    this.felt,
    this.cdi,
    this.mmi,
    this.alert,
    this.status,
    this.tsunami,
    this.sig,
    this.net,
    this.code,
    this.magType,
    this.type,
    this.title,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mag: _toDouble(json['mag']),
        place: json['place'],
        time: _toInt(json['time']),
        updated: _toInt(json['updated']),
        url: json['url'],
        detail: json['detail'],
        felt: _toInt(json['felt']),
        cdi: _toDouble(json['cdi']),
        mmi: _toDouble(json['mmi']),
        alert: json['alert'],
        status: json['status'],
        tsunami: _toInt(json['tsunami']),
        sig: _toInt(json['sig']),
        net: json['net'],
        code: json['code'],
        magType: json['magType'],
        type: json['type'],
        title: json['title'],
      );
}

class Geometry {
  String? type;
  List<double>? coordinates;

  Geometry({this.type, this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json['type'],
        coordinates: json['coordinates'] == null
            ? null
            : List<double>.from((json['coordinates'] as List)
                .map((x) => (x as num).toDouble())),
      );
}
