import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/view/components/dialogs.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/home.screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const String route = '/login';

  final AuthenticationService _authenticationService;

  const LoginScreen(this._authenticationService, {Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState(_authenticationService);
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  final AuthenticationService _authenticationService;

  _LoginScreenState(this._authenticationService);

  String? _validateLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите логин';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    return null;
  }

  void _onSubmit() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final email = _emailController.text;
      final password = _passwordController.text;
      try {
        await _authenticationService.login(email, password);
        Navigator.of(context)
            .pushNamedAndRemoveUntil(HomeScreen.route, (route) => false);
      } on AuthenticationFailed catch (ex) {
        showDialog(
            context: context,
            builder: (context) => buildAuthorizationErrorDialog(context, ex));
      } on NoInternetException {
        showDialog(
            context: context,
            builder: (context) => buildNoInternetDialog(context));
      } on ServerErrorException {
        showDialog(
            context: context,
            builder: (context) => buildServerErrorDialog(context));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _entryField(String title,
      {bool isPassword = false,
      FormFieldValidator<String>? validator,
      TextEditingController? controller}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              controller: controller,
              validator: validator,
              obscureText: isPassword,
              decoration:
                  InputDecoration(border: InputBorder.none, filled: true))
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return InkWell(
      onTap: _onSubmit,
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: AppColors.primaryColor),
          child: !_isLoading
              ? Text('Вход',
                  style: TextStyle(fontSize: 21, color: Colors.white))
              : SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )),
    );
  }

  Widget _title(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Sul',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
          children: [
            TextSpan(
              text: 'tan F',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            TextSpan(
              text: 'lats',
              style: TextStyle(color: AppColors.primaryColor, fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Логин",
            validator: _validateLogin, controller: _emailController),
        _entryField("Пароль",
            isPassword: true,
            validator: _validatePassword,
            controller: _passwordController),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: height * .2),
                _title(context),
                SizedBox(height: 50),
                Form(key: _formKey, child: _emailPasswordWidget()),
                SizedBox(height: 20),
                _submitButton(context),
              ],
            ),
          ),
        ),
      ]),
    ));
  }
}
