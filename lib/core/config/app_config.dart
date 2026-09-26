// lib/core/config/app_config.dart
// Environment configuration and remote provider parameter management

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String groqModel;
  final String cloudinaryCloudName;
  final String pineconeIndex;
  final String pineconeApiKey;
  final String pineconeHost;
  final String pineconeNamespace;
  final bool enableOfflineQueue;
  final bool enableDetailedLogging;

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.groqModel,
    required this.cloudinaryCloudName,
    required this.pineconeIndex,
    this.pineconeApiKey = 'pcsk_42Wcdd_KKuKA43EJLG5YT7xPLzG4qzdX2AyTydWLsdwFZz2z4aZz1ozWd7R3ePimVUBzbt',
    this.pineconeHost = 'https://research-index-384-xcpvnhr.svc.aped-4627-b74a.pinecone.io',
    this.pineconeNamespace = 'raksha-welfare',
    this.enableOfflineQueue = true,
    this.enableDetailedLogging = false,
  });

  bool get isProduction => environment == AppEnvironment.prod;
  bool get isDevelopment => environment == AppEnvironment.dev;

  static AppConfig? _current;
  static AppConfig get current {
    if (_current == null) {
      throw StateError(
        'AppConfig has not been initialized. Call AppConfig.initialize() first.',
      );
    }
    return _current!;
  }

  static void initialize(AppConfig config) {
    _current = config;
  }

  /// Default configuration loaded from build-time environment or fallback to prototype config
  factory AppConfig.prototype() {
    return const AppConfig(
      environment: AppEnvironment.dev,
      supabaseUrl: 'https://jkayuhgxjkyffvvalsqt.supabase.co',
      supabaseAnonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprYXl1aGd4amt5ZmZ2dmFsc3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzMzY2MTgsImV4cCI6MjEwNTkxMjYxOH0.RcXoEAX76CK4TKTqjgBSGZoQ6ZnHjXTKJKDv8s_b2ss',
      groqModel: 'qwen/qwen3.8-27b',
      cloudinaryCloudName: 'deii0fu4y',
      pineconeIndex: 'research-index-384',
      pineconeApiKey: 'pcsk_42Wcdd_KKuKA43EJLG5YT7xPLzG4qzdX2AyTydWLsdwFZz2z4aZz1ozWd7R3ePimVUBzbt',
      pineconeHost: 'https://research-index-384-xcpvnhr.svc.aped-4627-b74a.pinecone.io',
      pineconeNamespace: 'raksha-welfare',
      enableOfflineQueue: true,
      enableDetailedLogging: true,
    );
  }
}
