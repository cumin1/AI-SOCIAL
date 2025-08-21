import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_page.dart';
import 'services/profile_service.dart';
import 'data/models/profile.dart';
import 'features/chat/chat_page.dart';
import 'features/onboarding/tag_select_page.dart';
import 'services/persona_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/traits/traits_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'env/app.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '深度沟通',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  final ProfileService _profileService = ProfileService();
  final PersonaService _personaService = PersonaService();
  Profile? _profile;
  bool _hasPersona = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final Profile? p = await _profileService.loadProfile();
    final hasPersona = await _personaService.loadPersona() != null;
    if (!mounted) return;
    setState(() {
      _profile = p;
      _hasPersona = hasPersona;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profile == null) {
      return AuthPage(onSignedIn: (p) => setState(() => _profile = p));
    }
    if (!_hasPersona) {
      return TagSelectPage(
        profile: _profile!,
        onDone: () => setState(() => _hasPersona = true),
      );
    }
    return _RootShell(profile: _profile!);
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell({required this.profile});
  final Profile profile;

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _DiscoverPage(),
      const _ChatEntry(),
      _ProfilePage(profile: widget.profile),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: '聊天',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('匹配与活动', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('开始匹配', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '基于相似/互补策略，找到合适的对话或线下组队对象。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: () {}, child: const Text('开始')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('附近线下据点'),
              subtitle: const Text('咖啡店、书店，支持扫码打卡'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// legacy placeholder removed (replaced by ChatPage in features)

// Lightweight entry that navigates to real chat page (separate file) in MVP
class _ChatEntry extends StatelessWidget {
  const _ChatEntry();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('聊天')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ChatPage()));
          },
          child: const Text('进入聊天'),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: 12),
          const _PersonaCard(),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: const Text('徽章与成长'),
              subtitle: const Text('陪伴指数、连续打卡、固定搭子'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.style_outlined),
              title: const Text('我的特质卡片'),
              subtitle: const Text('5-10 张画像特质卡，点按查看详情'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TraitsListPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('设置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final Profile profile;

  Color _colorFromSeed(int seed) {
    // simple deterministic color
    final List<Color> colors = [
      const Color(0xFF7ED6C1),
      const Color(0xFF5B8DEF),
      const Color(0xFFF7B267),
      const Color(0xFF6EE7F2),
    ];
    return colors[seed % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _colorFromSeed(profile.avatarSeed),
          child: const Icon(Icons.person),
        ),
        title: Text(profile.displayName),
        subtitle: Text(profile.isAnonymous ? '匿名身份' : '实名'),
        trailing: FilledButton.tonal(
          onPressed: () async {
            final ProfileService svc = ProfileService();
            final Profile next = svc.generateAnonymous();
            await svc.saveProfile(next);
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已生成新的匿名身份')));
            }
          },
          child: const Text('换一个'),
        ),
      ),
    );
  }
}

class _PersonaCard extends StatefulWidget {
  const _PersonaCard();

  @override
  State<_PersonaCard> createState() => _PersonaCardState();
}

class _PersonaCardState extends State<_PersonaCard> {
  String? _summary;
  List<String> _traits = const [];
  List<String> _tags = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final persona = await PersonaService().loadPersona();
    if (!mounted) return;
    setState(() {
      _summary = persona?.summary;
      _traits = persona?.traits ?? const [];
      _tags = persona?.selectedTags ?? const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_summary == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('你的画像', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_summary!),
            if (_traits.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _traits.map((t) => Chip(label: Text(t))).toList(),
              ),
            ],
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('你的标签', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((t) => Chip(label: Text(t))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
