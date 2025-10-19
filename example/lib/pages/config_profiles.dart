import 'package:flutter/material.dart';
import 'package:flutter_sing_box_example/pages/new_remote_profile.dart';

class ConfigProfiles extends StatefulWidget {
  const ConfigProfiles({super.key});

  @override
  State<ConfigProfiles> createState() => _ConfigProfilesState();
}

class _ConfigProfilesState extends State<ConfigProfiles> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _loadProfiles() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅配置'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _popImportOptions();
        },
        child: const Icon(Icons.add),
      ),
      body: const Center(

      )
    );
  }

  void _popImportOptions() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('添加订阅'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (builder) {
                    return const NewRemoteProfile();
                  })
                );
              },
              child: const Text('订阅链接'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('本地文件'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('扫描二维码'),
            ),
          ],
        );
      }
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
