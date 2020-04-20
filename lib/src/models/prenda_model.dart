import 'dart:convert';

class Prenda {
    int id;
    String img;
    String detail;

    Prenda({
        this.id,
        this.img,
        this.detail,
    });

    factory Prenda.fromJson(String str) => Prenda.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Prenda.fromMap(Map<String, dynamic> json) => Prenda(
        id: json["id"],
        img: json["img"],
        detail: json["detail"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "img": img,
        "detail": detail,
    };
}