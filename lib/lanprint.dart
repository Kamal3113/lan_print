import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_admob/firebase_admob.dart';
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

const String testDevice = 'MobileId';
class Lanprint extends StatefulWidget {
  String urlchangetext;
   String ip_text;
Lanprint({this.urlchangetext,this.ip_text});

  @override
  State<Lanprint> createState() => _LanprintState();
}

class _LanprintState extends State<Lanprint> {
    static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Game', 'Mario'],
  );

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: BannerAd.testAdUnitId,
      //Change BannerAd adUnitId with Admob ID
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd $event");
        });
  }

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
  @override
  void initState() {
    super.initState();
      _timerForInter = Timer.periodic(Duration(minutes: 8), (result) {
  _interstitialAd = createInterstitialAd()
              ..load()
              ..show();
  //createInterstitialAd()..load();
  });
//     if(widget.ip_text==null||widget.ip_text==""){
//  setUrlValue();
//     }
//     else{
//       getip();
//     }
  // urlText="https://techsapphire.net";
setUrlValue();
  //  main();
 //getip();
  }
   @override
  void dispose() {
    _timerForInter.cancel();
   _interstitialAd.dispose();
//  _bannerAd.dispose();
    // _interstitialAd.dispose();
    super.dispose();
  }
  String url_Text;
