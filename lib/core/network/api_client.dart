class ApiClient {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static String get photos => '$baseUrl/photos';
  static String get albums => '$baseUrl/albums';
}
