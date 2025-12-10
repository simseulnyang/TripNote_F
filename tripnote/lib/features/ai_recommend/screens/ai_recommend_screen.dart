import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';

/// AI 추천 화면
///
/// AI와 대화하여 여행 일정 추천을 받는 화면
class AIRecommendScreen extends ConsumerStatefulWidget {
  const AIRecommendScreen({super.key});

  @override
  ConsumerState<AIRecommendScreen> createState() => _AIRecommendScreenState();
}

class _AIRecommendScreenState extends ConsumerState<AIRecommendScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 환영 메시지
    _messages.add(
      ChatMessage(
        content: '안녕하세요! 🎒 여행 일정 추천 AI입니다.\n\n'
            '어떤 여행을 계획하고 계신가요?\n'
            '예를 들어:\n'
            '• "제주도 2박 3일 일정 추천해줘"\n'
            '• "서울에서 부산까지 드라이브 코스 알려줘"\n'
            '• "혼자 가기 좋은 국내 여행지 추천해줘"',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),

            // 채팅 영역
            Expanded(
              child: isLoggedIn ? _buildChatArea() : _buildLoginPrompt(context),
            ),

            // 입력 영역
            if (isLoggedIn) _buildInputArea(),
          ],
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Text(
            'AI 추천받기',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 로그인 유도 화면
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🤖',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'AI 추천을 받으려면\n로그인이 필요해요',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('로그인하기', style: AppTextStyles.buttonMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 채팅 영역
  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildLoadingBubble();
        }
        return _ChatBubble(message: _messages[index]);
      },
    );
  }

  /// 로딩 버블
  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AI가 생각 중이에요...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 입력 영역
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: '여행지나 일정을 물어보세요...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메시지 전송
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // 사용자 메시지 추가
    setState(() {
      _messages.add(ChatMessage(
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // TODO: 실제 AI API 호출
    // 현재는 더미 응답
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _messages.add(ChatMessage(
        content: _getDummyResponse(text),
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  /// 스크롤 맨 아래로
  void _scrollToBottom() {
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

  /// 더미 응답 (테스트용)
  String _getDummyResponse(String query) {
    if (query.contains('제주') || query.contains('jeju')) {
      return '제주도 여행 좋은 선택이에요! 🌴\n\n'
          '**2박 3일 추천 코스:**\n\n'
          '📍 1일차\n'
          '• 제주공항 → 함덕해수욕장\n'
          '• 월정리 해변 카페거리\n'
          '• 성산일출봉 (일몰 감상)\n\n'
          '📍 2일차\n'
          '• 우도 일주 (자전거 추천)\n'
          '• 만장굴 탐험\n'
          '• 제주 흑돼지 거리\n\n'
          '📍 3일차\n'
          '• 한라산 영실코스 트레킹\n'
          '• 오설록 티뮤지엄\n'
          '• 제주공항\n\n'
          '이 일정을 저장하시겠어요?';
    }

    return '네, 좋은 질문이에요! 😊\n\n'
        '조금 더 구체적으로 알려주시면 맞춤 추천을 드릴 수 있어요:\n\n'
        '• 여행 기간이 어떻게 되나요?\n'
        '• 누구와 함께 가시나요?\n'
        '• 선호하는 여행 스타일이 있나요? (힐링, 액티비티, 맛집 등)';
  }
}

/// 채팅 메시지 모델
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

/// 채팅 버블 위젯
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
          border:
              message.isUser ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          message.content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
