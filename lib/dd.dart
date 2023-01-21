import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ads/ads.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:get_version/get_version.dart';
import 'package:printerset/jsontest.dart';
import 'package:printerset/newjson.dart';
import 'package:printerset/printertypelist.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:printerset/jsonlist.dart';
import 'package:printerset/sqllist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:http/http.dart' as http;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:path_provider/path_provider.dart';
const String testDevice = 'MobileId';

class Lanprint1 extends StatefulWidget {
  String urlchangetext;
  String ip_text;
  Lanprint1({this.urlchangetext, this.ip_text});

  @override
  State<Lanprint1> createState() => _LanprintState();
}

class _LanprintState extends State<Lanprint1> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Game', 'Mario'],
  );

  // BannerAd _bannerAd;
  // InterstitialAd _interstitialAd;

  // BannerAd createBannerAd() {
  //   return BannerAd(
  //       adUnitId: BannerAd.testAdUnitId,
  //     //Change BannerAd adUnitId with Admob ID
  //       size: AdSize.banner,
  //       targetingInfo: targetingInfo,
  //       listener: (MobileAdEvent event) {
  //         print("BannerAd $event");
  //       });
  // }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: InterstitialAd.testAdUnitId,
        //Change Interstitial AdUnitId with Admob ID
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("IntersttialAd $event");
        });
  }

  final DBPrinterManager dbPrinterManager = new DBPrinterManager();
  final _formkey = new GlobalKey<FormState>();
  Printer prt;
  int updateindex;

  List<Printer> prtlist;
  TextEditingController urltext = new TextEditingController();
  TextEditingController lictext = new TextEditingController();
  TextEditingController iptext = new TextEditingController();
  TextEditingController printername = new TextEditingController();
  TextEditingController printeraddress = new TextEditingController();
  String localIp = '';
  List<String> devices = [];
  bool isDiscovering = false;
  int found = -1;
  TextEditingController portController = TextEditingController(text: '9100');
  Timer _timerForInter;
  Ads appAds;

  final String appId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544~3347511713'
      : 'ca-app-pub-3940256099942544~1458002511';

  final String bannerUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final String screenUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';
  final String videoUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';
       bool _loading = true;
  @override
   initState()  {
    super.initState();
    _getId();
    data();
    main();
    initPlatformState();
    initSavetoPath();
    printertype.add(new PrinterType(localurlip, blname));
   print(printertype);
    if(blname==null){
      return null;
    }else{
   _connect();
    }

    //getappid();
   // fetchAprinterdata();
    var eventListener = (MobileAdEvent event) {
      if (event == MobileAdEvent.opened) {
        print("The opened ad is clicked on.");
      }
    };

    appAds = Ads(
      appId,
      bannerUnitId: bannerUnitId,
      screenUnitId: screenUnitId,
      keywords: <String>['ibm', 'computers'],
      contentUrl: 'http://www.ibm.com',
      childDirected: false,
      testDevices: ['Samsung_Galaxy_SII_API_26:5554'],
      testing: false,
      listener: eventListener,
    );

    appAds.setVideoAd(
      adUnitId: videoUnitId,
      keywords: ['dart', 'java'],
      contentUrl: 'http://www.publang.org',
      childDirected: true,
      testDevices: null,
      listener: (RewardedVideoAdEvent event,
          {String rewardType, int rewardAmount}) {
        print("The ad was sent a reward amount.");
      },
    );
  
   

   // setUrlValue();
    fetchdata();
  }

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  String pathImage;
  // TestPrint testPrint;


 initSavetoPath() async {
    //read and write
    //image max 300px X 300px
    final filename = 'yourlogo.png';
    var bytes = await rootBundle.load("asset/as.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes, '$dir/$filename');
    setState(() {
      pathImage = '$dir/$filename';
    });
  }

    Future<void> initPlatformState() async {
    bool isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });
      if (!mounted) return;
    setState(() {
      _devices = devices;
    });
