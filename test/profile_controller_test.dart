import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mar_cat/controllers/profile_controller.dart';
import 'package:mar_cat/services/profile_service.dart';
import 'package:mar_cat/services/auth_service.dart';

class MockProfileService extends Mock implements ProfileService {}
class MockAuthService extends Mock implements AuthService {}
class MockFile extends Mock implements File {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  group('ProfileController Tests', () {
    late MockProfileService mockProfileService;
    late MockAuthService mockAuthService;
    late ProfileController profileController;

    setUp(() {
      mockProfileService = MockProfileService();
      mockAuthService = MockAuthService();
      profileController = ProfileController(
        profileService: mockProfileService,
        authService: mockAuthService,
      );
    });

    test('Initial State - should have default loading and error states', () {
      expect(profileController.isLoading, isFalse);
      expect(profileController.error, isNull);
    });

    test('updateProfile Success (Text Only) - should update profile without calling uploadAvatar', () async {
      when(() => mockAuthService.updateProfile(
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          )).thenAnswer((_) async {});

      final result = await profileController.updateProfile(
        fullName: 'Jane Doe',
        phone: '11988888888',
      );

      expect(result, isTrue);
      expect(profileController.isLoading, isFalse);
      expect(profileController.error, isNull);

      verify(() => mockAuthService.updateProfile(
            fullName: 'Jane Doe',
            phone: '11988888888',
            avatarUrl: null,
          )).called(1);
      verifyNever(() => mockProfileService.uploadAvatar(any()));
    });

    test('updateProfile Success (With Photo Change) - should upload file first, then update profile attributes', () async {
      final mockFile = MockFile();
      final mockAvatarUrl = 'https://supabase.com/storage/v1/object/public/avatars/user-123/avatar.jpg';

      when(() => mockProfileService.uploadAvatar(any()))
          .thenAnswer((_) async => mockAvatarUrl);

      when(() => mockAuthService.updateProfile(
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          )).thenAnswer((_) async {});

      final result = await profileController.updateProfile(
        fullName: 'Jane Doe',
        phone: '11988888888',
        avatarFile: mockFile,
      );

      expect(result, isTrue);
      expect(profileController.isLoading, isFalse);
      expect(profileController.error, isNull);

      verify(() => mockProfileService.uploadAvatar(mockFile)).called(1);
      verify(() => mockAuthService.updateProfile(
            fullName: 'Jane Doe',
            phone: '11988888888',
            avatarUrl: mockAvatarUrl,
          )).called(1);
    });

    test('updateProfile Failure (Avatar Upload fails) - should set error and return false', () async {
      final mockFile = MockFile();
      when(() => mockProfileService.uploadAvatar(any()))
          .thenThrow(Exception('Supabase storage upload error'));

      final result = await profileController.updateProfile(
        fullName: 'Jane Doe',
        avatarFile: mockFile,
      );

      expect(result, isFalse);
      expect(profileController.isLoading, isFalse);
      expect(profileController.error, equals('Supabase storage upload error'));

      verifyNever(() => mockAuthService.updateProfile(
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          ));
    });

    test('updateProfile Failure (Auth Update fails) - should set error and return false', () async {
      final mockFile = MockFile();
      final mockAvatarUrl = 'https://supabase.com/storage/v1/object/public/avatars/user-123/avatar.jpg';

      when(() => mockProfileService.uploadAvatar(any()))
          .thenAnswer((_) async => mockAvatarUrl);

      when(() => mockAuthService.updateProfile(
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          )).thenThrow(Exception('Auth update error'));

      final result = await profileController.updateProfile(
        fullName: 'Jane Doe',
        avatarFile: mockFile,
      );

      expect(result, isFalse);
      expect(profileController.isLoading, isFalse);
      expect(profileController.error, equals('Auth update error'));
    });
  });
}
