import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:monsiegesocial/Animation/animateroute.dart';
import 'package:monsiegesocial/Database/dbhelper.dart';
import 'package:monsiegesocial/pages/page_acceuil.dart';
import 'package:monsiegesocial/pages/page_login.dart';
import 'package:http/http.dart' as http;
import 'package:monsiegesocial/pages/takepictures_global.dart';
import 'package:monsiegesocial/variables/dataglobal.dart';
import 'package:monsiegesocial/variables/expediteurs_list.dart';
import 'package:monsiegesocial/variables/salles_courrier_list.dart';
import 'package:monsiegesocial/variables/variables.dart';
import '../models/user.dart';
import 'entry_manually.dart';

// ignore: must_be_immutable
class ListClient extends StatefulWidget {
  String ocrText;
  String entryText;
  String token;
  String staffId;
  String imageTest;
  String firstName;
  String lastName;
  String lastConnexion;
  String lastActivite;

  ListClient(
      this.ocrText,
      this.entryText,
      this.token,
      this.staffId,
      this.imageTest,
      this.firstName,
      this.lastName,
      this.lastConnexion,
      this.lastActivite,
      {Key? key})
      : super(key: key);

  @override
  _ListClientState createState() => _ListClientState();
}

class _ListClientState extends State<ListClient> {
  int? selectedItem;

  late DbHelper dbHelper;
  static List listclient = [];
  bool iswaiting = true;
  List clients = [];
  bool isError = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController message = TextEditingController();
  String expediteurValue = "";
  String prioriteValue = "5";
  int indiceGroupe = 0;

  Future<List<User>> getData() async {
    final data = await dbHelper.getdata();
    return data;
  }

  Future<void> sendOcrtext() async {
    var uri = Uri.parse(url + "search");
    if (widget.ocrText != "") {
      final httpResponse = await http.post(uri, headers: <String, String>{
        'Authorization': 'Bearer $bearerToken',
        'Token': widget.token
      }, body: {
        'staffId': widget.staffId,
        'searchText': widget.ocrText,
        'isOcr': 'true'
      });
      if (httpResponse.statusCode == 200) {
        var result = jsonDecode(httpResponse.body);

        if (result['error'] == false && result['message'] == "successful") {
          clients = result['data']['clients'];
          if (clients.isNotEmpty) {
            for (int i = 0; i < clients.length; i++) {
              listclient.add(clients[i]);
            }
            setState(() {
              iswaiting = false;
            });
          }
        } else {
          setState(() {
            iswaiting = false;
          });
        }
      }
    }
  }

  Future<void> sendbyentry() async {
    var uri = Uri.parse(url + "search");
    if (widget.entryText != "") {
      final httpResponse = await http.post(uri, headers: <String, String>{
        'Authorization': 'Bearer $bearerToken',
        'Token': widget.token
      }, body: {
        'staffId': widget.staffId,
        'searchText': widget.entryText,
        'isOcr': 'false'
      });

      if (httpResponse.statusCode == 200) {
        var result = jsonDecode(httpResponse.body);

        if (result['error'] == false && result['message'] == "successful") {
          clients = result['data']['clients'];

          if (clients.isNotEmpty) {
            for (int i = 0; i < clients.length; i++) {
              listclient.add(clients[i]);
            }
            setState(() {
              iswaiting = false;
            });
          }
        } else {
          setState(() {
            iswaiting = false;
          });
        }
      }
    }
  }

