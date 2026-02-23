import 'package:dio/dio.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
<<<<<<< HEAD
      baseUrl: 'http://192.168.1.37:5000',
=======
      baseUrl: 'https://api.vidriobras.com',
>>>>>>> 6c8364a788af19309cf7c99d566e77818eb99a04
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
