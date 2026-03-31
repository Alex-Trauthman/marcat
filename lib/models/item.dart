/// Modelo que representa um item à venda ou doação no marketplace
class Item {
  final String id; // Identificador único do item
  final String title; // Título ou nome do produto
  final String description; // Descrição detalhada sobre o estado do item
  final double price; // Preço do item (0.0 significa que é doação)
  final String imageUrl; // Caminho da imagem local (assets/) ou URL
  final String contactInfo; // Informação de contato do vendedor (ex: telefone)

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.contactInfo,
  });

  // Getter calculado: retorna true se o preço for zero ou negativo (indicando doação)
  bool get isFree => price <= 0;
}
