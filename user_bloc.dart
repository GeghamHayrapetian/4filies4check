import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:snap_chat/blocs/user/user_event.dart';
import 'package:snap_chat/blocs/user/user_state.dart';
import 'package:snap_chat/data/realme/user.dart';
import 'package:snap_chat/data/repositories/user_repository.dart';
import 'package:snap_chat/extensions.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({this.usRep}) : super(UserInitial());
  final UserRepository usRep;
  final DateFormat _dateFormat = DateFormat("dd-MM-yyyy");

  Map<ProfileError, String> _map = {};
  Map<ProfileError, String> get map => _map;
  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is GetAllUsers) {
      final List<User> list = await usRep.getAllUsers();
      yield GetedAllUsers(users: list);
    } else if (event is AddUser) {
      try {
        usRep.addUser(event.user);
        // _addData(true, id);
        yield const UserAdded(userId: 1);
      } catch (e) {
        yield FailAddUser(e: e);
      }
    } else if (event is UserLogOut) {
      yield UserLogOuted();
    } else if (event is EditProfile) {
      yield* mapChangeEventToState(event);
    } else if (event is SaveEdit) {
      usRep.update(event.user, event.username);
    }
  }

  int i = 0;
  Stream<UserState> mapChangeEventToState(EditProfile event) async* {
    if (event.editsType == Edits.firstname) {
      if (event.defaultValue == event.edit || event.edit.length > 3) {
        _map[ProfileError.firstname] = null;
        yield EditedProfile(key: '${++i}');
      } else {
        _map[ProfileError.firstname] = "Invalid value";
        yield EditedProfile(key: '${++i}', error: ProfileError.firstname);
      }
    }
    if (event.defaultValue == event.edit || event.editsType == Edits.lastname) {
      if (event.edit.length > 3) {
        _map[ProfileError.lastname] = null;
        yield EditedProfile(key: '${++i}');
      } else {
        _map[ProfileError.lastname] = "Invalid value";
        yield EditedProfile(key: '${++i}', error: ProfileError.lastname);
      }
    } else if (event.editsType == Edits.birthday) {
      try {
        if (event.defaultValue == event.edit ||
            _dateFormat.parse(event.edit).isAdult()) {
          _map[ProfileError.birthday] = null;
          yield EditedProfile(key: '${++i}');
        } else {
          _map[ProfileError.birthday] =
              "Incorrect value or your age is smalest than 16";
          yield EditedProfile(key: '${++i}', error: ProfileError.birthday);
        }
      } catch (e) {
        _map[ProfileError.birthday] = "Invalid value";
        yield EditedProfile(key: '${++i}', error: ProfileError.birthday);
      }
    }
    if (event.editsType == Edits.username) {
      if (event.edit.length > 5) {
        if (event.defaultValue == event.edit) {
          _map[ProfileError.username] = null;
          yield EditedProfile(key: '${++i}');
        } else if (await usRep.checkUsername(event.edit)) {
          _map[ProfileError.username] = "Username is taken";
          yield EditedProfile(key: '${++i}', error: ProfileError.username);
        } else {
          _map[ProfileError.username] = null;
          yield EditedProfile(key: '${++i}');
        }
      } else {
        _map[ProfileError.username] = "Invalid value";
        yield EditedProfile(key: '${++i}', error: ProfileError.username);
      }
    }
    if (event.editsType == Edits.password) {
      if (event.defaultValue == event.edit || event.edit.isPassword) {
        _map[ProfileError.password] = null;
        yield EditedProfile(key: '${++i}');
      } else {
        _map[ProfileError.password] = "Your password should be at least 8";
        yield EditedProfile(key: '${++i}', error: ProfileError.password);
      }
    } else if (event.editsType == Edits.phoneOrEmail) {
      if (event.edit.isEmail || event.edit.isPhoneNumber(event.defaultValue)) {
        if (event.defaultValue == event.edit) {
          _map[ProfileError.phoneOrEmail] = null;
          yield EditedProfile(key: '${++i}');
        } else if (await usRep.checkEmailOrPhoneNumber(event.edit)) {
          _map[ProfileError.phoneOrEmail] = "Email or number is taken";
          yield EditedProfile(key: '${++i}', error: ProfileError.phoneOrEmail);
        } else {
          _map[ProfileError.phoneOrEmail] = null;
          yield EditedProfile(key: '${++i}');
        }
      } else {
        _map[ProfileError.phoneOrEmail] = "Invalid value";
        yield EditedProfile(key: '${++i}', error: ProfileError.phoneOrEmail);
      }
    }
  }

  void clearMap() {
    _map = {};
  }
}
