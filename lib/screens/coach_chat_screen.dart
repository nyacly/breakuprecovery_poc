import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:breakup_recovery/services/auth_service.dart';
import 'package:breakup_recovery/repositories/breakup_recovery_repository.dart';
import 'package:breakup_recovery/models/chat_message_model.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final AuthService _authService = AuthService();
  final BreakupRecoveryRepository _repository = BreakupRecoveryRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _threadId = 'main';

  bool _isLoading = false;
  bool _showTypingIndicator = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: Column(
        children: [
          BRAppBar(
            title: 'Recovery Coach',
            showBack: false,
          ),
          Expanded(child: _buildBody()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final user = _authService.currentUser;
    if (user == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return StreamBuilder<List<ChatMessageModel>>(
      stream: _repository.getChatMessages(_threadId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: BRSpacing.md,
                  vertical: BRSpacing.sm,
                ),
                itemCount: messages.length + (_showTypingIndicator ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && _showTypingIndicator) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(messages[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isUser = message.role == MessageRole.user;
    final isAssistant = message.role == MessageRole.coach;

    return Container(
      margin: const EdgeInsets.only(bottom: BRSpacing.sm),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAssistant) ...[
            Container(
              padding: const EdgeInsets.all(BRSpacing.xs),
              decoration: BoxDecoration(
                color: BRColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 20,
                color: BRColors.primary,
              ),
            ),
            const SizedBox(width: BRSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(BRSpacing.md),
              decoration: BoxDecoration(
                color: isUser ? BRColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isAssistant ? const Radius.circular(4) : null,
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isUser ? Colors.white : BRColors.text,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: BRSpacing.xs),
                  Text(
                    DateFormat.jm().format(message.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isUser 
                          ? Colors.white.withValues(alpha: 0.8) 
                          : BRColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: BRSpacing.sm),
            Container(
              padding: const EdgeInsets.all(BRSpacing.xs),
              decoration: BoxDecoration(
                color: BRColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: BRColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: BRSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(BRSpacing.xs),
            decoration: BoxDecoration(
              color: BRColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: 20,
              color: BRColors.primary,
            ),
          ),
          const SizedBox(width: BRSpacing.sm),
          Container(
            padding: const EdgeInsets.all(BRSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(200),
                const SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.4 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: BRColors.textSecondary.withValues(alpha: 0.3 + (0.4 * value)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BRSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(BRSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 6),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(BRSpacing.lg),
                decoration: BoxDecoration(
                  color: BRColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 48,
                  color: BRColors.primary,
                ),
              ),
              const SizedBox(height: BRSpacing.lg),
              Text(
                'Your Recovery Coach',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: BRColors.text,
                ),
              ),
              const SizedBox(height: BRSpacing.sm),
              Text(
                'I\'m here to support you through your healing journey. Ask me anything about breakups, emotional recovery, or just share how you\'re feeling.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BRColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: BRSpacing.lg),
              Wrap(
                spacing: BRSpacing.sm,
                runSpacing: BRSpacing.sm,
                children: [
                  _buildSuggestedMessage('How are you feeling today?'),
                  _buildSuggestedMessage('I need emotional support'),
                  _buildSuggestedMessage('Help me process my feelings'),
                  _buildSuggestedMessage('What should I do next?'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedMessage(String message) {
    return InkWell(
      onTap: () => _sendMessage(message),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BRSpacing.md,
          vertical: BRSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: BRColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: BRColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(BRSpacing.md),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: BRSpacing.md),
        child: Row(
          mainAxisAlignment: index.isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (index.isEven)
              Container(width: 32, height: 32, child: SkeletonCard()),
            if (index.isEven) const SizedBox(width: BRSpacing.sm),
            Flexible(
              child: SkeletonCard(height: 60),
            ),
            if (index.isOdd) const SizedBox(width: BRSpacing.sm),
            if (index.isOdd)
              Container(width: 32, height: 32, child: SkeletonCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(BRSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: BRColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: BRColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: BRSpacing.md,
                      vertical: BRSpacing.sm,
                    ),
                  ),
                  style: TextStyle(
                    color: BRColors.text,
                    fontSize: 16,
                  ),
                  onSubmitted: (_) => _sendCurrentMessage(),
                ),
              ),
            ),
            const SizedBox(width: BRSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: BRColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isLoading ? null : _sendCurrentMessage,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                iconSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendCurrentMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _sendMessage(message);
      _messageController.clear();
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      // Send user message (repository handles coach response automatically)
      await _repository.sendChatMessage(message, _threadId);
      
      // Show typing indicator briefly for UX
      setState(() => _showTypingIndicator = true);
      
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
      // Hide typing indicator after delay
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _showTypingIndicator = false);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: BRColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _showTypingIndicator = false;
      });
      
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _generateSupportiveResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('sad') || message.contains('cry') || message.contains('hurt')) {
      return 'I hear you, and it\'s completely okay to feel sad. These emotions are a natural part of healing. Have you tried any of the self-care activities in your recovery plan today?';
    } else if (message.contains('angry') || message.contains('mad') || message.contains('furious')) {
      return 'Anger is a valid emotion during breakup recovery. It shows you\'re processing what happened. Try some deep breathing or physical activity to help channel those feelings constructively.';
    } else if (message.contains('lonely') || message.contains('alone')) {
      return 'Loneliness after a breakup is so common. Remember, this feeling is temporary. Consider reaching out to friends, family, or focusing on activities that bring you joy. You\'re stronger than you know.';
    } else if (message.contains('progress') || message.contains('better') || message.contains('good')) {
      return 'That\'s wonderful to hear! Recognizing progress is so important. Keep celebrating these small victories - they add up to significant healing over time.';
    } else if (message.contains('step') || message.contains('plan')) {
      return 'Great question! I\'d recommend focusing on the current step in your recovery plan. Each step is designed to build on the previous one. How are you feeling about your current step?';
    } else if (message.contains('journal') || message.contains('write')) {
      return 'Journaling is such a powerful tool for processing emotions. Try writing about how you\'re feeling today, any challenges you faced, or positive moments you experienced.';
    } else {
      return 'Thank you for sharing that with me. Remember that healing isn\'t linear - some days will be harder than others, and that\'s completely normal. Take things one day at a time, and be gentle with yourself. What would feel most supportive for you right now?';
    }
  }
}