// if(devices[0].name==blname){
//    setState(() {
//         _connected = true;
//       });
// }
    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
    }
    main() {
    String complexText =
""" {
  "printer_name": [
    "Everycom-80-Series"
  ],
  "item_length": "35",
  "template": "1",
  "data": [
    {
      "type": "logo",
      "data": {
        "url": "https:\/\/irestoraplus.easypos4u.com\/assets\/POS\/logo\/265d723dc8291ee9bf2fb1a815042501.png"
      }
    },
    {
      "type": "kitchenlogo",
      "data": {
        "url": "https:\/\/irestoraplus.easypos4u.com\/assets\/POS\/logo\/265d723dc8291ee9bf2fb1a815042501.png",
        "y_axis": 10,
        "x_axis": 10,
        "logo_width": 150,
        "logo_height": 100
      }
    },
    {
      "type": "header",
      "data": {
        "top_title": "Khmer Angkor",
        "sub_titles": [
          "Phnom Penh",
          "0102225356",
          "Takeaway"
        ],
        "address": [
          "Phnom Penh"
        ],
        "bill_no": "",
        "ticket_no": "",
        "date_of_bill": "",
        "prepration_date": "",
        "time": "14:44",
        "print": "",
        "table": "",
        "online_order_id": "",
        "employee": "",
        "till": "",
        "order_type": "",
        "customer_name": "",
        "customer_phone": "",
        "customer_address": [
          "sd"
        ],
        "customer_remarks": [
          "sd"
        ],
        "split_bill_string": "",
        "headercomments": [
          "sd"
        ]
      }
    },
  {
      "type": "kitchenfooter",
      "data": {
        "align": "center",
        "kitchen_footer_text": [
          "",
          "Phnom Penh",
          "0102225356",
          "Takeaway"
        ]
      }
    },
    {
      "type": "footer",
      "data": {
        "align": "left",
        "footer_text": [
          "Invoice\/Bill No: KHA001-T-000431",
          "Customer Name: General Customer",
          "Phone No: 9999555522",
          "Cust Address:Phnom PenhnPhnom Penh,BKK1",
          "Sales Ast:                         sreymom",
          "Date:                         27\/04\/2022 14:44"
        ]
      }
    },
     {
      "type": "item",
      "data": {
        "itemdata": [
         
        ]
      }
    },
    {
      "type": "separator",
      "data": {
        "separator_length": ""
      }
    },
    {
      "type": "bigsummary",
      "data": {
        "bigsummary": [
          {
            "key": "Total Items",
            "value": "2"
          },
          {
            "key": "Subtotal",
            "value": "64.50"
          },
          {
            "key": "Discount Amount",
            "value": "0.00"
          },
          {
            "key": "Tip\/Delivery Charge",
            "value": "0.00"
          },
          {
            "key": "Grand Total",
            "value": "64.50"
          },
          {
            "key": "Paid Amount",
            "value": ""
          },
          {
            "key": "Due Amount",
            "value": ""
          }
        ]
      }
    },
    {
      "type": "separator",
      "data": {
        "separator_length": ""
      }
    },
    {
      "type": "summary",
      "data": {
        "summary": [
          {
            "key": "Subtotal",
            "value": "64.50"
          }
        ]
      }
    }
  ,
      {
      "type": "setting",
      "data": {
        "printer_name": [
          "Everycom-80-Series"
        ],
        "print_type": "",
        "item_length": 30,
        "print_logo": false,
        "thankyou_note": "",
        "thankyou_note2": "",
        "printer_type": "POS"
      }
    },
    {
      "type": "columndetails",
      "data": {
        "columnheader": {
          "column1": "Tax",
          "column2": "Over",
          "column3": "",
          "column4": "tax"
        },
        "columndata": [
          {
            "column1": "Bill",
            "column2": "1234",
            "column3": "",
            "column4": ""
          }
        ]
      }
    },
    {
      "type": "Receipt",
      "data": {
        "receipt_text": [
          "Payment Type : "
        ]
      }
    },
    {
      "type": "logo",
      "data": {
        "url": "https:\/\/irestoraplus.easypos4u.com\/assets\/POS\/logo\/2223a5e3a844650c6ebf5c3f8d6606c2.jpg"
      }
    },
    {
      "type": "footer",
      "data": {
        "align": "left",
        "footer_text": [
          "Footer test"
        ]
      }
    },
    {
      "type": "separator",
      "data": {
        "separator_length": ""
      }
    },{
      "type": "kitchenfooter",
      "data": {
        "align": "left",
        "kitchen_footer_text": [
          
        ]
      }
    },
    {
      "type": "kitchenfooter",
      "data": {
        "align": "center",
        "kitchen_footer_text": [
          
        ]
      }
    },
    {
      "type": "kitchenfooter",
      "data": {
        "align": "right",
        "kitchen_footer_text": [
          
        ]
      }
    }
    ,
    {
      "type": "kitchen_print",
      "printer_name": "Kitchen114",
      "individual_print": "0",
      "data": {
        "itemdata": [
          {
            "item_amount": "4.50",
            "item_name": "Sweet Potatoes Pancakes ",
            "item_subLine": "",
            "toppings_with_price": [
              "sd"
            ],
            "toppings": [
              "sd"
            ],
            "quantity": "1",
            "selected": false,
            "price": "44.99",
            "custpmer_remarks": "Testtng",
            "printer_name": "Kitchen114",
            "printer_label": "Testtng 3",
            "station": "",
            "food_stampable": "yes",
            "items": [
              "sd"
            ],
            "print_description": "",
            "deleted": false,
            "exists": false,
            "display_index": 0,
            "is_printed": false,
            "made_to": false,
            "menu_group": "Combo~10",
            "kitchen_print": false
          }
        ]
      }
    },
    {
      "type": "kitchen_print",
      "printer_name": "Bar115",
      "individual_print": "0",
      "data": {
        "itemdata": [
          {
            "item_amount": "60.00",
            "item_name": "mojito ",
            "item_subLine": "",
            "toppings_with_price": [
              "sd"
            ],
            "toppings": [
              "sd"
            ],
            "quantity": "1",
            "selected": false,
            "price": "44.99",
            "custpmer_remarks": "Testtng",
            "printer_name": "Bar115",
            "printer_label": "Testtng 3",
            "station": "",
            "food_stampable": "yes",
            "items": [
              "sd"
            ],
            "print_description": "",
            "deleted": false,
            "exists": false,
            "display_index": 0,
            "is_printed": false,
            "made_to": false,
            "menu_group": "Combo~10",
            "kitchen_print": false
          }
        ]
      }
    }
  ]
}"""
//"""{"printer_name":["192.168.1.77"],"item_length":"26","template":"2","data":[{"type":"summary","data":{"summary":[{"key":"Subtotal","value":91.95}]}},{"type":"header","data":{"top_title":"","sub_titles":["Title 1","Title 2"],"address":["#122 downtown"],"bill_no":"13355","ticket_no":"10","date_of_bill":"3/3/2022","prepration_date":"","time":"11:32 AM","print":"","table":"","online_order_id":"","employee":"User 1","till":"Terminal 2","order_type":"Dine In","customer_name":"","customer_phone":"","customer_address":["hahaha"],"customer_remarks":["hahaha"],"split_bill_string":"","headercomments":["hahaha"]}},{"type":"separator","data":{"separator_length":""}},{"type":"item","data":{"itemdata":[{"order_invoice_id":13309,"item_amount":46.98,"item_name":"Orchard Special 3 pizza 1","item_subLine":"","toppings_with_price":["hahaha"],"toppings":["Sugar","Extra salt","Cheese"],"quantity":1,"selected":false,"price":44.99,"custpmer_remarks":"","printer_name":"","printer_label":"","station":"","food_stampable":"","items":[{"order_invoice_id":"","item_amount":0,"item_name":"Garlic Bread 1 ","item_subLine":"","toppings_with_price":["hahaha"],"toppings":["fg"],"quantity":0,"selected":false,"price":0,"custpmer_remarks":"","printer_name":"","printer_label":"","station":"","food_stampable":"","items":["we"],"print_description":"","deleted":false,"exists":false,"display_index":0,"is_printed":false,"made_to":false,"menu_group":["hahaha"],"kitchen_print":false}],"print_description":"","deleted":false,"exists":false,"display_index":0,"is_printed":false,"made_to":false,"menu_group":"Combo~10","kitchen_print":false},{"order_invoice_id":13309,"item_amount":46.98,"item_name":"French fire","item_subLine":"","toppings_with_price":["hahaha"],"toppings":[],"quantity":1,"selected":false,"price":44.99,"custpmer_remarks":"","printer_name":"","printer_label":"","station":"","food_stampable":"","items":[{"order_invoice_id":"","item_amount":0,"item_name":"Render mest","item_subLine":"","toppings_with_price":["hahaha"],"toppings":["Salt","Extra sauce","Chilli"],"quantity":0,"selected":false,"price":0,"custpmer_remarks":"","printer_name":"","printer_label":"","station":"","food_stampable":"","items":["we"],"print_description":"","deleted":false,"exists":false,"display_index":0,"is_printed":false,"made_to":false,"menu_group":["hahaha"],"kitchen_print":false}],"print_description":"","deleted":false,"exists":false,"display_index":0,"is_printed":false,"made_to":false,"menu_group":"Combo~10","kitchen_print":false}]}},{"type":"separator","data":{"separator_length":""}},{"type":"bigsummary","data":{"bigsummary":[{"key":"Subtotal","value":91.95},{"key":"Total","value":43.96},{"key":"PaidAmount","value":43.96},{"key":"TaxTotal","value":5.73}]}},{"type":"separator","data":{"separator_length":""}},{"type":"item","data":{"itemdata":[{"order_invoice_id":13309,"item_amount":46.98,"item_name":"Orchard Special 3 pizza","item_subLine":"","toppings_with_price":["hahaha"],"toppings":["Sugar","Extra salt","Cheese"],"quantity":1,"selected":false,"price":44.99,"custpmer_remarks":"","printer_name":"","printer_label":"","station":"","food_stampable":"","items":[{"order_invoice_id":"","item_amount":0,"item_name":"Garlic Bread 1 ","item_subLine":"","toppings_with_price":["hahaha"],"toppings":["fg"],"quantity":0,"selected":false,"price":0,"custpmer_remarks":"","printer_name":"","printer_label":"","station":"","food_stampable":"","items":["we"],"print_description":"","deleted":false,"exists":false,"display_index":0,"is_printed":false,"made_to":false,"menu_group":["hahaha"],"kitchen_print":false}],"print_description":"","deleted":false,"exists":false,"display_index":0,"is_printed":false,"made_to":false,"menu_group":"Combo~10","kitchen_print":false},{"order_invoice_id":13309,"item_amount":46.98,"item_name":"French fire","item_subLine":"","toppings_with_price":["hahaha"],"toppings":[],"quantity":1,"selected":false,"price":44.99,"custpmer_remarks":"","printer_name":"","printer_label":"","station":"","food_stampable":"","items":[{"order_invoice_id":"","item_amount":0,"item_name":"Render mest","item_subLine":"","toppings_with_price":["hahaha"],"toppings":["Salt","Extra sauce","Chilli"],"quantity":0,"selected":false,"price":0,"custpmer_remarks":"","printer_name":"","printer_label":"","station":"","food_stampable":"","items":["we"],"print_description":"","deleted":false,"exists":false,"display_index":0,"is_printed":false,"made_to":false,"menu_group":["hahaha"],"kitchen_print":false}],"print_description":"","deleted":false,"exists":false,"display_index":0,"is_printed":false,"made_to":false,"menu_group":"Combo~10","kitchen_print":false}]}},{"type":"setting","data":{"printer_name":["EPSON TM-T81 Receipt"],"print_type":"","item_length":30,"print_logo":false,"thankyou_note":"","thankyou_note2":"","printer_type":"POS"}},{"type":"separator","data":{"separator_length":""}},{"type":"columndetails","data":{"columnheader":{"column1":"Tax","column2":"Over","column3":"","column4":"tax"},"columndata":[{"column1":"0%","column2":"0,00","column3":"","column4":"0,00"},{"column1":"9%","column2":"10,00","column3":"","column4":"0,83"},{"column1":"21%","column2":"0,00","column3":"","column4":"0,00"},{"column1":"Total","column2":"10,00","column3":"","column4":"0,83"}]}},{"type":"Receipt","data":{"align":"center","receipt_text":["hahaha"]}},{"type":"separator","data":{"separator_length":""}},{"type":"footer","data":{"align":"center","footer_text":["Hotsport development agency","350012, near dinning hall","Bookdev","Gujrat","BTN - 85823648","petorlrec@12gmail.com"]}},{"type":"logo","data":{"url":"https://pos.tradywork.com/images/22bef43a88f72e2a0e57992865302ba4.png"}}]}"""
;
    setState(() {
      complexTutorial = Autogenerated.fromJson(jsonDecode(complexText));
    });

    print(complexTutorial);
    // checkprinterlist();
  }
