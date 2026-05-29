import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mar_cat/services/item_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockHttpClient extends Mock implements http.Client {}
class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('ViaCEP API Tests in ItemService', () {
    late MockSupabaseClient mockSupabase;
    late MockHttpClient mockHttpClient;
    late ItemService itemService;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockHttpClient = MockHttpClient();
      itemService = ItemService(
        supabaseClient: mockSupabase,
        httpClient: mockHttpClient,
      );
    });

    test('Should return address Map when ViaCEP responds with success (200)', () async {
      final mockResponseJson = {
        'cep': '01001-000',
        'logradouro': 'Praça da Sé',
        'bairro': 'Sé',
        'localidade': 'São Paulo',
        'uf': 'SP',
      };

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(mockResponseJson), 200),
      );

      final result = await itemService.fetchAddressFromCep('01001-000');

      expect(result, isNotNull);
      expect(result!['logradouro'], equals('Praça da Sé'));
      expect(result['bairro'], equals('Sé'));
      expect(result['localidade'], equals('São Paulo'));
      expect(result['uf'], equals('SP'));

      // Verifica se a URL correta do ViaCEP foi chamada
      verify(() => mockHttpClient.get(Uri.parse('https://viacep.com.br/ws/01001000/json/'))).called(1);
    });

    test('Should return null when ViaCEP responds with erro true (200 but not found)', () async {
      final mockResponseJson = {'erro': true};

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(mockResponseJson), 200),
      );

      final result = await itemService.fetchAddressFromCep('99999999');

      expect(result, isNull);
      verify(() => mockHttpClient.get(Uri.parse('https://viacep.com.br/ws/99999999/json/'))).called(1);
    });

    test('Should return null when ViaCEP responds with an HTTP error status (500)', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      final result = await itemService.fetchAddressFromCep('01001-000');

      expect(result, isNull);
    });

    test('Should return null and handle exceptions gracefully when HTTP request fails', () async {
      when(() => mockHttpClient.get(any())).thenThrow(Exception('No Internet Connection'));

      final result = await itemService.fetchAddressFromCep('01001-000');

      expect(result, isNull);
    });

    test('Should return null immediately without making request if CEP length is not 8 digits', () async {
      final result1 = await itemService.fetchAddressFromCep('1234567');
      final result2 = await itemService.fetchAddressFromCep('123456789');
      final result3 = await itemService.fetchAddressFromCep('');

      expect(result1, isNull);
      expect(result2, isNull);
      expect(result3, isNull);

      // Garante que o httpClient não foi chamado
      verifyNever(() => mockHttpClient.get(any()));
    });
  });
}
