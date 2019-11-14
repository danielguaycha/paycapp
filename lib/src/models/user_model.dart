// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

import 'package:paycapp/src/models/person_model.dart';

class User {
  int id;
  String username;
  int personId;
  int status;
  Person person;

  User({
    this.id,
    this.username,
    this.personId,
    this.status,
    this.person,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    personId: json["person_id"],
    status: json["status"],
    person: Person.fromJson(json["person"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "person_id": personId,
    "status": status,
    "person": person,
  };
}
