import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_chat/blocs/birthday/birthday_screen.dart';

import 'package:snap_chat/blocs/sign_up/sign_up_bloc.dart';
import 'package:snap_chat/blocs/sign_up/sign_up_event.dart';
import 'package:snap_chat/blocs/sign_up/sign_up_state.dart';
import 'package:snap_chat/blocs/user/user_bloc.dart';
import 'package:snap_chat/data/realme/user.dart';

import 'package:snap_chat/widgets/login_signup_button.dart';
import 'package:snap_chat/widgets/txt_field.dart';

import '../../app_localizations.dart';

// ignore: must_be_immutable
  ---> Check and fix all warnings
class SignUpScreen extends StatefulWidget {
  final User _user = User();
  @override
  State<StatefulWidget> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignupBloc _signupBloc;
  final _formKey = GlobalKey<FormState>();

    ---> Is need this propertys here ?

  String _lastName = "";
  String _firstName = "";

  @override
  void initState() {
    super.initState();
    _signupBloc = SignupBloc();
  }

  @override
  void dispose() {
    _signupBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignupBloc>(create: (context) {
      return _signupBloc;
    }, child: BlocBuilder<SignupBloc, SignupState>(builder: (context, state) {
      return _render(state);
    }));
  }

  Widget _render(SignupState state) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.blue,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
            child: Form(
                key: _formKey,
                child: Stack(children: [
                  _fieldOnScreen(state),

                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _signUpButton(state)),
                  )
               
                ]))));
  }

 
---> Render functions should be like this  Widget _renderFieldOnScreen(SignupState state)
  Widget _fieldOnScreen(SignupState state) {
    return Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _textForHeadingScreen(),
              _textForFirstName(state),
              _textForLastName(state),
              _renderTextsecurity(),
            ],
          ),
        ));
  }

  Widget _textForHeadingScreen() {
    return Text(
      AppLocalizations.of(context).translate("whats_your_name"),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 25,
        fontWeight: FontWeight.w700,
      ),
    );
  }

    ---> Render functions name should be logical
  Widget _textForFirstName(SignupState state) {
    return Padding(
        padding: const EdgeInsets.only(
          top: 10,
        ),
        child: TxtFieldForScreen(
          txtType: TextInputType.name,
          label: AppLocalizations.of(context).translate("firstname"),
          obscure: false,
          focus: true,
          validator: (_) {
            return state is InvalidFirstname
                ? AppLocalizations.of(context).translate("invalid_value")
                : null;
          },
          onChange: (val) {
            _firstName = val.trim();
            _signupBloc.add(
                SignupValidationEvent(firstName: val, lastName: _lastName));
          },
        ));
  }

  Widget _textForLastName(SignupState state) {
    return Padding(
        padding: const EdgeInsets.only(
          top: 10,
        ),
        child: TxtFieldForScreen(
          focus: false,
          txtType: TextInputType.name,
          label: AppLocalizations.of(context).translate("lastname"),
          obscure: false,
          validator: (_) {
            return state is InvalidLastname
                ? AppLocalizations.of(context).translate("invalid_value")
                : null;
          },
          onChange: (val) {
            _lastName = val.trim();
            _signupBloc.add(
                SignupValidationEvent(firstName: _firstName, lastName: val));
          },
        ));
  }

  Widget _renderTextsecurity() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 35,
        right: 35,
      ),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
            text: AppLocalizations.of(context).translate("privacy_policy1"),
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: AppLocalizations.of(context).translate("privacy_policy2"),
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
              TextSpan(
                text: AppLocalizations.of(context).translate("privacy_policy3"),
                style: const TextStyle(color: Colors.black45, fontSize: 14),
              ),
              TextSpan(
                text: AppLocalizations.of(context).translate("privacy_policy4"),
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ]),
      ),
    );
  }

  Widget _signUpButton(SignupState state) {
    return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: LoginAndSignUpButton(
            color: state is SignupValidated ? Colors.blue : Colors.grey,
            text: AppLocalizations.of(context).translate("sign_up_and_accept"),
            onPress: () {
              if (state is SignupValidated) {
                widget._user.firstName = _firstName;
                widget._user.lastName = _lastName;
                _openBirthdayScreen();
              }
            }));
  }

  Future<void> _openBirthdayScreen() {
    return Navigator.push(context, MaterialPageRoute(builder: (_) {
      return BlocProvider.value(
          value: BlocProvider.of<UserBloc>(context),
          child: BirthdayScreen(widget._user));
    }));
  }
}
