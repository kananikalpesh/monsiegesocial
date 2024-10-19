import 'package:flutter/material.dart';
import 'package:monsiegesocial/Animation/animateroute.dart';
import 'package:monsiegesocial/pages/list_clients.dart';
import '../Database/dbhelper.dart';
import 'page_login.dart';

// ignore: must_be_immutable
class Entrymanually extends StatefulWidget {
  String token;
  String staffId;
  String firstName;
  String lastName;
  String lastConnexion;
  String lastActivite;
  final dynamic filepicture;
  Entrymanually(this.token, this.staffId, this.firstName, this.lastName,
      this.lastActivite, this.lastConnexion, this.filepicture,
      {Key? key})
      : super(key: key);

  @override
  _EntrymanuallyState createState() => _EntrymanuallyState();
}

class _EntrymanuallyState extends State<Entrymanually> {
  late DbHelper dbHelper;

  final TextEditingController _textcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> sendText() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        SlideRight(
            page: ListClient(
                "",
                _textcontroller.text,
                widget.token,
                widget.staffId,
                widget.filepicture,
                widget.firstName,
                widget.lastName,
                widget.lastConnexion,
                widget.lastActivite)),
      );

      setState(() {
        _textcontroller.text = "";
      });
    }
  }

  @override
  void initState() {
    dbHelper = DbHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffa641),
        title: Container(
          alignment: Alignment.center,
          // padding:
          //   EdgeInsets.only(left: MediaQuery.of(context).size.width / 2.5),
          child: const Image(
            image: AssetImage("images/Monsiegesocial_Logo_Orange.png"),
            width: 52,
            height: 52,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton(
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 35,
                ),
                itemBuilder: (context) => [
                      PopupMenuItem(
                          enabled: false,
                          child: Row(children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(widget.firstName.toString(),
                                  style: const TextStyle(
                                      color: Color(0xff241D17),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10, left: 5),
                              child: Text(widget.lastName.toString(),
                                  style: const TextStyle(
                                      color: Color(0xff241D17),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            )
                          ])),
                      PopupMenuItem(
                        height: 30,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.logout,
                              color: Color(0xff241D17),
                              size: 17,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10, top: 2),
                              child: Text(
                                "Se déconnecter",
                                style: TextStyle(
                                    color: Color(0xff241D17), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final data = await dbHelper.getdata();
                          if (data.isNotEmpty) {
                            dbHelper.deleteData(data[0].getToken);
                          }

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PageLogin()),
                              (route) => false);
                        },
                      ),
                    ]),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: TextFormField(
                      controller: _textcontroller,
                      style: const TextStyle(fontSize: 13),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nom du client est obligatoire...";
                        }
                        return null;
                      },
                      cursorColor: const Color(0xffF37906),
                      decoration: InputDecoration(
                          hintText: "Nom du client ...",
                          hintStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 5, top: 3),
                            child: Icon(
                              Icons.business,
                              color: Color(0xffF37906),
                              size: 25,
                            ),
                          ),
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
                                  color: Color.fromARGB(255, 255, 0, 0))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xffF37906),
                              ))),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40),
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
                        onPressed: () {
                          sendText();
                        },
                        child: const Text(
                          "Recherche",
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
    );
  }
}
