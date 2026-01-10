import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/gemini_service.dart';

class AiChatScreen
    extends
        StatefulWidget {
  final SensorData?
  sensorData;

  const AiChatScreen({
    super.key,
    required this.sensorData,
  });

  @override
  State<
    AiChatScreen
  >
  createState() => _AiChatScreenState();
}

class _AiChatScreenState
    extends
        State<
          AiChatScreen
        > {
  final GeminiService
  _geminiService = GeminiService();
  final TextEditingController
  _controller = TextEditingController();
  final List<
    ChatMessage
  >
  _messages = [];
  bool
  _isLoading = false;

  @override
  void
  initState() {
    super.initState();
    _addMessage(
      'Hello! I can answer questions about your sensor data. Try asking:\n\n'
      '• "Is the temperature normal?"\n'
      '• "Should I water the plant?"\n'
      '• "What\'s the humidity level?"',
      isUser: false,
    );
  }

  void
  _addMessage(
    String text, {
    required bool isUser,
  }) {
    setState(
      () {
        _messages.add(
          ChatMessage(
            text: text,
            isUser: isUser,
          ),
        );
      },
    );
  }

  Future<
    void
  >
  _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    _addMessage(
      question,
      isUser: true,
    );
    _controller.clear();

    setState(
      () => _isLoading = true,
    );

    final response = await _geminiService.askQuestion(
      question,
      widget.sensorData,
    );

    setState(
      () => _isLoading = false,
    );
    _addMessage(
      response,
      isUser: false,
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F8E9,
      ),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(
                8,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(
                      0xFF4CAF50,
                    ).withValues(
                      alpha: 0.1,
                    ),
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              child: const Icon(
                Icons.psychology,
                color: Color(
                  0xFF2E7D32,
                ),
                size: 24,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            const Text(
              'AI Assistant',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (widget.sensorData !=
              null)
            Container(
              margin: const EdgeInsets.all(
                12,
              ),
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  16,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.05,
                    ),
                    blurRadius: 8,
                    offset: const Offset(
                      0,
                      2,
                    ),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDataChip(
                    '${widget.sensorData!.temperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    const Color(
                      0xFFFF6F00,
                    ),
                  ),
                  _buildDataChip(
                    '${widget.sensorData!.humidity.toStringAsFixed(1)}%',
                    Icons.water_drop,
                    const Color(
                      0xFF0288D1,
                    ),
                  ),
                  _buildDataChip(
                    '${widget.sensorData!.soilPct.toStringAsFixed(1)}%',
                    Icons.grass,
                    const Color(
                      0xFF388E3C,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(
                16,
              ),
              itemCount: _messages.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final message = _messages[index];
                    return _buildMessageBubble(
                      message,
                    );
                  },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(
                8.0,
              ),
              child: CircularProgressIndicator(),
            ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget
  _buildDataChip(
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildMessageBubble(
    ChatMessage message,
  ) {
    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(
                context,
              ).size.width *
              0.75,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? const LinearGradient(
                  colors: [
                    Color(
                      0xFF2E7D32,
                    ),
                    Color(
                      0xFF4CAF50,
                    ),
                  ],
                )
              : null,
          color: message.isUser
              ? null
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(
              20,
            ),
            topRight: const Radius.circular(
              20,
            ),
            bottomLeft: Radius.circular(
              message.isUser
                  ? 20
                  : 4,
            ),
            bottomRight: Radius.circular(
              message.isUser
                  ? 4
                  : 20,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: message.isUser
                  ? const Color(
                      0xFF2E7D32,
                    ).withValues(
                      alpha: 0.3,
                    )
                  : Colors.black.withValues(
                      alpha: 0.05,
                    ),
              blurRadius: 8,
              offset: const Offset(
                0,
                2,
              ),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : const Color(
                    0xFF212121,
                  ),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget
  _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 8,
            offset: const Offset(
              0,
              -2,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF1F8E9,
                ),
                borderRadius: BorderRadius.circular(
                  24,
                ),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Ask about your farm...',
                  hintStyle: TextStyle(
                    color: Color(
                      0xFF9E9E9E,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted:
                    (
                      _,
                    ) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(
                    0xFF2E7D32,
                  ),
                  Color(
                    0xFF4CAF50,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(
                24,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(
                        0xFF2E7D32,
                      ).withValues(
                        alpha: 0.3,
                      ),
                  blurRadius: 8,
                  offset: const Offset(
                    0,
                    2,
                  ),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _isLoading
                  ? null
                  : _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String
  text;
  final bool
  isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}
