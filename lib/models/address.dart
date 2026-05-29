class Address {
  final String? id;
  final String userId;
  final String? alias;
  final String cep;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final DateTime? createdAt;

  Address({
    this.id,
    required this.userId,
    this.alias,
    required this.cep,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      alias: json['alias'] as String?,
      cep: json['cep'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (alias != null) 'alias': alias,
      'cep': cep,
      'street': street,
      'number': number,
      if (complement != null) 'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
    };
  }

  /// Retorna uma representação legível do endereço para exibição na UI
  String get formattedAddress {
    final aliasStr = alias != null && alias!.isNotEmpty ? '[$alias] ' : '';
    final complementStr = complement != null && complement!.isNotEmpty ? ' - $complement' : '';
    return '$aliasStr$street, $number$complementStr, $neighborhood, $city - $state';
  }
}
