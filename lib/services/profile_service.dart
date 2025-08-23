import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/profile.dart';

class ProfileService {
  static const String _key = 'profile_json';

  Future<Profile?> loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Profile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // Generates a local profile from email without backend.
  // userId will be 'mail_<hash>', displayName is anonymized nickname from local seed.
  Profile generateFromEmail(String email) {
    final String trimmed = email.trim().toLowerCase();
    final int seed = trimmed.hashCode & 0x7FFFFFFF;
    final String name = _generateAnonName(seed).replaceAll('#', '@');
    return Profile(
      userId: 'mail_${seed.toRadixString(16)}',
      displayName: name,
      avatarSeed: seed % 1000,
      isAnonymous: false,
    );
  }

  Future<void> saveProfile(Profile profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<void> signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Generates an anonymous profile with adjective+animal and random seed
  Profile generateAnonymous() {
    final DateTime now = DateTime.now();
    final int seed = now.microsecondsSinceEpoch & 0x7FFFFFFF;
    final String name = _generateAnonName(seed);
    return Profile(
      userId: 'anon_$seed',
      displayName: name,
      avatarSeed: seed % 1000,
      isAnonymous: true,
    );
  }

  String _generateAnonName(int seed) {
    const List<String> adjectives = [
      '温柔的', '安静的', '勇敢的', '真诚的', '好奇的', '沉稳的', '敏感的', '热心的', '耐心的', '温暖的'
    ];
    const List<String> animals = [
      '鲸鱼', '猫头鹰', '小鹿', '狐狸', '猫咪', '海豹', '向日葵', '萤火虫', '云雀', '麋鹿'
    ];
    final int a = (seed % adjectives.length).abs();
    final int b = (seed ~/ 7 % animals.length).abs();
    final int num = (seed % 999).abs();
    return '${adjectives[a]}${animals[b]}#${num.toString().padLeft(3, '0')}';
  }
}


