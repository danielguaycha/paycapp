// To parse this JSON data, do
//
//     final person = personFromJson(jsonString);

import 'dart:convert';

Person personFromJson(String str) => Person.fromJson(json.decode(str));

String personToJson(Person data) => json.encode(data.toJson());


class Person {
  int id;
  String name;
  String surname;
  String address;
  String phones;
  String email;
  int status;

  Person({
    this.id,
    this.name = '',
    this.surname = '',
    this.address = '',
    this.phones = '',
    this.email = '',
    this.status = 1,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json["id"],
    name: json["name"],
    surname: json["surname"],
    address: json["address"],
    phones: json["phones"],
    email: json["email"],
    status: json["status"],
  );

  String toRawJson() => json.encode(toJson());
  factory Person.fromRawJson(String str) => Person.fromJson(json.decode(str));


  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "surname": surname,
    "address": address,
    "phones": phones,
    "email": email,
    "status": status,
  };
}
