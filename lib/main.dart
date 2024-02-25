import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'second.dart';


// Future<void> main()  async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
Future<void> _firebadeMessagingBackgroundHandler(RemoteMessage message) async {
  if (message != null) {
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebadeMessagingBackgroundHandler);

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: first(),
    );
  }
}

class first extends StatefulWidget {
  @override
  State<first> createState() => _firstState();
}

class _firstState extends State<first> {
  GoogleSignInAccount? _userObj;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  String url = "";
  String name = "";
  String email = "";
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;

  GoogleSignInAuthentication? googleAuth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/drive.png"),
          SizedBox(
            height: 90,
          ),

          Text(
            'Personal Drive App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: MaterialButton(
              color: Color.fromARGB(255, 255, 255, 255),
              elevation: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              'https://cdn-icons-png.flaticon.com/512/2991/2991148.png'),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Sign In with Google",
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                var f = await signInWithGoogle();
                User? user = _auth.currentUser;
                if (f != null) {
                  var de = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .get();

                  if (de != null) {
                    ref.doc(user.uid).set({
                      'name': name,
                      'url': url,
                      'email': email,
                    });
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => (second(
                        url: url,
                      )),
                    ),
                  );
                }
              },
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(bottom: 50),
          // ),

          // SizedBox(
          //   height: 90,
          // ),
          // Text(
          //   'Made By',
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 15,
          //   ),
          // ),
          //
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text(
          //       'Web',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 35,
          //       ),
          //     ),
          //     Text(
          //       'Fun',
          //       style: TextStyle(
          //         color: Colors.yellow[700],
          //         fontSize: 35,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    print(googleUser);
    url = googleUser!.photoUrl.toString();
    name = googleUser.displayName.toString();
    email = googleUser.email;

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
    await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}