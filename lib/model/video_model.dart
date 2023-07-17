// To parse this JSON data, do
//
//     final videoModel = videoModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<VideoModel> videoModelFromJson(String str) =>
    List<VideoModel>.from(json.decode(str).map((x) => VideoModel.fromJson(x)));

String videoModelToJson(List<VideoModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VideoModel {
  String id;
  String title;
  String thumbnailUrl;
  String duration;
  String uploadTime;
  String views;
  String author;
  String videoUrl;
  String description;
  String subscriber;
  bool isLive;

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.uploadTime,
    required this.views,
    required this.author,
    required this.videoUrl,
    required this.description,
    required this.subscriber,
    required this.isLive,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    String? duration,
    String? uploadTime,
    String? views,
    String? author,
    String? videoUrl,
    String? description,
    String? subscriber,
    bool? isLive,
  }) =>
      VideoModel(
        id: id ?? this.id,
        title: title ?? this.title,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        duration: duration ?? this.duration,
        uploadTime: uploadTime ?? this.uploadTime,
        views: views ?? this.views,
        author: author ?? this.author,
        videoUrl: videoUrl ?? this.videoUrl,
        description: description ?? this.description,
        subscriber: subscriber ?? this.subscriber,
        isLive: isLive ?? this.isLive,
      );

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        id: json["id"],
        title: json["title"],
        thumbnailUrl: json["thumbnailUrl"],
        duration: json["duration"],
        uploadTime: json["uploadTime"],
        views: json["views"],
        author: json["author"],
        videoUrl: json["videoUrl"],
        description: json["description"],
        subscriber: json["subscriber"],
        isLive: json["isLive"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "thumbnailUrl": thumbnailUrl,
        "duration": duration,
        "uploadTime": uploadTime,
        "views": views,
        "author": author,
        "videoUrl": videoUrl,
        "description": description,
        "subscriber": subscriber,
        "isLive": isLive,
      };
}
