import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../data/models/persona.dart';
import '../data/models/trait.dart';
import '../data/models/persona_with_traits.dart';

class AiGateway {
  // Stub: generate a persona from tags. In future, call real LLM API.
  Future<PersonaWithTraits> generatePersonaAndTraits({
    required String userId,
    required List<String> tags,
    List<Map<String, String>>? answers, // optional Q&A context
  }) async {
    final String? apiKey = dotenv.env['DEEPSEEK_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      // Fallback to local stub if no key configured
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final String summary = _buildSummary(tags);
      final List<String> traits = _inferTraits(tags);
      final String moodBias = _inferMoodBias(tags);
      final persona = Persona(
        userId: userId,
        selectedTags: tags,
        summary: summary,
        traits: traits,
        moodBias: moodBias,
      );
      final List<UserTrait> userTraits = traits
          .map(
            (t) => UserTrait(
              id: 't_${t.hashCode}',
              title: t,
              description: '与你相关的性格倾向：$t',
              evidenceTags: tags,
            ),
          )
          .toList();
      return PersonaWithTraits(persona: persona, traits: userTraits);
    }

    try {
      final Uri uri = Uri.parse('https://api.deepseek.com/v1/chat/completions');
      final String systemPrompt = _personaSystemPrompt();
      final String userPrompt = _personaUserPrompt(tags, answers);
      final Map<String, dynamic> body = {
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.3,
      };
      final http.Response resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final Map<String, dynamic> data =
            jsonDecode(resp.body) as Map<String, dynamic>;
        final List choices = (data['choices'] as List? ?? <dynamic>[]);
        final String content = choices.isNotEmpty
            ? (choices.first['message']?['content'] as String? ?? '')
            : '';
        final Map<String, dynamic> parsed =
            jsonDecode(content) as Map<String, dynamic>;
        final String summary =
            (parsed['summary'] as String?)?.trim() ?? _buildSummary(tags);
        final List<String> traits =
            ((parsed['traits'] as List?)?.map((e) => e.toString()).toList() ??
            _inferTraits(tags));
        final String moodBias =
            (parsed['moodBias'] as String?)?.trim() ?? _inferMoodBias(tags);
        final List<String> normalizedTags =
            ((parsed['tagsNormalized'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            tags);
        final List<UserTrait> userTraits =
            ((parsed['userTraits'] as List?)?.map((e) {
              final m = e as Map<String, dynamic>;
              return UserTrait(
                id: (m['id']?.toString() ?? 't_${m['title']?.hashCode ?? 0}'),
                title: m['title']?.toString() ?? '特质',
                description: m['description']?.toString() ?? '',
                evidenceTags:
                    (m['evidenceTags'] as List?)
                        ?.map((x) => x.toString())
                        .toList() ??
                    normalizedTags,
              );
            }).toList()) ??
            <UserTrait>[];
        final persona = Persona(
          userId: userId,
          selectedTags: normalizedTags,
          summary: summary,
          traits: traits,
          moodBias: moodBias,
        );
        return PersonaWithTraits(
          persona: persona,
          traits: userTraits.isNotEmpty
              ? userTraits
              : traits
                    .map(
                      (t) => UserTrait(
                        id: 't_${t.hashCode}',
                        title: t,
                        description: '与你相关的性格倾向：$t',
                        evidenceTags: normalizedTags,
                      ),
                    )
                    .toList(),
        );
      }
    } catch (_) {
      // fallthrough to stub
    }

    final String summary = _buildSummary(tags);
    final List<String> traits = _inferTraits(tags);
    final String moodBias = _inferMoodBias(tags);
    final persona = Persona(
      userId: userId,
      selectedTags: tags,
      summary: summary,
      traits: traits,
      moodBias: moodBias,
    );
    final List<UserTrait> userTraits = traits
        .map(
          (t) => UserTrait(
            id: 't_${t.hashCode}',
            title: t,
            description: '与你相关的性格倾向：$t',
            evidenceTags: tags,
          ),
        )
        .toList();
    return PersonaWithTraits(persona: persona, traits: userTraits);
  }

  // Backward compatibility: return only persona
  Future<Persona> generatePersona({
    required String userId,
    required List<String> tags,
    List<Map<String, String>>? answers,
  }) async {
    final combined = await generatePersonaAndTraits(
      userId: userId,
      tags: tags,
      answers: answers,
    );
    return combined.persona;
  }

  String _buildSummary(List<String> tags) {
    final String joined = tags.take(5).join('、');
    return '基于你的选择（$joined），你更偏好慢节奏、共情式的沟通方式，渴望在安全的环境中建立稳定关系。';
  }

  List<String> _inferTraits(List<String> tags) {
    final Set<String> traits = <String>{};
    // Buckets
    final bool introvert = tags.any((t) => t.contains('安静') || t.contains('独处') || t.contains('慢热'));
    final bool empathy = tags.any((t) => t.contains('共情') || t.contains('倾听'));
    final bool rational = tags.any((t) => t.contains('理性') || t.contains('思考') || t.contains('探索'));
    final bool art = tags.any((t) => t.contains('音乐') || t.contains('艺术') || t.contains('文学') || t.contains('摄影') || t.contains('电影'));
    final bool outdoor = tags.any((t) => t.contains('徒步') || t.contains('露营') || t.contains('跑步') || t.contains('瑜伽'));
    final bool safety = tags.any((t) => t.contains('社恐') || t.contains('焦虑') || t.contains('需要安全感'));

    if (introvert) traits.addAll(['内向稳定', '慢热沉静']);
    if (empathy) traits.addAll(['耐心倾听', '共情敏锐']);
    if (rational) traits.addAll(['好奇理性', '条理清晰']);
    if (art) traits.addAll(['感性细腻', '审美在线']);
    if (outdoor) traits.addAll(['户外活力', '自我修复']);
    if (safety) traits.addAll(['社交谨慎', '需要边界感']);

    // General positive anchors
    traits.addAll(['真诚开放', '温和可信']);

    // Ensure 6-10 items
    final List<String> pool = [
      '自我反思', '稳重可靠', '表达克制', '细节敏感', '好奇探索', '情绪稳定', '乐于助人', '独立自主', '专注当下', '包容体谅',
    ];
    int i = 0;
    while (traits.length < 6 && i < pool.length) {
      traits.add(pool[i]);
      i++;
    }
    final List<String> out = traits.take(10).toList();
    return out;
  }

  String _inferMoodBias(List<String> tags) {
    if (tags.any((t) => t.contains('焦虑') || t.contains('社恐')))
      return '敏感/需要安全感';
    if (tags.any((t) => t.contains('运动') || t.contains('户外'))) return '积极/外向';
    return '平静/耐心';
  }
}

String _personaSystemPrompt() =>
    '你是一个画像分析助手。请只输出严格的 JSON，不要包含任何解释或额外文本。\n'
    '{\n'
    '  "summary": "40-60字中文总结，语气温和，描述沟通偏好与安全感需求",\n'
    '  "traits": ["特征1","特征2"],\n'
    '  "moodBias": "如 平静/敏感/外向/内向 中的组合",\n'
    '  "tagsNormalized": ["规范化标签1","规范化标签2"],\n'
    '  "userTraits": [\n'
    '    {"id":"trait_01","title":"温和而坚定","description":"一句话解释","evidenceTags":["安静独处","共情"]}\n'
    '  ]\n'
    '}\n'
    '请至少生成5条、至多10条 userTraits。若缺少信息，合理推断并保持温和、中性。';

String _personaUserPrompt(
  List<String> tags,
  List<Map<String, String>>? answers,
) {
  final String joined = tags.join('、');
  final String qa = (answers == null || answers.isEmpty)
      ? ''
      : '\n以下是问答：${answers.map((e) => 'Q:${e['q']} A:${e['a']}').join('；')}';
  return '以下是用户自己选择的标签：$joined$qa\n请根据这些信息生成人设 JSON，包含 5-10 条 userTraits。只输出 JSON。';
}
