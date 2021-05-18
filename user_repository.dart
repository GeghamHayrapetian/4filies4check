import 'package:flutter/material.dart';
import 'package:snap_chat/data/realme/user.dart';

class UserRepository {
  UserRepository() {
    //  DBProvider.db.createUserTable();
  }
  final UserModel _userModel = UserModel();
  Future<List<User>> getAllUsers() async {
    return _userModel.getAllUsers();
  }

  Future<dynamic> addUser(User user) async {
    return _userModel.addUser(user);
  }

  Future<bool> checkUsername(String username) async {
    return _userModel.checkUsername(username);
  }

  Future<bool> checkEmailOrPhoneNumber(String emailOrPhoneNumber) async {
    return _userModel.checkEmailOrPhoneNumber(emailOrPhoneNumber);
  }

  Future<User> login(
      {@required String username, @required String password}) async {
    return _userModel.login(username: username, password: password);
  }

  Future<void> update(User user, String userName) async {
    await _userModel.update(user: user, username: userName);
  }
}

/* SQLITE
  Future<int> addUser({@required User user}) async {
    return await DBProvider.db.addUser(user);
  }

  Future<List<User>> allUsers() async {
    return DBProvider.db.getAllUsers();
  }

  Future<User> getUserById(int id) async {
    return await DBProvider.db.getUserById(id);
  }

  Future<User> login({
    @required String enteringType,
    @required String password,
  }) async {
    return await DBProvider.db.getUser(enteringType, password);
  }

  Future<bool> checkUsername(String username) async {
    return await DBProvider.db.checkUsername(username);
  }

  Future<bool> checkEmail(String email) async {
    return await DBProvider.db.checkEmail(email);
  }

  Future<bool> checkNumber(String number) async {
    return await DBProvider.db.checkPhoneNumber(number);
  }*/