String localTestUrl;
getip() async
{
  // SharedPreferences local = await SharedPreferences.getInstance();
    SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('ip', widget.ip_text);
   setState(() {
    widget.ip_text  = prefs.getString('ip');
  
    });
    setUrlValue();
}
String localurltest;
  setUrlValue()async{
  // SharedPreferences local = await SharedPreferences.getInstance();
  // // setState(() {
  //   widget.urlchangetext  = local.getString('localurl');
  
  //   // });
 
   if (widget.urlchangetext == "" || widget.urlchangetext == null) {
      url_Text = "https://techsapphire.net";
      setState(() {
        urltext.text = url_Text;
 iptext.text = widget.ip_text;
      });
 
    }
//      else if(urlText==null||urlText==""){
//  urlText = localTestUrl;
//       setState(() {
//         urltext.text = urlText;
//       });
//     }
     else  {
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
 
  //  setState(() {
  //   widget.ip_text  = prefs.getString('ip');
  
  //   });
      // url_Text = widget.urlchangetext;
      setState(() {
        url_Text = widget.urlchangetext;
        urltext.text = url_Text;
         //iptext.text = localurltest;
       iptext.text = widget.ip_text;
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
  Restaurant restaurant;

  var printerlist;
  var seen = Set<String>();
//   main() {
//     String complexText =

// """{
//     "Total": "15.70",
//     "GrandTotal": "15.70",
//     "BillSummary": [
//         {
//             "key": "Total Item(s)",
//             "value": "1"
//         },
//         {
//             "key": "Discount",
//             "value": "0.00"
//         },
//         {
//             "key": "Delivery",
//             "value": "0.00"
//         },
//         {
//             "key": "VAT 15%",
//             "value": "2.04"
//         },
//         {
//             "key": "Paid Amount",
//             "value": "15.70"
//         }
//     ],
//     "Header": {
//         "HotelName": "TradyWork",
//         "Phone": "Tel: 0532300616",
//         "currency": "SR",
//         "Address": "سيهات - حي الطف - شارع مكه",
//         "Address1": "",
//         "Address2": "",
//         "BillNo": "000076",
//         "DateOfBill": "03/02/2022",
//         "TimeOfBill": "13:21",
//         "OrderType": "Dine In",
//         "Table": "Table 02",
//         "FssaiNo": "",
//         "GSTNo": "",
//         "CustomerRemarks": "",
//         "OrderNote": ""
//     },
//     "Item": [
//         {
//             "No": "107",
//             "ItemAmt": "8.70",
//             "ItemName": "Chicken Chow Mein small mai nahi khana",
//             "alternate_name": "চিকেন চৌ মেইন عربي",
//             "itemaddons": "",
//             "Qty": "1",
//             "menu_note": "",
//             "Rate": "8.70",
//             "modifiers": [
//                 "Beet Salada(3.00)",
//                 "Seasoned Fries(4.00)"
//             ],
//             "printer_name": "XP-80"
//         },
//          {
//             "No": "107",
//             "ItemAmt": "8.70",
//             "ItemName": "Paneer cousine large bottle",
//             "alternate_name": "চিকেন চৌ মেইন عربي",
//             "itemaddons": "",
//             "Qty": "1",
//             "menu_note": "",
//             "Rate": "8.70",
//             "modifiers": [
//                 "Beet Salada(3.00)",
//                 "Seasoned Fries(4.00)"
//             ],
//             "printer_name": "XP-80"
//         }
//     ],
//     "Settings": {
//         "PrinterName": "",
//         "PrinterType": "Default",
//         "customer_no": "1",
//         "ItemLength": 46,
//         "PrintLogo": "https://pos.tradywork.com/images/64981c79510befde7377d6be8d2a53f6.png",
//         "qr_path_content": "AQlET09SIFNIT1ACCTIyMjIyMjIyMgMTMjAyMi0wMi0wM1QxMzoyMTo0MQQCMTYFATI=",
//         "ThankYouNote": "Thank you for visiting us!",
//         "vat_title": "VAT",
//         "vat_no": "222222222",
//         "invoice_no": "000076",
//         "sale_date": "03/02/2022 13:21",
//         "sales_man": "Trady Admin",
//         "customer_name": "Walk-in Customer",
//         "customer_phone": "",
//         "customer_address": "",
//         "payment_name": "Cash",
//         "waiter_name": "Waiter user",
//         "ThankYouNote2": "",
//         "EIDRMK": "",
//         "PrintType": "invoice",
//         "PageSize": "",
//         "auto_print_kot": "1",
//         "auto_print_bot": "1"
//     }
// }"""
// ;
//     setState(() {
//       complexTutorial = Autogenerated.fromJson(jsonDecode(complexText));
//     });

//     print(complexTutorial);
//     checkprinterlist();
//   }

  // Autogenerated complexTutorial;
  var itemdatalist;
  // checkprinterlist() {
  //   setState(() {
  //     printerlist =
  //         complexTutorial.item.where((l) => seen.add(l.printerName)).toList();
  //   });
  //   return seen;

  // }
var datalist;
var datalistitem;
var datalistsummary;
var  databigsummary;  var taxlist; var footerlist;
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
        Printer st =
            new Printer(name: printername.text, address: printeraddress.text);
        dbPrinterManager.insertprinter(st).then((value) => {
              printername.clear(),
              printeraddress.clear(),
              print("printerlist Data Add to database $value"),
            });
      } else {
        prt.name = printername.text;
        prt.address = printeraddress.text;

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
    for (int j = 0; j < restaurant.data.length; j++){
 if (restaurant.data[j].type == "header") {
   datalist = restaurant.data[j].data;
 printer.row([
        PosColumn(
            text:  "#" + datalist.ticketNo,
            width: 7,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
              PosColumn(
          text: '',
          width: 5,
          styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2),
        ),
            
       
      ]);
       printer.row([
        PosColumn(
            text:   "#" + datalist.billNo,
            width: 8,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
         PosColumn(
          text: '',
          width: 4,
          styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2),
        ),
      ]);
      printer.hr();
        printer.row([
        PosColumn(
            text:"POS",
            width: 7,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
         PosColumn(
          text: '',
          width: 5,
          styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2),
        ),
      ]);
         printer.row([
        PosColumn(
            text:datalist.dateOfBill + " " + datalist.time,
            width: 10,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
         PosColumn(
          text: '',
          width: 2,
          styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2),
        ),
      ]); 
      printer.hr();
    
        printer.row([
        PosColumn(
            text:"Selected Item",
            width: 12,
            styles: PosStyles(bold: true, align: PosAlign.right, width: PosTextSize.size1)),
      
      ]);
 }
     if (restaurant.data[j].type == "item") {
                              datalistitem = restaurant.data[j].data;
                               for (int k = 0;
                                  k < datalistitem.itemdata.length;
                                  k++){
                                     var printsplit = splitByLength(
                                    datalistitem.itemdata[k].itemName, 30);
                                      printer.text("");
                                      printer.row([
        PosColumn(
            text:  datalistitem.itemdata[k].quantity
                                            .toString() +
                                        " x " +
                                        printsplit[0],
            width: 8,
            styles: PosStyles(bold: true,align: PosAlign.left, width: PosTextSize.size1)),
        PosColumn(
            text:    datalistitem.itemdata[k].itemAmount
                                        .toString(),
            width: 4,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      ]);
       if (printsplit.length > 1) {
                                  int skip = 1;
                                  for (int t = 1; t < printsplit.length; t++) {
                                                 printer.row([
        PosColumn(
            text:printsplit[t],
            width: 12,
            styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
       
      ]);
                                    // bluetooth.printLeftRight(
                                    //     printsplit[t], "", 1,
                                    //     format: "%-30s %15s %n");
                                  
                                  }
                                }
                                for (int l = 0;
                                    l <
                                        datalistitem
                                            .itemdata[k].toppings.length;
                                    l++){
                     printer.row([
        PosColumn(
            text:"  " + "x " +
                                          datalistitem.itemdata[k].toppings[l],
                                      
            width: 10,
            styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
       PosColumn(
            text: "",
                                      
            width: 2,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      ]);
                                    }
                                      for (int m = 0;
                                    m < datalistitem.itemdata[k].items.length;
                                    m++){
                                          printer.row([
        PosColumn(
            text: datalistitem.itemdata[k].items[m].itemName,
                                      
            width: 10,
            styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
       PosColumn(
            text: "",
                                      
            width: 2,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      ]);
       for (int n = 0;
                                      n <
                                          datalistitem.itemdata[k].items[m]
                                              .toppings.length;
                                      n++){
                                                                           printer.row([
        PosColumn(
            text: "  " + "x " +datalistitem.itemdata[k].items[m].toppings[n],
                                      
            width: 10,
            styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
       PosColumn(
            text: "",
                                      
            width: 2,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      ]);
   
                                      }
                                    }
                                  }
                                     printer.hr();
                              }
                               if (restaurant.data[j].type == "summary"){
                                  datalistsummary = restaurant.data[j].data;
                                 //  printer.hr();
    printer.row([
        PosColumn(
            text: datalistsummary.summary[0].key,
            width: 5,
            styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
        PosColumn(
            text: datalistsummary.summary[0].value.toString(),
            width: 7,
            styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      ]);
      printer.hr();
                               }
                                if (restaurant.data[j].type == "bigsummary") {
                              databigsummary = restaurant.data[j].data;
                                for (int e = 0;
                                  e < databigsummary.bigsummary.length;
                                  e++){
 printer.row([
        PosColumn(
            text: databigsummary.bigsummary[e].key,
            width: 5,
            styles: PosStyles(bold: true,align: PosAlign.left, width: PosTextSize.size1)),
        PosColumn(
            text: databigsummary.bigsummary[e].value.toString(),
            width: 7,
            styles: PosStyles(bold: true,align: PosAlign.right, width: PosTextSize.size1)),
      ]);
                                  }
                                    printer.hr();
                              }
                               if (restaurant.data[j].type == "columndetails") {
                              taxlist = restaurant.data[j].data;
                                printer.row([
      PosColumn(text: taxlist.columnheader.column1, width: 4,styles:PosStyles(bold: true,align: PosAlign.left,width: PosTextSize.size1)),
      PosColumn(text: taxlist.columnheader.column2, width: 5, styles: PosStyles(bold: true,align: PosAlign.center,width: PosTextSize.size1)),
      // PosColumn(
      //     text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right,width: PosTextSize.size1)),
      PosColumn(
          text: taxlist.columnheader.column4, width: 3, styles: PosStyles(bold: true,align: PosAlign.right,width: PosTextSize.size1)),
    ]);
    for (int k = 0;
                                  k < taxlist.columndata.length;
                                  k++){
                                                             printer.row([
      PosColumn(text:  taxlist.columndata[k].column1, width: 4,styles:PosStyles(bold: true,align: PosAlign.left,width: PosTextSize.size1)),
      PosColumn(text:  taxlist.columndata[k].column2, width: 5, styles: PosStyles(bold: true,align: PosAlign.center,width: PosTextSize.size1)),
      
      PosColumn(
          text:  taxlist.columndata[k].column4, width: 3, styles: PosStyles(bold: true,align: PosAlign.right,width: PosTextSize.size1)),
    ]);   
                                  }printer.hr();
                              } if (restaurant.data[j].type == "footer"){
                                  footerlist = restaurant.data[j].data;
                              for (int d = 0;
                                  d < footerlist.footerText.length;
                                  d++) {
 printer.row([
        PosColumn(
            text:footerlist.footerText[d],
            width: 11,
            styles: PosStyles(bold: true,align: PosAlign.center, width: PosTextSize.size1)),
              PosColumn(
          text: '',
          width: 1,
          styles: PosStyles(bold: true,align: PosAlign.right, width: PosTextSize.size1),
        ),
            
       
      ]);
                                  }
                              }
    }
printer.feed(1);
      printer.cut();
  }
double sd = 11.5;
double sds = 0.5;
  Future<void> cashDemoReceipt(NetworkPrinter printer) async{
    
      
  }
    List<String> splitByLength(String value, int length) {
  List<String> pieces = [];

  for (int i = 0; i < value.length; i += length) {
    int offset = i + length;
    pieces.add(value.substring(i, offset >= value.length ? value.length : offset));
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
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
   double width = MediaQuery.of(context).size.width;
    return Scaffold(
       key: _key,
      drawer: Drawer(
        child: Scaffold(
            bottomNavigationBar:Padding(padding: EdgeInsets.only(left: 50,right: 50),child:
             RaisedButton(
              color:Color(0xff0D2F69),
              shape: RoundedRectangleBorder(
                
  borderRadius: new BorderRadius.circular(18.0),
  side: BorderSide(color: Colors.black),
),
                child: Text("SAVE",style: TextStyle( color: Colors.white,fontSize: 16),),
                onPressed: ()async {
                // datasetUrl();
                   SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('ip', iptext.text);
//   setState(() {
//        localurltest = prefs.getString('ip');
//        iptext.text=localurltest;
       
//     });
// Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Lanprint(
                                urlchangetext: urltext.text,
                                ip_text: localurltest,
                              )),
                      (route) => false);
                })),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              actions: [
                IconButton(icon: Icon(Icons.info), onPressed: (){
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
                                                     SizedBox(height: 40,),
                                                        
 FlatButton(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
   onPressed: (){ _launchURL(); }, child: Text("https://techsapphire.net/",style: TextStyle(color: Color(0xff0D2F69),fontWeight: FontWeight.bold,fontSize: 18),)),
                                                    FlatButton(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,onPressed: (){
                                                      _launchmail();
                                                     },
                                                     child: Text("contact@techsapphire.net",style: TextStyle(color: Color(0xff0D2F69),fontWeight: FontWeight.bold,fontSize: 16)),
                                                     
                                                       ) ,
                                                         FlatButton(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,onPressed: (){
                                                      _launchphone();
                                                     },
                                                     child: Text("Call us +91-9360223756",style: TextStyle(color: Color(0xff0D2F69),fontWeight: FontWeight.bold,fontSize: 16)),
                                                     
                                                       )   ],
                                                ))));
                })
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
                        Padding(
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
                                EdgeInsets.only(top: 10, left: 30, right: 30),
                            child: ListTile(
                              title: Text("Kitchen",style: TextStyle(fontWeight: FontWeight.bold),),
                              trailing: IconButton(
                                  icon: Icon(Icons.add,size: 25,
                                color: Color(0xff0D2F69),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => new AlertDialog(
                                           backgroundColor: Color(0xffD5E2F1),
                                            title: Center(child: Text("Kitchen printer",style: TextStyle(fontWeight: FontWeight.bold),)),
                                            content: Container(
                                            color: Color(0xffD5E2F1),
                                                height: 250,
                                                child: Form(
                                                    key: _formkey,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          child: TextField(
                                                            controller:
                                                                printername,
                                                            decoration:
                                                                InputDecoration(
                                                                  fillColor: Colors.white,
                                                                  filled: true,
                                                              border:
                                                                  OutlineInputBorder(),
                                                              labelText:
                                                                  'Printer Name',
                                                              hintText:
                                                                  'Printer Name',
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          child: TextField(
                                                            controller:
                                                                printeraddress,
                                                            decoration:
                                                                InputDecoration(
                                                                  fillColor: Colors.white,
                                                                  filled: true,
                                                              border:
                                                                  OutlineInputBorder(),
                                                              labelText:
                                                                  'Printer address',
                                                              hintText:
                                                                  'Printer address',
                                                            ),
                                                          ),
                                                        ),
                                                          RaisedButton(
             color:Color(0xff0D2F69),
              shape: RoundedRectangleBorder(
                
  borderRadius: new BorderRadius.circular(18.0),
  side: BorderSide(color: Colors.black),
),
                child: Text("SUBMIT",style: TextStyle( color: Colors.white,fontSize: 16),),
                onPressed: ()async {
               submitStudent(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                })
                                                        // RaisedButton(
                                                        //   textColor:
                                                        //       Colors.white,
                                                        //   color: Colors.blue,
                                                        //   child: Text('SUBMIT'),
                                                        //   onPressed: () {
                                                        //     submitStudent(
                                                        //         context);
                                                        //     Navigator.pop(
                                                        //         context);
                                                        //   },
                                                        // )
                                                      ],
                                                    )))));
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
                                    color:Color(0xffD5E2F1),
                                      height: 300,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: prtlist == null
                                            ? 0
                                            : prtlist.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          Printer st = prtlist[index];
                                          return Card(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
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
                                                        .deleteprinter(st.id);
                                                    setState(() {
                                                      prtlist.removeAt(index);
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                   color: Color(0xff0D2F69),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )));
                            }
                            return CircularProgressIndicator();
                          },
                        )
                      ],
                    )))),
      ),
      // appBar: AppBar(
      //   title: Text('Discover Printers'),
      // ),
      body:Stack(children: [

     
      WebView(initialUrl:url_Text ,
       javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: <JavascriptChannel>{
            JavascriptChannel(
                name: 'messageHandler',
                onMessageReceived: (JavascriptMessage message) async{
                   print(message.message);
                   setState(() {
                            restaurant =
                          Restaurant.fromJson(jsonDecode(message.message));               
                                      });
                   
                      print(restaurant);
                  testPrint(widget.ip_text, context);
                })}),
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
                    // decoration: BoxDecoration(
                    //   // color: Color(0xffcccfc4),
                    //   // shape: BoxShape.circle
                    // ), endDrawer: Drawer(
                    //   child: Center(child: Text('Right!')),
                    // ),
                    child: Icon(
                      Icons.menu,
                      size: 30,
                color: Color(0xffcccfc4),
                    )
                    ),
              )
            ],
          ),
                ],),
      //      floatingActionButton: new FloatingActionButton(
      // tooltip: 'Add',
      // child: new Icon(Icons.add),
    
      // onPressed: (){
      //   showDialog(context: context, builder: (ctxt) => new AlertDialog(content: 
      //   Container(
      //     height: 600,
      //     width: 1500,
      //     child: 
      //    Builder(
      //   builder: (BuildContext context) {
      //     return Container(
      //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: <Widget>[
      //           TextField(
      //             controller: portController,
      //             keyboardType: TextInputType.number,
      //             decoration: InputDecoration(
      //               labelText: 'Port',
      //               hintText: 'Port',
      //             ),
      //           ),
      //           SizedBox(height: 10),
      //           Text('Local ip: $localIp', style: TextStyle(fontSize: 16)),
      //           SizedBox(height: 15),
      //           RaisedButton(
      //               child: Text(
      //                   '${isDiscovering ? 'Discovering...' : 'Discover'}'),
      //               onPressed: isDiscovering ? null : () => discover(context)),
      //           SizedBox(height: 15),
      //           found >= 0
      //               ? Text('Found: $found device(s)',
      //                   style: TextStyle(fontSize: 16))
      //               : Container(),
      //           Expanded(
      //             child: ListView.builder(
      //               itemCount: devices.length,
      //               itemBuilder: (BuildContext context, int index) {
      //                 return InkWell(
      //                   onTap: () => testPrint(devices[index], context),
      //                   child: Column(
      //                     children: <Widget>[
      //                       Container(
      //                         height: 60,
      //                         padding: EdgeInsets.only(left: 10),
      //                         alignment: Alignment.centerLeft,
      //                         child: Row(
      //                           children: <Widget>[
      //                             Icon(Icons.print),
      //                             SizedBox(width: 10),
      //                             Expanded(
      //                               child: Column(
      //                                 crossAxisAlignment:
      //                                     CrossAxisAlignment.start,
      //                                 mainAxisAlignment:
      //                                     MainAxisAlignment.center,
      //                                 children: <Widget>[
      //                                   Text(
      //                                     '${devices[index]}:${portController.text}',
      //                                     style: TextStyle(fontSize: 16),
      //                                   ),
      //                                   Text(
      //                                     'Click to print a test receipt',
      //                                     style: TextStyle(
      //                                         color: Colors.grey[700]),
      //                                   ),
      //                                 ],
      //                               ),
      //                             ),
      //                             Icon(
      //                               Icons.chevron_right,
      //                               color: Colors.red,
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                       Divider(),
      //                     ],
      //                   ),
      //                 );
      //               },
      //             ),
      //           )
      //         ],
      //       ),
      //     );
      //   },
      // )),));
     
      //   }     
      // ),   
     
    );
  }
}