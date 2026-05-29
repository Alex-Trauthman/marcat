/// Modelo que representa um item à venda ou doação no marketplace
class Item {
  final String id; // Identificador único do item
  final String title; // Título ou nome do produto
  final String description; // Descrição detalhada sobre o estado do item
  final double price; // Preço do item (0.0 significa que é doação)
  final String imageUrl; // Caminho da imagem local (assets/) ou URL
  final String contactInfo; // Informação de contato do vendedor (ex: telefone)
  final String condition; // Condição do item (ex: 'Usado', 'Novo')
  final String? sellerId; // ID do usuário que postou o item
  final String? cep;
  final String? street;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? number;
  final String? complement;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.contactInfo,
    this.condition = 'Usado',
    this.sellerId,
    this.cep,
    this.street,
    this.neighborhood,
    this.city,
    this.state,
    this.number,
    this.complement,
  });

  // Getter calculado: retorna true se o preço for zero ou negativo (indicando doação)
  bool get isFree => price <= 0;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      contactInfo: json['contact_info'] ?? json['contactInfo'] ?? '',
      condition: json['condition'] ?? 'Usado',
      sellerId: json['seller_id'],
      cep: json['cep'],
      street: json['street'],
      neighborhood: json['neighborhood'],
      city: json['city'],
      state: json['state'],
      number: json['number'],
      complement: json['complement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'contact_info': contactInfo,
      'condition': condition,
      'seller_id': sellerId,
      'cep': cep,
      'street': street,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'number': number,
      'complement': complement,
    };
  }
}
