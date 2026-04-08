import '../models/item.dart';

class LocalService {
  static final List<Item> mockItems = [
    Item(
      id: '1',
      title: 'Bicicleta Monark',
      description: 'Bicicleta em bom estado, linda e estilosa.',
      price: 250.00,
      imageUrl: 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/bicicleta.png',
      contactInfo: '11 99999-9999',
    ),
    Item(
      id: '2',
      title: 'Secador de roupa',
      description: 'Secador portátil a energia solar (varal de chão). Totalmente renovável.',
      price: 115.00,
      imageUrl: 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/secador.jpg',
      contactInfo: '11 88888-8888',
    ),
    Item(
      id: '3',
      title: 'Vitaminas',
      description: 'Uso recomendado para hipertrofia. Lacrado.',
      price: 300.00,
      imageUrl: 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/vitaminas.jpg',
      contactInfo: '11 77777-7777',
    ),
    Item(
      id: '4',
      title: 'Doação de Livros',
      description: 'Diversos livros acadêmicos. Quem chegar primeiro leva.',
      price: 0.0,
      imageUrl: 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/livros.jpg',
      contactInfo: '11 66666-6666',
    ),
  ];
}
