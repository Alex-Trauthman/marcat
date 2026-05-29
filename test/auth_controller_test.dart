import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mar_cat/controllers/auth_controller.dart';
import 'package:mar_cat/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockUser extends Mock implements User {}

void main() {
  group('AuthController Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      // Stub padrão para o construtor do AuthController que chama currentUser
      when(() => mockAuthService.currentUser).thenReturn(null);
    });

    test('Initial State - User should be null when not logged in', () {
      final controller = AuthController(authService: mockAuthService);

      expect(controller.userProfile, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      expect(controller.userName, isNull);
      expect(controller.avatarUrl, isNull);
    });

    test('Initial State - User should be populated if session exists', () {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('john@example.com');
      when(() => mockUser.userMetadata).thenReturn({
        'full_name': 'John Doe',
        'avatar_url': 'https://example.com/avatar.png',
      });
      when(() => mockAuthService.currentUser).thenReturn(mockUser);

      final controller = AuthController(authService: mockAuthService);

      expect(controller.userProfile, isNotNull);
      expect(controller.userProfile!.id, equals('user-123'));
      expect(controller.userProfile!.email, equals('john@example.com'));
      expect(controller.userName, equals('John Doe'));
      expect(controller.avatarUrl, equals('https://example.com/avatar.png'));
    });

    test('Login Success - should authenticate and set user profile', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('john@example.com');
      when(() => mockUser.userMetadata).thenReturn({'full_name': 'John Doe'});

      when(() => mockAuthService.login(any(), any())).thenAnswer((_) async {});
      
      final controller = AuthController(authService: mockAuthService);
      
      // Simula que após o login, currentUser retornará o usuário autenticado
      when(() => mockAuthService.currentUser).thenReturn(mockUser);

      final result = await controller.login('john@example.com', 'password123');

      expect(result, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      expect(controller.userProfile, isNotNull);
      expect(controller.userName, equals('John Doe'));
      verify(() => mockAuthService.login('john@example.com', 'password123')).called(1);
    });

    test('Login Failure - should catch error and set error message', () async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(Exception('Incorret password or email'));

      final controller = AuthController(authService: mockAuthService);

      final result = await controller.login('john@example.com', 'wrong');

      expect(result, isFalse);
      expect(controller.isLoading, isFalse);
      expect(controller.error, equals('Incorret password or email'));
      expect(controller.userProfile, isNull);
    });

    test('Register Success - should call register and update profile', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('john@example.com');
      when(() => mockUser.userMetadata).thenReturn({'full_name': 'John Doe'});

      when(() => mockAuthService.register(any(), any(), any())).thenAnswer((_) async {});
      final controller = AuthController(authService: mockAuthService);
      when(() => mockAuthService.currentUser).thenReturn(mockUser);

      final result = await controller.register('John Doe', 'john@example.com', 'password123');

      expect(result, isTrue);
      expect(controller.error, isNull);
      expect(controller.userName, equals('John Doe'));
      verify(() => mockAuthService.register('John Doe', 'john@example.com', 'password123')).called(1);
    });

    test('Register Failure - should fail and keep userProfile null', () async {
      when(() => mockAuthService.register(any(), any(), any()))
          .thenThrow(Exception('Email already registered'));

      final controller = AuthController(authService: mockAuthService);

      final result = await controller.register('John', 'john@example.com', 'pass');

      expect(result, isFalse);
      expect(controller.error, equals('Email already registered'));
      expect(controller.userProfile, isNull);
    });

    test('Logout - should sign out and clear profile', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('john@example.com');
      when(() => mockUser.userMetadata).thenReturn({'full_name': 'John'});
      when(() => mockAuthService.currentUser).thenReturn(mockUser);

      final controller = AuthController(authService: mockAuthService);
      expect(controller.userProfile, isNotNull);

      when(() => mockAuthService.logout()).thenAnswer((_) async {});
      when(() => mockAuthService.currentUser).thenReturn(null);

      await controller.logout();

      expect(controller.userProfile, isNull);
      verify(() => mockAuthService.logout()).called(1);
    });

    test('Delete Account Success - should delete account and clear profile', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('john@example.com');
      when(() => mockUser.userMetadata).thenReturn({'full_name': 'John'});
      when(() => mockAuthService.currentUser).thenReturn(mockUser);

      final controller = AuthController(authService: mockAuthService);
      expect(controller.userProfile, isNotNull);

      when(() => mockAuthService.deleteAccount()).thenAnswer((_) async {});
      
      final result = await controller.deleteAccount();

      expect(result, isTrue);
      expect(controller.userProfile, isNull);
      expect(controller.error, isNull);
      verify(() => mockAuthService.deleteAccount()).called(1);
    });

    test('Delete Account Failure - should keep profile and set error', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('john@example.com');
      when(() => mockUser.userMetadata).thenReturn({'full_name': 'John'});
      when(() => mockAuthService.currentUser).thenReturn(mockUser);

      final controller = AuthController(authService: mockAuthService);
      expect(controller.userProfile, isNotNull);

      when(() => mockAuthService.deleteAccount()).thenThrow(Exception('Delete failed'));

      final result = await controller.deleteAccount();

      expect(result, isFalse);
      expect(controller.userProfile, isNotNull);
      expect(controller.error, equals('Delete failed'));
    });
  });
}
