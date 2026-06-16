import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razdelchik/screens/profile_screen.dart';
import 'package:razdelchik/services/auth/auth_service.dart';
import 'package:razdelchik/services/admin/admin_messages_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _authService.registerWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } on BlockedUserException catch (e) {
      if (!mounted) return;
      // The user is still signed in here so the unblock appeal can pass
      // Firestore rules. Sign out only after the dialog is dismissed.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlockedUserDialog(
          userId: e.userId,
          userEmail: e.userEmail,
        ),
      );
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Авторизация қатесі')),
      );
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Қате: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Кіру' : 'Тіркелу'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Аты'),
                      validator: (value) {
                        if (!_isLogin) {
                          if (value == null || value.trim().length < 2) {
                            return 'Атыңызды енгізіңіз';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Дұрыс email енгізіңіз';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Құпия сөз'),
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'Кемінде 6 таңба';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isLogin ? 'Кіру' : 'Аккаунт құру'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                    child: Text(
                      _isLogin
                          ? 'Аккаунтыңыз жоқ па? Тіркелу'
                          : 'Аккаунтыңыз бар ма? Кіру',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlockedUserDialog extends StatefulWidget {
  const BlockedUserDialog({
    super.key,
    required this.userId,
    required this.userEmail,
  });

  final String userId;
  final String userEmail;

  @override
  State<BlockedUserDialog> createState() => _BlockedUserDialogState();
}

class _BlockedUserDialogState extends State<BlockedUserDialog> {
  final _service = AdminMessagesService();
  final _controller = TextEditingController();
  bool _showAppeal = false;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendAppeal() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _service.sendAppeal(
        userId: widget.userId,
        userEmail: widget.userEmail,
        message: text,
      );
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: cs.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Аккаунт бұғатталған',
              style: tt.titleLarge?.copyWith(color: cs.error),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: _submitted
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Хабарламаңыз жіберілді. Әкімші қарастырады.',
                      style: tt.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сіздің аккаунтыңыз бұғатталған.',
                      style:
                          tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Егер бұл қате деп санасаңыз, әкімшіге хабарлама жіберіңіз.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.65),
                      ),
                    ),
                    if (_showAppeal) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controller,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: 'Хабарлама',
                          hintText: 'Сіздің жағдайыңызды түсіндіріңіз...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
      actions: _submitted
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Жабу'),
              ),
            ]
          : _showAppeal
              ? [
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _showAppeal = false),
                    child: const Text('Артқа'),
                  ),
                  FilledButton(
                    onPressed: _submitting ? null : _sendAppeal,
                    child: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Жіберу'),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Жабу'),
                  ),
                  FilledButton.icon(
                    onPressed: () => setState(() => _showAppeal = true),
                    icon: const Icon(Icons.mail_outline, size: 18),
                    label: const Text('Әкімшіге хабарлау'),
                  ),
                ],
    );
  }
}
