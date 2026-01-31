import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // Stream auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  User? get currentUser => client.auth.currentUser;

  Future<void> signUp(String email, String password, String username) async {
    final AuthResponse res = await client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    
    // Create profile row immediately
    if (res.user != null) {
      await createProfile(res.user!.id, username);
    }
  }
  
  Future<void> createProfile(String userId, String username) async {
    await client.from('profiles').insert({
      'id': userId,
      'username': username,
      'level': 1,
      'xp': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Example: Sync user data
  Future<void> syncUser(int localLevel, int localXp) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await client.from('profiles').upsert({
        'id': user.id,
        'level': localLevel,
        'xp': localXp,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) print("Sync error: $e");
    }
  }
}
