import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
    final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue? _flutterBlue;
  BluetoothDevice? device;
  BluetoothState? state;
  BluetoothDeviceState? deviceState;
  List<ScanResult> scanResult=[];
  List<BluetoothCharacteristic> _bluetoothCharacteristic=[];

  List<BluetoothDevice> devices=[];

  List<String> Command_List = [

  "10AC540000000000",
  "10AC670000000000",     //"10AC670000000000"
  "10AC0a0000000000",     //"10AC0a0000000000"
  "10AC140000000000",
  "10AC590000000000",
  "10AC350000000000",
  "10AC430000000000",
  "10AC160000000000",
  "10AC390000000000",
  "10AC470000000000",
  "10AC520000000000",
  "10AC750000000000",
  "10AC1a0000000000",
  "10AC1b0000000000",
  "10AC730000000000",
  "10AC5d0000000000",
  "10AC840000000000"
  ];

  List<String> Command_list_Reply = [];

 Guid CCCD = new Guid("00002902-0000-1000-8000-00805f9b34fb");
  Guid RX_SERVICE_UUID = new Guid("49535343-FE7D-4AE5-8FA9-9FAFD205E455");     //microchip traperent profile
  Guid TX_CHAR_UUID  = new Guid("49535343-1E4D-4BD9-BA61-23C647249616");       //microchip traperent profile
  Guid RX_CHAR_UUID = new Guid("49535343-8841-43F4-A8D4-ECBE34729BB3");
  @override
  void initState() {
    // TODO: implement initState
    ScanForDevices();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(

        child:
        devices.isEmpty?
        ListView.builder(
            itemCount: scanResult.length,
          itemBuilder:  (context,i){
              return ListTile(
                title: Text("${scanResult[i].device.id}"),
                subtitle: Text("${scanResult[i].device.name}"),
                trailing: MaterialButton(
                  color: Colors.blue,
                  child: Text(
                    'Connect'
                  ),
                  onPressed: (){
                    print("the button pressed is $i");

                   print("in onpreseed in device ${scanResult[i].device}");
                    connectToDevice(scanResult[i].device);
                  },
                ),
              );
          }
        ):
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text("Already Connected" , style: TextStyle(
                color: Colors.blue,
              ),),),
              MaterialButton(onPressed: (){
                disconnect(devices);
              },
                child: Text(
                  "Disconnect",style: TextStyle(
                  color: Colors.white),
                ),
                color: Colors.black,
                ),
              _widgetLiveParameters(devices),
              MaterialButton(onPressed: (){

                disconnect(devices);

              },
                child: Text(
                  'Map',style: TextStyle(
                    color: Colors.white),
                ),
                color: Colors.black,
              ),

            ],
          ),
        ),


      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void ScanForDevices() async{
    _flutterBlue=FlutterBlue.instance;

    FlutterBlue.instance.state.listen((state) {

      if(state == BluetoothState.off){

        Fluttertoast.showToast(
            msg: "Start the Bluetooth!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.black,
            fontSize: 16.0
        );
        print("blueetooth is off");
        //give the bluetooth permission here if it off

      }else if(state==BluetoothState.on){
        print("blueetooth is on");

        try {
          _flutterBlue!.startScan(timeout: Duration(seconds: 4));
        }catch (e){
          Fluttertoast.showToast(msg: "Try Later", gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.blue);
        }
        // Listen to scan results
        var subscription=_flutterBlue!.scanResults.listen((event) async{
          print("event is ${event.runtimeType}");



          /*scanResult=event;*/
          print("event length is ${event.length}");
          for (ScanResult r in event) {
            if(r.device.name.contains("_") ||r.device.name.contains("-") ){
              scanResult.add(r);
              print("scan result in if statement ${scanResult}");
            }
            print("scan result in for statement ${scanResult}");
            print('${r.device.id} found! rssi: ${r.rssi}');
            setState(() {

            });
          }
          print("scan result outside of for statement ${scanResult}");
        });
        print("subscription type is #${subscription.runtimeType}");
        _flutterBlue!.stopScan();
        print("scanResult length is${scanResult.length}");

        scanForDevices();
      }else{
        //mske the gpslocation on and the bluetooth on
      }
    }) ;


    
  }

  //scan and stop for bluettoth

  void scanForDevices() async{
    //it shows the connected device
    try{
      devices = await _flutterBlue!.connectedDevices;
      print("the paired devices is ${devices}");
      print("the paired devices length ${devices.length}");
    }catch(e){
      print("error in the paired devices");
    }

    if(devices.length==null){
      discovery(devices[0]);
    }



  }

  void connectToDevice(BluetoothDevice device) async{
    print("in connect to devices");
    var subsription;
   try{
     await device.connect(timeout: Duration(seconds: 30));
     print("Subscription value is${subsription.toString()}");

   }catch(e){
     print("error while connecting $e");
   }

   print("in discoverable");
    //After connection start dicovering services
    discovery(device);

  }
  List<BluetoothService> _services=[];

  void discovery(BluetoothDevice device)async{

    _services = await device.discoverServices();
    print("_services for discover srevices ${_services}");


    /*_services.forEach((service) {
      print("service is deviceID is${service.deviceId}");

      _bluetoothCharacteristic=service.characteristics;
      print("the bluetppth Charactertics is ${_bluetoothCharacteristic}");

      for(BluetoothCharacteristic charcterstics in service.characteristics){
        var value =   charcterstics.read();
        print("the value of value is${value}");
        print("the value of value type ${value.runtimeType}");
      }
    });*/

    _bluetoothCharacteristic=_services.last.characteristics;
    print("the bluetooth Characterstics is ${_bluetoothCharacteristic}");
    print("the bluetooth descriptors is ${_services.last.includedServices}");



    setState(() {
      devices.add(device);
    });
  }

  disconnect(List<BluetoothDevice> devices) {
    SendData("10AC320000000000", "HEX");
    BluetoothDevice bluetoothDevice;
    bluetoothDevice=devices.last;
    setState(() {
      bluetoothDevice.disconnect();
    });

    print("discoonect the first device is ${devices.first.id}");
    print("discoonect the first device service is ${devices.first.services}");
    print("discoonect the last devices is ${bluetoothDevice.id}");
    print("discoonect the last devices service is ${bluetoothDevice.services}");
    print("Successfully disconnect");
  }

  _widgetLiveParameters(List<BluetoothDevice> devices) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Live data"
          ),
          MaterialButton(onPressed: (){
            writeData();
          },
            color: Colors.blue,
            child: Text(
              "Live Data"
            ),
          ),
        ],
      ),
    );
  }

  //read all charcterstics
  //writ all characterstics
  int counter=1;
  void writeData() async{

    if(counter==1){
      await sendCommandNeutral("10AC460000000000");
    }
    counter++;

    for (int j = 0; j < 17; j++){
      print("in j condition $j");
      print("the Command_List ${Command_List[j]}");
       await SendData(Command_List[j], "HEX");
    }

}

  sendCommandNeutral(String neutralData) async {
    final String hexData = neutralData;
    await SendData(hexData,"HEX");
  }

  SendData(String hexData, String s) async {
    List<int> value;

    /*Uint8List value2 = Uint8List.fromList(value);*/
    value =hexStringToByteArray(hexData);


    String encode = s;

    if(encode=="HEX"){
      try{
        // final convertedCommmand = value.iterator.moveNext().toString());
        // String convertedCommmand2="0x$convertedCommmand";
        // print("convertedCommmand2 is this $convertedCommmand2");
        // print("convertedCommmand is this $convertedCommmand");
        print("value is this $value");

        await _bluetoothCharacteristic.last.write(utf8.encode(value.iterator.moveNext().toString()));




        await _bluetoothCharacteristic.last.setNotifyValue(true);
        _bluetoothCharacteristic.last.value.listen((event) {
          print("");
          print("the notify value of the write data is $event");
        });

        print("_bluetoothCharacteristic.last.uuid is ${_bluetoothCharacteristic.last.uuid}");
        if(_bluetoothCharacteristic.last.uuid==Guid("49535343-4c8a-39b3-2f49-511cff073b7e")){
          print("this free");

          var valueIs=_bluetoothCharacteristic.last.descriptors;


        }


      }catch(e){
        print("the error is $e");
      }
    }


  }

  List<int> hexStringToByteArray(String hexData) {
    int len=hexData.length;
    print("hexdata is $hexData");

    List<int> data=[];
    for(int i=0;i<len;i+=2){


      print("i is $i");
      print("hexdata substring is the ${hexData.substring(i,i+1)}");
      print("hexdata radix is the ${int.parse(hexData.substring(i,i+1),radix: 16)}");
      print("hexdata int after left shift is the ${(int.parse(hexData.substring(i,i+1),radix: 16)<<4)}");
      print("hexdata int after left shift in to the byte ${utf8.encode((int.parse(hexData.substring(i,i+1),radix: 16)<<4).toString())}");

      int value=(int.parse(hexData.substring(i,i+1),radix: 16)<<4) + int.parse(hexData.substring(i+1,i+2),radix: 16);
      List<int> myValue=utf8.encode('$value');

      print("value after all the cal ${myValue}");
      data.addAll(myValue);
    }
    /*Uint8List data2 = Uint8List.fromList(data);*/
    print("data is $data");


   /* print("data2 is $data2");*/


    return data;
  }






}
