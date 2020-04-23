import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:paycapp/src/config.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/models/updater_model.dart';
import 'package:paycapp/src/providers/updater_provider.dart';
import 'package:paycapp/src/utils/local_storage.dart';
import 'package:paycapp/src/utils/utils.dart';

class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final _prefs = LocalStorage();
  Updater _update;
  bool _loadingInfo;
  TargetPlatform platform;
  _TaskInfo _task;
  _ItemHolder item;  
  String _localPath;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    _loadingInfo = false;
    
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);      

    _getUpdate();

    super.initState();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }


  //* Render widget
  @override
  Widget build(BuildContext context) {
    platform = Theme.of(context).platform;
    return Scaffold(
      appBar: AppBar(
        title: Text("Actualizar"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh), 
            onPressed: _getUpdate,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Center(child: _logo),
          SizedBox(height:15),
          _bodyOrLoader()        
        ],
      )
    );
  }

  //* Body
  Widget _bodyOrLoader() {
    if(_loadingInfo) {
      return loader(text: "Comprobando actualizaciones");
    }

    return Column(
      children: <Widget>[
        Text("$appName v${_update.version ?? buildVersion }", style: TextStyle(fontSize: Theme.of(context).textTheme.title.fontSize)),
        _textGreen(),
        SizedBox(height: 5),
        Text("${_update.description ?? "No necesitas actualizar, estas al dia" }", style: TextStyle(fontSize: Theme.of(context).textTheme.subtitle.fontSize)),
        SizedBox(height: 10),
        Text("Actualización con fecha de: ${dateForHumans(_update.last)}",style: TextStyle(color: Colors.black54, fontSize: Theme.of(context).textTheme.overline.fontSize)),
        SizedBox(height: 30),
        _progress(),
        SizedBox(height: 10),
        _renderDownLoadBtns(),
      ],
    );
  }

  //* buttons
  Widget _renderDownLoadBtns() {
    if(!_update.update) return Center(); // si no hay actualizaciones, los botones no son necesarios

    if(_task == null) return Center(); // Si la tarea is null

    if(_task.status == DownloadTaskStatus.undefined) {
      return _downloadBtn();
    }

    else if (_task.status == DownloadTaskStatus.running) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _btn(
            text: 'Cancelar',
            icon: FontAwesomeIcons.times,
            color: Colors.white10,
            fore: Colors.red,
            callback: _cancelDownload
          ),
          _btn(
            text: 'Pausar',
            icon: FontAwesomeIcons.pause,
            color: Colors.white10,
            fore: Colors.black54,
            callback: _pauseDownload
          ),
        ],
      );
    }

    else if (_task.status == DownloadTaskStatus.paused) {
      return _btn(
        text: 'Reanudar',
        icon: FontAwesomeIcons.play,
        color: Colors.white12,
        fore: colors['primary'],
        callback: _resumeDownload
      );
    }

    else if (_task.status == DownloadTaskStatus.failed) {
      return Column(
        children: <Widget>[
          Text('Algo ha salido mal, falló la descarga', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _btn(
            text: 'Reintentar',
            icon: FontAwesomeIcons.redo,
            color: colors['primary'],
            fore: Colors.white,
            callback: _retryDownload        
          )
        ],
      );
    }

    else if (_task.status == DownloadTaskStatus.complete) {
      return Column(
        children: <Widget>[
          _btn(
            text: 'Instalar actualización',
            callback: _installApk,
            color: Colors.green,
            icon: FontAwesomeIcons.android
          ),
          SizedBox(height: 15),
          _btn(
            text: 'Volver a descargar actualización',
            callback: _initDownload,
            icon: FontAwesomeIcons.download,
            color: Colors.white10,
            fore: Colors.black38
          )
        ],
      );
    }
    else if (_task.status == DownloadTaskStatus.canceled) {
      return _downloadBtn();
    }
    return Center();
  }

  Widget _downloadBtn() {
    return _btn(
      callback: _initDownload, 
      icon: FontAwesomeIcons.download,
      text: "Descargar Ahora",                    
      color: colors['primary'],          
    );
  }

  Widget _btn({String text: 'BTN', Color color: Colors.orange, IconData icon: Icons.add, Color fore: Colors.white, Function callback}) {
    return FlatButton.icon(
        onPressed: callback,
        label: Text("$text", style: TextStyle(color: fore)),
        icon: Icon(icon, color: fore),
        color: color,
        splashColor: Colors.white24,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        shape: StadiumBorder(),
      );
  }

  Widget _progress() {
    if(_task == null) return Container();
    
    if(_task.status == DownloadTaskStatus.running) {
      return LinearProgressIndicator(value: (_task == null) ? 0 : _task.progress / 100);
    }
    return Container();
  }

  Widget _textGreen() {

    if(_update.update)
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Nueva actualización disponible", style: TextStyle(
          color: Colors.orange[600],
          fontSize: Theme.of(context).textTheme.subhead.fontSize,
          fontWeight: FontWeight.w600
        )),
      );
    else return Center();
  }

  Widget _logo = SizedBox(
    height: 110.0,
    child: Image.asset(
      "assets/payicon.png",
      fit: BoxFit.contain,
    ),
  );

  // functions

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {        
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (_task != null) {
        setState(() {
          _task.status = status;
          _task.progress = progress;
        });
      } 
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {        
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void _cancelDownload() async {
    await FlutterDownloader.cancel(taskId: _task.taskId);
  }  

  void _pauseDownload() async {
    await FlutterDownloader.pause(taskId: _task.taskId);
  }

  void _resumeDownload() async {
    String newTaskId = await FlutterDownloader.resume(taskId: _task.taskId);
    _task.taskId = newTaskId;
  }

  void _retryDownload() async {
    String newTaskId = await FlutterDownloader.retry(taskId: _task.taskId);
    _task.taskId = newTaskId;
  }

  Future<Null> _prepare() async {
     final tasks = await FlutterDownloader.loadTasks();      
     //final tasks = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE status=1");
    _task = _TaskInfo(name: "$appName ${_update.version}", 
        link: "$urlApi/updates/${_update.src}"
        //link: 'https://upload.wikimedia.org/wikipedia/commons/6/60/The_Organ_at_Arches_National_Park_Utah_Corrected.jpg'
    );

    tasks?.forEach((task) {  
      if (_task.link == task.url) {
        _task.taskId = task.taskId;
        _task.status = task.status;
        _task.progress = task.progress;
      }   
    });

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    setState(() {});
  }

  void _initDownload() async {
    if(_update == null || _update.src == null) {
      return;
    }
    _removeUpdates();
    _task.taskId = await FlutterDownloader.enqueue(
        url: _task.link,
        headers: {
          "Accept": 'application/json',
          "Authorization" : "Bearer ${_prefs.token}"
        },
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  } 
   
  void _getUpdate() async{
    setState(() {
      _loadingInfo = true;
    });
    Responser res = await UpdaterProvider().comprobate();
      if(res.ok) {
        _update = Updater.fromMap(res.data);
        if(_update.update == true) {
          _prefs.update = true;      
          _prepare();
        } else {          
          _prefs.update = false;
          _removeUpdates();
        }
        setState(() {
          _loadingInfo = false;
        });
        
      }
  }

  // find path
  Future<String> _findLocalPath() async {
    final directory = this.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void _removeUpdates() async {
    final tasks = await FlutterDownloader.loadTasks();      
    tasks?.forEach((task) {  
      FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: true);
    });
  }

  void _installApk() async {
    String src = _update.src.replaceAll("apk/", "");
    final _apkFilePath = _localPath+Platform.pathSeparator+src;
    if (_apkFilePath.isEmpty) {
      print('make sure the apk file is set');
      return;
    }
   /*  Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]); */
    //if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      InstallPlugin.installApk(_apkFilePath, 'com.paycenter.paycapp')
          .then((result) {
        print('install apk $result');
      }).catchError((error) {
        print('install apk error: $error');
      });
    //} else {
      //print('Permission request fail!');
    //}
  }
}


/// Clases adicionales

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}