Autogenerated complexTutorial;
 // Restaurant complexTutorial;
   data()async{

    
       final dataList = await dbPrinterManager.getprinterList();

    localdatalist = dataList
        .map(
          (item) => Printer(
            address: item.address, name: item.name,

            ip: item.ip,
            lic: item.lic,
            url: item.url,
            // difficulty: item['difficulty'],
          ),
        )
        .toList();
     if (localdatalist.length == 0|| localdatalist.last.url == null)
// if (widget.urlchangetext == "" || widget.urlchangetext == null)
    {
     
      setState(() {
         url_Text = "https://techsapphire.net";
        urltext.text = url_Text;
          iptext.text =localurlip;
        //  iptext.text = widget.ip_text;
      });
    } else {
      
      //urltext.text;
     
      setState(() {
url_Text = localdatalist.last.url;
        // url_Text = localul;
        urltext.text = localdatalist.last.url;
        iptext.text = localdatalist.last.ip;
        // iptext.text =localurlip;
      });
    }  setState(() {
      _loading = false;
    });
    }
  bool deviceAdd = false;
var url = "https://techsapphire.net/2815-2/" ;
fetchdata() async{
  final http.Response response = await http.get(url);
  // response.contain("");
// var  data = json.decode(response.body);

  
  setState(() {
      response.body.contains('51e7ce01b5e9d919');
      print( response.body.contains('3234dfsvsdf2'));
      deviceAdd = response.body.contains('51e7ce01b5e9d919');
    });
      if(deviceAdd == true){
 _timerForInter = Timer.periodic(Duration(minutes: 2), (result) {
      appAds.showVideoAd(state: this);
      // _interstitialAd = createInterstitialAd()
      //             ..load()
      //             ..show();
    });
    }
  //  print(data);
}
  getappid() async {
    String projectAppID;
// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      projectAppID = await GetVersion.appID;
      print(projectAppID);
    } on PlatformException {
      projectAppID = 'Failed to get app ID.';
    }
  }
