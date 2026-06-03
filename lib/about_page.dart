import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/localizations.dart';
import 'src/utils.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with StateLocalizationHelpers {
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
      userId = client.currentUserId,
      account = userId ?? l.aboutNoneLabel,
      server = userId?.split("@").last ?? l.aboutNoneLabel;

    return Scaffold(
      appBar: AppBar(title: Text(l.aboutPageTitle)),
      body: ListView(
        children: [
          _InfoRow(label: l.aboutVersionLabel, value: _version ?? l.aboutLoadingPlaceholder),
          _InfoRow(label: l.aboutBuildNumberLabel, value: _buildNumber ?? l.aboutLoadingPlaceholder),
          _InfoRow(label: l.aboutBuildTypeLabel, value: _buildType),
          _InfoRow(label: l.aboutBuildDateLabel, value: _buildDate),
          _InfoRow(label: l.aboutBuildCommitLabel, value: _buildCommit),
          _InfoRow(label: l.aboutAccountLabel, value: account),
          _InfoRow(label: l.aboutServerLabel, value: server),
          _InfoRow(label: l.aboutServerVersionLabel, value: _serverVersionLabel(userId)),
          const Divider(),
          _LinkRow(
            label: l.aboutGithubRepositoryLabel,
            url: "https://github.com/jhass/insporation",
            onTap: (url) => openExternalUrl(context, url),
          ),
          _LinkRow(
            label: l.aboutHelpTranslateLabel,
            url: "https://hosted.weblate.org/engage/insporation/",
            onTap: (url) => openExternalUrl(context, url),
          ),
          _LinkRow(
            label: l.aboutPrivacyPolicyLabel,
            url: "https://github.com/jhass/insporation/blob/main/PRIVACY_POLICY.md",
            onTap: (url) => openExternalUrl(context, url),
          ),
          _LinkRow(
            label: l.aboutCodeOfConductLabel,
            url: "https://github.com/jhass/insporation/blob/main/CODE_OF_CONDUCT.md",
            onTap: (url) => openExternalUrl(context, url),
          ),
          _LinkRow(
            label: l.aboutChildSafetyLabel,
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

  String _serverVersionLabel(String? userId) {
    if (userId == null) {
      return l.aboutNoneLabel;
    }
    if (!_serverVersionLoaded) {
      return l.aboutLoadingPlaceholder;
    }
    return _serverVersion ?? l.aboutUnknownLabel;
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
