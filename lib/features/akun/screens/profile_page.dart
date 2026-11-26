import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/core/widgets/app_snackbar.dart';
import 'package:takarkuy_apk/core/widgets/async_state_view.dart';
import 'package:takarkuy_apk/features/akun/data/auth_state.dart';

/// Ringkasan akun dari endpoint terproteksi serta aksi keluar yang mencabut token.
class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthState>().loadProfile();
    });
  }

  Future<void> _logout() async {
    final auth = context.read<AuthState>();
    final success = await auth.logout();
    if (!mounted) return;
    context.go(AppRoutes.home);
    if (!success && auth.error != null) {
      showAppSnackBar(context, auth.error!, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun Saya')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer<AuthState>(
          builder: (context, auth, _) => AsyncStateView(
            loading: auth.profileLoading,
            hasData: auth.profile != null,
            error: auth.profileError,
            onRetry: auth.loadProfile,
            builder: (context) {
              final profile = auth.profile!;
              final preferences = profile['preferences'] is Map
                  ? Map<String, dynamic>.from(profile['preferences'] as Map)
                  : const <String, dynamic>{};
              return ListView(
                children: [
                  CircleAvatar(
                    radius: 36,
                    child: Text(_avatarInitial(profile['avatar'] as String?)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile['full_name'] as String? ??
                        auth.username ??
                        'Pengguna TAKARKUY',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    profile['email'] as String? ?? '',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _ProfileLine(
                    label: 'Username',
                    value: profile['username']?.toString() ?? '-',
                  ),
                  _ProfileLine(
                    label: 'Target diet',
                    value: _labels(preferences['targets']),
                  ),
                  _ProfileLine(
                    label: 'Alergi',
                    value: _labels(preferences['allergens']),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: auth.isLoading ? null : _logout,
                    icon: auth.isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: const Text('Keluar'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _labels(dynamic values) => values is List && values.isNotEmpty
      ? values.map((value) => value.toString().replaceAll('_', ' ')).join(', ')
      : 'Belum diatur';

  String _avatarInitial(String? avatar) => avatar == null || avatar.isEmpty
      ? 'T'
      : avatar.substring(0, 1).toUpperCase();
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value),
  );
}
