import 'package:flutter/material.dart';
import '../models/item.dart';

/// Um Widget customizado para exibir os itens em um "Cartão" na tela Home
class ItemCardWidget extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCardWidget({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // GestureDetector captura cliques na área do card e chama a função onTap repassada pelos construtores
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Utiliza o espaço disponível para a imagem
            Expanded(
              // Arredonda apenas os cantos superiores da imagem para acompanhar o formato do Card
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
              child: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                item.isFree ? 'Grátis' : 'R\$ ${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: item.isFree ? Colors.green[700] : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
