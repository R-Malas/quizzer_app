import 'dart:convert';

import 'package:quizzer_app/core/models/category_model.dart';
import 'package:quizzer_app/core/models/question_model.dart';
import 'package:http/http.dart' as http;
import 'package:quizzer_app/core/services/http_error_handler_service.dart';

class QuestionsService {
  static const _apiBaseUrl = {'scheme': 'https', 'host': 'opentdb.com'};
  static const _options = {'amount': '10', 'type': 'boolean'};
  static String _sessionToken = '';
  static const _httpErrorHandler = HttpErrorHandlerService();

  const QuestionsService();

  /// get list of questions
  Future<List<Question>> getQuestions(
      String category, String difficulty) async {
    var queryParam = {
      'category': category,
      'difficulty': difficulty,
      'token': _sessionToken
    };
    queryParam.addEntries(_options.entries);

    var url = Uri(
        scheme: _apiBaseUrl['scheme'],
        host: _apiBaseUrl['host'],
        path: 'api.php',
        queryParameters: queryParam);

    var res = await http.get(url);
    var resBody = jsonDecode(res.body);
    if (res.statusCode == 200) {
      if (resBody['response_code'] == 0 &&
          (resBody['results'] as List).isNotEmpty) {
        List<Question> questions = List.from((resBody['results'] as List)
            .map((question) => Question.parseJson(question)));
        return questions;
      } else {
        var errMsg = _httpErrorHandler
            .handleHttpErrorCode(resBody['response_code'] as int);
        throw Exception(errMsg);
      }
    } else {
      var errMsg = _httpErrorHandler
          .handleHttpErrorCode(resBody['response_code'] as int);
      throw Exception(errMsg);
    }
  }

  /// get list of Categories
  Future<List<Category>> getCategories() async {
    var url = Uri(
      scheme: _apiBaseUrl['scheme'],
      host: _apiBaseUrl['host'],
      path: 'api_category.php',
    );

    var res = await http.get(url);
    var resBody = jsonDecode(res.body);
    if (res.statusCode == 200 &&
        (resBody['trivia_categories'] as List).isNotEmpty) {
      List<Category> categories = List.from(
          (resBody['trivia_categories'] as List)
              .map((category) => Category.parseJson(category)));
      return categories;
    } else {
      return throw Exception('Error while retrieving categories!');
    }
  }

  bool hasSessionToken() {
    return _sessionToken != '' ? true : false;
  }

  /// Get session token
  Future<bool> getSessionToken() async {
    if (_sessionToken != '') return true;
    var url = Uri(
        scheme: _apiBaseUrl['scheme'],
        host: _apiBaseUrl['host'],
        path: 'api_token.php',
        queryParameters: {'command': 'request'});

    var res = await http.get(url);
    var resBody = jsonDecode(res.body);
    if (res.statusCode == 200) {
      if (resBody['response_code'] == 0) {
        _sessionToken = resBody['token'] as String;
        return true;
      } else {
        return throw Exception(resBody['response_message']);
      }
    } else {
      return throw Exception(resBody['response_code']);
    }
  }

  /// end open session
  Future<bool> closeSession() async {
    var url = Uri(
        scheme: _apiBaseUrl['scheme'],
        host: _apiBaseUrl['host'],
        path: 'api_token.php',
        queryParameters: {'command': 'reset', 'token': _sessionToken});

    var res = await http.get(url);
    var resBody = jsonDecode(res.body);
    if (res.statusCode == 200) {
      if (resBody['response_code'] == 0) {
        _sessionToken = '';
        return true;
      } else {
        return throw Exception(resBody['response_message']);
      }
    } else {
      return throw Exception(resBody['response_code']);
    }
  }
}
