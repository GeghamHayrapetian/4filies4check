import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/database/mongo_document.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';

class User extends Equatable {
  User(
      {this.firstName,
      this.lastName,
      this.birthday,
      this.userName,
      this.password,
      this.emailOrPhoneNumber});
  User.fromDocument(MongoDocument document) {
    firstName = document.get("firstName") ?? "";
    lastName = document.get("lastName") ?? "";
    birthday = document.get("birthday") ?? "";
    userName = document.get("userName") ?? "";
    password = document.get('password') ?? "";
    emailOrPhoneNumber = document.get("emailOrPhoneNumber") ?? "";
  }
  String firstName;

  String lastName;

  String birthday;

  String userName;

  String password;

  ---> Seperate emailOrPhoneNumber property to email and phone
  String emailOrPhoneNumber;

  Map<String, String> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "birthday": birthday,
      "userName": userName,
      "password": password,
      "emailOrPhoneNumber": emailOrPhoneNumber
    };
  }

  MongoDocument asDocument() {
    return MongoDocument({
      "firstName": firstName,
      "lastName": lastName,
      "birthday": birthday,
      "userName": userName,
      "password": password,
      "emailOrPhoneNumber": emailOrPhoneNumber
    });
  }

  @override
  List<Object> get props =>
      [firstName, lastName, birthday, userName, password, emailOrPhoneNumber];
}

---> Sepereate this class in other file
class UserModel {
  UserModel() {
    _collection = client.getDatabase("snapDB").getCollection("User");
  }
  final app = RealmApp();
  final client = MongoRealmClient();
  MongoCollection _collection;

  ---> Use extension for this functions or move to in repository
  Future<dynamic> addUser(User user) async {
    if (!await checkUsername(user.userName)) {
      final docsId = await _collection.insertOne(user.asDocument());
      return docsId;
    }
  }

  Future<List<User>> getAllUsers() async {
    final users = <User>[];
    final List documents = await _collection.find();
    for (final doc in documents) {
      users.add(User.fromDocument(doc));
    }

    return users;
  }

  Future<bool> checkUsername(String username) async {
    final document = await _collection.findOne(filter: {"userName": username});
    return document != null;
  }

  Future<bool> checkEmailOrPhoneNumber(String emailOrPhoneNumber) async {
    final document = await _collection
        .findOne(filter: {"emailOrPhoneNumber": emailOrPhoneNumber});
    return document != null;
  }

  Future<User> login(
      {@required String username, @required String password}) async {
    final doc = await _collection.find(
        filter: LogicalQueryOperator.or([
      {"emailOrPhoneNumber": username, "password": password},
      {"userName": username, "password": password}
    ]));
    return doc.isEmpty ? null : User.fromDocument(doc.first);
  }

  Future<void> update({User user, String username}) async {
    await _collection.updateMany(
        filter: {
          "userName": username,
        },
        update: UpdateOperator.set({
          "firstName": user.firstName,
          "lastName": user.lastName,
          "birthday": user.birthday,
          "userName": user.userName,
          "password": user.password,
          "emailOrPhoneNumber": user.emailOrPhoneNumber,
        }));
  }
}
