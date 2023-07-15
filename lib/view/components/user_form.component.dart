import 'package:event_flats/models/repositories/users_repository.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/validation_exception.dart';
import 'package:event_flats/view/components/dialogs.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/login.screen.dart';
import 'package:flutter/material.dart';

class UserFormComponent extends StatefulWidget {
  const UserFormComponent(this.user, this._usersRepository, {Key? key})
      : super(key: key);

  final Map<String, dynamic> user;
  final UsersRepository _usersRepository;

  @override
  _UserFormComponentState createState() => _UserFormComponentState(user);
}

class _UserFormComponentState extends State<UserFormComponent> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Map<String, dynamic> user;

  _UserFormComponentState(this.user);

  bool _userFormLoading = false;

  void _onUserFormSave() async {
    if (_userFormLoading) return;
    setState(() {
      _userFormLoading = true;
    });
    try {
      var updatedUser = await widget._usersRepository.update(user['id'],
          user['name'], _emailController.text, _passwordController.text);
      setState(() {
        user = updatedUser;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text(
            'Пользователь обновлён',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 18),
          )));
    } on ServerErrorException {
      showDialog(
          context: context,
          builder: (context) => buildServerErrorDialog(context));
      return;
    } on NoInternetException {
      showDialog(
          context: context,
          builder: (context) => buildNoInternetDialog(context));
      return;
    } on AuthenticationFailed {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
      return;
    } on ValidationException {
      showDialog(
          context: context,
          builder: (context) => buildValidationError(context));
      return;
    } finally {
      setState(() {
        _userFormLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _emailController.text = user['email'];
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8,
          ),
          Text(
            'Активность: ' + (user['last_activity_date'] ?? 'Отсутстввует'),
            style: TextStyle(fontSize: 21),
          ),
          SizedBox(
            height: 30,
          ),
          TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Логин')),
          TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Пароль', helperText: 'Установить новый пароль')),
          SizedBox(
            height: 30,
          ),
          Center(
            child: MaterialButton(
                onPressed: _onUserFormSave,
                color: AppColors.primaryColor,
                minWidth: 130,
                child: !_userFormLoading
                    ? Text('Сохранить',
                        style: TextStyle(fontSize: 18, color: Colors.black))
                    : SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ))),
          )
        ],
      ),
    );
  }
}
