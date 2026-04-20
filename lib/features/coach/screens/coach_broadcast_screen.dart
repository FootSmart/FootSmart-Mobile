import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/theme_context.dart';

class CoachBroadcastScreen extends StatefulWidget {
  const CoachBroadcastScreen({super.key});

  @override
  State<CoachBroadcastScreen> createState() => _CoachBroadcastScreenState();
}

class _CoachBroadcastScreenState extends State<CoachBroadcastScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();

  final List<_BroadcastMessage> _messages = [
    _BroadcastMessage(
      text: 'Squad, this Saturday we play to win. 4-3-3 formation. Be ready!',
      time: 'Today, 10:00 AM',
      reactions: {'🔥': 8, '💪': 5, '👍': 3},
      type: MessageType.text,
    ),
    _BroadcastMessage(
      text: 'Lineup has been posted. Check the Tactics Board for positions.',
      time: 'Yesterday, 6:00 PM',
      reactions: {'👍': 11, '✅': 4},
      type: MessageType.tactic,
    ),
    _BroadcastMessage(
      text: 'Training moved to 5 PM tomorrow. Don\'t be late!',
      time: 'Feb 27, 3:30 PM',
      reactions: {'👍': 9, '✅': 7},
      type: MessageType.schedule,
    ),
  ];

  final List<_ScheduledMessage> _scheduledMessages = [
    _ScheduledMessage(
      text: 'Pre-match lineup for Saturday',
      scheduledFor: 'Friday, 6:00 PM',
      icon: Icons.draw,
    ),
    _ScheduledMessage(
      text: 'Motivational message before kickoff',
      scheduledFor: 'Saturday, 4:00 PM',
      icon: Icons.local_fire_department,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    setState(() {
      _messages.insert(
        0,
        _BroadcastMessage(
          text: _messageController.text,
          time: 'Just now',
          reactions: {},
          type: MessageType.text,
        ),
      );
      _messageController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Broadcast sent to all players!'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: context.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Squad Broadcast',
                          style: AppTextStyles.h3.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'One voice to the whole squad',
                          style: AppTextStyles.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people,
                          color: AppColors.accentGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '18',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: context.accentOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor:
                    context.isDark ? AppColors.primaryDark : Colors.white,
                unselectedLabelColor: context.textSecondary,
                labelStyle: AppTextStyles.buttonMedium,
                dividerHeight: 0,
                tabs: const [
                  Tab(text: 'Messages'),
                  Tab(text: 'Scheduled'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Messages Tab
                  _MessagesTab(messages: _messages),

                  // Scheduled Tab
                  _ScheduledTab(scheduled: _scheduledMessages),
                ],
              ),
            ),

            // Message Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.navBarBg,
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Attachment options
                  GestureDetector(
                    onTap: () {
                      _showAttachmentPicker(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.add,
                        color: context.iconInactive,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      style: AppTextStyles.inputText.copyWith(
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Broadcast to squad...',
                        hintStyle: AppTextStyles.inputHint.copyWith(
                          color: context.textHint,
                        ),
                        filled: true,
                        fillColor: context.inputBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.accentOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.send,
                        color: context.isDark
                            ? AppColors.primaryDark
                            : Colors.white,
                        size: 20,
                      ),
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

  void _showAttachmentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.navBarBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attach',
              style: AppTextStyles.h4.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachOption(
                  icon: Icons.draw,
                  label: 'Tactic Board',
                  color: context.accentOrange,
                  onTap: () => Navigator.pop(context),
                ),
                _AttachOption(
                  icon: Icons.image,
                  label: 'Image',
                  color: AppColors.chartBlue,
                  onTap: () => Navigator.pop(context),
                ),
                _AttachOption(
                  icon: Icons.schedule,
                  label: 'Schedule',
                  color: AppColors.chartPurple,
                  onTap: () => Navigator.pop(context),
                ),
                _AttachOption(
                  icon: Icons.local_fire_department,
                  label: 'Hype',
                  color: AppColors.error,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Messages Tab ────────────────────────────────────────────────────────────
class _MessagesTab extends StatelessWidget {
  final List<_BroadcastMessage> messages;

  const _MessagesTab({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _messageTypeColor(message.type, context)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _messageTypeIcon(message.type),
                      color: _messageTypeColor(message.type, context),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Coach',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    message.time,
                    style: AppTextStyles.caption.copyWith(
                      color: context.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                message.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.textPrimary,
                  height: 1.4,
                ),
              ),
              if (message.reactions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: message.reactions.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Text(
                        '${entry.key} ${entry.value}',
                        style: AppTextStyles.caption.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _messageTypeColor(MessageType type, BuildContext context) {
    switch (type) {
      case MessageType.text:
        return context.accentOrange;
      case MessageType.tactic:
        return AppColors.chartBlue;
      case MessageType.schedule:
        return AppColors.chartPurple;
    }
  }

  IconData _messageTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.campaign;
      case MessageType.tactic:
        return Icons.draw;
      case MessageType.schedule:
        return Icons.schedule;
    }
  }
}

// ─── Scheduled Tab ───────────────────────────────────────────────────────────
class _ScheduledTab extends StatelessWidget {
  final List<_ScheduledMessage> scheduled;

  const _ScheduledTab({required this.scheduled});

  @override
  Widget build(BuildContext context) {
    if (scheduled.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              color: context.iconInactive,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No scheduled messages',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: scheduled.length,
      itemBuilder: (context, index) {
        final msg = scheduled[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.chartPurple.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.chartPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  msg.icon,
                  color: AppColors.chartPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: context.textTertiary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          msg.scheduledFor,
                          style: AppTextStyles.caption.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.edit_outlined,
                  color: context.iconInactive,
                  size: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Attach Option ───────────────────────────────────────────────────────────
class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Models ──────────────────────────────────────────────────────────────────
enum MessageType { text, tactic, schedule }

class _BroadcastMessage {
  final String text;
  final String time;
  final Map<String, int> reactions;
  final MessageType type;

  _BroadcastMessage({
    required this.text,
    required this.time,
    required this.reactions,
    required this.type,
  });
}

class _ScheduledMessage {
  final String text;
  final String scheduledFor;
  final IconData icon;

  _ScheduledMessage({
    required this.text,
    required this.scheduledFor,
    required this.icon,
  });
}
