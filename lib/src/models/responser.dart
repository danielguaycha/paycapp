// To parse this JSON data, do
//
//     final responser = responserFromJson(jsonString);

import 'dart:convert';

Responser responserFromJson(String str) => Responser.fromJson(json.decode(str));

String responserToJson(Responser data) => json.encode(data.toJson());

class Responser<T> {
    T data;
    bool ok;
    String message;

    Responser({
        this.data,
        this.ok,
        this.message,
    });

    factory Responser.fromJson(Map<String, dynamic> json) => Responser(
        data: json["data"] == null ? null : json["data"],
        ok: json["ok"] == null ? false : json["ok"],
        message: json["message"] == null ? null : json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? null : data,
        "ok": ok == null ? false : ok,
        "message": message == null ? null : message,
    };
}
