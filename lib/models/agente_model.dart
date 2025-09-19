class AgenteModel {
  final int codigo; // Código de instalação (principal)
  final String cnpj; // CNPJ da empresa
  final String razaoSocial; // Nome oficial da empresa
  final String cep; // CEP
  final String municipio; // Município
  final String estado; // Estado
  final String status; // Situação atual (ex: ABERTO)

  AgenteModel({
    required this.codigo,
    required this.cnpj,
    required this.razaoSocial,
    required this.cep,
    required this.municipio,
    required this.estado,
    required this.status,
  });

  // JSON -> Model
  factory AgenteModel.fromJson(Map<String, dynamic> json) {
    return AgenteModel(
      codigo: json['codigo'],
      cnpj: json['cnpj'],
      razaoSocial: json['razaoSocial'],
      cep: json['cep'],
      municipio: json['municipio'],
      estado: json['estado'],
      status: json['status'],
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
      codigo: map['codigo'],
      cnpj: map['cnpj'],
      razaoSocial: map['razaoSocial'],
      cep: map['cep'],
      municipio: map['municipio'],
      estado: map['estado'],
      status: map['status'],
    );
  }

  // Model -> SQLite
  Map<String, dynamic> toMap() {
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
}
