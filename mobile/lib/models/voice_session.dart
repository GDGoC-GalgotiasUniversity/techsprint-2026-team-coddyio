class VoiceSession {
  final String sessionId;
  final String channelName;
  final String rtcToken;
  final String agentId;
  final DateTime startTime;
  final String status; // 'active', 'paused', 'ended'
  final List<String> transcriptions;
  final List<String> responses;

  VoiceSession({
    required this.sessionId,
    required this.channelName,
    required this.rtcToken,
    required this.agentId,
    required this.startTime,
    this.status = 'active',
    this.transcriptions = const [],
    this.responses = const [],
  });

  /// Create a copy with updated fields
  VoiceSession copyWith({
    String? sessionId,
    String? channelName,
    String? rtcToken,
    String? agentId,
    DateTime? startTime,
    String? status,
    List<String>? transcriptions,
    List<String>? responses,
  }) {
    return VoiceSession(
      sessionId: sessionId ?? this.sessionId,
      channelName: channelName ?? this.channelName,
      rtcToken: rtcToken ?? this.rtcToken,
      agentId: agentId ?? this.agentId,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      transcriptions: transcriptions ?? this.transcriptions,
      responses: responses ?? this.responses,
    );
  }

  /// Get session duration
  Duration get duration => DateTime.now().difference(startTime);

  /// Check if session is active
  bool get isActive => status == 'active';

  /// Add transcription
  VoiceSession addTranscription(String text) {
    final updated = List<String>.from(transcriptions);
    updated.add(text);
    return copyWith(transcriptions: updated);
  }

  /// Add response
  VoiceSession addResponse(String text) {
    final updated = List<String>.from(responses);
    updated.add(text);
    return copyWith(responses: updated);
  }
}
