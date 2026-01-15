import 'package:flutter/material.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box_example/pages/new_remote_profile.dart';

class ConfigProfiles extends StatefulWidget {
  const ConfigProfiles({super.key});

  @override
  State<ConfigProfiles> createState() => _ConfigProfilesState();
}

class _ConfigProfilesState extends State<ConfigProfiles> {
  final ScrollController _scrollController = ScrollController();
  final List<Profile> profiles = [];
  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    profiles.clear();
    profiles.addAll(
        ProfileManager().getProfiles()
    );
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅配置'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // _popImportOptions();
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (builder) {
                return const NewRemoteProfile();
              })
          );
          _loadProfiles();
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
      child: profiles.isEmpty
          ? const Text('暂无配置文件')
          : ListView.builder(
              controller: _scrollController,
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return ListTile(
                  title: Text(profile.name),
                  subtitle: Text(DateTime.fromMillisecondsSinceEpoch(profile.typed.lastUpdated).toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // TODO: 实现删除配置文件功能
                      ProfileManager().deleteProfile(profile.id);
                      _loadProfiles();
                    },
                  ),
                  onTap: () {
                    // TODO: 实现配置文件点击功能
                  },
                );
              },
            ),
      )
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
