import 'package:YouAudio/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);
  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  final key = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> _wifiOnly;
  Future<bool> _notifications;
  Future<bool> _autoDownload;
  Future<int> _syncInterval;

  @override
  void initState() {
    super.initState();

    _wifiOnly = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('wifiOnly') ?? false);
    });
    _notifications = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('notifications') ?? false);
    });
    _autoDownload = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('autoDownload') ?? true);
    });
    _syncInterval = _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('syncInterval') ?? 5);
    });
  }

  void _valueWifiOnlyChanged(bool value) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _wifiOnly = prefs.setBool("wifiOnly", value).then((bool success) {
        return value;
      });
    });
  }

  void _valueNotificationsChanged(bool value) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _notifications =
          prefs.setBool("notifications", value).then((bool success) {
        return value;
      });
    });
  }

  void _valueAutoDownloadChanged(bool value) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _autoDownload = prefs.setBool("autoDownload", value).then((bool success) {
        return value;
      });
    });
  }

  void _valueCheckIntervalChanged(int value) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _syncInterval = prefs.setInt("syncInterval", value).then((bool success) {
        return value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: accentColor,
          centerTitle: true,
          title: new Text(
            "Settings",
            style: new TextStyle(
              color: Colors.white,
            ),
          )),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Column(
          children: <Widget>[
            FutureBuilder<bool>(
                future: _wifiOnly,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else
                        return new CheckboxListTile(
                          value: snapshot.data,
                          onChanged: _valueWifiOnlyChanged,
                          title: new Text('Wifi Only'),
                          controlAffinity: ListTileControlAffinity.leading,
                          subtitle: new Text(
                              'Enabling this, the app will only download while on WiFi'),
                          secondary: new Icon(Icons.wifi),
                          activeColor: Colors.red,
                        );
                  }
                }),
            Spacer(),
            FutureBuilder<bool>(
                future: _notifications,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else
                        return new CheckboxListTile(
                          value: snapshot.data,
                          onChanged: _valueNotificationsChanged,
                          title: new Text('Notifications'),
                          controlAffinity: ListTileControlAffinity.leading,
                          subtitle: new Text(
                              'Enabling this, the app will notify you whenever a file is done downloading'),
                          secondary: new Icon(Icons.notifications),
                          activeColor: Colors.red,
                        );
                  }
                }),
            Spacer(),
            FutureBuilder<bool>(
                future: _autoDownload,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else
                        return new CheckboxListTile(
                          value: snapshot.data,
                          onChanged: _valueAutoDownloadChanged,
                          title: new Text('Auto Download'),
                          controlAffinity: ListTileControlAffinity.leading,
                          subtitle: new Text(
                              'Enabling this, the app will download the videos whenever an user uploads a video'),
                          secondary: new Icon(Icons.file_download),
                          activeColor: Colors.red,
                        );
                  }
                }),
            Spacer(),
            FutureBuilder<int>(
                future: _syncInterval,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      else
                        return new DropdownButton<int>(
                          hint: Text("Sync Interval: ${snapshot.data}"),
                          items: <int>[1, 5, 15, 30, 60].map((int value) {
                            return new DropdownMenuItem<int>(
                              value: value,
                              child: new Text("$value minutes"),
                            );
                          }).toList(),
                          onChanged: _valueCheckIntervalChanged,
                        );
                  }
                }),
            Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}
