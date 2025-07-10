// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showDeleteConfirmationDialog() async {
    _passwordController.clear();
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apagar Conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Esta ação é permanente. Para confirmar, por favor, insira a sua senha.'),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text.isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Apagar', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await ApiService.deleteOwnAccount(widget.user.id, _passwordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta apagada com sucesso.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(widget.user.name),
            subtitle: Text(widget.user.email),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: _logout,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text('Apagar Minha Conta', style: TextStyle(color: Colors.redAccent)),
            onTap: _showDeleteConfirmationDialog,
          ),
          const Divider(),
          const SizedBox(height: 20),
          // ===== INÍCIO DA ALTERAÇÃO =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Desenvolvido por Cássio',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ciência da Computação - Sexto Período',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          // ===== FIM DA ALTERAÇÃO =====
        ],
      ),
    );
  }
}
