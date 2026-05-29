import 'package:flutter_test/flutter_test.dart';
import 'package:mar_cat/models/item.dart';

void main() {
  group('Item Model Tests', () {
    test('Should parse Item from Json correctly with full fields', () {
      final json = {
        'id': 'item-123',
        'title': 'Gato Arranhador',
        'description': 'Lindo brinquedo para gatos',
        'price': 45.90,
        'image_url': 'https://example.com/image.png',
        'contact_info': '11999999999',
        'condition': 'Novo',
        'seller_id': 'seller-456',
        'cep': '01001000',
        'street': 'Praça da Sé',
        'neighborhood': 'Sé',
        'city': 'São Paulo',
        'state': 'SP',
        'number': '10',
        'complement': 'Ap 2',
      };

      final item = Item.fromJson(json);

      expect(item.id, equals('item-123'));
      expect(item.title, equals('Gato Arranhador'));
      expect(item.description, equals('Lindo brinquedo para gatos'));
      expect(item.price, equals(45.90));
      expect(item.imageUrl, equals('https://example.com/image.png'));
      expect(item.contactInfo, equals('11999999999'));
      expect(item.condition, equals('Novo'));
      expect(item.sellerId, equals('seller-456'));
      expect(item.cep, equals('01001000'));
      expect(item.street, equals('Praça da Sé'));
      expect(item.neighborhood, equals('Sé'));
      expect(item.city, equals('São Paulo'));
      expect(item.state, equals('SP'));
      expect(item.number, equals('10'));
      expect(item.complement, equals('Ap 2'));
      expect(item.isFree, isFalse);
    });

    test('Should parse Item from Json with default fallback values', () {
      final json = {
        'id': 'item-123',
        'title': 'Doação de Ração',
      };

      final item = Item.fromJson(json);

      expect(item.id, equals('item-123'));
      expect(item.title, equals('Doação de Ração'));
      expect(item.description, equals(''));
      expect(item.price, equals(0.0));
      expect(item.imageUrl, equals(''));
      expect(item.contactInfo, equals(''));
      expect(item.condition, equals('Usado'));
      expect(item.isFree, isTrue);
    });

    test('Should convert Item to Json map correctly', () {
      final item = Item(
        id: 'item-123',
        title: 'Gato Arranhador',
        description: 'Lindo brinquedo para gatos',
        price: 45.90,
        imageUrl: 'https://example.com/image.png',
        contactInfo: '11999999999',
        condition: 'Novo',
        sellerId: 'seller-456',
        cep: '01001000',
        street: 'Praça da Sé',
        neighborhood: 'Sé',
        city: 'São Paulo',
        state: 'SP',
        number: '10',
        complement: 'Ap 2',
      );

      final json = item.toJson();

      expect(json['id'], equals('item-123'));
      expect(json['title'], equals('Gato Arranhador'));
      expect(json['description'], equals('Lindo brinquedo para gatos'));
      expect(json['price'], equals(45.90));
      expect(json['image_url'], equals('https://example.com/image.png'));
      expect(json['contact_info'], equals('11999999999'));
      expect(json['condition'], equals('Novo'));
      expect(json['seller_id'], equals('seller-456'));
      expect(json['cep'], equals('01001000'));
      expect(json['street'], equals('Praça da Sé'));
      expect(json['neighborhood'], equals('Sé'));
      expect(json['city'], equals('São Paulo'));
      expect(json['state'], equals('SP'));
      expect(json['number'], equals('10'));
      expect(json['complement'], equals('Ap 2'));
    });

    test('isFree should return true when price is 0 or negative', () {
      final item1 = Item(
        id: '1',
        title: 'Item Grátis',
        description: '',
        price: 0.0,
        imageUrl: '',
        contactInfo: '',
      );
      final item2 = Item(
        id: '2',
        title: 'Item Grátis Negativo',
        description: '',
        price: -1.0,
        imageUrl: '',
        contactInfo: '',
      );
      final item3 = Item(
        id: '3',
        title: 'Item Pago',
        description: '',
        price: 0.01,
        imageUrl: '',
        contactInfo: '',
      );

      expect(item1.isFree, isTrue);
      expect(item2.isFree, isTrue);
      expect(item3.isFree, isFalse);
    });
  });
}
