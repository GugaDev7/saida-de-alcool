class AgenteModel {
  final int codigo; // Código de instalação (principal)
  final String cnpj; // CNPJ da empresa (normalizado, somente dígitos)
  final String razaoSocial; // Nome oficial da empresa
  final String? cep; // CEP (pode vir nulo)
  final String? municipio; // Município (pode vir nulo)
  final String? estado; // Estado (pode vir nulo)
  final String? status; // Situação atual (ex: ABERTO) (pode vir nulo)

  AgenteModel({
    required this.codigo,
    required this.cnpj,
    required this.razaoSocial,
    this.cep,
    this.municipio,
    this.estado,
    this.status,
  });

  // JSON -> Model
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

  // Model -> JSON
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

  // SQLite -> Model
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

  // Model -> SQLite
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

  // Normaliza mantendo apenas dígitos (remove pontos, barras e traços)
  static String _digitsOnly(String? value) {
    if (value == null) return '';
    return value.replaceAll(RegExp(r'\D'), '');
  }
}
