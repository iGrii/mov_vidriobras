class LoginResponse {
  final bool success;
  final dynamic data;
  final String message;

  LoginResponse({required this.success, this.data, required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data, 'message': message};
  }
}

class AreasResponse {
  final bool success;
  final dynamic data;
  final String message;

  AreasResponse({required this.success, this.data, required this.message});

  factory AreasResponse.fromJson(Map<String, dynamic> json) {
    return AreasResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data, 'message': message};
  }
}

class LoginRequest {
  final String areaId;
  final String nombre;
  final String codigoEmpresa;

  LoginRequest({
    required this.areaId,
    required this.nombre,
    required this.codigoEmpresa,
  });

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'nombre': nombre,
      'codigo_empresa': codigoEmpresa,
    };
  }
}
