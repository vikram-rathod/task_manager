class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) {
    return ApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }


  @override
  String toString() {
    return 'ApiResponse('
        'status: $status, '
        'message: $message, '
        'data: $data, '
        'error: $error'
        ')';
  }

}
