import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monsiegesocial/pages/page_acceuil.dart';
import 'package:monsiegesocial/pages/page_login.dart';

import '../Animation/animateroute.dart';
import '../Database/dbhelper.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../variables/variables.dart';

class LoginChecker extends StatefulWidget {
  const LoginChecker({Key? key}) : super(key: key);

  @override
  _LoginCheckerState createState() => _LoginCheckerState();
}

class _LoginCheckerState extends State<LoginChecker> {
  late DbHelper dbhelper;

  String userFirstname = "";
  String userLastname = "";
  String userEmail = "";
  String lastLogin = "";
  String lastActivity = "";
  String token = "";
  bool checkConnect = false;

  Future<void> userConnect(token, id) async {
    var uri = Uri.parse(url + "auto_login");
    final httpResponse = await http.post(uri, headers: <String, String>{
      'Authorization': 'Bearer $bearerToken',
      'Token': '$token'
    }, body: {
      'staffId': '$id'
    });
    if (httpResponse.statusCode == 200) {
      var result = jsonDecode(httpResponse.body);
      userFirstname = result['data']['firstName'];
      userLastname = result['data']['lastName'];
      userEmail = result['data']['email'];
      lastActivity = result['data']['lastActivity'];
      lastLogin = result['data']['lastLogin'];

      if (result['error'] == false) {
        Navigator.of(context).pushReplacement(SlideRight(
            page: PageAccueil(token, id.toString(), userFirstname, userLastname,
                lastActivity, lastLogin)));
      } else {
        Navigator.of(context)
            .pushReplacement(SlideRight(page: const PageLogin()));
      }
    } else {
      throw Exception('data not received');
    }
  }

  Future<List<User>> getData() async {
    final data = await dbhelper.getdata();
    return data;
  }

  @override
  void initState() {
    dbhelper = DbHelper();

    getData().then((value) => {
          if (value.isEmpty)
            {
              Navigator.of(context)
                  .pushReplacement(SlideRight(page: const PageLogin()))
            }
          else
            {userConnect(value[0].getToken, value[0].getId)}
        });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE26A2A),
        child: const Center(
          child: Image(
              image: AssetImage("images/Monsiegesocial_Orange.png"),
              width: 170,
              height: 170),
        ),
      ),
    );
  }
}
