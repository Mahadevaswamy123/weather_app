import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/model/weathermodel.dart';

class WeatherService {
  Future<WeatherData?> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=${dotenv.env['API_KEY']}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherData.fromJson(json);
      } else {
        throw Exception("Error in API call: ${response.statusCode}");
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
