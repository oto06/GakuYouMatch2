import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gakuyoumatch2/Chat.dart';
import 'package:gakuyoumatch2/ChatSelect.dart';
import 'package:gakuyoumatch2/acountregister.dart';
import 'package:gakuyoumatch2/calender.dart';
import 'package:gakuyoumatch2/login.dart';
import 'package:gakuyoumatch2/map%20search.dart';
import 'package:gakuyoumatch2/profile.dart';
import 'package:gakuyoumatch2/rogo.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Firebaseの初期化
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      // 初期画面を指定
      routes: {
        '/initial': (context) => SplashScreen(),
        '/other': (context) => ChatListScreen(),
      },

    );
  }
}


class FirstScene extends StatelessWidget {
   FirstScene({super.key});


   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: Container(
         decoration: const BoxDecoration(
           gradient: LinearGradient(
             colors: [Colors.brown, Colors.orangeAccent],
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
           ),
         ),
         child: Center(
           child: Padding(
             padding: const EdgeInsets.all(20.0),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Container(
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(15),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black26,
                         blurRadius: 10,
                         spreadRadius: 2,
                         offset: Offset(0, 5),
                       ),
                     ],
                   ),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Text(
                         '新規登録',
                         style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown),
                       ),
                       const SizedBox(height: 30),
                       ElevatedButton(
                         onPressed: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => AccountRegister()),
                           );
                         },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.brown,
                           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10),
                           ),
                         ),
                         child: const Text(
                           'Googleアカウントで登録',
                           style: TextStyle(color: Colors.white, fontSize: 16),
                         ),
                       ),
                       const SizedBox(height: 20),
                       ElevatedButton(
                         onPressed: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => LoginScreen()),
                           );
                         },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.orangeAccent,
                           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10),
                           ),
                         ),
                         child: const Text(
                           'ログイン',
                           style: TextStyle(color: Colors.white, fontSize: 16),
                         ),
                       ),
                     ],
                   ),
                 ),
               ],
             ),
           ),
         ),
       ),
     );
   }
}