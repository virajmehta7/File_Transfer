import 'dart:io';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class Share extends StatefulWidget {
  final username;
  const Share({Key? key, this.username}) : super(key: key);

  @override
  _ShareState createState() => _ShareState();
}

class _ShareState extends State<Share> {

  final Strategy strategy = Strategy.P2P_STAR;
  var crypt = AesCrypt('cool password');

  String cId = "0";
  String? tempFileUri;
  String? encFilepath,aesFilepath,directory,decFilepath;

  Map<int, String> map = Map();
  Map<String, ConnectionInfo> endpointMap = Map();

  permissions() async {
    await [
      Permission.storage,
      Permission.location,
    ].request();
    await Nearby().enableLocationServices();
  }

  @override
  void initState() {
    super.initState();
    permissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ]
              )
          ),
        ),
        title: Text('File Transfer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text('Share everything',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w300, color: Colors.black)
              ),
              Text('For everyone',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w300, color: Colors.black)
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      primary: Color(0xFF667eea),
                      elevation: 2,
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.17,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 30.0,left: 15.0),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.white,
                                  image: DecorationImage(image: AssetImage('assets/sendArrow.jpeg')),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 18.0,
                                      spreadRadius: 1.0,
                                      offset: Offset(6,7),
                                    )
                                  ]
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15.0,top: 80.0),
                            child: Text('Send',
                                style: TextStyle(fontSize: 20.0, fontFamily: 'Comfortaa', color: Colors.black)
                            ),
                          )
                        ],
                      ),
                    ),
                    onPressed: () async {
                      if (await Permission.location.isGranted && await Nearby().enableLocationServices() && await Permission.storage.isGranted) {
                        // setState(() {
                        //   pressed = true;
                        // });
                        try {
                          bool a = await Nearby().startDiscovery(
                            widget.username,
                            strategy,
                            onEndpointFound: (id, name, serviceId) {
                              // show sheet automatically to request connection
                              showModalBottomSheet(
                                context: context,
                                builder: (builder) {
                                  return Center(
                                    child: Column(
                                      children: <Widget>[
                                        Text("id: " + id),
                                        Text("Name: " + name),
                                        Text("ServiceId: " + serviceId),
                                        ElevatedButton(
                                          child: Text("Request Connection"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Nearby().requestConnection(
                                              widget.username,
                                              id,
                                              onConnectionInitiated: (id, info) {
                                                onConnectionInit(id, info);
                                              },
                                              onConnectionResult: (id, status) {
                                                showSnackbar(status);
                                              },
                                              onDisconnected: (id) {
                                                setState(() {
                                                  endpointMap.remove(id);
                                                });
                                                showSnackbar(
                                                    "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            onEndpointLost: (id) {
                              showSnackbar(
                                  "Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id");
                            },
                          );
                          showSnackbar("DISCOVERING: " + a.toString());
                        } catch (e) {
                          showSnackbar(e);
                        }
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      primary: Color(0xFF764ba2),
                      elevation: 2,
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.17,
                      width: MediaQuery.of(context).size.width * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0,left: 15.0),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: AssetImage('assets/receiveArrow.jpeg'),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 18.0, // soften the shadow
                                      spreadRadius: 1.0, //extend the shadow
                                      offset: Offset(6.0,7.0),
                                    )
                                  ]
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0,top: 80.0),
                            child: Text('Receive',
                                style: TextStyle(fontSize: 20.0, fontFamily: 'Comfortaa', color: Colors.black)
                            ),
                          )
                        ],
                      ),
                    ),
                    onPressed: () async {
                      if (await Permission.location.isGranted && await Nearby().enableLocationServices() && await Permission.storage.isGranted) {
                        // setState(() {
                        //   pressed = false;
                        // });
                        try {
                          bool a = await Nearby().startAdvertising(
                            widget.username,
                            strategy,
                            onConnectionInitiated: onConnectionInit,
                            onConnectionResult: (id, status) {
                              showSnackbar(status);
                            },
                            onDisconnected: (id) {
                              showSnackbar(
                                  "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
                              setState(() {
                                endpointMap.remove(id);
                              });
                            },
                          );
                          showSnackbar("ADVERTISING: " + a.toString());
                        } catch (exception) {
                          showSnackbar(exception);
                        }
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              // if (pressed)
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {

                        FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any);

                        if (result == null) return;

                        result.files.forEach((element) async {
                          encFilepath = element.path;
                          crypt.setOverwriteMode(AesCryptOwMode.on);
                          try {
                            aesFilepath = await crypt.encryptFile(encFilepath).then((value) async {
                              for (MapEntry<String, ConnectionInfo> m
                              in endpointMap.entries) {
                                int payloadId =
                                    await Nearby().sendFilePayload(m.key, value);
                                showSnackbar("Sending file to ${m.key}");
                                Nearby().sendBytesPayload(
                                    m.key,
                                    Uint8List.fromList(
                                        "$payloadId:${value.split('/').last}".codeUnits));
                              }
                            });
                          } catch(e) {
                            print(e);
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 150,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[Color(0xFF667eea), Color(0xFF764ba2)]
                            )
                        ),
                        child: Text("Send File",
                            style: TextStyle(fontSize: 20.0, fontFamily: 'Comfortaa', color: Colors.white)
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {

                        var file =  await ImagePicker().pickImage(source: ImageSource.camera);

                        encFilepath = file!.path;
                        crypt.setOverwriteMode(AesCryptOwMode.on);
                        try {
                          aesFilepath = await crypt.encryptFile(encFilepath).then((value) async {
                            for (MapEntry<String, ConnectionInfo> m
                            in endpointMap.entries) {
                              int payloadId =
                              await Nearby().sendFilePayload(m.key, value);
                              showSnackbar("Sending file to ${m.key}");
                              Nearby().sendBytesPayload(
                                  m.key,
                                  Uint8List.fromList(
                                      "$payloadId:${value.split('/').last}".codeUnits));
                            }
                          });
                        } catch(e) {
                          print(e);
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 250,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[Color(0xFF667eea), Color(0xFF764ba2)]
                            )
                        ),
                        child: Text("Send from Camera",
                            style: TextStyle(fontSize: 20.0, fontFamily: 'Comfortaa', color: Colors.white)
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  Future<bool> moveFile(String uri, String fileName) async {
    String parentDir = '/storage/emulated/0/Download';


    final b =
    await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');

    showSnackbar("Moved file:" + b.toString());
    await decrypt(parentDir, fileName);
    return b;
  }

  Future decrypt(parentDir, fileName) async {

    var file = parentDir + '/' + fileName;

      crypt.setOverwriteMode(AesCryptOwMode.on);
      try {
        decFilepath = parentDir;
        decFilepath = await crypt.decryptFile(file);
        deleteFile(File(file));
      } catch (e) {
        print(e);
      }
  }

  List<FileSystemEntity> ?files;

  deleteFile(File file) async {

    Directory dir = Directory('/storage/emulated/0/Download');
    setState(() {
      files = dir.listSync(recursive: true, followLinks: false);
      for(FileSystemEntity entity in files!) {
        String path = entity.path;
        if(path.endsWith('.aes'))
          File(path).delete();
      }
    });


    // try {
    //   if (await file.exists()) {
    //     await file.delete();
    //     print('deleted');
    //   }
    // } catch (e) {
    //   print(e);
    // }
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Token: " + info.authenticationToken),
              Text("Name" + info.endpointName),
              ElevatedButton(
                child: Text("Accept Connection"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    endpointMap[id] = info;
                  });
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                      if (payload.type == PayloadType.BYTES) {
                        String str = String.fromCharCodes(payload.bytes!);
                        showSnackbar(endid + ": " + str);

                        if (str.contains(':')) {
                          // used for file payload as file payload is mapped as
                          // payloadId:filename
                          int payloadId = int.parse(str.split(':')[0]);
                          String fileName = (str.split(':')[1]);

                          if (map.containsKey(payloadId)) {
                            if (tempFileUri != null) {
                              moveFile(tempFileUri!, fileName);
                            } else {
                              showSnackbar("File doesn't exist");
                            }
                          } else {
                            //add to map if not already
                            map[payloadId] = fileName;
                          }
                        }
                      } else if (payload.type == PayloadType.FILE) {
                        showSnackbar(endid + ": File transfer started");
                        tempFileUri = payload.uri;
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status ==
                          PayloadStatus.IN_PROGRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.FAILURE) {
                        print("failed");
                        showSnackbar(endid + ": FAILED to transfer file");
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.SUCCESS) {
                        showSnackbar(
                            "$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");

                        if (map.containsKey(payloadTransferUpdate.id)) {
                          //rename the file now
                          String name = map[payloadTransferUpdate.id]!;
                          moveFile(tempFileUri!, name);
                        } else {
                          //bytes not received till yet
                          map[payloadTransferUpdate.id] = "";
                        }
                      }
                    },
                  );
                },
              ),
              ElevatedButton(
                child: Text("Reject Connection"),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}




//
//
// flutter build apk --release --no-sound-null-safety
//
//