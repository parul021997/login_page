import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_page/homeScreeb.dart';
import 'package:pinput/pin_put/pin_put.dart';

class OTPControllerScreen extends StatefulWidget {
 final String phone;
 final String codeDigits;

 OTPControllerScreen({required this.phone,required this.codeDigits});


  @override
  State<OTPControllerScreen> createState() => _OTPControllerScreenState();
}

class _OTPControllerScreenState extends State<OTPControllerScreen> {
   final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
   final TextEditingController _pinOTPCodeController = TextEditingController();
   final FocusNode _pinOTPCodeFocus = FocusNode();
   String? varificationCode;

   final BoxDecoration pinOTPCodeDecoration =BoxDecoration(
     color: Colors.blueAccent,
     borderRadius: BorderRadius.circular(10.0),
     border: Border.all(
       color: Colors.grey,
     )
   );



  @override
  void initState(){
    super.initState();
    verifyPhone();
  }
  verifyPhone() async{
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "${widget.codeDigits + widget.phone}",
      verificationCompleted: (PhoneAuthCredential credential) async
      {
        await FirebaseAuth.instance.signInWithCredential(credential).then((value){
          if(value.user != null)
          {
            Navigator.of(context).push(MaterialPageRoute(builder:(c)=> homeScreen()));
          }
        });
      },
      verificationFailed: (FirebaseAuthException e)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message.toString()),
            duration: Duration(seconds: 3),
          ),
        );
      },
      codeSent: (String vID, int? resendToken)
        {
          setState(() {
           varificationCode = vID;
          });
        },
      codeAutoRetrievalTimeout: (String vID)
        {
          setState(() {
            varificationCode = vID;
          });
        },
      timeout: Duration(seconds: 60)
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey ,
      appBar: AppBar(
        title: Text("OTP verification"),
      ),body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/otp.png"),
        ),

        Container(
          margin: EdgeInsets.only(top: 20),
          child: Center(
            child: GestureDetector(
              onTap: (){
                verifyPhone();
              },
              child: Text(
                  "verifying : ${widget.codeDigits}-${widget.phone}",
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
              )
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(40.0),
          child: PinPut(
            fieldsCount: 6,
            textStyle: TextStyle(fontSize: 25.0,color: Colors.white),
            eachFieldWidth: 40.0,
            eachFieldHeight: 55.0,
            focusNode: _pinOTPCodeFocus,
            controller: _pinOTPCodeController ,
            submittedFieldDecoration: pinOTPCodeDecoration ,
            selectedFieldDecoration: pinOTPCodeDecoration,
            followingFieldDecoration: pinOTPCodeDecoration,
            pinAnimationType: PinAnimationType.rotation,
            onSubmit: (pin) async{
              try{
                await FirebaseAuth.instance
                    .signInWithCredential(PhoneAuthProvider
                    .credential(verificationId: varificationCode!, smsCode: pin))
                    .then((value) {
                      if(value.user != null)
                      {
                        Navigator.of(context).push(MaterialPageRoute(builder:(c)=> homeScreen()));
                      }

                });

              }
              catch(e){
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("invalid password"),
                    duration: Duration(seconds: 3),
                  ),
                );

              }
            },

          ),
        )
      ],
    ),
    );
  }
}
