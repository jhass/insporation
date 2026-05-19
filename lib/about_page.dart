import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? _version;
  String? _buildNumber;

  static const _buildCommit = String.fromEnvironment("BUILD_COMMIT", defaultValue: "unknown");
  static const _configuredBuildType = String.fromEnvironment("BUILD_TYPE");

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    final client = context.read<Client>(),
      account = client.currentUserId ?? "none",
      server = client.currentUserId?.split("@").last ?? "none";

    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: ListView(
        children: [
          _InfoRow(label: "Version", value: _version ?? "loading…"),
          _InfoRow(label: "Build number", value: _buildNumber ?? "loading…"),
          _InfoRow(label: "Build type", value: _buildType),
          _InfoRow(label: "Build commit", value: _buildCommit),
          _InfoRow(label: "Account", value: account),
          _InfoRow(label: "Server", value: server),
        ],
      ),
    );
  }

  String get _buildType {
    if (_configuredBuildType.isNotEmpty) {
      return _configuredBuildType;
    }
    if (kReleaseMode) {
      return "release";
    }
    if (kProfileMode) {
      return "profile";
    }
    return "debug";
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
