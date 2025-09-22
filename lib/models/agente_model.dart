/// Representa um agente (instalação) retornado pela ANP e armazenado localmente.
class AgenteModel {
  final int codigo;
  final String cnpj;
  final String razaoSocial;
  final String? cep;
  final String? municipio;
  final String? estado;
  final String? status;

  /// Cria uma instância de [AgenteModel].
  AgenteModel({
    required this.codigo,
    required this.cnpj,
    required this.razaoSocial,
    this.cep,
    this.municipio,
    this.estado,
    this.status,
  });

  /// Constrói um [AgenteModel] a partir de um JSON da API (Map).
  factory AgenteModel.fromJson(Map<String, dynamic> json) {
    return AgenteModel(
      codigo: json['codigo'] as int,
      cnpj: _digitsOnly(json['cnpj'] as String?),
      razaoSocial: (json['razaoSocial'] ?? '') as String,
      cep: json['cep'] as String?,
      municipio: json['municipio'] as String?,
      estado: json['estado'] as String?,
      status: json['status'] as String?,
    );
  }

  /// Serializa este modelo para JSON (Map) compatível com a API.
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'cnpj': cnpj,
      'razaoSocial': razaoSocial,
      'cep': cep,
      'municipio': municipio,
      'estado': estado,
      'status': status,
    };
  }

  /// Constrói um [AgenteModel] a partir de um Map vindo do SQLite.
  factory AgenteModel.fromMap(Map<String, dynamic> map) {
    return AgenteModel(
      codigo: map['codigo'] as int,
      cnpj: _digitsOnly(map['cnpj'] as String?),
      razaoSocial: (map['razaoSocial'] ?? '') as String,
      cep: map['cep'] as String?,
      municipio: map['municipio'] as String?,
      estado: map['estado'] as String?,
      status: map['status'] as String?,
    );
  }

  /// Serializa este modelo para um Map adequado ao SQLite.
  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'cnpj': _digitsOnly(cnpj),
      'razaoSocial': razaoSocial,
      'cep': cep,
      'municipio': municipio,
      'estado': estado,
      'status': status,
    };
  }

  static String _digitsOnly(String? value) {
    if (value == null) return '';
    return value.replaceAll(RegExp(r'\D'), '');
  }
}
