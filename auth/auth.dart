import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kuis4/auth/shared_preferences_helper.dart';
import 'package:kuis4/barayafood_uri.dart';
import 'dart:convert';
import 'package:kuis4/item/items.dart';

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool _isLoginForm = true;
  bool _isLoading = false;

  void _toggleForm() {
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              _isLoginForm ? 'Login' : 'Register',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: _isLoginForm
          ? LoginForm(
              toggleForm: _toggleForm,
              isLoading: _isLoading,
              onLogin: _login,
            )
          : RegisterForm(
              toggleForm: _toggleForm,
              isLoading: _isLoading,
              onRegister: _register), // Pass register method to RegisterForm
    );
  }

  void _login(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({"username": username, "password": password}),
      );

      print(jsonEncode({"username": username, "password": password}));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data);

        await SharedPreferencesHelper.savePreference(
            'user_id', data['user_id']);
        await SharedPreferencesHelper.savePreference(
            'access_token', data['access_token']);

        print(data);
        print('Login successfully');
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => FoodListPage()));
      } else {
        print('Failed to login');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _register(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}users/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        print('Registration successful');
        // Tampilkan pesan berhasil registrasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful'),
            duration: Duration(seconds: 2), // Durasi snackbar
          ),
        );
        // Setelah registrasi berhasil, pindahkan pengguna ke halaman login
        _toggleForm();
      } else {
        print('Failed to register');
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class LoginForm extends StatelessWidget {
  final VoidCallback toggleForm;
  final bool isLoading;
  final Function(String, String) onLogin;

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
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 90.0),
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
            onPressed: isLoading
                ? null
                : () => onLogin(
                      usernameController.text.toString(),
                      passwordController.text.toString(),
                    ),
            child: isLoading
                ? Container(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                    ),
                  )
                : Text('Login'),
          ),
          SizedBox(height: 20.0),
          TextButton(
            onPressed: toggleForm,
            child: Text('Don\'t have an account? Register here'),
          ),
          SizedBox(height: 100.0),
          Text(
            'Kelompok 28',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          Text(
            'Franklin Impianro (2203211) || Roshan Syalwan (22203142)',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatelessWidget {
  final VoidCallback toggleForm;
  final bool isLoading;
  final Function(String, String) onRegister;

  RegisterForm(
      {required this.toggleForm,
      required this.isLoading,
      required this.onRegister});

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 90.0),
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
            onPressed: isLoading
                ? null
                : () => onRegister(
                      usernameController.text.toString(),
                      passwordController.text.toString(),
                    ),
            child: isLoading
                ? Container(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                    ),
                  )
                : Text('Register'),
          ),
          SizedBox(height: 20.0),
          TextButton(
            onPressed: toggleForm,
            child: Text('Already have an account? Login here'),
          ),
          SizedBox(height: 100.0),
          Text(
            'Kelompok 28',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          Text(
            'Franklin Impianro (2203211) || Roshan Syalwan (22203142)',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
