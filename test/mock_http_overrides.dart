import 'dart:io';
import 'dart:convert';
import 'dart:async';

class MockHttpOverrides extends HttpOverrides {
  final Map<String, String> responses;
  MockHttpOverrides(this.responses);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient(responses);
  }
}

class MockHttpClient implements HttpClient {
  final Map<String, String> responses;
  MockHttpClient(this.responses);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) async {
    return MockHttpClientRequest(responses, path);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return MockHttpClientRequest(responses, url.path);
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) async {
    return MockHttpClientRequest(responses, path);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest(responses, url.path);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return MockHttpClientRequest(responses, url.path);
  }

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) async {
    return MockHttpClientRequest(responses, path);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    print("MockHttpClient noSuchMethod: ${invocation.memberName}");
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  final Map<String, String> responses;
  final String path;
  MockHttpClientRequest(this.responses, this.path);

  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    print("MockHttpClientRequest: path = $path");
    final matchedPath = responses.keys.firstWhere(
      (k) => path.contains(k),
      orElse: () => '',
    );
    if (matchedPath.isNotEmpty) {
      final responseBody = responses[matchedPath]!;
      print("MockHttpClientRequest: matchedPath = $matchedPath, responseBody = $responseBody");
      return MockHttpClientResponse(utf8.encode(responseBody));
    }
    final isImage = path.contains(RegExp(r'\.(png|jpg|jpeg|gif|webp|bmp)', caseSensitive: false)) ||
                    path.contains('/150') ||
                    path.contains('avatar');
    if (isImage) {
      print("MockHttpClientRequest: returning 1x1 transparent PNG for path = $path");
      return MockHttpClientResponse(base64Decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="));
    }
    print("MockHttpClientRequest: unmatched path = $path, returning empty JSON");
    return MockHttpClientResponse(utf8.encode('{}'));
  }

  @override
  void write(Object? obj) {}

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) async {
    await stream.drain();
  }

  @override
  Future<HttpClientResponse> get done => Future.value(MockHttpClientResponse(utf8.encode('')));

  @override
  dynamic noSuchMethod(Invocation invocation) {
    print("MockHttpClientRequest noSuchMethod: ${invocation.memberName}");
    return null;
  }
}

class MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};

  @override
  List<String>? operator [](String name) {
    if (name.toLowerCase() == 'content-type') {
      return ['application/json; charset=utf-8'];
    }
    return _headers[name];
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.putIfAbsent(name, () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name] = [value.toString()];
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    action('content-type', ['application/json; charset=utf-8']);
    _headers.forEach(action);
  }

  @override
  ContentType? get contentType => ContentType.parse('application/json; charset=utf-8');

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse implements HttpClientResponse {
  final List<int> bodyBytes;
  MockHttpClientResponse(this.bodyBytes);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => bodyBytes.length;

  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => true;

  @override
  String get reasonPhrase => 'OK';

  @override
  final List<RedirectInfo> redirects = [];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([bodyBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    print("MockHttpClientResponse noSuchMethod: ${invocation.memberName}");
    return null;
  }
}
