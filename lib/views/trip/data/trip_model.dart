class TripModel {
  String? id;
  String? title;
  String? description;
  String? startDate;
  String? endDate;
  double? pricePerPerson;
  int? maxCapacity;

  TripModel({
    this.id,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.pricePerPerson,
    this.maxCapacity,
  });

  TripModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    title = json['title']?.toString();
    description = json['description']?.toString();
    startDate = json['startDate']?.toString();
    endDate = json['endDate']?.toString();

    pricePerPerson = json['pricePerPerson'] != null
        ? (json['pricePerPerson'] as num).toDouble()
        : null;

    maxCapacity = json['maxCapacity'] != null
        ? (json['maxCapacity'] as num).toInt()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['pricePerPerson'] = this.pricePerPerson;
    data['maxCapacity'] = this.maxCapacity;
    return data;
  }
}
