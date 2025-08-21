import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/trait.dart';

class TraitService {
  static const String _key = 'traits_json_list';

  Future<List<UserTrait>> loadTraits() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return <UserTrait>[];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => UserTrait.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return <UserTrait>[];
    }
  }

  Future<void> saveTraits(List<UserTrait> traits) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonStr = jsonEncode(traits.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  Future<void> clearTraits() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}


