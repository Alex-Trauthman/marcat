import 'package:flutter/material.dart';
import '../models/item.dart';

/// Widget para criar o carrossel horizontal de destaques
class CarouselWidget extends StatelessWidget {
  final List<Item> items; // Lista de itens a serem mostrados
  final Function(Item) onItemTap;

  const CarouselWidget({super.key, required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      // Constrói páginas horizontais que o usuário pode deslizar, mostrando 85% de cada imagem por vez
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onItemTap(item),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // Gradiente escuro na parte inferior para garantir que o texto branco seja sempre legível
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
