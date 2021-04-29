import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import './DemoHomePage.dart';
import 'Home.dart';
Future<void> main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool loginCheck=await prefs.get('isLoggedIn');
  String user = await prefs.get('user');
  String ip = await prefs.get('ip');
  bool isDarkMode = await prefs.get('isDark');
  bool check_url = await prefs.get('check_url');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: loginCheck==false?MyApp():Home(user,ip,false,check_url),
    routes: {
      '/home': (context) => Home(user,ip,false,check_url),
    },
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future get_Ip(String name) async{
    //final response = await http.get('http://34.83.46.202.xip.io/cyberhome/home.php?username=$name&query=table');
    final response = await http.get(Uri.http("34.83.46.202.xip.io", "/cyberhome/home.php",{"username":"$name","query":"table"}));
    final response_value = await http.get(Uri.http("34.83.46.202.xip.io", "/cyberhome/home.php",{"username":"$name","query":"value"}));

    //final response_value = await http.get('http://34.83.46.202.xip.io/cyberhome/home.php?username=$name&query=value');
    var fetchdata = jsonDecode(response.body);
    var fetc_values = jsonDecode(response_value.body);
    List ip_data;
    List ip_data_value;
    if(response.statusCode==200) {
      setState( () {
        ip_data = fetchdata;
        ip_data_value = fetc_values;
      } );
      for(int i=0;i<ip_data.length;i++) {
       // print( "ip offline ${ip_data[i].toString( )}" );
        if(ip_data[i].toString().contains("local")){
          setState(() {
            ln=ip_data[i].toString();
            ipValue=ip_data_value[0][i].toString();
            ipIndex=i;
            update_Ip();
          //  print("ip address $ipValue");
          });
        }
      }

    }

  }

  String ln,ipValue;
  int ipIndex;
  String ipAddress;

  Future<bool> update_Ip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', ipValue);
    await prefs.setBool('first', true);
    return true;
  }




  bool checkLogInUser;
  Future<bool> update() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', emailController.text);
    await prefs.setString('password', passwordController.text);
    await prefs.setBool('isLoggedIn',true);
    await prefs.setBool('isDark', false);
    await prefs.setBool('first', true);
    //print(await prefs.getBool('seen'));
    return true;
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void _showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
  Future<bool> checkuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = await prefs.get('user');
    String pass = await prefs.get('password');
    String ip = await prefs.get('ip');
    bool login = await prefs.get('isLoggedIn');
    emailController.text = user;
    passwordController.text = pass;
   // print(user);
    //print(pass);
    //print(ip);
    //print("login status $login");
    setState(() {
      checkLogInUser=login;
    });
    //print(await prefs.getBool('seen'));
    return true;
  }
  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool loading=false;
  bool internet=false;
  bool _validateP = false;
  bool _validateE = false;
  bool pass=true;
  String errortextp;
  String errortexte;


  Future<http.Response> fetchData() async
  {
    // Map<String, String> params;
    //params.put("username", usernam);
    //params.put("password", pass);
    try {
      /*final response =
      await http.get(
          'http://34.83.46.202.xip.io/cyberhome/login.php?username=' +
              emailController.text + '&password=' + passwordController.text);*/
      final response = await http.get(Uri.http("34.83.46.202.xip.io", "/cyberhome/login.php",{"username":"${emailController.text}","password":"${passwordController.text}"}));

      if (response.statusCode == 200) {
        setState(() {
          update();
          loading = false;
        });
        // If server returns an OK response, parse the JSON.

        if (response.body != '"failed"') {
          String body = response.body.replaceAll('"', '');
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: Colors.black,
                title: Text(
                  "Login Successful",
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                    "Welcome " + response.body.replaceAll('"', ''),
                    style: TextStyle(color: Colors.white)),
              ));

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Home(emailController.text,"",true,true)),
                (Route<dynamic> route) => false,
          );


          /*
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage(email: body)));*/
        }
        else {
          showDialog( context: context,
              builder: (_) =>
                  AlertDialog(
                    backgroundColor: Colors.black,
                    title: Text(
                      "Login " + response.body.replaceAll( '"', '' ),
                      style: TextStyle( color: Colors.white ), ),
                    content: Text( "Please check the details",
                        style: TextStyle( color: Colors.white ) ), ) );
        }



        return response;
      }
      else {
        setState(() {
          loading = false;
        });
        // If that response was not OK, throw an error.
        throw Exception('Failed to load post');
      }
    }on SocketException {
      setState(() {
        loading=false;
        if(internet)
          showDialog(context: context,
              builder: (_) =>
                  AlertDialog(
                      backgroundColor: Colors.black,
                      title: Text("No Response!..",
                        style: TextStyle(color: Colors.white),),
                      content: Text("Slow Server Response or Internet connection",
                        style: TextStyle(color: Colors.white),))
          );
      });
      throw Exception('Internet is down');
    }
  }

  Widget _submitButton() {
    return InkWell(
      //borderRadius: BorderRadius.all(Radius.circular(10)),
        onTap:()        {
          FocusScope.of(context).requestFocus(new FocusNode());
          check().then((intenet) {
            if (intenet) {
              // Internet Present Case
              setState(() {
                internet=true;
              });
              //print("Connection: present");
             // print(internet);
            }
            else {
              setState(() {
                internet=false;
              });
           //   print("Connection: not present");
           //   print(internet);
            }
            // No-Internet Case
          });
          setState(() {
            emailController.text.isEmpty ? _validateE = true : _validateE = false;
            passwordController.text.isEmpty ? _validateP = true : _validateP = false;
          });
          if(_validateP==false&&_validateE==false&&internet==true) {
            loading = true;
            fetchData();
            get_Ip(emailController.text);
            setState(() {
              errortextp=null;
              errortexte=null;
            });
          }
          else {
            setState(() {
              if(_validateP==true)
                errortextp = 'Password cannot be empty';
              if(_validateE==true)
                errortexte = 'Username or Email cannot be empty';
            });
          }
        },
        child:Container(
          margin: const EdgeInsets.only(left:30,right:30),
          width: MediaQuery.of(context).size.width*0.3,
          padding: EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,

          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.grey[900],
                  Colors.grey[850],
                  Colors.grey[900],
                ]
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Text(
            'Login',
            style: GoogleFonts.robotoSlab(fontSize: 18,color: Colors.white),
          ),
        ));
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        //Text("Login",style: GoogleFonts.robotoSlab(fontSize: 20),),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                  style: TextStyle(color: Colors.black),
                  onTap: () {
                    errortexte = null;
                  },
                  controller: emailController,
                  obscureText: false,
                  cursorColor: Colors.grey[900],
                  decoration: InputDecoration(
                    //labelText: 'Enter the Value',
                    errorText: _validateE ? errortexte : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Container(
                      child: Icon(Icons.account_circle_outlined,color: Colors.white,size: MediaQuery.of(context).size.height*0.05,),
                      margin: EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Colors.grey[900],
                              Colors.grey[850],
                              Colors.grey[900],
                            ]
                        ),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8)),
                      ),
                    ),
                    hintText: "Username",
                    hintStyle: TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  )),

            ],
          ),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                  cursorColor: Colors.grey[900],
                  style: TextStyle(color: Colors.black),
                  onTap: () {
                    errortextp = null;
                  },
                  controller: passwordController,
                  obscureText: pass,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Container(
                        child: Icon(Icons.lock_outline,color: Colors.white,size: MediaQuery.of(context).size.height*0.05,),
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.grey[900],
                                  Colors.grey[850],
                                  Colors.grey[900],
                                ]
                            ),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8))
                        ),
                      ),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.black),
                      errorText: _validateP ? errortextp : null,
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                      suffixIcon: IconButton(
                        icon: pass==true?Icon(Icons.lock_outline):Icon(Icons.lock_open),
                        onPressed: (){
                          if(pass==true){
                            setState(() {
                              pass=false;
                            });
                          }
                          else{

                            setState(() {
                              pass=true;
                            });
                          }

                        },

                      )
                  ))
            ],
          ),

        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    return Scaffold(
        key: _scaffoldKey ,
        resizeToAvoidBottomInset : false,
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      /* HexColor("#614385"),
                      HexColor("#516395")*/
                      Colors.grey[900],
                      Colors.grey[850],
                      Colors.grey[900],
                    ]
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height*0.12,
                    width: MediaQuery.of(context).size.width*0.8,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: AssetImage('assets/onwords2.png'),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: height*0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(10),
                    width: width*0.8,
                    child: Column(
                      children: <Widget>[
                        _emailPasswordWidget(),
                        SizedBox(
                          height: height*0.02,
                        ),
                        _submitButton(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.03,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> DemoHome("test","",false,false)));
                                },
                                child: Text('Demo Login',
                                    style: GoogleFonts.robotoSlab(fontSize: 15)),
                              ),
                              InkWell(
                                onTap: () async{

                                },
                                child: Text('Contact us',
                                    style:GoogleFonts.robotoSlab(fontSize: 15)),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            loading   ? Container(
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor:  Colors.grey[700],
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Colors.white70),
                ),
              ),
              color: Colors.black.withOpacity(0.5),
            ):Container(),
            !internet  ? Container(
              child: Center(
                child: AlertDialog(
                  backgroundColor: Colors.black,
                  title: Text(
                    "No Internet", style: TextStyle(color: Colors.white),),
                  content: Text("Please check your Connection",
                      style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    Center(
                      child: FlatButton(
                        child: Text("Refresh", style: TextStyle(
                            color: Colors.white),),
                        onPressed: () {
                          check().then((intenet) {
                            if (intenet) {
                              // Internet Present Case
                              setState(() {
                                internet = true;
                              });
                             // print("Connection: present");
                             // print(internet);
                            }
                            else {
                              setState(() {
                                internet=false;
                                loading=false;
                              });
                              //print("Connection: not present");
                              //print(internet);
                            }
                            // No-Internet Case
                          });

                          //  Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                ),
              ),
              color: Colors.white.withOpacity(0.2),
            ):Container()
          ],
        ));
  }

  @override
  void initState() {
    check().then((intenet) {
      if (intenet) {
        // Internet Present Case
        setState(() {
          internet = true;
        });
        //print("Connection: present");
        //print(internet);
        checkuser().then((value) {
          if (emailController.text != "" && passwordController != "" && checkLogInUser==false)
            fetchData();
        });
      }
      else {
        setState(() {
          internet=false;
        });
       // print("Connection: not present");
      //  print(internet);
      }
      // No-Internet Case
    });
  }

}