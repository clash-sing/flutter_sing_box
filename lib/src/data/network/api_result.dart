/// The result of a network request, holding the decoded [data] and [headers].
class ApiResult<T> {
  /// The decoded response body.
  final T data;
  /// The response headers keyed by header name.
  final Map<String, dynamic> headers;

  /// Creates an [ApiResult] with the given [data] and [headers].
  ApiResult(this.data, this.headers);
}
