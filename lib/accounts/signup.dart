import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
    @override
 _SignupPageState createState() => _SignupPageState();
}


class _SignupPageState extends State<SignupPage> {
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
      appBar: AppBar(title: Text('back')),
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
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username ';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        focusNode: _usernameFocusNode,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 10.0),
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
                            return 'Please enter youremail';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        focusNode: _passwordFocusNode,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 10.0),
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
                          child: Text('Sign Up'),
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
                      child: Text("Already have an account?, Sign In"),
                      onPressed: () {
                          Navigator.pop(context);
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













// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('back')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//             Expanded(
//                 // child: ClipRRect(
//                   // borderRadius: BorderRadius.circular(15.0),
//                   child: Image.asset(
//                     'assets/logo.png',
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 // ),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(
//                     labelText: 'Username',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.orange, width: 2.0), // Adjust color and width as needed
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
                
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your username ';
//                   }
//                   return null;
//                 },
//               ),
              
//             SizedBox(height:10),
//               TextFormField(
//                 decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.orange, width: 2.0), // Adjust color and width as needed
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
                
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: 10),
//               TextFormField(
//                 decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.orange, width: 2.0), // Adjust color and width as needed
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height:30),
//               SizedBox(
//                 // height: 40,
//                 width: double.infinity, // This will make the button take the full width of its parent container
//                 child: ElevatedButton(
//                   child: Text('Sign Up'),
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Handle login logic here if the form is valid
//                     }
//                   },
//                 ),
//               ),

//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: TextButton(
//                 child: Text("Already have an account?, Sign In"),
//                 onPressed: () {
//                     Navigator.pop(context);
//                 },
//                 ),

//               )


              

//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





