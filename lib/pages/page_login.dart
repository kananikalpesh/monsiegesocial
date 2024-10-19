import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monsiegesocial/models/user.dart';
import 'package:monsiegesocial/pages/page_acceuil.dart';
import '../Animation/animateroute.dart';
import '../Database/dbhelper.dart';
import 'package:http/http.dart' as http;

import '../variables/variables.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);

  @override
  _PageLoginState createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  bool isscrolling = false;

  int userId = 0;
  String userFirstname = "";
  String userLastname = "";
  String userEmail = "";
  String lastLogin = "";
  String lastActivity = "";
  String token = "";

  late DbHelper dbhelper;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailaddress = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isChecked = false;

  bool isObscure = true;

  Color getColor(Set<MaterialState> states) {
    return const Color(0xffF37906);
  }

  Future<void> userLogin(String emailaddress, String password) async {
    if (_formKey.currentState!.validate()) {
      var uri = Uri.parse(url + "login");
      final httpResponse = await http.post(
        uri,
        body: {"email": emailaddress, "password": password},
        headers: <String, String>{'Authorization': 'Bearer $bearerToken'},
      );

      //print("login responce"+jsonDecode(httpResponse.toString()));

      if (httpResponse.statusCode == 200) {
        var result = jsonDecode(httpResponse.body);
        setState(() {
          if (result['error'] == false) {
            userId = result['data']['staffId'];
            userFirstname = result['data']['firstName'];
            userLastname = result['data']['lastName'];
            userEmail = result['data']['email'];
            lastLogin = result['data']['lastLogin'];
            lastActivity = result['data']['lastActivity'];
            token = result['data']['token'];

            if (isChecked == true) {
              setState(() {
                isscrolling = true;
              });
              dbhelper.saveData(User(
                  userId: userId,
                  userFirstname: userFirstname,
                  userLastname: userLastname,
                  userEmail: userEmail,
                  userToken: token));
            } else {
              setState(() {
                isscrolling = true;
              });
            }
            Navigator.of(context).pushReplacement(SlideRight(
                page: PageAccueil(token, userId.toString(), userFirstname,
                    userLastname, lastActivity, lastLogin)));
          } else {
            isscrolling = false;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: Icon(
                      Icons.warning,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text("Email ou mot de passe invalide",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                        )),
                  ),
                ],
              ),
              backgroundColor: const Color(0xffF69704),
            ));
          }
        });
      } else {
        throw Exception('data not received');
      }
    }
  }

  @override
  void initState() {
    dbhelper = DbHelper();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: const Color(0xFFFAFAFA),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage(
                        "images/Monsiegesocial_Logo_TypoVerticale_Orange_RVB.png"),
                    width: 250,
                    height: 250,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: TextFormField(
                      validator: (value) {
                        final emailReg = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value!);
                        if (value.isEmpty) {
                          setState(() {
                            isscrolling = false;
                          });
                          return "S'il vous plaît entrez votre adresse e-mail";
                        } else if (!emailReg) {
                          setState(() {
                            isscrolling = false;
                          });
                          return "Veuillez entrer une adresse e-mail valide";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 13),
                      cursorColor: const Color(0xffF37906),
                      controller: emailaddress,
                      decoration: InputDecoration(
                          hintText: "Adresse e-mail",
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 5, top: 3),
                            child: Icon(
                              Icons.person,
                              color: Color(0xffF37906),
                              size: 25,
                            ),
                          ),
                          errorStyle: const TextStyle(fontSize: 10),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 14),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xffF37906),
                              )),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 0, 0),
                              )),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 0, 0),
                              )),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xffF37906),
                              ))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            isscrolling = false;
                          });
                          return "s'il vous plaît entrez votre mot de passe";
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 13),
                      cursorColor: const Color(0xffF37906),
                      obscureText: isObscure,
                      controller: password,
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              if (isObscure) {
                                isObscure = false;
                              } else {
                                isObscure = true;
                              }
                            });
                          },
                          child: isObscure
                              ? const Icon(
                                  Icons.visibility,
                                  color: Color(0xffF37906),
                                  size: 25,
                                )
                              : const Icon(
                                  Icons.visibility_off,
                                  color: Color(0xffF37906),
                                  size: 25,
                                ),
                        ),
                        hintText: "Mot de passe",
                        hintStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 5, top: 3),
                          child: Icon(
                            Icons.lock_rounded,
                            color: Color(0xffF37906),
                            size: 25,
                          ),
                        ),
                        errorStyle: const TextStyle(fontSize: 10),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 14),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color(0xffF37906),
                            )),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 255, 0, 0),
                            )),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 255, 0, 0),
                            )),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xffF37906),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Checkbox(
                            checkColor: Colors.white,
                            activeColor: const Color(0xffF37906),
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                            }),
                        const Text(
                          "Rester connecté",
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xffF37906),
                            blurRadius: 5,
                          )
                        ],
                        gradient: const LinearGradient(
                            colors: [Color(0xffF37906), Color(0xffF8AC03)])),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: TextButton(
                        onPressed: () async {
                          isscrolling = true;
                          await userLogin(emailaddress.text, password.text);
                        },
                        child: isscrolling
                            ? const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                "Se connecter",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
