import 'dart:io';

import 'package:flutter/material.dart';
import 'package:monsiegesocial/Animation/animateroute.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../variables/dataglobal.dart';
import 'list_clients_qrcode.dart';

// ignore: must_be_immutable
class PageScanqrcode extends StatefulWidget {
  String token;
  String staffId;
  String firstName;
  String lastName;
  String lastConnexion;
  String lastActivite;
  PageScanqrcode(
    this.staffId,
    this.token,
    this.firstName,
    this.lastName,
    this.lastConnexion,
    this.lastActivite, {
    Key? key,
  }) : super(key: key);

  @override
  _PageScanqrcodeState createState() => _PageScanqrcodeState();
}

class _PageScanqrcodeState extends State<PageScanqrcode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;

  QRViewController? qrviewcontroller;

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrviewcontroller = controller;
    });

    controller.scannedDataStream.listen((Barcode scanData) {
      setState(() {
        result = scanData;
      });
      if (result != null && result?.code != "") {
        qrviewcontroller?.stopCamera();
        DataGlobal.listPictures.clear();
        Navigator.pushReplacement(
          context,
          SlideRight(
              page: Listclientsqrcode(
                  result?.code,
                  widget.staffId,
                  widget.token,
                  widget.firstName,
                  widget.lastName,
                  widget.lastConnexion,
                  widget.lastActivite)),
        );
        qrviewcontroller?.resumeCamera();
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrviewcontroller!.pauseCamera();
    } else if (Platform.isIOS) {
      qrviewcontroller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    qrviewcontroller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  borderColor: const Color(0xFFF37906),
                  borderWidth: 4,
                  borderRadius: 10,
                  cutOutSize: MediaQuery.of(context).size.width * 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
