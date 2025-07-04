// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text, // Em um app real, a senha deve ser criptografada!
      );

      try {
        await DatabaseService.instance.createUser(newUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta criada com sucesso! Faça o login.')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        // O erro mais comum aqui é de email duplicado (UNIQUE constraint)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível criar a conta. O email já pode estar em uso.')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome Completo'),
                  validator: (value) => value!.isEmpty ? 'Por favor, insira seu nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, insira seu email';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, insira uma senha';
                    if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) return 'As senhas não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Criar Conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
