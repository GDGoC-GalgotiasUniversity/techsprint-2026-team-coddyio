/// Voice Agent Configuration
///
/// This file contains all configuration constants for the Agora Conversational AI
/// voice agent integration. Update these values with your actual credentials.

class VoiceAgentConfig {
  // ============================================================================
  // AGORA CONFIGURATION
  // ============================================================================

  /// Your Agora App ID from https://console.agora.io
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';

  /// Your Agora Customer ID from Account → Credentials
  static const String agoraCustomerId = 'YOUR_CUSTOMER_ID';

  /// Your Agora Customer Secret from Account → Credentials
  static const String agoraCustomerSecret = 'YOUR_CUSTOMER_SECRET';

  /// Your Agora App Certificate (for token generation)
  static const String agoraAppCertificate = 'YOUR_AGORA_APP_CERTIFICATE';

  // ============================================================================
  // GEMINI AI CONFIGURATION
  // ============================================================================

  /// Google Gemini API Key from https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  /// Gemini model to use
  static const String geminiModel = 'gemini-2.0-flash';

  /// Maximum conversation history to maintain
  static const int geminiMaxHistory = 32;

  // ============================================================================
  // CARTESIA TTS CONFIGURATION
  // ============================================================================

  /// Cartesia API Key from https://cartesia.ai
  static const String cartesiaApiKey = 'YOUR_CARTESIA_API_KEY';

  /// Cartesia TTS Model ID
  static const String cartesiaModelId = 'sonic-2';

  /// Cartesia Voice ID (e.g., "en-US-AndrewMultilingualNeural")
  static const String cartesiaVoiceId = 'YOUR_VOICE_ID';

  /// Audio sample rate in Hz
  static const int audioSampleRate = 16000;

  // ============================================================================
  // SERVER CONFIGURATION
  // ============================================================================

  /// Your backend server IP/URL for token generation
  static const String serverUrl = 'http://YOUR_SERVER_IP:3000';

  /// RTC token generation endpoint
  static const String rtcTokenEndpoint = '/api/rtc-token';

  // ============================================================================
  // VOICE AGENT BEHAVIOR
  // ============================================================================

  /// Greeting message from the agent
  static const String greetingMessage =
      'Hello! I am your agricultural assistant. How can I help you with your farm today?';

  /// Fallback message when agent doesn't understand
  static const String failureMessage =
      'Sorry, I did not understand that. Could you please repeat?';

  /// Session idle timeout in seconds
  static const int idleTimeoutSeconds = 120;

  /// ASR (Automatic Speech Recognition) language
  static const String asrLanguage = 'en-US';

  // ============================================================================
  // SYSTEM PROMPTS
  // ============================================================================

  /// Default system prompt for the AI agent
  static const String defaultSystemPrompt =
      '''You are an expert agricultural assistant for IoT-based farm monitoring.
Help farmers understand their sensor data and provide actionable recommendations.
Be concise, friendly, and practical in your responses.
Focus on:
- Temperature management and crop health
- Humidity levels and disease prevention
- Soil moisture and irrigation scheduling
- Seasonal recommendations
- Pest and disease prevention''';

  // ============================================================================
  // AGORA API ENDPOINTS
  // ============================================================================

  /// Base URL for Agora Conversational AI API
  static const String agoraApiBase =
      'https://api.agora.io/api/conversational-ai-agent/v2/projects';

  /// Join agent endpoint
  static String get agoraJoinEndpoint => '$agoraApiBase/$agoraAppId/join';

  /// Leave agent endpoint
  static String agoraLeaveEndpoint(String agentId) =>
      '$agoraApiBase/$agoraAppId/agents/$agentId/leave';

  /// Query agent status endpoint
  static String agoraStatusEndpoint(String agentId) =>
      '$agoraApiBase/$agoraAppId/agents/$agentId';

  // ============================================================================
  // VALIDATION METHODS
  // ============================================================================

  /// Check if all required credentials are configured
  static bool isConfigured() {
    return agoraAppId != 'YOUR_AGORA_APP_ID' &&
        agoraCustomerId != 'YOUR_CUSTOMER_ID' &&
        agoraCustomerSecret != 'YOUR_CUSTOMER_SECRET' &&
        geminiApiKey != 'YOUR_GEMINI_API_KEY' &&
        cartesiaApiKey != 'YOUR_CARTESIA_API_KEY' &&
        cartesiaVoiceId != 'YOUR_VOICE_ID' &&
        serverUrl != 'http://YOUR_SERVER_IP:3000';
  }

  /// Get list of missing configurations
  static List<String> getMissingConfigurations() {
    final missing = <String>[];

    if (agoraAppId == 'YOUR_AGORA_APP_ID') missing.add('Agora App ID');
    if (agoraCustomerId == 'YOUR_CUSTOMER_ID') missing.add('Agora Customer ID');
    if (agoraCustomerSecret == 'YOUR_CUSTOMER_SECRET')
      missing.add('Agora Customer Secret');
    if (geminiApiKey == 'YOUR_GEMINI_API_KEY') missing.add('Gemini API Key');
    if (cartesiaApiKey == 'YOUR_CARTESIA_API_KEY')
      missing.add('Cartesia API Key');
    if (cartesiaVoiceId == 'YOUR_VOICE_ID') missing.add('Cartesia Voice ID');
    if (serverUrl == 'http://YOUR_SERVER_IP:3000') missing.add('Server URL');

    return missing;
  }
}
