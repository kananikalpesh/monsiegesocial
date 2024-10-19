import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:monsiegesocial/pages/page_acceuil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../variables/dataglobal.dart';

// ignore: must_be_immutable
class TakePictures extends StatefulWidget {
  final List<CameraDescription>? cameras;
  String token;
  String staffId;
  String firstName;
  String lastName;
  String lastConnexion;
  String lastActivite;

  TakePictures(
    this.cameras,
    this.token,
    this.staffId,
    this.firstName,
    this.lastName,
    this.lastConnexion,
    this.lastActivite, {
    Key? key,
  }) : super(key: key);

  @override
  _TakePicturesState createState() => _TakePicturesState();
}

class _TakePicturesState extends State<TakePictures> {
  late CameraController cameracontroller =
      CameraController(widget.cameras![0], ResolutionPreset.veryHigh);

  XFile? filepicture;

  bool flashturn = false;
  Permission permissionCamera = Permission.camera;
  Permission permissionaudio = Permission.microphone;
  Permission permissionstorage = Permission.manageExternalStorage;

  Future scanImage(filepicture) async {
    DataGlobal.listPictures.add(filepicture);
    Navigator.pop(context);
  }

  Future<void> permession() async {
    await permissionCamera.request();
    await permissionaudio.request();
    await permissionstorage.request();
    if (await permissionCamera.isPermanentlyDenied == true ||
        await permissionCamera.isDenied == true ||
        await permissionCamera.isRestricted == true ||
        await permissionaudio.isPermanentlyDenied == true ||
        await permissionaudio.isDenied == true ||
        await permissionaudio.isRestricted == true) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                actionsAlignment: MainAxisAlignment.end,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                actions: [
                  TextButton(
                      onPressed: () async {
                        openAppSettings();
                      },
                      child: const Text(
                        "Paramètre",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF48705)),
                      )),
                  TextButton(
                      onPressed: () async {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PageAccueil(
                                      widget.token,
                                      widget.staffId,
                                      widget.firstName,
                                      widget.lastName,
                                      widget.lastActivite,
                                      widget.lastConnexion,
                                    )),
                            (route) => false);
                      },
                      child: const Text(
                        "Annuler",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF48705)),
                      ))
                ],
                title: const Center(
                    child: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 90,
                )),
                content: const Text(
                  "Autoriser l'application à utiliser l'appareil photo!",
                  textAlign: TextAlign.center,
                ),
                contentTextStyle:
                    const TextStyle(fontSize: 18, color: Color(0xff231F20)),
              ),
            );
          });
    } else {
      cameracontroller =
          CameraController(widget.cameras![0], ResolutionPreset.veryHigh);
      cameracontroller.initialize().then((_) {
        if (!mounted) {
          return;
        }

        setState(() {});
      });
    }
  }

  @override
  void initState() {
    permession();
    super.initState();
  }

  @override
  void dispose() {
    cameracontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !cameracontroller.value.isInitialized
            ? Container(
                color: const Color(0xffF37906),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CameraPreview(
                  cameracontroller,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                            onPressed: () async {
                              if (flashturn) {
                                cameracontroller.setFlashMode(FlashMode.torch);
                                cameracontroller.setFocusMode(FocusMode.auto);
                              } else {
                                cameracontroller.setFlashMode(FlashMode.off);
                              }

                              filepicture =
                                  await cameracontroller.takePicture();
                              await scanImage(filepicture!.path);
                              cameracontroller.setFlashMode(FlashMode.off);
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 90),
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
                                child: Text(
                                  "Capture".toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                )),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, top: 30),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                              onPressed: () async {
                                if (flashturn) {
                                  cameracontroller.setFlashMode(FlashMode.off);
                                  flashturn = false;
                                  setState(() {});
                                } else {
                                  flashturn = true;
                                  setState(() {});
                                }
                              },
                              child: flashturn
                                  ? const Icon(
                                      Icons.flash_on,
                                      color: Color(0xFFF48705),
                                      size: 28,
                                    )
                                  : const Icon(
                                      Icons.flash_off_rounded,
                                      color: Color(0xFFF48705),
                                      size: 28,
                                    )),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}
