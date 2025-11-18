// To parse this JSON data, do
//
//     final deleteHistoryModel = deleteHistoryModelFromJson(jsonString);

import 'dart:convert';

DeleteHistoryModel deleteHistoryModelFromJson(String str) => DeleteHistoryModel.fromJson(json.decode(str));

String deleteHistoryModelToJson(DeleteHistoryModel data) => json.encode(data.toJson());

class DeleteHistoryModel {
    String? message;
    Data? data;

    DeleteHistoryModel({
        this.message,
        this.data,
    });

    factory DeleteHistoryModel.fromJson(Map<String, dynamic> json) => DeleteHistoryModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    String? id;

    Data({
        this.id,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
    };
}
