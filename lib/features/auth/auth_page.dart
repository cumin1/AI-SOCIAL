import 'package:flutter/material.dart';

import '../../services/profile_service.dart';
import '../../data/models/profile.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.onSignedIn});

  final void Function(Profile profile) onSignedIn;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  final ProfileService _profileService = ProfileService();

  Future<void> _continueAnonymously() async {
    setState(() => _isLoading = true);
    final Profile profile = _profileService.generateAnonymous();
    await _profileService.saveProfile(profile);
    if (!mounted) return;
    widget.onSignedIn(profile);
  }

  Future<void> _loginWithEmail() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效邮箱地址')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final Profile profile = _profileService.generateFromEmail(email);
    await _profileService.saveProfile(profile);
    if (!mounted) return;
    widget.onSignedIn(profile);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('登录/创建身份')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '为了更安全舒适的交流环境，你可以选择匿名开始，或使用邮箱/手机号登录。',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _continueAnonymously,
              icon: const Icon(Icons.bolt),
              label: const Text('匿名开始'),
            ),
            const SizedBox(height: 24),
            Text('邮箱', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'name@example.com'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isLoading ? null : _loginWithEmail,
              child: const Text('使用邮箱登录'),
            ),
            const SizedBox(height: 24),
            Text('手机号', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '11位手机号'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: null, // mock placeholder
              child: const Text('短信验证码登录 (开发测试中)'),
            ),
            const SizedBox(height: 32),
            Text(
              '提示：你可在个人页控制披露程度，随时切换匿名/实名。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
