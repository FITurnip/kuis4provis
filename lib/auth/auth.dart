import 'package:flutter/material.dart';
import 'package:kuis4/item/items.dart';
import 'package:http/http.dart';
import 'dart:convert';

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool _isLoginForm = true;

  void _toggleForm() {
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginForm ? 'Login' : 'Register'),
      ),
      body: Center(
        child: _isLoginForm
            ? LoginForm(toggleForm: _toggleForm)
            : RegisterForm(toggleForm: _toggleForm),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final VoidCallback toggleForm;

  LoginForm({required this.toggleForm});

  //tambahan dari yt
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login(String username, password) async {
    try {
      Response response = await post(
          Uri.parse('http://146.190.109.66:8000/login'),
          body: {'username': username, 'password': password});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        print(data);
        print('Login successfully');
      } else {
        print('Gagal Login');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(hintText: 'Username'),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(hintText: 'Password'),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              login(usernameController.text.toString(),
                  passwordController.text.toString());

              // // Implement login functionality here
              // Navigator.of(context).push(
              //     MaterialPageRoute(builder: (context) => FoodListPage()));
            },
            child: Text('Login'),
          ),
          SizedBox(height: 20.0),
          TextButton(
            onPressed: toggleForm,
            child: Text('Don\'t have an account? Register here'),
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatelessWidget {
  final VoidCallback toggleForm;

  RegisterForm({required this.toggleForm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              // Implement registration functionality here
            },
            child: Text('Register'),
          ),
          SizedBox(height: 20.0),
          TextButton(
            onPressed: toggleForm,
            child: Text('Already have an account? Login here'),
          ),
        ],
      ),
    );
  }
}
