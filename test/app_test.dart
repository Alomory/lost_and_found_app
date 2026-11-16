import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_founds_simple/model/item.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/providers/app_provider.dart';
import 'package:lost_and_founds_simple/screens/auth_screen.dart';
import 'package:lost_and_founds_simple/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  group('User model', () {
    test('hashes password and verifies correctly', () {
      final user = User.withPlainPassword(
        email: 'Test@Example.com ',
        username: 'Omar Alomory',
        password: 'secret123',
        phoneNo: '0123456789',
      );

      expect(user.email, 'test@example.com');
      expect(user.passwordHash, isNot('secret123'));
      expect(user.verifyPassword('secret123'), isTrue);
      expect(user.verifyPassword('wrong'), isFalse);
      expect(user.firstName, 'Omar');
    });

    test('round-trips toMap and fromMap', () {
      final user = User.withPlainPassword(
        email: 'ali@example.com',
        username: 'Ali',
        password: 'pw',
        phoneNo: '0111111111',
      );
      final restored = User.fromMap(user.toMap());
      expect(restored.email, user.email);
      expect(restored.username, user.username);
      expect(restored.passwordHash, user.passwordHash);
      expect(restored.phoneNo, user.phoneNo);
    });
  });

  group('Item model', () {
    test('round-trips toMap and fromMap', () {
      final user = User.withPlainPassword(
        email: 'omar@example.com',
        username: 'Omar',
        password: 'pw',
        phoneNo: '01234',
      );
      final item = Item(
        id: 'item_1',
        imagePath: '/tmp/test.jpg',
        itemName: 'Keys',
        itemDescription: 'Silver keys',
        location: 'Library',
        user: user,
        type: false,
        isSynced: true,
      );

      final restored = Item.fromMap(item.toMap(), user);
      expect(restored.id, 'item_1');
      expect(restored.itemName, 'Keys');
      expect(restored.type, isFalse);
      expect(restored.typeLabel, 'Lost');
      expect(restored.isSynced, isTrue);
    });
  });

  group('AuthScreen widget', () {
    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AuthScreen(),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });
}
