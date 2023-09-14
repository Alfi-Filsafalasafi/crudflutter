import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;

class EditPage extends StatefulWidget {
  final Function() onDataUpdated;
  final Map? todo;
  const EditPage({super.key, required this.onDataUpdated, this.todo});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  TextEditingController titleC = TextEditingController();
  TextEditingController descC = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    final data = widget.todo;
    final title = data!['title'];
    final desc = data['description'];
    titleC.text = title;
    descC.text = desc;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.todo;

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Data"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleC,
            decoration: InputDecoration(hintText: 'Judul'),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: descC,
            decoration: InputDecoration(hintText: 'Deskripsi'),
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
                backgroundColor: Color.fromARGB(255, 36, 247, 194),
              ),
              onPressed: () => updateData(data!['_id']),
              child: Text(
                "Update",
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
    );
  }

  Future<void> updateData(String id) async {
    //menyembunyikan keyboard
    FocusScope.of(context).unfocus();

    //proses update
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final body = {
      'title': titleC.text,
      'description': descC.text,
      'is_completed': 'false',
    };
    final resp = await http.put(uri, body: jsonEncode(body), headers: {
      'accept': 'application/json',
      'Content-Type': 'application/json'
    });
    if (resp.statusCode == 200) {
      widget.onDataUpdated();
      showMessage("Berhasil", "Anda berhasil mengupdate data");
    } else {
      showMessage("Gagal", "Anda gagal mengupdate data");
    }
  }

  void showMessage(String title, String desc) {
    final message = SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(desc)
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
    );
    ScaffoldMessenger.of(context).showSnackBar(message);
  }
}
