import 'package:flutter/material.dart';

class PasswordPage extends StatefulWidget {
    @override
 _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('back')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2.0), // Adjust color and width as needed
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email ';
                  }
                  return null;
                },
              ),
              

              SizedBox(height:30),
              SizedBox(
                // height: 40,
                width: double.infinity, // This will make the button take the full width of its parent container
                child: ElevatedButton(
                  child: Text('Reset'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle login logic here if the form is valid
                    }
                  },
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                child: Text("Go back home"),
                onPressed: () {
                    Navigator.pop(context);
                },
                ),

              )
            ],
          ),
        ),
      ),
    );
  }
}





