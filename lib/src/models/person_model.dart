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
  String phones_b;
  String email;
  int status;
  int mora;
  int rank;

  Person({
    this.id,
    this.name = '',
    this.surname = '',
    this.address = '',
    this.phones = '',
    this.phones_b = '',
    this.email = '',
    this.status = 1,
    this.mora = 0,
    this.rank = 100,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json["id"],
    name: json["name"],
    surname: json["surname"],
    address: json["address"],
    phones: json["phones"],
    phones_b: json["phones_b"],
    email: json["email"],
    status: json["status"],
    mora: json["mora"],
    rank: int.parse(json["rank"] == null ? '0' : json["rank"]),
  );

  String toRawJson() => json.encode(toJson());
  factory Person.fromRawJson(String str) => Person.fromJson(json.decode(str));


  @override
  String toString() {
    return 'Person{id: $id, name: $name, surname: $surname, address: $address, phones: $phones, email: $email, status: $status}';
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "surname": surname,
    "address": address,
    "phones": phones,
    "phones_b": phones_b,
    "email": email,
    "status": status,
    "mora": mora,
    "rank": rank,
  };
}
