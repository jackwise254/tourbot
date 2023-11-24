import 'package:flutter/material.dart';
import 'accounts/signup.dart';
import 'accounts/password_reset.dart';
import 'dashboard/home.dart';



void main() => runApp(LoginApp());


class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.orange,   // Set primary theme color to orange
        primaryTextTheme: TextTheme(    // Set primary text theme color to white
          headline6: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: LoginPage(),
    );
  }
}


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isFocused = false;
  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_usernameFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
      setState(() {
        _isFocused = true;
      });
    } else {
      setState(() {
        _isFocused = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: Text('Login'),
      backgroundColor: Colors.orange,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Conditional rendering of the image
            if (!_isFocused)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/logo.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        focusNode: _usernameFocusNode,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
                            labelText: 'Username or Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username or email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        focusNode: _passwordFocusNode,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text('Login'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MainDashboardPage()),  // Adjust "MainDashboardPage()" to whatever your main screen class name is.
                              );
                            }
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          child: Text('Forgot Password?'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PasswordPage()),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: TextButton(
                          child: Text("Don't have an account?, Sign up"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
