import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/utils.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? _version;
  String? _buildNumber;
  String? _serverVersion;
  bool _serverVersionLoaded = false;

  static const _buildCommit = String.fromEnvironment("BUILD_COMMIT", defaultValue: "unknown");
  static const _buildDate = String.fromEnvironment("BUILD_DATE", defaultValue: "unknown");
  static const _configuredBuildType = String.fromEnvironment("BUILD_TYPE");

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    _loadServerVersion();
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
          _InfoRow(label: "Build date", value: _buildDate),
          _InfoRow(label: "Build commit", value: _buildCommit),
          _InfoRow(label: "Account", value: account),
          _InfoRow(label: "Server", value: server),
          _InfoRow(label: "Server version", value: _serverVersionLabel(account)),
          const Divider(),
          _LinkRow(
            label: "GitHub repository",
            url: "https://github.com/jhass/insporation",
            onTap: (url) => openExternalUrl(context, url),
          ),
          _LinkRow(
            label: "Privacy policy",
            url: "https://github.com/jhass/insporation/blob/main/PRIVACY_POLICY.md",
            onTap: (url) => openExternalUrl(context, url),
          ),
          _LinkRow(
            label: "Code of conduct",
            url: "https://github.com/jhass/insporation/blob/main/CODE_OF_CONDUCT.md",
            onTap: (url) => openExternalUrl(context, url),
          ),
          _LinkRow(
            label: "Child safety",
            url: "https://github.com/jhass/insporation/blob/main/CHILD_SAFETY.md",
            onTap: (url) => openExternalUrl(context, url),
          ),
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

  String _serverVersionLabel(String account) {
    if (account == "none") {
      return "none";
    }
    if (!_serverVersionLoaded) {
      return "loading…";
    }
    return _serverVersion ?? "unknown";
  }

  Future<void> _loadServerVersion() async {
    final serverVersion = await context.read<Client>().fetchServerVersion();
    if (!mounted) {
      return;
    }
    setState(() {
      _serverVersion = serverVersion;
      _serverVersionLoaded = true;
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

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url, required this.onTap});

  final String label;
  final String url;
  final void Function(String url) onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(url),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => onTap(url),
    );
  }
}
