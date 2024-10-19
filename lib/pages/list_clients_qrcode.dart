import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monsiegesocial/models/clientsmap.dart';
import 'package:monsiegesocial/models/ticket.dart';
import 'package:monsiegesocial/pages/page_acceuil.dart';
import 'package:monsiegesocial/pages/page_login.dart';
import 'package:monsiegesocial/pages/page_scan_qrcode.dart';
import 'package:monsiegesocial/pages/takepictures_global.dart';
import 'package:monsiegesocial/variables/dataglobal.dart';
import 'package:monsiegesocial/variables/variables.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../Animation/animateroute.dart';
import '../Database/dbhelper.dart';

// ignore: must_be_immutable
class Listclientsqrcode extends StatefulWidget {
  final dynamic result;
  String staffId;
  String token;
  String firstName;
  String lastName;
  String lastConnexion;
  String lastActivite;

  Listclientsqrcode(this.result, this.staffId, this.token, this.firstName,
      this.lastName, this.lastConnexion, this.lastActivite,
      {Key? key})
      : super(key: key);

  @override
  _ListclientsqrcodeState createState() => _ListclientsqrcodeState();
}

class _ListclientsqrcodeState extends State<Listclientsqrcode> {
  late DbHelper dbHelper;

  // ignore: prefer_typing_uninitialized_variables
  var dataLogin;
  bool isscrolling = false;
  bool noData = false;
  final SignatureController _controllerSignature = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.black,
  );
  String allTicketselected = "";
  List<Ticket> tickets = [];
  List<Ticket> ticketsSelected = [];

  Future<File> saveImage(Uint8List signature) async {
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(signature);
    return file;
  }

  Future<bool> validateTicket(
      File fileSignature, ticketId, List listpictures) async {
    var uri = Uri.parse(url + "validate");
    Map<String, String> headers = {
      'Authorization': 'Bearer $bearerToken',
      'Token': widget.token.toString()
    };

    var request = http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);

    request.fields["staffId"] = widget.staffId;
    request.fields["ticketsId"] = ticketId;

    var picture = await http.MultipartFile.fromPath(
        "contractSignatureFile", fileSignature.path);

    for (int i = 0; i < listpictures.length; i++) {
      var pictures = await http.MultipartFile.fromPath(
          "pieceIdentite[" + i.toString() + "]", listpictures[i]);
      request.files.add(pictures);
    }

    request.files.add(picture);
    var response = await request.send();
    var responsed = await http.Response.fromStream(response);

    var result = jsonDecode(responsed.body);
    var error = result['error'];
    return error;
  }

  Future<void> getDataqrcode() async {
    ClientMap.client.clear();

    var uri = Uri.parse(url + "scan_qr");
    final httpResponse = await http.post(
      uri,
      body: {"qrCode": widget.result.toString(), "staffId": widget.staffId},
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Token': widget.token.toString()
      },
    );

    if (httpResponse.statusCode == 200) {
      var result = jsonDecode(httpResponse.body);

      if (result['error'] == false && result['message'] == "successful") {
        setState(() {
          noData = false;
        });
        final clients = result['data']['client'];
        final ticket = result['data']['tickets'];
        if (clients.isNotEmpty) {
          setState(() {
            clients.forEach(((key, value) {
              ClientMap.client.addAll({key: value});
            }));
            if (ticket.isNotEmpty) {
              for (int i = 0; i < ticket.length; i++) {
                tickets.add(
                  Ticket(
                      idTicket: int.parse(ticket[i]['ticketid']),
                      subject: ticket[i]['subject'],
                      date: ticket[i]['DateTicket'],
                      isSelected: false),
                );
              }
            }
          });
        }
      } else {
        setState(() {
          noData = true;
        });
      }
    } else {
      throw (Exception);
    }
  }

  Future<void> showDialogqrcode() async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (context, setState) {
              return WillPopScope(
                onWillPop: () async => false,
                child: Dialog(
                  insetPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (DataGlobal.listPictures.length < 2)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      "Pièce(s) d'identité:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: (() async {
                                      await availableCameras().then((value) => {
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
                                                .then((value) {
                                              Navigator.pop(context);
                                              showDialogqrcode();
                                            })
                                          });
                                    }),
                                    icon: const Icon(Icons.add_a_photo_rounded,
                                        size: 40, color: Color(0XFFEF8206)),
                                  ),
                                ),
                              ],
                            ),
                          DataGlobal.listPictures.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text("Aucun!"),
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (int i = 0;
                                            i < DataGlobal.listPictures.length;
                                            i++)
                                          if (i < 2)
                                            Padding(
                                              padding: i >= 1
                                                  ? const EdgeInsets.only(
                                                      left: 8, right: 5)
                                                  : const EdgeInsets.only(
                                                      right: 5),
                                              child: InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Center(
                                                          child:
                                                              SingleChildScrollView(
                                                            child:
                                                                InteractiveViewer(
                                                                    clipBehavior:
                                                                        Clip
                                                                            .hardEdge,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      child: Image
                                                                          .file(
                                                                        File(DataGlobal
                                                                            .listPictures[i]
                                                                            .toString()),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width: MediaQuery.of(context).size.width -
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
                                                            BorderRadius
                                                                .circular(15),
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
                                                            DataGlobal
                                                                .listPictures
                                                                .removeAt(i);
                                                          });
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
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
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Signature:",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  width: MediaQuery.of(context).size.width - 20,
                                  height: 220,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0XFFEF8206))),
                                  child: Signature(
                                    height: 220,
                                    controller: _controllerSignature,
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: (() => _controllerSignature.clear()),
                                child: const Icon(Icons.refresh,
                                    size: 35, color: Color(0XFFEF8206)),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Annuler'),
                                      child: const Text(
                                        'Annuler',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0XFFEF8206)),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Valider'),
                                    child: const Text(
                                      'Valider',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0XFFEF8206)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }));
    if (result == "Valider") {
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
      if (_controllerSignature.isNotEmpty) {
        Uint8List? signature = await _controllerSignature.toPngBytes();
        File imageFile = await saveImage(signature!);
        bool error = await validateTicket(
            imageFile,
            allTicketselected.substring(0, allTicketselected.length - 1),
            DataGlobal.listPictures);

        Navigator.pop(context);

        if (error == false) {
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
                      "Courier Livré !",
                      textAlign: TextAlign.center,
                    ),
                    contentTextStyle:
                        const TextStyle(fontSize: 18, color: Color(0xff231F20)),
                  ),
                );
              });
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
                      Icons.error,
                      color: Colors.red,
                      size: 90,
                    )),
                    content: const Text(
                      "Une erreur est survenu merci de réessayer...",
                      textAlign: TextAlign.center,
                    ),
                    contentTextStyle:
                        const TextStyle(fontSize: 18, color: Color(0xff231F20)),
                  ),
                );
              });
        }
      } else {
        Navigator.pop(context);
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
                  backgroundColor: Colors.white,
                  title: const Center(
                      child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 90,
                  )),
                  content: const Text(
                    "Veuillez signer!",
                    textAlign: TextAlign.center,
                  ),
                  contentTextStyle:
                      const TextStyle(fontSize: 18, color: Color(0xff231F20)),
                ),
              );
            });
      }
    }
  }

  @override
  void initState() {
    dbHelper = DbHelper();
    getDataqrcode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
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
      body: noData
          ? Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                child: InkWell(
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      SlideRight(
                          page: PageScanqrcode(
                        widget.staffId,
                        widget.token,
                        widget.firstName,
                        widget.lastName,
                        widget.lastConnexion,
                        widget.lastActivite,
                      )),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
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
            )
          : ClientMap.client.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber[700],
                    strokeWidth: 2,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.only(bottom: 15, top: 10),
                          decoration: const BoxDecoration(
                              color: Color(0xffffa641),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xffffa641), blurRadius: 10)
                              ]),
                          child: ListTile(
                              title: Text(
                                ClientMap.client.values.elementAt(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xff231F20)),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 2;
                                      i < ClientMap.client.length;
                                      i++)
                                    if (ClientMap.client.values.elementAt(i) !=
                                        "")
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Row(
                                          children: [
                                            Text(
                                                "${ClientMap.client.keys.elementAt(i)}: ",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xff231F20))),
                                            Expanded(
                                              child: Text(
                                                "${ClientMap.client.values.elementAt(i)}",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    color: Color(0xFF012F47)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                ],
                              ))),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(30),
                              child: Center(
                                child: Text(
                                  "Tickets".toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            tickets.isNotEmpty
                                ? Expanded(
                                    child: ListView.builder(
                                        itemCount: tickets.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 30),
                                            child: ListTile(
                                              onTap: () {
                                                setState(() {
                                                  tickets[index].isSelected =
                                                      !tickets[index]
                                                          .isSelected;
                                                  if (tickets[index]
                                                          .isSelected ==
                                                      true) {
                                                    ticketsSelected.add(Ticket(
                                                      idTicket: tickets[index]
                                                          .idTicket,
                                                      subject: tickets[index]
                                                          .subject,
                                                      date: tickets[index].date,
                                                      isSelected: true,
                                                    ));
                                                  } else if (tickets[index]
                                                          .isSelected ==
                                                      false) {
                                                    ticketsSelected.removeWhere(
                                                        (element) =>
                                                            element.idTicket ==
                                                            tickets[index]
                                                                .idTicket);
                                                  }
                                                });
                                              },
                                              trailing: tickets[index]
                                                      .isSelected
                                                  ? const Icon(
                                                      Icons.check_circle,
                                                      color: Color(0xffFE6D00))
                                                  : const Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: Colors.grey),
                                              title: Text(
                                                tickets[index].getDate,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              leading: const Icon(
                                                Icons.description,
                                                size: 30,
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                      "Subject:",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 5.0,
                                                        bottom: tickets.length -
                                                                    1 ==
                                                                index
                                                            ? 30
                                                            : 0),
                                                    child: Text(
                                                        tickets[index]
                                                            .getSubject,
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xffFE6D00))),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }))
                                : Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const Center(
                                              child: Text("Aucun Ticket")),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 40, horizontal: 30),
                                            child: InkWell(
                                              onTap: () async {
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    SlideRight(
                                                        page: PageScanqrcode(
                                                      widget.staffId,
                                                      widget.token,
                                                      widget.firstName,
                                                      widget.lastName,
                                                      widget.lastConnexion,
                                                      widget.lastActivite,
                                                    )),
                                                    (route) => false);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 15,
                                                ),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0xffF37906),
                                                        blurRadius: 5,
                                                      )
                                                    ],
                                                    gradient:
                                                        const LinearGradient(
                                                            colors: [
                                                          Color(0xffF37906),
                                                          Color(0xffF8AC03)
                                                        ])),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 15),
                                                        child: Icon(
                                                          Icons.refresh,
                                                          size: 32,
                                                          color:
                                                              Color(0XFFFCC626),
                                                        ),
                                                      ),
                                                      Text(
                                                        "RÉESSAYER"
                                                            .toUpperCase(),
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
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30),
                                            child: InkWell(
                                              onTap: () async {
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
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 15,
                                                ),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0xffF37906),
                                                        blurRadius: 5,
                                                      )
                                                    ],
                                                    gradient:
                                                        const LinearGradient(
                                                            colors: [
                                                          Color(0xffF37906),
                                                          Color(0xffF8AC03)
                                                        ])),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 15),
                                                        child: Icon(
                                                          Icons.arrow_back,
                                                          size: 32,
                                                          color:
                                                              Color(0XFFFCC626),
                                                        ),
                                                      ),
                                                      Text(
                                                        "Revenir à l'accueil"
                                                            .toUpperCase(),
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
                                    ),
                                  ),
                            ticketsSelected.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 30),
                                    child: TextButton(
                                        onPressed: () async {
                                          for (int i = 0;
                                              i < ticketsSelected.length;
                                              i++) {
                                            allTicketselected +=
                                                ticketsSelected[i]
                                                        .idTicket
                                                        .toString() +
                                                    ",";
                                          }

                                          await showDialogqrcode();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 60),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xffF37906),
                                                  Color(0xffF8AC03)
                                                ]),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Color(0xffF37906),
                                                  blurRadius: 5)
                                            ],
                                            color: Colors.amber[700],
                                          ),
                                          child: const Text(
                                            "Clôturer",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )))
                                : const Text(""),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
