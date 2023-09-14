import 'dart:convert';

import 'package:coba_crud/page/add.dart';
import 'package:coba_crud/page/edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  List items = [];
  bool isLoading = false;
  void initState() {
    // TODO: implement initState
    allData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List")),
      body: Visibility(
        visible: isLoading,
        replacement: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return LinearProgressIndicator();
          },
        ),
        child: RefreshIndicator(
          onRefresh: allData,
          child: items.length == 0
              ? Center(
                  child: Text("Tidak ada data"),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map;
                    final id = item['_id'] as String;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text("${index + 1}"),
                      ),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            navigateToEditPage(item);
                            // print("Edit page menuju");
                          } else if (value == 'hapus') {
                            deleteByID(id);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Text("Edit"),
                              value: 'edit',
                            ),
                            PopupMenuItem(
                              child: Text("Hapus"),
                              value: 'hapus',
                            ),
                          ];
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddPage(),
        child: Icon(Icons.add),
      ),
    );
  }

  void navigateToAddPage() {
    final route = MaterialPageRoute(
      builder: (context) => AddPage(
        onDataAdded: allData,
      ),
    );
    Navigator.push(context, route);
  }

  void navigateToEditPage(Map item) {
    final route = MaterialPageRoute(
      builder: (context) => EditPage(
        onDataUpdated: allData,
        todo: item,
      ),
    );
    Navigator.push(context, route);
  }

  Future<void> allData() async {
    setState(() {
      isLoading = false;
    });
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {
      setState(() {
        items = [];
      });
    }

    setState(() {
      isLoading = true;
    });
    print(isLoading);
  }

  Future<void> deleteByID(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final resp = await http.delete(uri);
    if (resp.statusCode == 200) {
      allData();
      showMessage("Berhasil", "Data anda berhasil di hapus");
    } else {
      showMessage("Gagal", "Data anda gagal di hapus");
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
    );
    ScaffoldMessenger.of(context).showSnackBar(message);
  }
}
