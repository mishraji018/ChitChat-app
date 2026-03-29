import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/message_provider.dart';
import '../../../core/services/socket_service.dart';
import '../../../data/providers/socket_provider.dart';
import 'dart:convert';
import '../../../data/providers/settings_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String? receiverId; // Added to handle receiverId for socket send
  
  const ChatScreen({
    super.key, 
    required this.conversationId,
    this.receiverId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Step 3.1: Socket Room Join
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketService.joinRoom(widget.conversationId);
      ref.read(messageProvider(widget.conversationId).notifier).markAsRead();
      
      // Listen for typing indicators
      SocketService.onTypingStart((data) {
        if (data['conversationId'] == widget.conversationId) {
          ref.read(isTypingProvider(widget.conversationId).notifier).state = true;
        }
      });
      SocketService.onTypingStop((data) {
        if (data['conversationId'] == widget.conversationId) {
          ref.read(isTypingProvider(widget.conversationId).notifier).state = false;
        }
      });
    });
  }

  @override
  void dispose() {
    // Step 3.2: De-register listeners and leave room
    SocketService.leaveRoom(widget.conversationId);
    SocketService.off('typing_start');
    SocketService.off('typing_stop');
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 200;
    if (show != ref.read(showScrollToBottomProvider)) {
      ref.read(showScrollToBottomProvider.notifier).state = show;
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onTextChanged(String value) {
    // Step 3.4: Typing Indicators with debounce
    if (value.trim().isNotEmpty) {
      SocketService.startTyping(widget.conversationId);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        SocketService.stopTyping(widget.conversationId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageProvider(widget.conversationId));
    final isTyping = ref.watch(isTypingProvider(widget.conversationId));
    final replyTo = ref.watch(replyToMessageProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final wallpaperType = ref.watch(wallpaperTypeProvider);
    final wallpaperValue = ref.watch(wallpaperValueProvider);
    final fontSize = ref.watch(chatFontSizeProvider);
    BoxDecoration? backgroundDecoration;

    if (wallpaperType == 'solid') {
      backgroundDecoration = BoxDecoration(
        color: Color(int.parse(wallpaperValue.replaceAll('#', '0xff'))),
      );
    } else if (wallpaperType == 'gradient') {
      final colors = wallpaperValue.split(',');
      if (colors.length == 2) {
        backgroundDecoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(int.parse(colors[0].replaceAll('#', '0xff'))),
              Color(int.parse(colors[1].replaceAll('#', '0xff'))),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      }
    } else if (wallpaperType == 'image' && wallpaperValue.isNotEmpty) {
      try {
        final bytes = base64Decode(wallpaperValue);
        backgroundDecoration = BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(bytes),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: isDark ? 0.6 : 0.2), BlendMode.darken),
          ),
        );
      } catch (_) {}
    } else if (wallpaperType == 'premium') {
      backgroundDecoration = BoxDecoration(
        image: DecorationImage(
          image: AssetImage(wallpaperValue),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.15), 
            BlendMode.lighten,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundDecoration == null ? theme.scaffoldBackgroundColor : Colors.transparent,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context, theme, colorScheme),
      body: Container(
        decoration: backgroundDecoration,
        child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isTyping && index == 0) {
                      return _buildTypingIndicator(colorScheme);
                    }
                    final messageIndex = isTyping ? index - 1 : index;
                    final message = messages[messageIndex];
                    
                    bool showDate = false;
                    if (messageIndex == messages.length - 1) {
                      showDate = true;
                    } else {
                      final prevMessage = messages[messageIndex + 1];
                      if (!_isSameDay(message.timestamp, prevMessage.timestamp)) {
                        showDate = true;
                      }
                    }

                    return Column(
                      children: [
                        if (showDate) _buildDateChip(message.timestamp, colorScheme),
                        _MessageBubble(
                          message: message,
                          fontSize: fontSize,
                          onReply: () => ref.read(replyToMessageProvider.notifier).state = message,
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (replyTo != null) _ReplyPreviewBar(
                message: replyTo,
                onCancel: () => ref.read(replyToMessageProvider.notifier).state = null,
              ),
              _ChatInputBar(
                controller: _textController,
                focusNode: _focusNode,
                onChanged: _onTextChanged,
                onSend: (text) {
                  // Step 3.3: Send message via provider
                  ref.read(messageProvider(widget.conversationId).notifier).sendTextMessage(
                    text: text.trim(),
                    receiverId: widget.receiverId ?? '',
                    replyTo: ref.read(replyToMessageProvider),
                  );
                  _textController.clear();
                  ref.read(replyToMessageProvider.notifier).state = null;
                  _scrollToBottom();
                },
              ),
            ],
          ),
          _buildScrollToBottomButton(),
        ],
      ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    // Step 3.6: Online Status
    final onlineUsers = ref.watch(onlineUsersProvider);
    final isOnline = widget.receiverId != null && onlineUsers.contains(widget.receiverId);

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0.5,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: InkWell(
        onTap: () => context.push(
          '/contact-info/${widget.receiverId}',
          extra: {
            'conversationId': widget.conversationId,
            'name': 'Contact',
            'avatar': '',
            'about': 'Hey there! I am using ChitChat.',
          },
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                  child: Text('C', style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                if (isOnline) Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.appBarTheme.backgroundColor ?? Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact',
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isOnline ? 'Online' : 'last seen recently',
                    style: TextStyle(color: colorScheme.secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (val) {
            if (val == 'view') {
              context.push(
                '/contact-info/${widget.receiverId}',
                extra: {
                  'conversationId': widget.conversationId,
                  'name': 'Contact',
                  'avatar': '',
                  'about': 'Hey there! I am using ChitChat.',
                },
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View Contact')),
            const PopupMenuItem(value: 'media', child: Text('Media, Links, Docs')),
            const PopupMenuItem(value: 'search', child: Text('Search')),
            const PopupMenuItem(value: 'mute', child: Text('Mute Notifications')),
            const PopupMenuItem(value: 'wallpaper', child: Text('Wallpaper')),
            const PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
            const PopupMenuItem(value: 'block', child: Text('Block')),
            const PopupMenuItem(value: 'report', child: Text('Report')),
          ],
        ),
      ],
    );
  }

  Widget _buildDateChip(DateTime date, ColorScheme colorScheme) {
    String text = _getDateString(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(color: colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  String _getDateString(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(date, now)) return 'Today';
    if (_isSameDay(date, yesterday)) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: _AnimatedTypingDots(color: colorScheme.secondary),
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    final show = ref.watch(showScrollToBottomProvider);
    if (!show) return const SizedBox.shrink();

    return Positioned(
      bottom: 80,
      right: 16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton.small(
            onPressed: _scrollToBottom,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _AnimatedTypingDots extends StatefulWidget {
  final Color color;
  const _AnimatedTypingDots({required this.color});

  @override
  State<_AnimatedTypingDots> createState() => _AnimatedTypingDotsState();
}

class _AnimatedTypingDotsState extends State<_AnimatedTypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final sinVal = (sin((_controller.value * 2 * pi) + (i * pi / 1.5)) + 1) / 2;
            return Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.3 + (0.7 * sinVal)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onReply;
  final double fontSize;

  const _MessageBubble({required this.message, required this.onReply, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMe = message.isMe;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context, theme, colorScheme),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMe ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.replyTo != null) _buildReplyPreview(message.replyTo!, isMe, colorScheme),
                  _buildContent(message, isMe, colorScheme, fontSize),
                  _buildStatusRow(message, isMe, colorScheme),
                ],
              ),
            ),
            if (message.reactions.isNotEmpty) _buildReactionsPill(message.reactions, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(MessageModel reply, bool isMe, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isMe ? Colors.black : colorScheme.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: isMe ? colorScheme.onPrimary : colorScheme.primary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.isMe ? 'You' : 'Contact',
            style: TextStyle(
              color: isMe ? colorScheme.onPrimary : colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            reply.text ?? 'Media',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: (isMe ? colorScheme.onPrimary : colorScheme.onSurface).withValues(alpha: 0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MessageModel message, bool isMe, ColorScheme colorScheme, double fontSize) {
    if (message.isDeleted) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Message deleted',
          style: TextStyle(color: (isMe ? colorScheme.onPrimary : colorScheme.onSurface).withValues(alpha: 0.5), fontStyle: FontStyle.italic),
        ),
      );
    }

    switch (message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
          child: Text(
            message.text ?? '',
            style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.onSurface, fontSize: fontSize),
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                message.mediaUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            if (message.text != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  message.text!,
                  style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.onSurface),
                ),
              ),
          ],
        );
      case MessageType.pdf:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text!,
                      style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.onSurface, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('1.2 MB • PDF', style: TextStyle(color: (isMe ? colorScheme.onPrimary : colorScheme.onSurface).withValues(alpha: 0.6), fontSize: 11)),
                  ],
                ),
              ),
              TextButton(onPressed: () {}, child: Text('OPEN', style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.primary, fontWeight: FontWeight.bold))),
            ],
          ),
        );
      case MessageType.voice:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: (isMe ? Colors.black : colorScheme.primary).withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(Icons.play_arrow, color: isMe ? colorScheme.onPrimary : colorScheme.primary),
              ),
              const SizedBox(width: 8),
              _buildStaticWaveform(isMe, colorScheme),
              const SizedBox(width: 8),
              Text('${message.duration}s', style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.onSurface, fontSize: 12)),
            ],
          ),
        );
      case MessageType.location:
        return Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey.withValues(alpha: 0.3),
              child: Icon(Icons.location_on, size: 48, color: colorScheme.primary),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                message.text ?? 'Location sharing',
                style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.onSurface),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStaticWaveform(bool isMe, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(15, (i) {
        final height = (i % 3 + 1) * 4.0;
        return Container(
          width: 2,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: (isMe ? colorScheme.onPrimary : colorScheme.primary).withValues(alpha: i < 7 ? 1.0 : 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  Widget _buildStatusRow(MessageModel message, bool isMe, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: TextStyle(
              color: (isMe ? colorScheme.onPrimary : colorScheme.onSurface).withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            _buildStatusIcon(message.status, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status, ColorScheme colorScheme) {
    switch (status) {
      case MessageStatus.sent:
        return Icon(Icons.check, size: 14, color: colorScheme.onPrimary.withValues(alpha: 0.6));
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14, color: colorScheme.onPrimary.withValues(alpha: 0.6));
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 14, color: Colors.blueAccent);
    }
  }

  Widget _buildReactionsPill(Map<String, List<String>> reactions, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.entries.map((e) {
          return Row(
            children: [
              Text(e.key, style: const TextStyle(fontSize: 12)),
              if (e.value.length > 1) Text(' ${e.value.length}', style: TextStyle(color: colorScheme.secondary, fontSize: 10)),
              const SizedBox(width: 4),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.secondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              _buildEmojiRow(colorScheme),
              const Divider(),
              _buildOption(Icons.reply, 'Reply', colorScheme, () {
                onReply();
                Navigator.pop(context);
              }),
              _buildOption(Icons.copy, 'Copy', colorScheme, () => Navigator.pop(context)),
              _buildOption(Icons.star_outline, 'Star', colorScheme, () => Navigator.pop(context)),
              _buildOption(Icons.forward_outlined, 'Forward', colorScheme, () => Navigator.pop(context)),
              if (message.isMe) ...[
                _buildOption(Icons.edit_outlined, 'Edit', colorScheme, () => Navigator.pop(context)),
                _buildOption(Icons.delete_outline, 'Delete', Colors.red, () => Navigator.pop(context)),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmojiRow(ColorScheme colorScheme) {
    final emojis = ['❤️', '😂', '😮', '😢', '👍', '👎'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ...emojis.map((e) => GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(e, style: const TextStyle(fontSize: 26)),
            ),
          )),
          IconButton(icon: Icon(Icons.add_circle_outline, color: colorScheme.secondary), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, dynamic color, VoidCallback onTap) {
    final displayColor = color is Color ? color : (color as ColorScheme).onSurface;
    return ListTile(
      leading: Icon(icon, color: displayColor),
      title: Text(title, style: TextStyle(color: displayColor)),
      onTap: onTap,
    );
  }
}

class _ReplyPreviewBar extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onCancel;

  const _ReplyPreviewBar({required this.message, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.1))),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Replying to ${message.isMe ? 'yourself' : 'Contact'}', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(message.text ?? 'Media', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.secondary, fontSize: 13)),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.close, size: 20, color: colorScheme.secondary), onPressed: onCancel),
          ],
        ),
      ),
    );
  }
}

class _ChatInputBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSend;
  final Function(String) onChanged;

  const _ChatInputBar({
    required this.controller, 
    required this.focusNode, 
    required this.onSend,
    required this.onChanged,
  });

  @override
  ConsumerState<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<_ChatInputBar> {
  bool _showSend = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = widget.controller.text.trim();
    if (_showSend != text.isNotEmpty) {
      setState(() {
        _showSend = text.isNotEmpty;
      });
    }
    widget.onChanged(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRecording = ref.watch(isRecordingProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!isRecording) IconButton(icon: Icon(Icons.emoji_emotions_outlined, color: colorScheme.secondary), onPressed: () {}),
            Expanded(
              child: isRecording 
                ? _buildRecordingUI(colorScheme)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            maxLines: 5,
                            minLines: 1,
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.5)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        IconButton(icon: Icon(Icons.attach_file, color: colorScheme.secondary), onPressed: () => _showAttachments(context, colorScheme)),
                      ],
                    ),
                  ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onLongPress: _showSend ? null : () => ref.read(isRecordingProvider.notifier).state = true,
              onLongPressUp: isRecording ? () => ref.read(isRecordingProvider.notifier).state = false : null,
              onTap: _showSend ? () => widget.onSend(widget.controller.text) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                child: Icon(
                  _showSend ? Icons.send : Icons.mic,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingUI(ColorScheme colorScheme) {
    return Row(
      children: [
        const Icon(Icons.mic, color: Colors.red, size: 20),
        const SizedBox(width: 8),
        const Text('Recording...', style: TextStyle(color: Colors.red)),
        const Spacer(),
        Text('0:05', style: TextStyle(color: colorScheme.secondary)),
      ],
    );
  }

  void _showAttachments(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          children: [
            _buildAttachmentItem(Icons.insert_drive_file, 'Document', Colors.indigo, colorScheme),
            _buildAttachmentItem(Icons.camera_alt, 'Camera', Colors.pink, colorScheme),
            _buildAttachmentItem(Icons.image, 'Gallery', Colors.purple, colorScheme),
            _buildAttachmentItem(Icons.headset, 'Audio', Colors.orange, colorScheme),
            _buildAttachmentItem(Icons.location_on, 'Location', Colors.green, colorScheme),
            _buildAttachmentItem(Icons.person, 'Contact', Colors.blue, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(IconData icon, String label, Color color, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: colorScheme.onSurface, fontSize: 12)),
      ],
    );
  }
}
