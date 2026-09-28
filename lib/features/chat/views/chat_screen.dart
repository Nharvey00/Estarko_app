import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String inquiryId;
  final String title;
  final String? subtitle;
  final ChatService? chatService;

  const ChatScreen({
    super.key,
    required this.inquiryId,
    this.title = 'Viewing Chat',
    this.subtitle,
    this.chatService,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatService _chatService;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _chatService = widget.chatService ?? ChatService();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getCurrentUserId(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.uid.isNotEmpty) {
        return authProvider.currentUser!.uid;
      }
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final senderId = _getCurrentUserId(context);
    if (senderId.isEmpty) return;

    _messageController.clear();
    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(
        inquiryId: widget.inquiryId,
        senderId: senderId,
        text: text,
      );

      // Auto scroll to bottom
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuad,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64.0,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Coordinate the viewing schedule directly with the host here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey.shade500,
              ),
            ),
          ]
              .animate(interval: 100.ms)
              .fade(duration: 400.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFFE11D48) // Ruby Red for sender
                      : const Color(0xFFF1F5F9), // Soft grey for recipient
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18.0),
                    topRight: const Radius.circular(18.0),
                    bottomLeft: Radius.circular(isMe ? 18.0 : 4.0),
                    bottomRight: Radius.circular(isMe ? 4.0 : 18.0),
                  ),
                  boxShadow: isMe
                      ? const [
                          BoxShadow(
                            color: Color(0x33E11D48),
                            blurRadius: 8.0,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : const [],
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: isMe ? Colors.white : const Color(0xFF111827),
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 3.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  _formatTime(msg.createdAt),
                  style: TextStyle(
                    fontSize: 11.0,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _getCurrentUserId(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111827),
            size: 20.0,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 2.0),
              Text(
                widget.subtitle!,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFF1F5F9),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages Stream
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: _chatService.getMessages(widget.inquiryId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(20.0),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final isRight = index % 2 != 0;
                        return Align(
                          alignment: isRight
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: EstarSkeleton(
                              width: 200.0,
                              height: 48.0,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                },
              ),
            ),

            // Message Composer
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 16.0,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                        onSubmitted: (_) => _handleSendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Container(
                    width: 46.0,
                    height: 46.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE11D48),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x40E11D48),
                          blurRadius: 8.0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 18.0,
                              height: 18.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20.0,
                            ),
                      onPressed: _isSending ? null : _handleSendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
