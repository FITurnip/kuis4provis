import 'package:flutter/material.dart';
import 'package:kuis4/item/items.dart';

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
        child: _isLoginForm ? LoginForm(toggleForm: _toggleForm) : RegisterForm(toggleForm: _toggleForm),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final VoidCallback toggleForm;

  LoginForm({required this.toggleForm});

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
              // Implement login functionality here
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => FoodListPage()));
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
