// To parse this JSON data, do
//
//     final presenceHistoryModel = presenceHistoryModelFromJson(jsonString);

import 'dart:convert';

PresenceHistoryModel presenceHistoryModelFromJson(String str) =>
    PresenceHistoryModel.fromJson(json.decode(str));

String presenceHistoryModelToJson(PresenceHistoryModel data) =>
    json.encode(data.toJson());

class PresenceHistoryModel {
  String? message;
  List<Presences>? data;

  PresenceHistoryModel({this.message, this.data});

  factory PresenceHistoryModel.fromJson(Map<String, dynamic> json) =>
      PresenceHistoryModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Presences>.from(
                json["data"]!.map((x) => Presences.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Presences {
  int? id;
  DateTime? attendanceDate;
  CheckInTime? checkInTime;
  String? checkOutTime;
  double? checkInLat;
  double? checkInLng;
  double? checkOutLat;
  double? checkOutLng;
  CheckAddress? checkInAddress;
  CheckAddress? checkOutAddress;
  CheckLocation? checkInLocation;
  CheckLocation? checkOutLocation;
  Status? status;
  AlasanIzin? alasanIzin;

  Presences({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLocation,
    this.checkOutLocation,
    this.status,
    this.alasanIzin,
  });

  factory Presences.fromJson(Map<String, dynamic> json) => Presences(
    id: json["id"],
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"] == null
        ? null
        : checkInTimeValues.map[json["check_in_time"]], // ← HAPUS ! di sini
    checkOutTime: json["check_out_time"],
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkOutLat: json["check_out_lat"]?.toDouble(),
    checkOutLng: json["check_out_lng"]?.toDouble(),
    checkInAddress: json["check_in_address"] == null
        ? null
        : checkAddressValues.map[json["check_in_address"]], // ← HAPUS ! di sini
    checkOutAddress: json["check_out_address"] == null
        ? null
        : checkAddressValues
              .map[json["check_out_address"]], // ← HAPUS ! di sini
    checkInLocation: json["check_in_location"] == null
        ? null
        : checkLocationValues
              .map[json["check_in_location"]], // ← HAPUS ! di sini
    checkOutLocation: json["check_out_location"] == null
        ? null
        : checkLocationValues
              .map[json["check_out_location"]], // ← HAPUS ! di sini
    status: json["status"] == null
        ? null
        : statusValues.map[json["status"]], // ← HAPUS ! di sini
    alasanIzin: json["alasan_izin"] == null
        ? null
        : alasanIzinValues.map[json["alasan_izin"]], // ← HAPUS ! di sini
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date": attendanceDate == null
        ? null
        : "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime == null
        ? null
        : checkInTimeValues.reverse[checkInTime],
    "check_out_time": checkOutTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
    "check_in_address": checkInAddress == null
        ? null
        : checkAddressValues.reverse[checkInAddress],
    "check_out_address": checkOutAddress == null
        ? null
        : checkAddressValues.reverse[checkOutAddress],
    "check_in_location": checkInLocation == null
        ? null
        : checkLocationValues.reverse[checkInLocation],
    "check_out_location": checkOutLocation == null
        ? null
        : checkLocationValues.reverse[checkOutLocation],
    "status": status == null ? null : statusValues.reverse[status],
    "alasan_izin": alasanIzin == null
        ? null
        : alasanIzinValues.reverse[alasanIzin],
  };
}

enum AlasanIzin { ALASAN_TIDAK_BISA_HADIR_KARENA_SAKIT }

final alasanIzinValues = EnumValues({
  "Alasan tidak bisa hadir karena sakit":
      AlasanIzin.ALASAN_TIDAK_BISA_HADIR_KARENA_SAKIT,
});

enum CheckAddress { JAKARTA }

final checkAddressValues = EnumValues({"Jakarta": CheckAddress.JAKARTA});

enum CheckLocation { THE_6123456106123456, THE_621068 }

final checkLocationValues = EnumValues({
  "-6.123456,106.123456": CheckLocation.THE_6123456106123456,
  "6.2,106.8": CheckLocation.THE_621068,
});

enum CheckInTime { THE_0810, THE_1351, THE_1352 }

final checkInTimeValues = EnumValues({
  "08:10": CheckInTime.THE_0810,
  "13:51": CheckInTime.THE_1351,
  "13:52": CheckInTime.THE_1352,
});

enum Status { IZIN, MASUK }

final statusValues = EnumValues({"izin": Status.IZIN, "masuk": Status.MASUK});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
