class TransportModel {
  String? id;
  String? type;
  double? price;
  String? departureCity;
  String? arrivalCity;

  TransportModel({
    this.id,
    this.type,
    this.price,
    this.departureCity,
    this.arrivalCity,
  });

  TransportModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    price = json['price'];
    departureCity = json['departureCity'];
    arrivalCity = json['arrivalCity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['price'] = this.price;
    data['departureCity'] = this.departureCity;
    data['arrivalCity'] = this.arrivalCity;
    return data;
  }
}
