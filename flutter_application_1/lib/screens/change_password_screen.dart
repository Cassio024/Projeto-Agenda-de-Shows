// lib/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;

  const ChangePasswordScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await DatabaseService.instance.updatePassword(
        widget.userId,
        _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha alterada com sucesso!')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ocorreu um erro ao alterar a senha.')),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Senha'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira uma nova senha';
                  if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirmar Nova Senha'),
                obscureText: true,
                validator: (value) {
                  if (value != _newPasswordController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Salvar Nova Senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
