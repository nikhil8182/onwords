import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
class DemoAbout extends StatefulWidget {
  String name;
  Gradient g1;
  bool isDark;
  DemoAbout(this.name,this.g1,this.isDark);
  @override
  _DemoAboutState createState() => _DemoAboutState();
}

class _DemoAboutState extends State<DemoAbout> {
  List data;
  List data_value;
  bool result = false;
  bool result2 = false;
  Future<http.Response> call() async {
    //final response = await http.get('http://192.168.101.18:8000/key/');
    //final response = await http.get(
      //  'http://34.83.46.202.xip.io/cyberhome/home.php?username=${widget.name}&query=table');

    final response = await http.get(Uri.http("34.83.46.202.xip.io", "cyberhome/home.php",{"username":"${widget.name}","query":"table"}));

    if (response.statusCode == 200) {

      // print("response: ${response.statusCode}");
      setState(() {
        data = jsonDecode(response.body);
      });

      //print("values $data");
      //print("response: ${response.body}");
      result = true;
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //  return Album.fromJson(json.decode(response.body));
    } else {
      setState(() {
        result = false;
      });
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
    return response;
  }

  Future<bool> call_value() async {
    //final response = await http.get('http://34.83.46.202.xip.io/cyberhome/home.php?username=${widget.name}&query=value');
    final response = await http.get(Uri.http("34.83.46.202.xip.io", "cyberhome/home.php",{"username":"${widget.name}","query":"value"}));

    if (response.statusCode == 200) {
      setState(() {
        data_value = jsonDecode(response.body);

      });
      //("response 2: ${response.body}");
      result2 = true;

      Future.delayed(const Duration(seconds: 2), () {

// Here you can write your code

        setState(() {
          //print("after");
          for(int i=0; i<data_value[0].length;i++) {
            //print(data_value[0][i]);
            data_value[0][i] = data_value[0][i];
          }

          // _buildButtonsWithNames();


          // Here you can write your code for open new view
        });

      });
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //  return Album.fromJson(json.decode(response.body));
    } else {
      setState(() {
        result2 = false;
      });
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
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

  List<Container> ContainerList = new List<Container>();

  List<Widget>  _buildContainerWithNames() {
    ContainerList.clear();
    for (int i = 0; i < data.length; i++)
    {
      TextContainer(i);
    }
    setState(() {
      ContainerList = ContainerList.toSet().toList();
    });
    return ContainerList;
  }

  void TextContainer(int i){
    if(data[i].toString().contains("About")){
      ContainerList.add(Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data[i].toString().split("About")[0].replaceAll("_", " "),style: GoogleFonts.robotoSlab(color:Colors.white),),
            Text(data_value[0][i],style: GoogleFonts.robotoSlab(color:Colors.white,),),
          ],
        ),
      ));
    }

  }
  Timer timer;
  @override
  void initState() {
    // TODO: implement initState
    check().then((intenet) {
      if (intenet) {
        call().then((value) => call_value());
      }
      else {
        showDialog(
            context: context,
            builder: (_) =>
                AlertDialog(
                  backgroundColor: Colors.black,
                  title: Text(
                    "No Internet Connection",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Text(
                      "Please check your Internet Connection",
                      style: TextStyle(color: Colors.white)),
                ));
        //print("Connection: not present");
      }
    });
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) =>
        check().then((intenet) {
          if (intenet) {
            call().then((value) => call_value());
          }
          else {
            showDialog(
                context: context,
                builder: (_) =>
                    AlertDialog(
                      backgroundColor: Colors.black,
                      title: Text(
                        "No Internet Connection",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                          "Please check your Internet Connection",
                          style: TextStyle(color: Colors.white)),
                    ));
          }
        }));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final height =MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Stack(
          children: [
            Container(
              child: Container(
                margin:EdgeInsets.only(bottom: height*0.06),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //SizedBox(width: width*0.12,),
                    IconButton(icon: Icon(Icons.keyboard_backspace_outlined,color: Colors.white,), onPressed: (){Navigator.pop(context);}),
                    Container(child: Center(child: Text("About Home",style: GoogleFonts.robotoSlab(fontSize: 18,color: Colors.white),))),

                    Container(
                      padding:  const EdgeInsets.all(15.0),
                    ),
                  ],
                ),
              ),
              height: height*0.15,
              width: width*1,
              decoration: BoxDecoration(
                gradient: widget.g1,
              ),
            ),
            Container(
                margin: EdgeInsets.only(top:height*0.09),
                width: width*12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.elliptical(20, 20),topRight:Radius.elliptical(20,20) ),
                  color:Colors.grey[900],
                ),
                child:SingleChildScrollView(
                  child: Column(
                    children: [
                      result && result2
                          ? SingleChildScrollView(child: Container(padding:EdgeInsets.all(5),child: Wrap(children: _buildContainerWithNames())))
                          : Container(
                        child: Container(
                          margin: EdgeInsets.only(top:height*0.4),
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.grey[700],
                            valueColor:new AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}
