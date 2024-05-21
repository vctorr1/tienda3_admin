import 'package:flutter/material.dart';
import 'package:tienda3_admin/firebase_options.dart';
import 'package:tienda3_admin/views/admin.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Admin(),
  ));
}
