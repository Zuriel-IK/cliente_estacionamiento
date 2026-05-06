class ApiResponse<T> {
  final T? data;
  final String? message;

  ApiResponse({this.data, this.message});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json)? fromJsonT
      ) {
    return ApiResponse<T>(
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
      message: json['message'] as String?,
    );
  }
}