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
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final bool isNetworkImage = item.imageUrl.startsWith('http');

          final hasImage = item.imageUrl.isNotEmpty;

          return GestureDetector(
            onTap: () => onItemTap(item),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImage)
                      isNetworkImage
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                            )
                          : Image.asset(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                            )
                    else
                      const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                    Container(
                      decoration: BoxDecoration(
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
