// To parse this JSON data, do
//
//     final ruta = rutaFromJson(jsonString);

import 'dart:convert';

Ruta rutaFromJson(String str) => Ruta.fromJson(json.decode(str));

String rutaToJson(Ruta data) => json.encode(data.toJson());

class Ruta {
    int id;
    String name;
    String description;
    int status;

    Ruta({
        this.id,
        this.name,
        this.description,
        this.status,
    });

    factory Ruta.fromJson(Map<String, dynamic> json) => Ruta(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "status": status,
    };
}
