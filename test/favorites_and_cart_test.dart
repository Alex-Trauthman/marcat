import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mar_cat/controllers/favorite_controller.dart';
import 'package:mar_cat/controllers/cart_controller.dart';
import 'package:mar_cat/services/favorite_service.dart';
import 'package:mar_cat/services/cart_service.dart';
import 'package:mar_cat/models/item.dart';

class MockFavoriteService extends Mock implements FavoriteService {}
class MockCartService extends Mock implements CartService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Item(
      id: 'item-123',
      title: 'Bicicleta Caloi',
      description: 'Laranja, 18 marchas',
      price: 150.0,
      imageUrl: 'assets/images/bicicleta.png',
      contactInfo: '11 99999-9999',
      condition: 'Usado',
    ));
  });

  group('FavoriteController Tests', () {
    late MockFavoriteService mockFavoriteService;
    late FavoriteController favoriteController;

    setUp(() {
      mockFavoriteService = MockFavoriteService();
      favoriteController = FavoriteController(favoriteService: mockFavoriteService);
    });

    test('Initial State - empty and not loading', () {
      expect(favoriteController.isLoading, isFalse);
      expect(favoriteController.favoriteItemIds, isEmpty);
    });

    test('fetchFavorites - loads favorite Items successfully', () async {
      final mockItems = [
        Item(id: 'item-1', title: 'Bike', description: '', price: 10, imageUrl: '', contactInfo: ''),
        Item(id: 'item-2', title: 'Phone', description: '', price: 20, imageUrl: '', contactInfo: ''),
      ];
      when(() => mockFavoriteService.fetchFavoriteItems())
          .thenAnswer((_) async => mockItems);

      await favoriteController.fetchFavorites();

      expect(favoriteController.isLoading, isFalse);
      expect(favoriteController.favoriteItemIds, equals({'item-1', 'item-2'}));
      expect(favoriteController.isFavorite('item-1'), isTrue);
      expect(favoriteController.isFavorite('item-3'), isFalse);
    });

    test('toggleFavorite - adds if not favorite, calls service', () async {
      when(() => mockFavoriteService.addFavorite(any())).thenAnswer((_) async {});

      final testItem = Item(id: 'item-3', title: 'A', description: '', price: 0, imageUrl: '', contactInfo: '');
      await favoriteController.toggleFavorite(testItem);

      expect(favoriteController.isFavorite('item-3'), isTrue);
      verify(() => mockFavoriteService.addFavorite('item-3')).called(1);
    });

    test('toggleFavorite - removes if already favorite, calls service', () async {
      // Pré-popula
      final testItem = Item(id: 'item-3', title: 'A', description: 'A', price: 0, imageUrl: '', contactInfo: '');
      when(() => mockFavoriteService.fetchFavoriteItems()).thenAnswer((_) async => [testItem]);
      await favoriteController.fetchFavorites();

      when(() => mockFavoriteService.removeFavorite(any())).thenAnswer((_) async {});

      await favoriteController.toggleFavorite(testItem);

      expect(favoriteController.isFavorite('item-3'), isFalse);
      verify(() => mockFavoriteService.removeFavorite('item-3')).called(1);
    });
  });

  group('CartController Tests', () {
    late MockCartService mockCartService;
    late CartController cartController;

    setUp(() {
      mockCartService = MockCartService();
      cartController = CartController(cartService: mockCartService);
    });

    test('Initial State - empty cart', () {
      expect(cartController.isLoading, isFalse);
      expect(cartController.cartItems, isEmpty);
      expect(cartController.totalPrice, equals(0.0));
    });

    test('fetchCart - populates cart and selects all items by default', () async {
      final mockItems = [
        Item(id: 'item-1', title: 'Bike', description: 'Desc', price: 100.0, imageUrl: 'img', contactInfo: '123', condition: 'Usado'),
        Item(id: 'item-2', title: 'Secador', description: 'Desc', price: 50.0, imageUrl: 'img', contactInfo: '123', condition: 'Usado'),
      ];

      when(() => mockCartService.fetchCartItems()).thenAnswer((_) async => mockItems);

      await cartController.fetchCart();

      expect(cartController.cartItems, equals(mockItems));
      expect(cartController.totalPrice, equals(150.0));
      expect(cartController.isItemSelected('item-1'), isTrue);
      expect(cartController.isItemSelected('item-2'), isTrue);
    });

    test('addToCart - inserts item and selects it', () async {
      final item = Item(id: 'item-1', title: 'Bike', description: 'Desc', price: 100.0, imageUrl: 'img', contactInfo: '123', condition: 'Usado');
      when(() => mockCartService.addToCart(any())).thenAnswer((_) async {});

      final success = await cartController.addToCart(item);

      expect(success, isTrue);
      expect(cartController.isInCart('item-1'), isTrue);
      expect(cartController.isItemSelected('item-1'), isTrue);
      expect(cartController.totalPrice, equals(100.0));
      verify(() => mockCartService.addToCart('item-1')).called(1);
    });

    test('removeFromCart - deletes item and updates total', () async {
      final item = Item(id: 'item-1', title: 'Bike', description: 'Desc', price: 100.0, imageUrl: 'img', contactInfo: '123', condition: 'Usado');
      cartController.cartItems.add(item);
      cartController.selectedCartItemIds.add(item.id);

      when(() => mockCartService.removeFromCart(any())).thenAnswer((_) async {});

      final success = await cartController.removeFromCart('item-1');

      expect(success, isTrue);
      expect(cartController.isInCart('item-1'), isFalse);
      expect(cartController.totalPrice, equals(0.0));
      verify(() => mockCartService.removeFromCart('item-1')).called(1);
    });

    test('toggleItemSelection - excludes item price from total when deselected', () async {
      final item1 = Item(id: 'item-1', title: 'Bike', description: 'Desc', price: 100.0, imageUrl: 'img', contactInfo: '123', condition: 'Usado');
      final item2 = Item(id: 'item-2', title: 'Secador', description: 'Desc', price: 50.0, imageUrl: 'img', contactInfo: '123', condition: 'Usado');
      
      cartController.cartItems.addAll([item1, item2]);
      cartController.selectedCartItemIds.addAll(['item-1', 'item-2']);

      expect(cartController.totalPrice, equals(150.0));

      cartController.toggleItemSelection('item-2');

      expect(cartController.isItemSelected('item-2'), isFalse);
      expect(cartController.totalPrice, equals(100.0));
    });

    test('addToCart - fails if adding own item', () async {
      final item = Item(
        id: 'item-1',
        title: 'Bike',
        description: 'Desc',
        price: 100.0,
        imageUrl: 'img',
        contactInfo: '123',
        condition: 'Usado',
        sellerId: 'user-123',
      );

      final success = await cartController.addToCart(item, currentUserId: 'user-123');

      expect(success, isFalse);
      expect(cartController.isInCart('item-1'), isFalse);
      expect(cartController.error, contains('seu próprio item'));
      verifyNever(() => mockCartService.addToCart(any()));
    });
  });
}
