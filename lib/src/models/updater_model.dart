// To parse this JSON data, do
//
//     final updater = updaterFromJson(jsonString);

import 'dart:convert';

import 'package:paycapp/src/utils/utils.dart' show parseDouble;

class Updater {
    bool update;
    double build;
    String description;
    String src;
    String version;
    DateTime last;

    Updater({
        this.update,
        this.build,
        this.description,
        this.src,
        this.version,
        this.last,
    });

    factory Updater.fromJson(String str) => Updater.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Updater.fromMap(Map<String, dynamic> json) => Updater(
        update: json["update"],
        build: parseDouble(json["build"]),
        description: json["description"],
        src: json["src"],
        version: json["version"],
        last: json["last"] == null ? DateTime.now() : DateTime.parse(json["last"]),
    );

    Map<String, dynamic> toMap() => {
        "update": update,
        "build": build,
        "description": description,
        "src": src,
        "version": version,
        "last": "${last.year.toString().padLeft(4, '0')}-${last.month.toString().padLeft(2, '0')}-${last.day.toString().padLeft(2, '0')}",
    };
}



//last: json["last"] == null ? DateTime.now() : DateTime.parse(json["last"]),
