import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mar_cat/controllers/address_controller.dart';
import 'package:mar_cat/services/address_service.dart';
import 'package:mar_cat/models/address.dart';

class MockAddressService extends Mock implements AddressService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Address(
      userId: 'user-123',
      cep: '01001000',
      street: 'Praça da Sé',
      number: '123',
      neighborhood: 'Sé',
      city: 'São Paulo',
      state: 'SP',
    ));
  });

  group('AddressController Tests', () {
    late MockAddressService mockAddressService;
    late AddressController addressController;

    setUp(() {
      mockAddressService = MockAddressService();
      addressController = AddressController(addressService: mockAddressService);
    });

    test('Initial State - should have default loading, error and empty list states', () {
      expect(addressController.isLoading, isFalse);
      expect(addressController.error, isNull);
      expect(addressController.addresses, isEmpty);
    });

    test('fetchAddresses Success - should populate addresses list', () async {
      final mockAddresses = [
        Address(
          id: 'addr-123',
          userId: 'user-123',
          alias: 'Casa',
          cep: '01001000',
          street: 'Praça da Sé',
          number: '123',
          neighborhood: 'Sé',
          city: 'São Paulo',
          state: 'SP',
        )
      ];

      when(() => mockAddressService.fetchAddresses()).thenAnswer((_) async => mockAddresses);

      await addressController.fetchAddresses();

      expect(addressController.isLoading, isFalse);
      expect(addressController.error, isNull);
      expect(addressController.addresses, equals(mockAddresses));
      verify(() => mockAddressService.fetchAddresses()).called(1);
    });

    test('addAddress Success - should create address and add to list', () async {
      final returnedAddress = Address(
        id: 'addr-456',
        userId: 'user-123',
        alias: 'Trabalho',
        cep: '01001000',
        street: 'Praça da Sé',
        number: '123',
        neighborhood: 'Sé',
        city: 'São Paulo',
        state: 'SP',
      );

      when(() => mockAddressService.createAddress(any())).thenAnswer((_) async => returnedAddress);

      final result = await addressController.addAddress(
        userId: 'user-123',
        alias: 'Trabalho',
        cep: '01001000',
        street: 'Praça da Sé',
        number: '123',
        neighborhood: 'Sé',
        city: 'São Paulo',
        state: 'SP',
      );

      expect(result, isTrue);
      expect(addressController.isLoading, isFalse);
      expect(addressController.error, isNull);
      expect(addressController.addresses.contains(returnedAddress), isTrue);
      verify(() => mockAddressService.createAddress(any())).called(1);
    });

    test('removeAddress Success - should delete and remove from list', () async {
      final address = Address(
        id: 'addr-789',
        userId: 'user-123',
        alias: 'Outro',
        cep: '01001000',
        street: 'Praça da Sé',
        number: '123',
        neighborhood: 'Sé',
        city: 'São Paulo',
        state: 'SP',
      );

      addressController.addresses.add(address);

      when(() => mockAddressService.deleteAddress(any())).thenAnswer((_) async {});

      final result = await addressController.removeAddress('addr-789');

      expect(result, isTrue);
      expect(addressController.isLoading, isFalse);
      expect(addressController.error, isNull);
      expect(addressController.addresses, isEmpty);
      verify(() => mockAddressService.deleteAddress('addr-789')).called(1);
    });
  });
}
