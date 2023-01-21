import 'package:flutter/material.dart';
import 'package:printerset/dd.dart';
import 'package:printerset/lanprint.dart';


void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        primarySwatch: Colors.blue,
      ),
      home: Lanprint1(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:io' show Platform;
// import 'package:firebase_admob/firebase_admob.dart';

// import 'package:ads/ads.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key key}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   Ads appAds;
//   int _coins = 0;

//   final String appId = Platform.isAndroid
//       ? 'ca-app-pub-3940256099942544~3347511713'
//       : 'ca-app-pub-3940256099942544~1458002511';

//   final String bannerUnitId = Platform.isAndroid
//       ? 'ca-app-pub-3940256099942544/6300978111'
//       : 'ca-app-pub-3940256099942544/2934735716';

//   final String screenUnitId = Platform.isAndroid
//       ? 'ca-app-pub-3940256099942544/1033173712'
//       : 'ca-app-pub-3940256099942544/4411468910';

//   final String videoUnitId = Platform.isAndroid
//       ? 'ca-app-pub-3940256099942544/5224354917'
//       : 'ca-app-pub-3940256099942544/1712485313';

//   @override
//   void initState() {
//     super.initState();

//     /// Assign a listener.
//     var eventListener = (MobileAdEvent event) {
//       if (event == MobileAdEvent.opened) {
//         print("The opened ad is clicked on.");
//       }
//     };

//     appAds = Ads(
//       appId,
//       bannerUnitId: bannerUnitId,
//       screenUnitId: screenUnitId,
//       keywords: <String>['ibm', 'computers'],
//       contentUrl: 'http://www.ibm.com',
//       childDirected: false,
//       testDevices: ['Samsung_Galaxy_SII_API_26:5554'],
//       testing: false,
//       listener: eventListener,
//     );

//     appAds.setVideoAd(
//       adUnitId: videoUnitId,
//       keywords: ['dart', 'java'],
//       contentUrl: 'http://www.publang.org',
//       childDirected: true,
//       testDevices: null,
//       listener: (RewardedVideoAdEvent event,
//           {String rewardType, int rewardAmount}) {
//         print("The ad was sent a reward amount.");
//         setState(() {
//           _coins += rewardAmount;
//         });
//       },
//     );

//     appAds.showBannerAd();
//   }

//   @override
//   void dispose() {
//     appAds.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('AdMob Ad Examples'),
//         ),
//         body: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 RaisedButton(
//                     key: ValueKey<String>('SHOW BANNER'),
//                     child: const Text('SHOW BANNER'),
//                     onPressed: () {
//                       appAds.showBannerAd(state: this, anchorOffset: null);
//                     }),
//                 RaisedButton(
//                     key: ValueKey<String>('REMOVE BANNER'),
//                     child: const Text('REMOVE BANNER'),
//                     onPressed: () {
//                       appAds.hideBannerAd();
//                     }),
//                 RaisedButton(
//                   key: ValueKey<String>('SHOW INTERSTITIAL'),
//                   child: const Text('SHOW INTERSTITIAL'),
//                   onPressed: () {
//                     appAds.showFullScreenAd(state: this);
//                   },
//                 ),
//                 RaisedButton(
//                   key: ValueKey<String>('SHOW REWARDED VIDEO'),
//                   child: const Text('SHOW REWARDED VIDEO'),
//                   onPressed: () {
//                     appAds.showVideoAd(state: this);
//                   },
//                 ),
//                 Text(
//                   "You have $_coins coins.",
//                   key: ValueKey<String>('COINS'),
//                 ),
//               ].map((Widget button) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   child: button,
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }