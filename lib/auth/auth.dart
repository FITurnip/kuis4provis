import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kuis4/auth/shared_preferences_helper.dart';
import 'dart:convert';
import 'package:kuis4/item/items.dart';

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool _isLoginForm = true;
  bool _isLoading = false; // Add loading state variable

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
            ? LoginForm(
                toggleForm: _toggleForm,
                isLoading: _isLoading, // Pass loading state to LoginForm
                onLogin: _login, // Pass login method to LoginForm
              )
            : RegisterForm(toggleForm: _toggleForm),
      ),
    );
  }

  void _login(String username, String password) async {
    setState(() {
      _isLoading = true; // Set loading state to true when login process starts
    });

    try {
      final response = await http.post(
        Uri.parse("http://146.190.109.66:8000/login"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(
            {"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        // Save user ID and token to shared preferences
        await SharedPreferencesHelper.savePreference('user_id', data['user_id']);
        await SharedPreferencesHelper.savePreference('access_token', data['access_token']);

        print(data);
        print('Login successfully');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => FoodListPage()));
      } else {
        print('Gagal Login');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false when login process ends
      });
    }
  }
}

class LoginForm extends StatelessWidget {
  final VoidCallback toggleForm;
  final bool isLoading; // Add loading state variable
  final Function(String, String) onLogin; // Add login method

  // Add loading state variable and login method to constructor
  LoginForm({
    required this.toggleForm,
    required this.isLoading,
    required this.onLogin,
  });

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
            onPressed: isLoading // Disable button when loading
                ? null
                : () => onLogin(
                    usernameController.text.toString(),
                    passwordController.text.toString(),
                  ),
            child: isLoading // Show loading indicator if loading
                ? CircularProgressIndicator()
                : Text('Login'),
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