  Future<bool> createTicket(
      clientId,
      Expediteurs expediteurValue,
      SallesCourrier sallecourrier,
      prioriteValue,
      List listpictures,
      message) async {
    if (prioriteValue.toString().isNotEmpty &&
        sallecourrier.departmentId != "" &&
        listpictures.isNotEmpty) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                  content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.amber[700],
                    strokeWidth: 2,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 5),
                    child: Text(
                      'Veuillez patienter ...',
                      style: TextStyle(fontSize: 15),
                    ),
                  )
                ],
              )),
            );
          });

      var uri = Uri.parse(url + "create_ticket");
      Map<String, String> headers = {
        'Authorization': 'Bearer $bearerToken',
        'Token': widget.token
      };

      var request = http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["companyId"] = clientId.toString();
      request.fields["staffId"] = widget.staffId;
      request.fields["serviceId"] = expediteurValue.serviceId;
      //request.fields["departmentId"] = sallecourrier.departmentId;
      request.fields["priorityId"] = prioriteValue;
      request.fields["staffMessage"] = message;

      for (int i = 0; i < listpictures.length; i++) {
        var pic = await http.MultipartFile.fromPath(
            "attachments[" + i.toString() + "]", listpictures[i]);
        request.files.add(pic);
      }

      var response = await request.send();
      var responsed = await http.Response.fromStream(response);
      var result = jsonDecode(responsed.body);

      bool error = result["error"];
      if (!error) {
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.of(context).pop(true);
              });
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: const Center(
                      child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF77AE46),
                    size: 90,
                  )),
                  content: const Text(
                    "Message envoyé au client avec succès.",
                    textAlign: TextAlign.center,
                  ),
                  contentTextStyle:
                      const TextStyle(fontSize: 18, color: Color(0xff231F20)),
                ),
              );
            });
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
            context,
            SlideRight(
                page: PageAccueil(
              widget.token,
              widget.staffId,
              widget.firstName,
              widget.lastName,
              widget.lastActivite,
              widget.lastConnexion,
            )),
            (route) => false);
      }
    } else {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).pop(true);
            });
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: const Center(
                    child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 90,
                )),
                content: const Text(
                  "Les champs (*) sonts obligatoires!",
                  textAlign: TextAlign.center,
                ),
                contentTextStyle:
                    const TextStyle(fontSize: 18, color: Color(0xff231F20)),
              ),
            );
          });
    }
    return isError;
  }

  Future<void> showDialogglobal() async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(0),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: (() async {
                                  await availableCameras().then((value) => {
                                        Navigator.pop(context),
                                        Navigator.of(context)
                                            .push(SlideRight(
                                                page: TakePictures(
                                              value,
                                              widget.token,
                                              widget.staffId,
                                              widget.firstName,
                                              widget.lastName,
                                              widget.lastConnexion,
                                              widget.lastActivite,
                                            )))
                                            .then((value) => showDialogglobal())
                                      });
                                }),
                                icon: const Icon(Icons.add_a_photo_rounded,
                                    size: 40, color: Color(0XFFEF8206)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (int i = 0;
                                        i < DataGlobal.listPictures.length;
                                        i++)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Center(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: InteractiveViewer(
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            child: Image.file(
                                                              File(DataGlobal
                                                                  .listPictures[
                                                                      i]
                                                                  .toString()),
                                                              fit: BoxFit.cover,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  50,
                                                            ),
                                                          )),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              SizedBox(
                                                width: 130,
                                                height: 130,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Image.file(
                                                    File(DataGlobal
                                                        .listPictures[i]
                                                        .toString()),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      DataGlobal.listPictures
                                                          .removeAt(i);
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                    child: const Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.white,
                                                      size: 25,
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /*   Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    child: DropdownButtonFormField<Priorities>(
                                      decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 10),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none)),
                                      value: DataGlobal.valuePriorities,
                                      onChanged: (Priorities? newValue) {
                                        setState(() {
                                          DataGlobal.valuePriorities = newValue!;
                                        });
                                      },
                                      items: DataGlobal.listPriorities
                                          .map<DropdownMenuItem<Priorities>>(
                                              (value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value.priorityName,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),*/
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 5),
                                        child: Text(
                                          "Type".toUpperCase(),
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 29, 17, 3),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 5, left: 3),
                                        child: Text(
                                          "(*)".toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (indiceGroupe = 0;
                                              indiceGroupe <
                                                  DataGlobal.listPriorities
                                                          .length /
                                                      2;
                                              indiceGroupe++)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 45,
                                                  child: Radio(
                                                      activeColor:
                                                          const Color.fromARGB(
                                                              255, 29, 17, 3),
                                                      value: DataGlobal
                                                          .listPriorities[
                                                              indiceGroupe]
                                                          .priorityId
                                                          .toString(),
                                                      groupValue: prioriteValue,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          prioriteValue =
                                                              value!;
                                                        });
                                                      }),
                                                ),
                                                Text(DataGlobal
                                                    .listPriorities[
                                                        indiceGroupe]
                                                    .priorityName)
                                              ],
                                            ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int i = indiceGroupe;
                                              i <
                                                  DataGlobal
                                                      .listPriorities.length;
                                              i++)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 45,
                                                  child: Radio(
                                                      activeColor:
                                                          const Color.fromARGB(
                                                              255, 29, 17, 3),
                                                      value: DataGlobal
                                                          .listPriorities[i]
                                                          .priorityId
                                                          .toString(),
                                                      groupValue: prioriteValue,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          prioriteValue =
                                                              value!;
                                                        });
                                                      }),
                                                ),
                                                Text(DataGlobal
                                                    .listPriorities[i]
                                                    .priorityName)
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  /*
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (indiceGroupe = 0;
                                              indiceGroupe <
                                                  (DataGlobal
                                                          .listExpediteur.length /
                                                      2);
                                              indiceGroupe++)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 35,
                                                  child: Radio(
                                                      activeColor:
                                                          const Color.fromARGB(
                                                              255, 29, 17, 3),
                                                      value: DataGlobal
                                                          .listExpediteur[
                                                              indiceGroupe]
                                                          .serviceId
                                                          .toString(),
                                                      groupValue: expediteurValue,
                                                      onChanged: (String? value) {
                                                        setState(() {
                                                          expediteurValue =
                                                              value!;
                                                        });
                                                      }),
                                                ),
                                                Text(DataGlobal
                                                    .listExpediteur[indiceGroupe]
                                                    .serviceName)
                                              ],
                                            ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int i = indiceGroupe;
                                              i <
                                                  DataGlobal
                                                      .listExpediteur.length;
                                              i++)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 35,
                                                  child: Radio(
                                                      activeColor:
                                                          const Color.fromARGB(
                                                              255, 29, 17, 3),
                                                      value: DataGlobal
                                                          .listExpediteur[i]
                                                          .serviceId
                                                          .toString(),
                                                      groupValue: expediteurValue,
                                                      onChanged: (String? value) {
                                                        setState(() {
                                                          expediteurValue =
                                                              value!;
                                                        });
                                                      }),
                                                ),
                                                Text(DataGlobal.listExpediteur[i]
                                                    .serviceName)
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  */

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15, bottom: 5),
                                    child: Text(
                                      "Message".toUpperCase(),
                                      style: const TextStyle(
                                          color: Color.fromARGB(255, 29, 17, 3),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Material(
                                    color: const Color.fromARGB(
                                        255, 223, 223, 223),
                                    borderRadius: BorderRadius.circular(5),
                                    child: TextFormField(
                                      controller: message,
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 10),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5, top: 20),
                                    child: Text(
                                      "Groupe".toUpperCase(),
                                      style: const TextStyle(
                                          color: Color.fromARGB(255, 29, 17, 3),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Material(
                                    color: const Color.fromARGB(
                                        255, 223, 223, 223),
                                    borderRadius: BorderRadius.circular(5),
                                    child: DropdownButtonFormField<Expediteurs>(
                                      decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 10),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide.none)),
                                      value: DataGlobal.valueExpediteurs,
                                      onChanged: (Expediteurs? newValue) {
                                        setState(() {
                                          DataGlobal.valueExpediteurs =
                                              newValue!;
                                        });
                                      },
                                      items: DataGlobal.listExpediteur
                                          .map<DropdownMenuItem<Expediteurs>>(
                                              (value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value.serviceName,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),

                                  /*                              Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 5),
                                          child: Text(
                                            "SALLE DE COURRIER".toUpperCase(),
                                            style: const TextStyle(
                                                color: Color.fromARGB(255, 29, 17, 3),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 5, left: 3),
                                          child: Text(
                                            "(*)".toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Material(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      child: DropdownButtonFormField<SallesCourrier>(
                                        decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 12, horizontal: 10),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                borderSide: BorderSide.none)),
                                        value: DataGlobal.valueSallesCourrier,
                                        onChanged: (SallesCourrier? newValue) {
                                          setState(() {
                                            DataGlobal.valueSallesCourrier =
                                                newValue!;
                                          });
                                        },
                                        items: DataGlobal.listSallesCourrier
                                            .map<DropdownMenuItem<SallesCourrier>>(
                                                (value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                              value.departmentName,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                       */

                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          final result = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  WillPopScope(
                                                    onWillPop: () async =>
                                                        false,
                                                    child: AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              243,
                                                              195,
                                                              150),
                                                      title: const Center(
                                                          child: Icon(
                                                        Icons.warning,
                                                        color: Colors.red,
                                                        size: 90,
                                                      )),
                                                      content: const Text(
                                                        "Êtes-vous sure de bien vouloir envoyer le ticket?",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      contentTextStyle:
                                                          const TextStyle(
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xff231F20)),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  'Non'),
                                                          child: const Text(
                                                            'Non',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0XFFEF8206)),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  'Oui'),
                                                          child: const Text(
                                                            'Oui',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0XFFEF8206)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ));

                                          if (result == "Oui") {
                                            await createTicket(
                                                listclient[selectedItem!]
                                                    .values
                                                    .elementAt(0),
                                                DataGlobal.valueExpediteurs,
                                                DataGlobal.valueSallesCourrier,
                                                prioriteValue,
                                                DataGlobal.listPictures,
                                                message.text);
                                          }
                                        },
                                        child: Container(
                                            width: double.infinity,
                                            margin:
                                                const EdgeInsets.only(top: 15),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 30),
                                            decoration: BoxDecoration(
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0XFFEF8206),
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              "Valider".toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            )),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final result = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  WillPopScope(
                                                    onWillPop: () async =>
                                                        false,
                                                    child: AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              243,
                                                              195,
                                                              150),
                                                      title: const Center(
                                                          child: Icon(
                                                        Icons.warning,
                                                        color: Colors.red,
                                                        size: 90,
                                                      )),
                                                      content: const Text(
                                                        "Voulez-vous vraiment quitter?",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      contentTextStyle:
                                                          const TextStyle(
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xff231F20)),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  'Non'),
                                                          child: const Text(
                                                            'Non',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0XFFEF8206)),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  'Oui'),
                                                          child: const Text(
                                                            'Oui',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0XFFEF8206)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ));

                                          if (result == "Oui") {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 25),
                                            decoration: BoxDecoration(
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0XFFEF8206),
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              "Annuler".toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  void initState() {
    dbHelper = DbHelper();
    listclient.clear();
    if (widget.ocrText != "") {
      sendOcrtext();
    } else if (widget.entryText != "") {
      sendbyentry();
    } else {
      setState(() {
        iswaiting = false;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffa641),
        title: Container(
          alignment: Alignment.center,
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
      body: iswaiting == true
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.amber[700],
                strokeWidth: 2,
              ),
            )
          : listclient.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          Navigator.pushReplacement(
                            context,
                            SlideRight(
                                page: Entrymanually(
                                    widget.token,
                                    widget.staffId,
                                    widget.firstName,
                                    widget.lastName,
                                    widget.lastConnexion,
                                    widget.lastActivite,
                                    widget.imageTest)),
                          );
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
                                    Icons.rate_review,
                                    size: 32,
                                    color: Color(0XFFFCC626),
                                  ),
                                ),
                                Text(
                                  "SAISIE MANUELLE".toUpperCase(),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(context);
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
                                      Icons.refresh,
                                      size: 32,
                                      color: Color(0XFFFCC626),
                                    ),
                                  ),
                                  Text(
                                    "RÉESSAYER".toUpperCase(),
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
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: listclient.length,
                          itemBuilder: (context, index) {
                            return Container(
                                padding:
                                    const EdgeInsets.only(bottom: 15, top: 10),
                                child: ListTile(
                                  onTap: () async {
                                    setState(() {
                                      selectedItem = index;
                                    });
                                    showDialogglobal();
                                  },
                                  trailing: selectedItem == index
                                      ? const Icon(Icons.check_circle,
                                          color: Color(0xffFE6D00))
                                      : const Icon(Icons.check_circle_outline,
                                          color: Colors.grey),
                                  title: Text(
                                    listclient[index].values.elementAt(1),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xff231F20)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 3;
                                          i < listclient[index].length;
                                          i++)
                                        if (listclient[index]
                                                .values
                                                .elementAt(i) !=
                                            "")
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              children: [
                                                Text(
                                                    "${listclient[index].keys.elementAt(i)} : ",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff231F20))),
                                                Expanded(
                                                  child: Text(
                                                    "${listclient[index].values.elementAt(i)}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xffFE6D00)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ],
                                  ),
                                ));
                          }),
                    ),
                  ],
                ),
    );
  }
}
