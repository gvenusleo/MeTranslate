import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:metranslate/utils/init_dio.dart';

/// 剑桥词典
Future<Map> translateByCambridgeDict(
  String text,
  String from,
  String to,
) async {
  try {
    from = cambridgeDictSupportLanguage()[from]!;
    to = cambridgeDictSupportLanguage()[to]!;
  } catch (_) {
    return {"error": "不支持的语言"};
  }
  const String url = "https://dictionary.cambridge.org/search/direct/";
  const Map<String, String> headers = {
    "Content-Type": "text/html;charset=UTF-8",
  };
  final Map<String, String> quer = {
    "datasetsearch": "$from-$to",
    "q": text,
  };

  final Dio dio = initDio();
  final Response response = await dio.get(
    url,
    queryParameters: quer,
    options: Options(headers: headers),
  );
  final String htmlString = response.data.toString();
  final Document html = parse(htmlString);

  Map result = {
    "pronunciation": {
      "uk": getCambridgeDictPronunciation(html, 'uk'),
      "us": getCambridgeDictPronunciation(html, 'us'),
    },
    "translation": getCambridgeDictTranslation(html),
  };

  return result;
}

/// 剑桥词典支持的语言
Map<String, String> cambridgeDictSupportLanguage() {
  return {
    // "自动": "auto",
    "英语": "english",
    "中文": "chinese-simplified",
    "繁体中文": "chinese-traditional",
  };
}

/// 获取发音
/// 参数可选 uk, us
Map<String, String> getCambridgeDictPronunciation(Document html, String type) {
  Map<String, String> result = {
    "ipa": "",
    "mp3": "",
  };
  final List<Element> usAudio = html.querySelectorAll('.$type.dpron-i');
  if (usAudio.isNotEmpty) {
    Element? ipa = usAudio[0].querySelector('.ipa');
    if (ipa != null) {
      result['ipa'] = '/${ipa.text}/';
    }
    List<Element> audio = usAudio[0].querySelectorAll('source');
    if (audio.isNotEmpty) {
      for (Element i in audio) {
        if (i.attributes['type'] == 'audio/mpeg') {
          String mp3Url =
              'https://dictionary.cambridge.org${i.attributes['src']!}';
          result['mp3'] = mp3Url;
        }
      }
    }
  }
  return result;
}

/// 获取翻译结果, 按照词性分类
List<Map<String, dynamic>> getCambridgeDictTranslation(Document html) {
  List<Map<String, dynamic>> result = [];
  final List<Element> entryBodys = html.querySelectorAll('.entry-body__el');
  for (Element entryBody in entryBodys) {
    Map<String, dynamic> item = {
      "pos": "",
      "tran": [],
    };
    List<Element> pos = entryBody.querySelectorAll('.posgram');
    if (pos.isNotEmpty) {
      item['pos'] = pos[0].text;
    }
    List<Element> tranBody = entryBody.querySelectorAll('.def-body');
    if (tranBody.isNotEmpty) {
      for (Element tranItem in tranBody) {
        List<Element> children = tranItem.children;
        if (children.isNotEmpty) {
          for (Element tran in children) {
            if (tran.localName == "span") {
              item['tran']!.add(tran.text);
            }
          }
        }
      }
    }
    result.add(item);
  }
  return result;
}
