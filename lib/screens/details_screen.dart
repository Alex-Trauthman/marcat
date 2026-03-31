import 'package:flutter/material.dart';
import '../models/item.dart';

/// Tela de detalhes que exibe nome, imagem grande, preço, descrição e contato de um único item
class DetailsScreen extends StatelessWidget {
  final Item item;

  const DetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      appBar: AppBar(
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFF9DB),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animação Hero: cria uma transição suave da imagem do card direto para esta tela
            Hero(
              tag: 'image_${item.id}',
              child: Image.asset(
                item.imageUrl,
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover, // Preenche todo o espaço sem distorcer as proporções da imagem
                // Exibe um ícone caso ocorra falha ao carregar a imagem
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 320, child: Center(child: Icon(Icons.broken_image, size: 64))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: item.isFree ? Colors.green.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.isFree ? 'Grátis' : 'R\$ ${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: item.isFree ? Colors.green[800] : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Descrição',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Contato',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.black54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        item.contactInfo,
                        style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
