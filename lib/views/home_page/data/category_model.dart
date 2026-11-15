// To parse this JSON info_bloc, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

import 'dart:convert';

List<CategoryModel> categoryModelFromJson(String str) =>
    List<CategoryModel>.from(
      json.decode(str).map((x) => CategoryModel.fromJson(x)),
    );

String categoryModelToJson(List<CategoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryModel {
  String? id;
  String? name;
  String? extraServices;
  double? totalPrice;
  int? numberOfNights;
  String? imageUrl;
  String? hotelName;
  String? transportType;
  String? tripId;
  String? transportServiceId;

  CategoryModel({
    this.id,
    this.name,
    this.extraServices,
    this.totalPrice,
    this.numberOfNights,
    this.imageUrl,
    this.hotelName,
    this.transportType,
    this.tripId,
    this.transportServiceId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["id"],
    name: json["name"],
    extraServices: json["extraServices"],
    totalPrice: json["totalPrice"],
    numberOfNights: json["numberOfNights"],
    imageUrl: json["imageUrl"],
    hotelName: json["hotelName"],
    transportType: json["transportType"],
    tripId: json["tripId"],
    transportServiceId: json["transportServiceId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "extraServices": extraServices,
    "totalPrice": totalPrice,
    "numberOfNights": numberOfNights,
    "imageUrl": imageUrl,
    "hotelName": hotelName,
    "transportType": transportType,
  };
}
