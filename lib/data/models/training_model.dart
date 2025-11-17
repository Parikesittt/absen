// To parse this JSON data, do
//
//     final trainingModel = trainingModelFromJson(jsonString);

import 'dart:convert';

TrainingModel trainingModelFromJson(String str) => TrainingModel.fromJson(json.decode(str));

String trainingModelToJson(TrainingModel data) => json.encode(data.toJson());

class TrainingModel {
    String? message;
    List<Trainings>? data;

    TrainingModel({
        this.message,
        this.data,
    });

    factory TrainingModel.fromJson(Map<String, dynamic> json) => TrainingModel(
        message: json["message"],
        data: json["data"] == null ? [] : List<Trainings>.from(json["data"]!.map((x) => Trainings.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Trainings {
    int? id;
    String? title;

    Trainings({
        this.id,
        this.title,
    });

    factory Trainings.fromJson(Map<String, dynamic> json) => Trainings(
        id: json["id"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
    };
}
