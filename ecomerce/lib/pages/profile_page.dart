import 'package:flutter/material.dart';  // wajib import ini supaya bisa pakai StatefulWidget, BuildContext, dll

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);  // kalau pakai super.key, harus import material.dart dulu

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman Profil', style: TextStyle(fontSize: 24)),
    );
  }
}
