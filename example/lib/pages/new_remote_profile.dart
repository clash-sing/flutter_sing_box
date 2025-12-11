import 'package:flutter/material.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';

class NewRemoteProfile extends StatefulWidget {
  const NewRemoteProfile({super.key});

  @override
  State<NewRemoteProfile> createState() => _NewRemoteProfileState();
}

class _NewRemoteProfileState extends State<NewRemoteProfile> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _link;

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      // 创建配置
      final uri = Uri.parse(_link!);
      final profile = await ProfileService().importProfile(
        subscribeLink: uri,
        name: _name,
        autoUpdateInterval: 1440,
      );
      if(mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Remote Profile'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: '配置名称'),
                  validator: (value) {
                    return null;
                  },
                  onSaved: (value) => _name = value?.trim(),
                ),

                TextFormField(
                  decoration: InputDecoration(labelText: '订阅链接'),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return '请输入订阅链接';
                    }
                    final Uri? uri = Uri.tryParse(value!.trim());
                    if (uri?.host.isEmpty ?? true) {
                      return '请输入正确的订阅链接';
                    }
                    return null;
                  },
                  onSaved: (value) => _link = value?.trim(),
                ),
                ElevatedButton(
                  onPressed: () {
                    _onSubmit();
                  },
                  child: Text("创建"),
                )
              ]
            ),
          ),
        )
      )
    );
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }
}
