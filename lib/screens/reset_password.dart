import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // declaring variables
  late String password, email;
  // form key parameter for validating
  final _formkey = GlobalKey<FormState>();
  // editting controllers
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //email field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      // validator: (value) {},
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.mail),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'Email',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      validator: (value){
        if(value!.isEmpty)
        {
          return 'Please Enter your email';
        }
        if(!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)){
          return 'Please Enter a valid Email';
        }
        return null;
      },
      onChanged: (value) => email = value,
    );

    // Reset Password button
    final resetButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
        onPressed: () async {
          if(_formkey.currentState!.validate()) {
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);

              // show this pop up message to the user
              Fluttertoast.showToast(msg: "Go to your email and follow the link to reset the password",
                  gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);

              //Success
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            } on FirebaseAuthException catch (error){
              Fluttertoast.showToast(msg: error.message ?? "Something went wrong",
                gravity: ToastGravity.TOP,toastLength: Toast.LENGTH_LONG,backgroundColor: Colors.white, textColor: Colors.red,

              );
            }
          }
        },
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        child: const Text(
          'Reset',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            //passing this to the root
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Reset Password'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 130,
                        child: Image.asset(
                          "assets/images/download.jpg",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      emailField,
                      const SizedBox(
                        height: 25,
                      ),
                      resetButton,
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
