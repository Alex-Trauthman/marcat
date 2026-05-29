import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mar_cat/controllers/item_controller.dart';
import 'package:mar_cat/services/item_service.dart';

class MockItemService extends Mock implements ItemService {}

void main() {
  group('ItemController Tests', () {
    late MockItemService mockItemService;
    late ItemController itemController;

    setUp(() {
      mockItemService = MockItemService();
      itemController = ItemController(itemService: mockItemService);
    });

    test('Initial State - should have default states', () {
      expect(itemController.isLoading, isFalse);
      expect(itemController.error, isNull);
    });

    test('fetchAddressFromCep - should delegate call to ItemService', () async {
      final mockAddress = {
        'logradouro': 'Praça da Sé',
        'bairro': 'Sé',
        'localidade': 'São Paulo',
        'uf': 'SP',
      };

      when(() => mockItemService.fetchAddressFromCep('01001000'))
          .thenAnswer((_) async => mockAddress);

      final result = await itemController.fetchAddressFromCep('01001000');

      expect(result, isNotNull);
      expect(result!['logradouro'], equals('Praça da Sé'));
      verify(() => mockItemService.fetchAddressFromCep('01001000')).called(1);
    });

    test('createItem Success - should return true, clear error, and toggle loading', () async {
      when(() => mockItemService.createItem(
            title: any(named: 'title'),
            description: any(named: 'description'),
            price: any(named: 'price'),
            condition: any(named: 'condition'),
            contactInfo: any(named: 'contactInfo'),
            imageFile: any(named: 'imageFile'),
            cep: any(named: 'cep'),
            street: any(named: 'street'),
            neighborhood: any(named: 'neighborhood'),
            city: any(named: 'city'),
            state: any(named: 'state'),
            number: any(named: 'number'),
            complement: any(named: 'complement'),
          )).thenAnswer((_) async {});

      final result = await itemController.createItem(
        title: 'Arranhador Gato',
        description: 'Novo e resistente',
        price: 99.90,
        condition: 'Novo',
        contactInfo: '11999999999',
        cep: '01001000',
        street: 'Praça da Sé',
        neighborhood: 'Sé',
        city: 'São Paulo',
        state: 'SP',
      );

      expect(result, isTrue);
      expect(itemController.isLoading, isFalse);
      expect(itemController.error, isNull);

      verify(() => mockItemService.createItem(
            title: 'Arranhador Gato',
            description: 'Novo e resistente',
            price: 99.90,
            condition: 'Novo',
            contactInfo: '11999999999',
            imageFile: null,
            cep: '01001000',
            street: 'Praça da Sé',
            neighborhood: 'Sé',
            city: 'São Paulo',
            state: 'SP',
            number: null,
            complement: null,
          )).called(1);
    });

    test('createItem Failure - should return false and capture the exception message', () async {
      when(() => mockItemService.createItem(
            title: any(named: 'title'),
            description: any(named: 'description'),
            price: any(named: 'price'),
            condition: any(named: 'condition'),
            contactInfo: any(named: 'contactInfo'),
            imageFile: any(named: 'imageFile'),
            cep: any(named: 'cep'),
            street: any(named: 'street'),
            neighborhood: any(named: 'neighborhood'),
            city: any(named: 'city'),
            state: any(named: 'state'),
            number: any(named: 'number'),
            complement: any(named: 'complement'),
          )).thenThrow(Exception('Supabase database insert error'));

      final result = await itemController.createItem(
        title: 'Arranhador Gato',
        description: 'Novo e resistente',
        price: 99.90,
        condition: 'Novo',
        contactInfo: '11999999999',
      );

      expect(result, isFalse);
      expect(itemController.isLoading, isFalse);
      expect(itemController.error, equals('Supabase database insert error'));
    });

    test('updateItem Success - should return true and clear error', () async {
      when(() => mockItemService.updateItem(
            id: any(named: 'id'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            price: any(named: 'price'),
            condition: any(named: 'condition'),
            contactInfo: any(named: 'contactInfo'),
            imageFile: any(named: 'imageFile'),
            existingImageUrl: any(named: 'existingImageUrl'),
            cep: any(named: 'cep'),
            street: any(named: 'street'),
            neighborhood: any(named: 'neighborhood'),
            city: any(named: 'city'),
            state: any(named: 'state'),
            number: any(named: 'number'),
            complement: any(named: 'complement'),
          )).thenAnswer((_) async {});

      final result = await itemController.updateItem(
        id: 'item-123',
        title: 'Arranhador Gato Modificado',
        description: 'Usado por 2 semanas',
        price: 70.00,
        condition: 'Usado',
        contactInfo: '11999999999',
        existingImageUrl: 'https://example.com/image.png',
      );

      expect(result, isTrue);
      expect(itemController.isLoading, isFalse);
      expect(itemController.error, isNull);

      verify(() => mockItemService.updateItem(
            id: 'item-123',
            title: 'Arranhador Gato Modificado',
            description: 'Usado por 2 semanas',
            price: 70.00,
            condition: 'Usado',
            contactInfo: '11999999999',
            imageFile: null,
            existingImageUrl: 'https://example.com/image.png',
            cep: null,
            street: null,
            neighborhood: null,
            city: null,
            state: null,
            number: null,
            complement: null,
          )).called(1);
    });

    test('updateItem Failure - should return false and capture the exception message', () async {
      when(() => mockItemService.updateItem(
            id: any(named: 'id'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            price: any(named: 'price'),
            condition: any(named: 'condition'),
            contactInfo: any(named: 'contactInfo'),
            imageFile: any(named: 'imageFile'),
            existingImageUrl: any(named: 'existingImageUrl'),
            cep: any(named: 'cep'),
            street: any(named: 'street'),
            neighborhood: any(named: 'neighborhood'),
            city: any(named: 'city'),
            state: any(named: 'state'),
            number: any(named: 'number'),
            complement: any(named: 'complement'),
          )).thenThrow(Exception('Update error on database'));

      final result = await itemController.updateItem(
        id: 'item-123',
        title: 'Arranhador Gato Modificado',
        description: 'Usado por 2 semanas',
        price: 70.00,
        condition: 'Usado',
        contactInfo: '11999999999',
      );

      expect(result, isFalse);
      expect(itemController.isLoading, isFalse);
      expect(itemController.error, equals('Update error on database'));
    });

    test('deleteItem Success - should return true and clear error', () async {
      when(() => mockItemService.deleteItem(any())).thenAnswer((_) async {});

      final result = await itemController.deleteItem('item-123');

      expect(result, isTrue);
      expect(itemController.isLoading, isFalse);
      expect(itemController.error, isNull);
      verify(() => mockItemService.deleteItem('item-123')).called(1);
    });

    test('deleteItem Failure - should return false and capture error', () async {
      when(() => mockItemService.deleteItem(any())).thenThrow(Exception('Delete access denied'));

      final result = await itemController.deleteItem('item-123');

      expect(result, isFalse);
      expect(itemController.isLoading, isFalse);
      expect(itemController.error, equals('Delete access denied'));
    });
  });
}