String getdeviceid;
  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      
      setState(() {
           getdeviceid =   androidDeviceInfo.androidId; 
            });
    }
  }

  List<Printer> localdatalist = [];
  Future<void> fetchAprinterdata() async {
    final dataList = await dbPrinterManager.getprinterList();

    localdatalist = dataList
        .map(
          (item) => Printer(
            address: item.address, name: item.name,

            ip: item.ip,
            lic: item.lic,
            url: item.url,
            // difficulty: item['difficulty'],
          ),
        )
        .toList();

    setState(() {
      localurlip = localdatalist.last.ip;
      localul = localdatalist.last.url;
      iptext.text = localurlip;
      urltext.text = localul;
     
    });

    print(printertype);
//  return  setUrlValue();
  }

  @override
  void dispose() {
    _timerForInter.cancel();
    //  _interstitialAd.dispose();

    super.dispose();
  }

  String url_Text;
  String localTestUrl;
// getip() async
// {

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setString('ip', widget.ip_text);
//    setState(() {
//     widget.ip_text  = prefs.getString('ip');

//     });
//     setUrlValue();
// }
  String localurlip;
  String localul;
  setUrlValue() async {
    if (urltext.text == "" || urltext.text == null)
// if (widget.urlchangetext == "" || widget.urlchangetext == null)
    {
      url_Text = "https://techsapphire.net";
      setState(() {
        urltext.text = url_Text;
        //   iptext.text =localurlip;
        //  iptext.text = widget.ip_text;
      });
    } else {
      url_Text = urltext.text;
      //widget.urlchangetext;
      setState(() {
        // url_Text = localul;
        urltext.text = url_Text;
        iptext.text = localurlip;
        // iptext.text =localurlip;
      });
    }
  }

  void discover(BuildContext ctx) async {
    setState(() {
      isDiscovering = true;
      devices.clear();
      found = -1;
    });

    String ip;
    try {
      ip = await Wifi.ip;
      print('local ip:\t$ip');
    } catch (e) {
      final snackBar = SnackBar(
          content: Text('WiFi is not connected', textAlign: TextAlign.center));
      Scaffold.of(ctx).showSnackBar(snackBar);
      return;
    }
    setState(() {
      localIp = ip;
    });

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    int port = 9100;
    try {
      port = int.parse(portController.text);
    } catch (e) {
      portController.text = port.toString();
    }
    print('subnet:\t$subnet, port:\t$port');

    final stream = NetworkAnalyzer.discover2(subnet, port);

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}');
        setState(() {
          devices.add(addr.ip);
          found = devices.length;
        });
      }
    })
      ..onDone(() {
        setState(() {
          isDiscovering = false;
          found = devices.length;
        });
      })
      ..onError((dynamic e) {
        final snackBar = SnackBar(
            content: Text('Unexpected exception', textAlign: TextAlign.center));
        Scaffold.of(ctx).showSnackBar(snackBar);
      });
  }

  Autogenerated restaurant;

  var printerlist;
  var seen = Set<String>();
List<PrinterType> printertype =[];
  var itemdatalist;
