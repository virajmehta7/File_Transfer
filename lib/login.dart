import 'package:flutter/material.dart';
import 'share.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController username = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ]
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              Text('File \nTransfer',
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 50, color: Colors.white,),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15,55,15,20),
                child: TextField(
                  controller: username,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person,color: Colors.white,size: 30),
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20,),
                    enabledBorder: outlineInputBorder,
                    focusedBorder: outlineInputBorder,
                    errorBorder: outlineInputBorder,
                    focusedErrorBorder: outlineInputBorder,
                  ),
                ),
              ),
              Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  child: Text('Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black.withOpacity(0.4),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: (){
                    if (username.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Username can\'t be empty',
                          style: TextStyle(color: Colors.red),
                        ),
                        backgroundColor: Colors.white,
                        duration: Duration(seconds: 2),
                      ));
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => Share(username: username.text.trim())
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide(
        color: Colors.black
    ),
    borderRadius: BorderRadius.circular(12)
);