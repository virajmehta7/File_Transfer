import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class Send extends StatefulWidget {
  final String userName;
  Send({@required this.userName});
  @override
  _SendState createState() => _SendState(
      userName1:userName
  );
}

class _SendState extends State<Send> {
  final String userName1;
  _SendState({@required this.userName1});

  final Strategy strategy = Strategy.P2P_STAR;
  String cId = "0";
  File tempFile;
  Map<int, String> map = Map();
  bool pressed = false, pressedRec = false;
  int index;
  String encFilepath,aesFilepath,directory,decFilepath;
  var crypt = AesCrypt('cool password');
  // ignore: deprecated_member_use
  List file = new List();
  List data;

  permissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.location,
    ].request();
    await Nearby().enableLocationServices();
    print(statuses);
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Text("Token: " + info.authenticationToken,
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Comfortaa', color: Colors.black)
              ),
              Text("Username: " + info.endpointName,
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Comfortaa', color: Colors.black)
              ),
              SizedBox(
                height: 40.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF764ba2),
                ),
                child: Text("Accept Connection",
                    style: TextStyle(fontSize: 15.0, fontFamily: 'Comfortaa', color: Colors.white)
                ),
                onPressed: () {
                  Navigator.pop(context);
                  cId = id;
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                      if (payload.type == PayloadType.BYTES) {
                        String str = String.fromCharCodes(payload.bytes);
                        showSnackbar(endid + ": " + str);

                        if (str.contains(':')) {
                          int payloadId = int.parse(str.split(':')[0]);
                          String fileName = (str.split(':')[1]);

                          if (map.containsKey(payloadId)) {
                            if (await tempFile.exists()) {
                              tempFile.rename(
                                  tempFile.parent.path + "/" + fileName);
                            } else {
                              showSnackbar("File doesn't exist");
                            }
                          } else {
                            map[payloadId] = fileName;
                          }
                        }
                      }
                      else if (payload.type == PayloadType.FILE) {
                        showSnackbar("File transfer started");
                        tempFile = File(payload.uri);
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status == PayloadStatus.IN_PROGRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else {
                        if (payloadTransferUpdate.status == PayloadStatus.SUCCESS) {
                          showSnackbar("Success");
                          if (map.containsKey(payloadTransferUpdate.id)) {
                            String name = map[payloadTransferUpdate.id];
                            tempFile.rename(tempFile.parent.path + "/" + name);
                          } else {
                            map[payloadTransferUpdate.id] = "";
                          }
                        } else if (payloadTransferUpdate.status == PayloadStatus.FAILURE) {
                          showSnackbar("Failed to transfer file");
                        }
                      }
                    },
                  );
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF764ba2),
                ),
                child: Text("Reject Connection",
                    style: TextStyle(fontSize: 15.0, fontFamily: 'Comfortaa', color: Colors.white)
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    permissions();
    super.initState();
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
                    colors: <Color>[Color(0xFF667eea), Color(0xFF764ba2)]
                )
            ),
          ),
          title: Text('File Transfer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23, fontFamily: 'Comfortaa'),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text('Share everything',
                  style: TextStyle(fontSize: 30.0, fontFamily: 'Comfortaa', fontWeight: FontWeight.bold, color: Colors.black)
              ),
              SizedBox(height: 10),
              Text('For everyone',
                  style: TextStyle(fontSize: 28, fontFamily: 'Comfortaa', color: Colors.black)
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                            padding: const EdgeInsets.only(top: 30.0,left: 15.0),
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
                                      blurRadius: 18.0, // soften the shadow
                                      spreadRadius: 1.0, //extend the shadow
                                      offset: Offset(6,7),
                                    )
                                  ]
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0,top: 80.0),
                            child: Text('Send',
                                style: TextStyle(fontSize: 20.0, fontFamily: 'Comfortaa', color: Colors.black)
                            ),
                          )
                        ],
                      ),
                    ),
                    onPressed: () async {
                      if (await Permission.location.isGranted && await Nearby().enableLocationServices() && await Permission.storage.isGranted) {
                        setState(() {
                          pressed = true;
                          pressedRec = false;
                        });
                        try {
                          await Nearby().startDiscovery(
                            userName1,
                            strategy,
                            onEndpointFound: (id, name, serviceId) {
                              showModalBottomSheet(
                                context: context,
                                builder: (builder) {
                                  return Center(
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(height: 20),
                                        Text("Username: " + name,
                                          style: TextStyle(fontFamily: 'Comfortaa',fontSize: 15.0),
                                        ),
                                        SizedBox(height: 40),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xFF764ba2),
                                          ),
                                          child: Text("Request Connection",
                                            style: TextStyle(fontFamily: 'Comfortaa',fontSize: 15.0,color: Colors.white),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Nearby().requestConnection(
                                              userName1,
                                              id,
                                              onConnectionInitiated: (id, info) {
                                                onConnectionInit(id, info);
                                              },
                                              onConnectionResult: (id, status) {
                                                showSnackbar(status);
                                              },
                                              onDisconnected: (id) {
                                                showSnackbar(id);
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
                              showSnackbar("Lost Endpoint:" + id);
                            },
                          );
                          showSnackbar("Searching for user..." );
                        } catch (e) {
                          showSnackbar(e);
                        }
                      }
                      else if(await Permission.location.isDenied || await Permission.storage.isDenied){
                        Map<Permission, PermissionStatus> statuses = await [
                          Permission.storage,
                          Permission.location
                        ].request();
                        await Nearby().enableLocationServices();
                        print(statuses);
                      }
                      else if (await Permission.location.isPermanentlyDenied || await Permission.storage.isPermanentlyDenied){
                        showDialog(context: context,
                            builder: (BuildContext context){
                              return Theme(
                                  data: ThemeData(dialogBackgroundColor: Colors.white),
                                  child: CupertinoAlertDialog(
                                    title: Text('Permissions Required'),
                                    content: Text('This app needs permission. You can grant them in app settings.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text('Settings'),
                                        onPressed: (){
                                          openAppSettings();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: Text('Cancel'),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  )
                              );
                            }
                        );
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
                        setState(() {
                          pressed = false;
                          pressedRec = true;
                        });
                        try {
                          await Nearby().startAdvertising(
                            userName1,
                            strategy,
                            onConnectionInitiated: onConnectionInit,
                            onConnectionResult: (id, status) {
                              showSnackbar(status);
                            },
                            onDisconnected: (id) {
                              showSnackbar("Disconnected: " + id);
                            },
                          );
                          showSnackbar("Hosting connection...");
                        } catch (exception) {
                          showSnackbar(exception);
                        }
                      }
                      else if(await Permission.location.isDenied || await Permission.storage.isDenied){
                        Map<Permission, PermissionStatus> statuses = await [
                          Permission.storage,
                          Permission.location
                        ].request();
                        await Nearby().enableLocationServices();
                        print(statuses);
                      }
                      else if (await Permission.location.isPermanentlyDenied || await Permission.storage.isPermanentlyDenied){
                        showDialog(context: context,
                            builder: (BuildContext context){
                              return Theme(
                                  data: ThemeData(dialogBackgroundColor: Colors.white),
                                  child: CupertinoAlertDialog(
                                    title: Text('Permissions Required'),
                                    content: Text('This app needs permission. You can grant them in app settings.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text('Settings'),
                                        onPressed: (){
                                          openAppSettings();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: Text('Cancel'),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  )
                              );
                            }
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  pressed? GestureDetector(
                    onTap: () async {
                      List<File> files = await FilePicker.getMultiFile(type: FileType.any,);
                      for(int i=0;i<files.length;i++) {
                        encFilepath = files[i].path;
                        crypt.setOverwriteMode(AesCryptOwMode.on);
                        try {
                          aesFilepath = await crypt.encryptFile(encFilepath);
                          print('The encryption has been completed successfully.');
                        } on AesCryptException catch (e) {
                          if (e.type == AesCryptExceptionType.destFileExists) {
                            print('The encryption has been completed unsuccessfully.');
                          }
                          return;
                        }
                        int payloadId = await Nearby().sendFilePayload(cId, aesFilepath);
                        showSnackbar("Sending file");
                        Nearby().sendBytesPayload(
                            cId,
                            Uint8List.fromList(
                                "$payloadId:${files[i].path
                                    .split('/')
                                    .last}".codeUnits
                            )
                        );
                      }
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
                  ) : SizedBox(),
                  SizedBox(height: 10),
                  pressed? GestureDetector(
                    onTap: () async {
                      PickedFile file =  await ImagePicker().getImage(source: ImageSource.camera);
                      encFilepath = file.path;
                      crypt.setOverwriteMode(AesCryptOwMode.on);
                      try {
                        aesFilepath = await crypt.encryptFile(encFilepath);
                        print('The encryption has been completed successfully.');
                      } on AesCryptException catch (e) {
                        if (e.type == AesCryptExceptionType.destFileExists) {
                          print('The encryption has been completed unsuccessfully.');
                        }
                        return;
                      }
                      int payloadId = await Nearby().sendFilePayload(cId, aesFilepath);
                      showSnackbar("Sending file");
                      Nearby().sendBytesPayload(
                          cId,
                          Uint8List.fromList(
                              "$payloadId:${file.path
                                  .split('/')
                                  .last}".codeUnits
                          )
                      );
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
                  ) : SizedBox(),
                ],
              ),
              pressedRec? GestureDetector(
                onTap: () async {
                  directory = '/storage/emulated/0/Download/Nearby';
                  file = io.Directory("$directory").listSync();
                  String s;
                  String ext;

                  for(int i = 0; i < file.length; i++)
                  {
                    String newPath = file[i].path + '.aes';
                    print(newPath);
                    file[i]=file[i].renameSync(newPath);
                    s = file[i].path;
                    ext = file[i].path;
                    s = s.substring(s.lastIndexOf("/") + 1,s.indexOf("."));
                    ext = ext.substring(ext.indexOf(".")+1,ext.lastIndexOf("."));
                    crypt.setOverwriteMode(AesCryptOwMode.on);
                    try {
                      decFilepath = directory;
                      decFilepath =  await crypt.decryptFile(file[i].path, '$decFilepath/$s.$ext');
                      file[i].delete();
                    }
                    on AesCryptException catch (e) {
                      if (e.type == AesCryptExceptionType.destFileExists) {
                        print(e.message);
                      }
                    }
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
                  child: Text("Decrypt",
                      style: TextStyle(fontSize: 20.0, fontFamily: 'Comfortaa', color: Colors.white)
                  ),
                ),
              ) : SizedBox(),
            ],
          ),
        ),
      );
  }
}