String blname;
  var datalist;
  var datalistitem;
  var datalistsummary;
  var databigsummary;
  var taxlist;
  var footerlist;
  Future<void> testReceipt(NetworkPrinter printer) async {
    printer.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: 'CP1252'));
    printer.text('Special 2: blåbærgrød',
        styles: PosStyles(codeTable: 'CP1252'));

    printer.text('Bold text', styles: PosStyles(bold: true));
    printer.text('Reverse text', styles: PosStyles(reverse: true));
    printer.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    printer.text('Align left', styles: PosStyles(align: PosAlign.left));
    printer.text('Align center', styles: PosStyles(align: PosAlign.center));
    printer.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    printer.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    // Print image
    // final ByteData data = await rootBundle.load('assets/logo.png');
    // final Uint8List bytes = data.buffer.asUint8List();
    // final Image image = decodeImage(bytes);
    // printer.image(image);
    // Print image using alternative commands
    // printer.imageRaster(image);
    // printer.imageRaster(image, imageFn: PosImageFn.graphics);

    // Print barcode
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    printer.barcode(Barcode.upcA(barData));

    // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
    // printer.text(
    //   'hello ! 中文字 # world @ éphémère &',
    //   styles: PosStyles(codeTable: PosCodeTable.westEur),
    //   containsChinese: true,
    // );

    printer.feed(2);
    printer.cut();
  }

  void submitStudent(BuildContext context) {
   
    if (_formkey.currentState.validate()) {
      if (prt == null) {
        Printer st = new Printer(
            name: printername.text,
            address: printeraddress.text,
            ip: iptext.text,
            lic: lictext.text,
            url: urltext.text);
        dbPrinterManager.insertprinter(st).then((value) => {
              printername.clear(),
              printeraddress.clear(),
              print("printerlist Data Add to database $value"),
            });
      } else {
        prt.name = printername.text;
        prt.address = printeraddress.text;
        prt.ip = iptext.text;
        prt.lic = lictext.text;
        prt.url = urltext.text;
        // dbStudentManager.update(prt).then((value) {
        //   setState(() {
        //     prtlist[updateindex].name = printername.text;
        //     prtlist[updateindex].address = printeraddress.text;
        //   });
        //   printername.clear();
        //   printeraddress.clear();
        //   prt = null;
        // });
      }
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Lanprint1(
                // urlchangetext: localdatalist[0].url,
                // ip_text: localdatalist[0].ip,
                )),
        (route) => false);
  }

  void submitprinterdetails(BuildContext context) {
    if (_formkey.currentState.validate()) {
      if (prt == null) {
        Printer st = new Printer(
            name: printername.text,
            address: printeraddress.text,
            ip: iptext.text,
            lic: lictext.text,
            url: urltext.text);
        dbPrinterManager.insertprinter(st).then((value) => {
              printername.clear(),
              printeraddress.clear(),
              print("printerlist Data Add to database $value"),
            });
      } else {
        prt.name = printername.text;
        prt.address = printeraddress.text;
        prt.ip = iptext.text;
        prt.lic = lictext.text;
        prt.url = urltext.text;
        // dbStudentManager.update(prt).then((value) {
        //   setState(() {
        //     prtlist[updateindex].name = printername.text;
        //     prtlist[updateindex].address = printeraddress.text;
        //   });
        //   printername.clear();
        //   printeraddress.clear();
        //   prt = null;
        // });
      }
    }
  }

  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    for (int j = 0; j < restaurant.data.length; j++) {
      if (restaurant.data[j].type == "header") {
        datalist = restaurant.data[j].data;
        printer.row([
          PosColumn(
              text: "#" + datalist.ticketNo,
              width: 7,
              styles:
                  PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
          PosColumn(
            text: '',
            width: 5,
            styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2),
          ),
        ]);
        printer.row([
          PosColumn(
              text: "#" + datalist.billNo,
              width: 8,
              styles:
                  PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
          PosColumn(
            text: '',
            width: 4,
            styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2),
          ),
        ]);
        printer.hr();
        printer.row([
          PosColumn(
              text: "POS",
              width: 7,
              styles:
                  PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
          PosColumn(
            text: '',
            width: 5,
            styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2),
          ),
        ]);
        printer.row([
          PosColumn(
              text: datalist.dateOfBill + " " + datalist.time,
              width: 10,
              styles:
                  PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2),
          ),
        ]);
        printer.hr();

        printer.row([
          PosColumn(
              text: "Selected Item",
              width: 12,
              styles: PosStyles(
                  bold: true, align: PosAlign.right, width: PosTextSize.size1)),
        ]);
      }
      if (restaurant.data[j].type == "item") {
        datalistitem = restaurant.data[j].data;
        for (int k = 0; k < datalistitem.itemdata.length; k++) {
          var printsplit = splitByLength(datalistitem.itemdata[k].itemName, 30);
          printer.text("");
          printer.row([
            PosColumn(
                text: datalistitem.itemdata[k].quantity.toString() +
                    " x " +
                    printsplit[0],
                width: 8,
                styles: PosStyles(
                    bold: true,
                    align: PosAlign.left,
                    width: PosTextSize.size1)),
            PosColumn(
                text: datalistitem.itemdata[k].itemAmount.toString(),
                width: 4,
                styles:
                    PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
          ]);
          if (printsplit.length > 1) {
            int skip = 1;
            for (int t = 1; t < printsplit.length; t++) {
              printer.row([
                PosColumn(
                    text: printsplit[t],
                    width: 12,
                    styles: PosStyles(
                        align: PosAlign.left, width: PosTextSize.size1)),
              ]);
              // bluetooth.printLeftRight(
              //     printsplit[t], "", 1,
              //     format: "%-30s %15s %n");

            }
          }
          for (int l = 0; l < datalistitem.itemdata[k].toppings.length; l++) {
            printer.row([
              PosColumn(
                  text: "  " + "x " + datalistitem.itemdata[k].toppings[l],
                  width: 10,
                  styles: PosStyles(
                      align: PosAlign.left, width: PosTextSize.size1)),
              PosColumn(
                  text: "",
                  width: 2,
                  styles: PosStyles(
                      align: PosAlign.right, width: PosTextSize.size1)),
            ]);
          }
          for (int m = 0; m < datalistitem.itemdata[k].items.length; m++) {
            printer.row([
              PosColumn(
                  text: datalistitem.itemdata[k].items[m].itemName,
                  width: 10,
                  styles: PosStyles(
                      align: PosAlign.left, width: PosTextSize.size1)),
              PosColumn(
                  text: "",
                  width: 2,
                  styles: PosStyles(
                      align: PosAlign.right, width: PosTextSize.size1)),
            ]);
            for (int n = 0;
                n < datalistitem.itemdata[k].items[m].toppings.length;
                n++) {
              printer.row([
                PosColumn(
                    text: "  " +
                        "x " +
                        datalistitem.itemdata[k].items[m].toppings[n],
                    width: 10,
                    styles: PosStyles(
                        align: PosAlign.left, width: PosTextSize.size1)),
                PosColumn(
                    text: "",
                    width: 2,
                    styles: PosStyles(
                        align: PosAlign.right, width: PosTextSize.size1)),
              ]);
            }
          }
        }
        printer.hr();
      }
      if (restaurant.data[j].type == "summary") {
        datalistsummary = restaurant.data[j].data;
        //  printer.hr();
        printer.row([
          PosColumn(
              text: datalistsummary.summary[0].key,
              width: 5,
              styles:
                  PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
          PosColumn(
              text: datalistsummary.summary[0].value.toString(),
              width: 7,
              styles:
                  PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
        ]);
        printer.hr();
      }
      if (restaurant.data[j].type == "bigsummary") {
        databigsummary = restaurant.data[j].data;
        for (int e = 0; e < databigsummary.bigsummary.length; e++) {
          printer.row([
            PosColumn(
                text: databigsummary.bigsummary[e].key,
                width: 5,
                styles: PosStyles(
                    bold: true,
                    align: PosAlign.left,
                    width: PosTextSize.size1)),
            PosColumn(
                text: databigsummary.bigsummary[e].value.toString(),
                width: 7,
                styles: PosStyles(
                    bold: true,
                    align: PosAlign.right,
                    width: PosTextSize.size1)),
          ]);
        }
        printer.hr();
      }
      if (restaurant.data[j].type == "columndetails") {
        taxlist = restaurant.data[j].data;
        printer.row([
          PosColumn(
              text: taxlist.columnheader.column1,
              width: 4,
              styles: PosStyles(
                  bold: true, align: PosAlign.left, width: PosTextSize.size1)),
          PosColumn(
              text: taxlist.columnheader.column2,
              width: 5,
              styles: PosStyles(
                  bold: true,
                  align: PosAlign.center,
                  width: PosTextSize.size1)),
          // PosColumn(
          //     text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right,width: PosTextSize.size1)),
          PosColumn(
              text: taxlist.columnheader.column4,
              width: 3,
              styles: PosStyles(
                  bold: true, align: PosAlign.right, width: PosTextSize.size1)),
        ]);
        for (int k = 0; k < taxlist.columndata.length; k++) {
          printer.row([
            PosColumn(
                text: taxlist.columndata[k].column1,
                width: 4,
                styles: PosStyles(
                    bold: true,
                    align: PosAlign.left,
                    width: PosTextSize.size1)),
            PosColumn(
                text: taxlist.columndata[k].column2,
                width: 5,
                styles: PosStyles(
                    bold: true,
                    align: PosAlign.center,
                    width: PosTextSize.size1)),
            PosColumn(
                text: taxlist.columndata[k].column4,
                width: 3,
                styles: PosStyles(
                    bold: true,
                    align: PosAlign.right,
                    width: PosTextSize.size1)),
          ]);
        }
        printer.hr();
      }
      if (restaurant.data[j].type == "footer") {
        footerlist = restaurant.data[j].data;
        for (int d = 0; d < footerlist.footerText.length; d++) {
          printer.row([
            PosColumn(
                text: footerlist.footerText[d],
                width: 11,
                styles: PosStyles(
                    bold: true,
                    align: PosAlign.center,
                    width: PosTextSize.size1)),
            PosColumn(
              text: '',
              width: 1,
              styles: PosStyles(
                  bold: true, align: PosAlign.right, width: PosTextSize.size1),
            ),
          ]);
        }
      }
      //  if (restaurant.data[j].type == "setting"){
      //    printer.text("kamal");
      //  }
    }
    printer.feed(1);
    printer.cut();
  }

  double sd = 11.5;
  double sds = 0.5;
  Future<void> cashDemoReceipt(NetworkPrinter printer) async {}
  List<String> splitByLength(String value, int length) {
    List<String> pieces = [];

    for (int i = 0; i < value.length; i += length) {
      int offset = i + length;
      pieces.add(
          value.substring(i, offset >= value.length ? value.length : offset));
    }
    return pieces;
  }

  void testPrint(String printerIp, BuildContext ctx) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      // DEMO RECEIPT
      await printDemoReceipt(printer);
      await cashDemoReceipt(printer);
      // TEST PRINT
      // await testReceipt(printer);
      printer.disconnect();
    }

    // final snackBar =
    //     SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
    // Scaffold.of(ctx).showSnackBar(snackBar);
  }

  _launchURL() async {
    const url = 'https://techsapphire.net/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchmail() async {
    const url = 'mailto:contact@techsapphire.net';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchphone() async {
    const url = 'tel://+91-9360223756';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  var urlText;
  bool isANumber = true;
  WebViewController controller;
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  bool radioitem = false;
  @override
  Widget build(BuildContext context) {
    void setValidator(valid) {
      setState(() {
        isANumber = valid;
      });
    }

    double width = MediaQuery.of(context).size.width;
    return WillPopScope( onWillPop:()async{
  if (await controller.canGoBack()){
          await controller.goBack();
          return false;
        }else{
 return true;
        }
    } ,child:  Scaffold(
      key: _key,
      drawer: Drawer(
        child: Scaffold(
            bottomNavigationBar: Padding(
                padding: EdgeInsets.only(left: 50, right: 50),
                child: RaisedButton(
                    color: Color(0xff0D2F69),
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      "SAVE",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () async {
                      printertype.add(new PrinterType(iptext.text, blname));
                      submitStudent(context);
//                SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setString('ip', iptext.text);
//    prefs.setString('ul', urltext.text);
//   setState(() {
//        localurlip = prefs.getString('ip');
//        localul = prefs.getString('ul');
//        iptext.text=localurlip;
//        urltext.text=localul;
//     });
// //  Navigator.pop(context);
//                   Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => Lanprint1(
//                                 urlchangetext: localul,
//                                 ip_text: localurlip,
//                               )),
//                       (route) => false);
                    })),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
                actions: [
                  Row(
                    children: [
                       IconButton(
                      icon: Icon(Icons.list),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                                backgroundColor: Color(0xffD5E2F1),
                                //title: Center(child: Text("Kitchen printer",style: TextStyle(fontWeight: FontWeight.bold),)),
                                content: Container(
                                    color: Color(0xffD5E2F1),
                                    height: 250,
                                    child: ListView.builder(
        itemCount: printertype.length,
        itemBuilder: (BuildContext context,int index){
          return ListTile(
            leading: Icon(Icons.list),
            trailing: Text("GFG",
                           style: TextStyle(
                             color: Colors.green,fontSize: 15),),
            title:Text("List item $index")
            );
        }
        ),)));
                      }),
 IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                                backgroundColor: Color(0xffD5E2F1),
                                //title: Center(child: Text("Kitchen printer",style: TextStyle(fontWeight: FontWeight.bold),)),
                                content: Container(
                                    color: Color(0xffD5E2F1),
                                    height: 250,
                                    child: Column(
                                      children: [
                                        Image.asset("asset/techlogo.png"),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        FlatButton(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onPressed: () {
                                              _launchURL();
                                            },
                                            child: Text(
                                              "https://techsapphire.net/",
                                              style: TextStyle(
                                                  color: Color(0xff0D2F69),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            )),
                                        FlatButton(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onPressed: () {
                                            _launchmail();
                                          },
                                          child: Text(
                                              "contact@techsapphire.net",
                                              style: TextStyle(
                                                  color: Color(0xff0D2F69),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        ),
                                        FlatButton(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onPressed: () {
                                            _launchphone();
                                          },
                                          child: Text("Call us +91-9360223756",
                                              style: TextStyle(
                                                  color: Color(0xff0D2F69),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        ),
                                        Text(getdeviceid)
                                      ],
                                    ))));
                      })
                    ],
                  )
                 
                ],
                backgroundColor: Color(0xff0D2F69),
                title: Center(
                  child: Text(
                    "Printer Detials",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )),
            body: SingleChildScrollView(
                child: Container(
                    color: Color(0xffD5E2F1),
                    child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 20, left: 30, right: 30),
                              child: TextField(
                                controller: urltext,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: 'Url',
                                  hintText: 'Url',
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 10, left: 30, right: 30),
                              child: TextField(
                                controller: lictext,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: 'License no.',
                                  hintText: 'License no.',
                                ),
                              ),
                            ),
                          radioitem == true?Container(
         height: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Expanded(
                      child: DropdownButton(
                        items: _getDeviceItems(),
                        onChanged: (value) => setState(() => _device = value),
                        value: _device,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.brown),
                      onPressed: () {
                        initPlatformState();
                      },
                      child: Text(
                        'Refresh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: _connected ? Colors.red : Colors.green),
                      onPressed: _connected ? _disconnect : _connect,
                      child: Text(
                        _connected ? 'Disconnect' : 'Connect',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(primary: Colors.brown),
                //     onPressed: () {
          
                //     },
                //     child: Text('PRINT TEST',
                //         style: TextStyle(color: Colors.white)),
                //   ),
                // ),
              ],
            ),
          ),
        ):   Padding(
                              padding:
                                  EdgeInsets.only(top: 10, left: 30, right: 30),
                              child: TextField(
                                controller: iptext,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                  labelText: 'IP no.',
                                  hintText: 'IP no.',
                                ),
                              ),
                            ),
     Padding(
                              padding:
                                  EdgeInsets.only(top: 20, left: 30, right: 30),child:   Row(children: [
  Checkbox(
            value: radioitem,
            onChanged: (bool value) {
                setState(() {
                    radioitem = value;
                    print(radioitem);
                });
            },
        ),
        Text("Bluetooth")
       ],) ) ,
   
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 10, left: 30, right: 30),
                                child: ListTile(
                                  title: Text(
                                    "Kitchen",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        size: 25,
                                        color: Color(0xff0D2F69),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                new AlertDialog(
                                                    backgroundColor:
                                                        Color(0xffD5E2F1),
                                                    title: Center(
                                                        child: Text(
                                                      "Kitchen printer",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                    content: Container(
                                                        color:
                                                            Color(0xffD5E2F1),
                                                        height: 250,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(15),
                                                              child: TextField(
                                                                onChanged:
                                                                    (inputValue) {
                                                                  if (inputValue
                                                                      .isEmpty) {
                                                                    setValidator(
                                                                        true);
                                                                  } else {
                                                                    setValidator(
                                                                        false);
                                                                  }
                                                                },
                                                                controller:
                                                                    printername,
                                                                decoration:
                                                                    InputDecoration(
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  filled: true,
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  labelText:
                                                                      'Printer Name',
                                                                  hintText:
                                                                      'Printer Name',
                                                                  //  errorText: isANumber ? null : "Please enter a printer name first"
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(15),
                                                              child: TextField(
                                                                onChanged:
                                                                    (inputValue) {
                                                                  if (inputValue
                                                                      .isEmpty) {
                                                                    setValidator(
                                                                        true);
                                                                  } else {
                                                                    setValidator(
                                                                        false);
                                                                  }
                                                                },
                                                                controller:
                                                                    printeraddress,
                                                                decoration:
                                                                    InputDecoration(
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  filled: true,
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  labelText:
                                                                      'Printer address',
                                                                  hintText:
                                                                      'Printer address',
                                                                  // errorText: isANumber ? null : "Please enter a printer name first"
                                                                ),
                                                              ),
                                                            ),
                                                            RaisedButton(
                                                                color: Color(
                                                                    0xff0D2F69),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      new BorderRadius
                                                                              .circular(
                                                                          18.0),
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                child: Text(
                                                                  "SUBMIT",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  submitprinterdetails(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                })
                                                          ],
                                                        ))));
                                      }),
                                )),
                            FutureBuilder(
                              future: dbPrinterManager.getprinterList(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  prtlist = snapshot.data;
                                
                                    return Padding(
                                        padding: EdgeInsets.only(),
                                        child: Container(
                                            color: Color(0xffD5E2F1),
                                            height: 300,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: prtlist == null
                                                  ? 0
                                                  : prtlist.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                Printer st = prtlist[index];
                                                  if (st.name == "" &&
                                      st.address == "") {
                                    return Text("");
                                  } else {
                                                return Card(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Container(
                                                          width: width * 0.50,
                                                          child: Column(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Name: ${st.name}'),
                                                              Text(
                                                                  'Address: ${st.address}'),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          dbPrinterManager
                                                              .deleteprinter(
                                                                  st.id);
                                                          setState(() {
                                                            prtlist.removeAt(
                                                                index);
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.delete,
                                                          color:
                                                              Color(0xff0D2F69),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );}
                                              },
                                            )));
                                  }
                                
                                return CircularProgressIndicator();
                              },
                            )
                          ],
                        ))))),
      ),
      body: Stack(
        children: [
          _loading!=true?
       new   WebView(
              initialUrl: url_Text,
              javascriptMode: JavascriptMode.unrestricted,
               onWebViewCreated: (WebViewController wc){
               controller = wc;
             },
              javascriptChannels: <JavascriptChannel>{
                JavascriptChannel(
                    name: 'messageHandler',
                    onMessageReceived: (JavascriptMessage message) async {
                       bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printImage(pathImage);
        bluetooth.printNewLine();
       bluetooth.printCustom("Food Store", 1, 1);
        bluetooth.printCustom("#214 near deop store ", 1, 1);
          bluetooth.printCustom("Phn no. - 90790877896", 1, 1);
           bluetooth.printLeftRight(
                            "________________________________________________",
                            "",
                            1);

                        bluetooth.printLeftRight(
                            "Bill id:", "465", 1,
                            format: "%-25s %15s %n");
                        bluetooth.write("________________________________________________");
                            
                        bluetooth.printLeftRight("Time","2/09/2022", 1,
                            format: "%-25s %15s %n");
                        bluetooth.printLeftRight(
                            "Employee", "Colin", 1,
                            format: "%-25s %15s %n");
                        bluetooth.printLeftRight("Terminal", "23", 1,
                            format: "%-25s %15s %n");
                             bluetooth.printLeftRight("Average", "", 1,
                            format: "%10s %40s %n");
                             bluetooth.write("------------------------------------------------");
                             bluetooth.printLeftRight(
                             "12" +
                                  " x " +
                              "Cheese chilly",
                             //  datalistitem.itemdata[k].itemName,
                              "1",
                              1,
                              format: "%-30s %15s %n");
                               bluetooth.write("------------------------------------------------");
                       // bluetooth.write("---------------------------------------------------------");
                        bluetooth.printLeftRight("SubTotal",
                            "124.67", 1,
                            format: "%-25s %15s %n");
                             bluetooth.printLeftRight("Tax.",
                            "45.04", 1,
                            format: "%-25s %15s %n");
                    
                           bluetooth.printLeftRight("Total",
                            "170.67", 1,
                            format: "%-25s %15s %n");
                             bluetooth.write("------------------------------------------------");
                           bluetooth.printCustom("Thank You", 2, 1);
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
                      print(message.message);
                      setState(() {
                        restaurant = complexTutorial;
                      //      Restaurant.fromJson(jsonDecode(message.message));
                      });

                      print(restaurant);
                      testPrint(localdatalist.last.ip, context);
                    })
              }):Text(""),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _key.currentState.openEndDrawer();
                },
                child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(0xffcccfc4),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(60.0),
                      ),
                    ),
                    child: Icon(
                      Icons.menu,
                      size: 30,
                      color: Color(0xffcccfc4),
                    )),
              )
            ],
          ),
        ],
      ),
     ) );
  }
    List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
       
      });
      
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected)async {
        if (!isConnected) {
             SharedPreferences prefs = await SharedPreferences.getInstance();
           prefs.setString('bluname', _device.name);
       setState(() {
                blname=  prefs.getString("bluname");
         print(blname);
              });  
            //  if (blname==null){
   bluetooth.connect(_device).catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
            //  }
          // bluetooth.connect(blname).catchError((error) {
          //   setState(() => _connected = false);
          // });
          // setState(() => _connected = true);
        
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  
  }
}
