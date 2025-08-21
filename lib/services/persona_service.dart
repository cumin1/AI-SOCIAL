import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/persona.dart';

class PersonaService {
  static const String _key = 'persona_json';

  Future<Persona?> loadPersona() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Persona.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePersona(Persona persona) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(persona.toJson()));
  }

  Future<void> clearPersona() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}


