import 'package:flutter/material.dart';

/// Halaman masuk Modul 3, dikembangkan dari kerangka Akun yang sudah ada.
class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MasukKuy')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Halaman Login'),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/signup',
                  arguments: const {'fromLogin': true},
                ),
                child: const Text('Buka halaman daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
