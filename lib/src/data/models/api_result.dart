class ApiResult<T> {
  final T data;
  final Map<String, dynamic> headers;

  ApiResult(this.data, this.headers);
}