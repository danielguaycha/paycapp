// To parse this JSON data, do
//
//     final auth = authFromJson(jsonString);

import 'dart:convert';

class Auth {
  int id;
  dynamic emailVerifiedAt;
  String username;
  int personId;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  bool admin;
  bool root;
  Person person;
  List<Zone> zones;

  Auth({
    this.id,
    this.emailVerifiedAt,
    this.username,
    this.personId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.admin,
    this.root,
    this.person,
    this.zones,
  });

  factory Auth.fromJson(String str) => Auth.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Auth.fromMap(Map<String, dynamic> json) => Auth(
    id: json["id"],
    emailVerifiedAt: json["email_verified_at"],
    username: json["username"],
    personId: json["person_id"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    admin: json["admin"],
    root: json["root"],
    person: Person.fromMap(json["person"]),
    zones: List<Zone>.from(json["zones"].map((x) => Zone.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "email_verified_at": emailVerifiedAt,
    "username": username,
    "person_id": personId,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "admin": admin,
    "root": root,
    "person": person.toMap(),
    "zones": List<dynamic>.from(zones.map((x) => x.toMap())),
  };
}

class Person {
  int id;
  String name;
  String surname;
  String address;
  String phones;
  String phonesB;
  String email;
  int status;
  int mora;
  String type;
  int rank;

  Person({
    this.id,
    this.name,
    this.surname,
    this.address,
    this.phones,
    this.phonesB,
    this.email,
    this.status,
    this.mora,
    this.type,
    this.rank,
  });

  factory Person.fromJson(String str) => Person.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Person.fromMap(Map<String, dynamic> json) => Person(
    id: json["id"],
    name: json["name"],
    surname: json["surname"],
    address: json["address"],
    phones: json["phones"],
    phonesB: json["phones_b"],
    email: json["email"],
    status: json["status"],
    mora: json["mora"],
    type: json["type"],
    rank: json["rank"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "surname": surname,
    "address": address,
    "phones": phones,
    "phones_b": phonesB,
    "email": email,
    "status": status,
    "mora": mora,
    "type": type,
    "rank": rank,
  };
}

class Zone {
  int id;
  String name;

  Zone({
    this.id,
    this.name,
  });

  factory Zone.fromJson(String str) => Zone.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Zone.fromMap(Map<String, dynamic> json) => Zone(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
  };
}
