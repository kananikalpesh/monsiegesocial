import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:monsiegesocial/Animation/animateroute.dart';
import 'package:monsiegesocial/Database/dbhelper.dart';
import 'package:monsiegesocial/pages/page_scan_envelope.dart';
import 'package:monsiegesocial/pages/page_scan_qrcode.dart';
import 'package:monsiegesocial/pages/takepicture.dart';
import 'package:http/http.dart' as http;
import 'package:monsiegesocial/variables/dataglobal.dart';
import 'package:path_provider/path_provider.dart';
import '../variables/expediteurs_list.dart';
import '../variables/priorities_list.dart';
import '../variables/salles_courrier_list.dart';
import '../variables/variables.dart';

import 'page_login.dart';

// ignore: must_be_immutable
class PageAccueil extends StatefulWidget {
  String token;
  String staffId;
  String firstName;
  String lastName;
  String lastConnexion;
  String lastActivite;

  PageAccueil(this.token, this.staffId, this.firstName, this.lastName,
      this.lastActivite, this.lastConnexion,
      {Key? key})
      : super(key: key);

  @override
  _PageAccueilState createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  late DbHelper dbHelper;

  List listExpediteur = [];
  List listSallesCourrier = [];
  List listPriorities = [];
  late Expediteurs valueExpediteurs;
  late SallesCourrier valueSallesCourrier;
  late Priorities valuePriorities;

  Future<void> getDataglobal() async {
    var uri = Uri.parse(url + "global&getlist=all");

    final httpResponse = await http.post(uri, headers: <String, String>{
      'Authorization': 'Bearer $bearerToken',
      'Token': widget.token
    }, body: {
      'staffId': widget.staffId,
    });

    if (httpResponse.statusCode == 200) {
      var result = jsonDecode(httpResponse.body);

      if (result['error'] == false && result['message'] == "successful") {
        List dataExpediteurs = result['data']['ExpediteursList'];
        List dataSallesCourrier = result['data']['SallesCourrierList'];
        List dataPriorities = result['data']['PrioritiesList'];
        setState(() {
          //------------set data-----------//
          for (int i = 0; i < dataExpediteurs.length; i++) {
            listExpediteur.add(Expediteurs(
                serviceId: dataExpediteurs[i]["ServiceId"],
                serviceName: dataExpediteurs[i]["ServiceName"]));
          }
          for (int i = 0; i < dataSallesCourrier.length; i++) {
            listSallesCourrier.add(SallesCourrier(
                departmentId: dataSallesCourrier[i]["DepartmentId"],
                departmentName: dataSallesCourrier[i]["DepartmentName"]));
          }
          for (int i = 0; i < dataPriorities.length; i++) {
            listPriorities.add(Priorities(
                priorityId: dataPriorities[i]["PriorityId"],
                priorityName: dataPriorities[i]["PriorityName"]));
          }
        });
        //------------initialise data-----------//
        valueExpediteurs = listExpediteur[0];
        valueSallesCourrier = listSallesCourrier[0];
        valuePriorities = listPriorities[0];

        DataGlobal.valueExpediteurs = valueExpediteurs;
        DataGlobal.valueSallesCourrier = valueSallesCourrier;
        DataGlobal.valuePriorities = valuePriorities;
        DataGlobal.listExpediteur = listExpediteur;
        DataGlobal.listSallesCourrier = listSallesCourrier;
        DataGlobal.listPriorities = listPriorities;
      }
    }
  }

  Future<void> _deleteCacheDir() async {
    var tempDir = await getTemporaryDirectory();

    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }

  Future<void> deleteAppDir() async {
    var appDocDir = await getApplicationDocumentsDirectory();

    if (appDocDir.existsSync()) {
      appDocDir.deleteSync(recursive: true);
    }
  }

  @override
  void initState() {
    _deleteCacheDir();
    dbHelper = DbHelper();
    getDataglobal();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffa641),
        title: Container(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width / 2.5),
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
      body: Container(
        color: const Color(0xFFFAFAFA),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 25, left: 10),
                  //dernière activité dernière connexion
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Dernière activité        : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color.fromARGB(90, 0, 0, 0))),
                          Text(widget.lastActivite.toString(),
                              style: const TextStyle(
                                  color: Color.fromARGB(207, 243, 121, 6),
                                  fontSize: 12))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Text("Dernière connexion   : ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color.fromARGB(90, 0, 0, 0))),
                            Text(
                              widget.lastConnexion.toString(),
                              style: const TextStyle(
                                  color: Color.fromARGB(207, 243, 121, 6),
                                  fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 100),
                                child: Text('Bonjour, ',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 100),
                                child: Text(widget.firstName + "!",
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: Color.fromARGB(255, 255, 136, 0),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await availableCameras().then((value) => {
                                  Navigator.of(context).push(SlideRight(
                                      page: PageScanenvelope(
                                          value,
                                          widget.token,
                                          widget.staffId,
                                          widget.firstName,
                                          widget.lastName,
                                          widget.lastConnexion,
                                          widget.lastActivite)))
                                });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xffF37906),
                                    blurRadius: 5,
                                  )
                                ],
                                gradient: const LinearGradient(colors: [
                                  Color(0xffF37906),
                                  Color(0xffF8AC03)
                                ])),
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Icon(
                                      Icons.document_scanner,
                                      size: 32,
                                      color: Color(0XFFFCC626),
                                    ),
                                  ),
                                  Text(
                                    "Scan D'Enveloppe".toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.of(context).push(
                              SlideRight(
                                  page: PageScanqrcode(
                                      widget.staffId,
                                      widget.token,
                                      widget.firstName,
                                      widget.lastName,
                                      widget.lastConnexion,
                                      widget.lastActivite)),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
                                gradient: const LinearGradient(colors: [
                                  Color(0xffF37906),
                                  Color(0xffF8AC03)
                                ])),
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      size: 32,
                                      color: Color(0XFFFCC626),
                                    ),
                                  ),
                                  Text(
                                    "Scan code qr".toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await availableCameras().then((value) => {
                                  Navigator.of(context).push(SlideRight(
                                      page: Takepicture(
                                    value,
                                    widget.token,
                                    widget.staffId,
                                    widget.firstName,
                                    widget.lastName,
                                    widget.lastConnexion,
                                    widget.lastActivite,
                                  )))
                                });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            margin: const EdgeInsets.only(top: 40, bottom: 40),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xffF37906),
                                    blurRadius: 5,
                                  )
                                ],
                                gradient: const LinearGradient(colors: [
                                  Color(0xffF37906),
                                  Color(0xffF8AC03)
                                ])),
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Icon(Icons.rate_review,
                                        size: 32, color: Color(0XFFFCC626)),
                                  ),
                                  Text(
                                    "Saisie Manuelle".toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
