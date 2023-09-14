import 'dart:convert';

import 'package:coba_crud/page/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Function() onDataAdded;
  const AddPage({super.key, required this.onDataAdded});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleC = TextEditingController();
  TextEditingController descC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Data")),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleC,
            decoration: InputDecoration(hintText: "Judul"),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: descC,
            decoration: InputDecoration(hintText: "Deskripsi"),
            maxLines: 8,
            minLines: 5,
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () => addData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 36, 247, 194),
                padding: EdgeInsets.all(20),
              ),
              child: Text(
                "Simpan",
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
    );
  }

  Future<void> addData() async {
    //menyembunyikan keyboard
    FocusScope.of(context).unfocus();

    //proses penambahan data
    final title = titleC.text;
    final desc = descC.text;
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final body = {'title': title, 'description': desc, 'is_completed': 'false'};
    final resp = await http.post(uri, body: jsonEncode(body), headers: {
      'accept': 'application/json',
      'Content-Type': 'application/json'
    });
    if (resp.statusCode == 201) {
      showMessage("Berhasil", "Data anda berhasil ditambahkan");
      titleC.text = "";
      descC.text = "";
      widget.onDataAdded();
    } else {
      showMessage("Gagal", "Data anda gagal ditambahkan");
    }
  }

  void showMessage(String title, String desc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              desc,
            ),
          ],
        ),
        duration: Duration(seconds: 2), // Durasi tampilan snackbar (opsional)
        action: SnackBarAction(
          // Tambahkan tindakan (opsional)
          label: 'Tutup',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
