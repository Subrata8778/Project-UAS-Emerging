import 'package:flutter/material.dart';
import 'package:dolan_yuk/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfileScreen(),
      routes: {},
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nama = '';
  String _email = '';
  String _photo = '';
  String error_login = '';
  String userId = "";

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();

  Future<String> checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    String user_id = prefs.getString("user_id") ?? '';
    return user_id;
  }

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420002/DolanYuk/selectUser.php"),
        body: {'users_id': userId.toString()});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    Future<String> data = fetchData();
    data.then((value) {
      Map json = jsonDecode(value);
      setState(() {
        _namaController.text = json['data']['nama'];
        _emailController.text = json['data']['email'];
        _photoController.text = json['data']['photo'];
      });
    });
  }

  Future<void> doLogOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_id", "");
    main();
  }

  @override
  void initState() {
    super.initState();
    Future<String> userOnly = checkUser();
    userOnly.then((value) {
      userId = value;
      bacaData();
    });
  }

  void doUpdate() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420002/DolanYuk/updateUser.php"),
        body: {
          'nama': _namaController.text,
          'photo': _photoController.text,
          'id': userId,
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {});
      } else {
        print(json['message']);
        setState(() {
          error_login = "Gagal update";
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: 700,
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          border: Border.all(width: 1),
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 20)]),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Tulisan Tombol',
              style: TextStyle(fontSize: 16.0),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                doLogOut();
              },
            ),
          ],
        ),
        Container(
          width: 150,
          height: 150,
          child: ClipOval(
            child: Image.network(
              _photoController.text,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: _namaController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap anda disini'),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: _emailController,
            enabled: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                hintText: 'Masukkan email Anda'),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          //padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _photoController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Photo',
                hintText: 'Masukkan url Photo Profile Anda'),
          ),
        ),
        Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: ElevatedButton(
                onPressed: () {
                  doUpdate();
                },
                child: Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            )),
      ]),
    ));
  }
}
