import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ir_sensor_plugin/ir_sensor_plugin.dart';
import 'package:remote_ir/constants.dart' as Constants;
import 'package:remote_ir/globals.dart' as Globals;
import 'package:remote_ir/ip_settings_Screen.dart';
import 'package:remote_ir/lpr_dashboard_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ظهير المُغُر',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ظهير المُغُر'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// https://flutterui.design/components/buttonsAndControls
class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';
  bool _hasIrEmitter = false;
  String _getCarrierFrequencies = 'Unknown';

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    bool hasIrEmitter;
    String getCarrierFrequencies;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await IrSensorPlugin.platformVersion;
      hasIrEmitter = await IrSensorPlugin.hasIrEmitter;
      getCarrierFrequencies = await IrSensorPlugin.getCarrierFrequencies;

      /*
      platformVersion = "";
      hasIrEmitter = false;
      getCarrierFrequencies = "";
      */
      final String result = await IrSensorPlugin.setFrequencies(38000);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('hasIREmitter: ' + hasIrEmitter.toString() + "\n"),
        duration: Duration(milliseconds: 600),
      ));
    } on PlatformException {
      platformVersion = 'Failed to get data in a platform.';
      hasIrEmitter = false;
      getCarrierFrequencies = 'None';
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to get platform data!")));
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _platformVersion = platformVersion;
    _hasIrEmitter = hasIrEmitter;
    _getCarrierFrequencies = getCarrierFrequencies;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController txtCtrl = TextEditingController(
        text:
            "0000 006D 0022 0002 0155 00AA 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0040 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0015 0040 0015 0040 0015 0040 0015 0040 0015 0040 0015 0040 0015 0040 0015 0040 0015 05ED 0155 0055 0015 0E47");
    txtCtrl.text = ""; // for final version.
    initPlatformState();
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
                child: Text("Functions"),
              ),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: Text("مين بالأرض"),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LPRDashboardScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: Text("Server Settings"),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IpSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
            title: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(Globals.rotationAngle),
                child: Text(
                  "ظهير المُغُر",
                  style: TextStyle(fontSize: 25),
                )),
            centerTitle: true,
            actions: <Widget>[
              Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationZ(Globals.rotationAngle),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        Globals.rotationAngle =
                            (Globals.rotationAngle - pi).abs();
                      });
                    },
                    icon: Icon(Icons.flip_camera_android), // The icon
                    label: Text("إفتل الشاشة"), // The text
                  )),
            ]),
        body: Container(
          child: SingleChildScrollView(
              child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationZ(Globals.rotationAngle),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Running on: $_platformVersion\n'),
                      Text('Has Ir Emitter: $_hasIrEmitter\n'),
                      Text('IR Carrier Frequencies:$_getCarrierFrequencies'),
                      TextFormField(
                        key: Key('textField_code_hex'),
                        decoration: InputDecoration(
                          hintText: 'Write specific String code to transmit',
                          suffixIcon: IconButton(
                            onPressed: () => {},
                            icon: Icon(Icons.clear),
                          ),
                        ),
                        controller: txtCtrl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Write the code to transmit';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Systems",
                            style: TextStyle(fontSize: 25),
                          ),
                          const SizedBox(height: 60),
                          Text(
                            "الصغير",
                            style: TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SimpleElevatedButtonWithIcon(
                                label: const Text("ON"),
                                iconData: Icons.light_mode,
                                color: Colors.green,
                                onPressed: () async {
                                  print(_platformVersion);
                                  String TV_POWER_HEX = txtCtrl.text;
                                  // final String result = await IrSensorPlugin.transmitString(pattern: TV_POWER_HEX);
                                  customSendIR(
                                      Constants.SMALL_ON_LIST, "ON SMALL");
                                },
                              ),
                              SimpleElevatedButtonWithIcon(
                                label: const Text("OFF"),
                                iconData: Icons.tv_off,
                                color: Colors.red,
                                onPressed: () async {
                                  customSendIR(
                                      Constants.SMALL_OFF_LIST, "OFF SMALL");
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    customSendIR(Constants.SMALL_BRIGHTNESS_UP,
                                        "Brightness+ SMALL");
                                  },
                                  child: Icon(Icons.light_mode)),
                              ElevatedButton(
                                  onPressed: () async {
                                    customSendIR(
                                        Constants.SMALL_BRIGHTNESS_DOWN,
                                        "Brightness- SMALL");
                                  },
                                  child: Icon(Icons.light_mode_outlined)),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            "Wالفوتة - الكبير 600",
                            style: TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SimpleElevatedButtonWithIcon(
                                label: const Text("ON/OFF"),
                                iconData: Icons.light_mode,
                                color: Colors.orange,
                                onPressed: () async {
                                  customSendIR(Constants.BIG_600W_ON_OFF_LIST,
                                      "ON/OFF 600W BIG");
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 35),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    customSendIR(
                                        Constants.BIG_600W_BRIGHTNESS_UP,
                                        "Brightness+ BIG 600W");
                                  },
                                  child: Icon(Icons.add)),
                              ElevatedButton(
                                  onPressed: () async {
                                    customSendIR(
                                        Constants.BIG_600W_BRIGHTNESS_DOWN,
                                        "Brightness- BIG 600W");
                                  },
                                  child: Icon(Icons.remove)),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            "Wالقعدة - الكبير 1000",
                            style: TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SimpleElevatedButtonWithIcon(
                                label: const Text("OFF"),
                                iconData: Icons.tv_off,
                                color: Colors.red,
                                onPressed: () async {
                                  customSendIR(Constants.LARGE_1000W_OFF_LIST,
                                      "OFF 1000W LARGE");
                                },
                              ),
                              const SizedBox(height: 35),
                            ],
                          ),
                          const SizedBox(height: 35),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      customSendIR(
                                          Constants
                                              .LARGE_1000W_FULL_BRIGHTNESS_LIST,
                                          "Brightness+ LARGE");
                                    },
                                    child: Icon(Icons.light_mode)),
                                ElevatedButton(
                                    onPressed: () async {
                                      customSendIR(
                                          Constants
                                              .LARGE_1000W_HALF_BRIGHTNESS_LIST,
                                          "Brightness- LARGE");
                                    },
                                    child: Icon(Icons.light_mode_outlined))
                              ]),
                          const SizedBox(height: 28),
                          ElevatedButton(
                              onPressed: () async {
                                customSendIR(Constants.LARGE_1000W_ALWAYS_LIST,
                                    "LARGE Always");
                              },
                              child: Text(
                                "Always",
                                style: TextStyle(color: Colors.white),
                              )),
                          const SizedBox(height: 40)
                        ],
                      ),
                    ],
                  ))),
        ));
  }

  void customSendIR(List<int> list_of_ir_ints, String code_name) async {
    final String result =
        await IrSensorPlugin.transmitListInt(list: list_of_ir_ints);
    if (result.contains('Emitting')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Sending " + code_name + "..."),
          duration: Duration(milliseconds: 500)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("IrSensorPlugin result doesn't contain emitting")));
    }
  }

  Future<void> refreshFuturisticMenuState() async {
    setState(() {});
  } // 3mltha Future + async 3sha a3'dr ast3mlha fo2 bl RefreshIndicator
}

class SimpleElevatedButtonWithIcon extends StatelessWidget {
  const SimpleElevatedButtonWithIcon(
      {required this.label,
      this.color,
      this.iconData,
      required this.onPressed,
      this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      Key? key})
      : super(key: key);
  final Widget label;
  final Color? color;
  final IconData? iconData;
  final Function onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed as void Function()?,
      icon: Icon(iconData),
      label: label,
      style: ElevatedButton.styleFrom(primary: color, padding: padding),
    );
  }
}
