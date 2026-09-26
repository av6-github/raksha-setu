// lib/features/auth/data/auth_repository.dart
// Authentication data layer managing Supabase Auth and session caching

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/errors/app_exceptions.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/security/secure_storage_service.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';

abstract class IAuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInWithPassword(String email, String password);
  Future<void> signOut();
  Stream<AppUser?> get authStateChanges;
}

class AuthRepository implements IAuthRepository {
  final sp.SupabaseClient? client;
  final ISecureStorageService secureStorage;
  static const String _userCacheKey = 'cached_app_user_v1';

  AuthRepository({
    this.client,
    required this.secureStorage,
  });

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final session = client?.auth.currentSession;
      if (session == null) {
        return null;
      }

      return await _fetchUserProfile(session.user.id, session.user.email);
    } catch (e) {
      AppLogger.warning('Failed to get current user session', error: e);
      return null;
    }
  }

  @override
  Future<AppUser> signInWithPassword(String email, String password) async {
    try {
      if (client == null) {
        // Fallback mock user for prototype offline/local preview
        return AppUser(
          id: 'mock-user-id',
          email: email,
          role: UserRole.officer,
          firstName: 'Vikram',
          lastName: 'Singh',
          serviceNumber: 'CRPF-2024-8891',
        );
      }

      final res = await client!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        throw const AuthException('Sign in succeeded but user record was null');
      }

      final appUser = await _fetchUserProfile(user.id, user.email);
      await secureStorage.write(_userCacheKey, user.id);
      return appUser;
    } on sp.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client?.auth.signOut();
      await secureStorage.delete(_userCacheKey);
      AppLogger.info('User successfully signed out');
    } catch (e) {
      AppLogger.error('Error during sign out', error: e);
    }
  }

  @override
  Stream<AppUser?> get authStateChanges {
    if (client == null) {
      return Stream.value(null);
    }
    return client!.auth.onAuthStateChange.asyncMap((data) async {
      final session = data.session;
      if (session == null) return null;
      return await _fetchUserProfile(session.user.id, session.user.email);
    });
  }

  Future<AppUser> _fetchUserProfile(String authUserId, String? email) async {
    if (client == null) {
      return AppUser(
        id: authUserId,
        email: email,
        role: UserRole.officer,
      );
    }

    try {
      final identityRes = await client!
          .from('identities')
          .select('id, role_id, roles(name)')
          .eq('auth_user_id', authUserId)
          .maybeSingle();


      UserRole role = UserRole.officer;
      if (identityRes != null && identityRes['roles'] != null) {
        role = UserRole.fromString(identityRes['roles']['name']);
      }

      final officerRes = await client!
          .from('officers')
          .select('id, service_number, first_name, last_name')
          .eq('identity_id', identityRes?['id'] ?? '')
          .maybeSingle();


      return AppUser(
        id: authUserId,
        email: email,
        role: role,
        officerId: officerRes?['id'] as String?,
        serviceNumber: officerRes?['service_number'] as String?,
        firstName: officerRes?['first_name'] as String?,
        lastName: officerRes?['last_name'] as String?,
      );
    } catch (e) {
      AppLogger.warning('Failed to resolve full user profile from database; using base', error: e);
      return AppUser(id: authUserId, email: email, role: UserRole.officer);
    }
  }
}
