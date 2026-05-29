import 'package:flutter_test/flutter_test.dart';
import 'package:mar_cat/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('Should parse UserProfile from Supabase metadata with full fields', () {
      final metadata = {
        'full_name': 'John Doe',
        'avatar_url': 'https://example.com/avatar.png',
        'phone': '11999999999',
      };
      final id = 'user-123';
      final email = 'john@example.com';

      final profile = UserProfile.fromSupabase(metadata, id, email);

      expect(profile.id, equals(id));
      expect(profile.email, equals(email));
      expect(profile.fullName, equals('John Doe'));
      expect(profile.avatarUrl, equals('https://example.com/avatar.png'));
      expect(profile.phone, equals('11999999999'));
    });

    test('Should parse UserProfile with default values when metadata is empty', () {
      final metadata = <String, dynamic>{};
      final id = 'user-123';
      final email = 'john@example.com';

      final profile = UserProfile.fromSupabase(metadata, id, email);

      expect(profile.id, equals(id));
      expect(profile.email, equals(email));
      expect(profile.fullName, equals('john')); // Split before @
      expect(profile.avatarUrl, isNull);
      expect(profile.phone, isNull);
    });

    test('Should convert UserProfile to metadata map correctly', () {
      final profile = UserProfile(
        id: 'user-123',
        email: 'john@example.com',
        fullName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.png',
        phone: '11999999999',
      );

      final metadata = profile.toMetadata();

      expect(metadata['full_name'], equals('John Doe'));
      expect(metadata['avatar_url'], equals('https://example.com/avatar.png'));
      expect(metadata['phone'], equals('11999999999'));
    });

    test('Should convert UserProfile with null optional fields to metadata map without them', () {
      final profile = UserProfile(
        id: 'user-123',
        email: 'john@example.com',
        fullName: 'John Doe',
      );

      final metadata = profile.toMetadata();

      expect(metadata['full_name'], equals('John Doe'));
      expect(metadata.containsKey('avatar_url'), isFalse);
      expect(metadata.containsKey('phone'), isFalse);
    });
  });
}
