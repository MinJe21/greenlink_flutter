import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:greenlink_front/screen/home/pages/inventory_page.dart';
import 'package:greenlink_front/screen/home/pages/quest_page.dart';
import 'package:greenlink_front/screen/home/widgets/common_glass.dart';
import 'package:greenlink_front/data/resource_service.dart';

class SubTab extends StatefulWidget {
  const SubTab({super.key});

  @override
  State<SubTab> createState() => _SubTabState();
}

class _SubTabState extends State<SubTab> {
  final ResourceService _resourceService = ResourceService();
  late Future<List<Map<String, dynamic>>> _userQuestsFuture;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<Map<String, dynamic>> _userQuests = [];

  @override
  void initState() {
    super.initState();
    _userQuestsFuture = _loadUserQuests();
  }

  Future<List<Map<String, dynamic>>> _loadUserQuests() async {
    final data = await _resourceService.fetchUserQuests();
    _userQuests = data;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _userQuestsFuture,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          key: const ValueKey('sub_tab'),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text("부 페이지", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: glassButton(
                  text: "내 식물 등록",
                  onTap: () => _showCreatePlantModal(context, _resourceService),
                ),
              ),
              const SizedBox(height: 12),
              glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("닉네임?", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: _pillButton("퀘스트 보기", const Color(0xFFDDF8A5), () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestPage()));
                        }),
                      ),
                      const SizedBox(height: 18),
                      _buildCalendar(snapshot),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: glassButton(
                          text: "인벤토리",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage())),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pillButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.5), blurRadius: 16, spreadRadius: -2),
          ],
        ),
        child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // -------- 캘린더 (유저 퀘스트 표시) --------
  Widget _buildCalendar(AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    final days = _buildMonthDays(_focusedMonth);
    return glassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white70),
                  onPressed: () => setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                  }),
                ),
                Text("${_focusedMonth.year}년 ${_focusedMonth.month}월",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white70),
                  onPressed: () => setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: const [
                _Dow("일"), _Dow("월"), _Dow("화"), _Dow("수"), _Dow("목"), _Dow("금"), _Dow("토"),
              ],
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.1,
              ),
              itemCount: days.length,
              itemBuilder: (_, index) {
                final day = days[index];
                if (day == null) return const SizedBox();
                final markers = _markersFor(day);
                final now = DateTime.now();
                final isToday = _isSameDate(day, now);
                return GestureDetector(
                  onTap: markers.isEmpty ? null : () => _showQuestsForDate(day, markers),
                  child: Container(
                    decoration: BoxDecoration(
                      color: markers.isNotEmpty
                          ? Colors.white.withOpacity(0.07)
                          : isToday
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isToday ? Colors.amberAccent.withOpacity(0.6) : Colors.white10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${day.day}",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 2,
                            runSpacing: 2,
                            alignment: WrapAlignment.center,
                            children: markers.isNotEmpty
                                ? markers
                                    .take(3)
                                    .map((m) => Container(
                                          width: 8,
                                          height: 8,
                                          decoration:
                                              BoxDecoration(color: _colorForType(m.type), shape: BoxShape.circle),
                                        ))
                                    .toList()
                                : isToday
                                    ? [
                                        Container(
                                          width: 10,
                                          height: 2,
                                          color: Colors.amberAccent,
                                        )
                                      ]
                                    : [],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            _legend(),
          ],
        ),
      ),
    );
  }

  List<DateTime?> _buildMonthDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final leadingEmpty = first.weekday % 7;
    final total = leadingEmpty + last.day;
    final rows = ((total + 6) ~/ 7) * 7;
    return List.generate(rows, (i) {
      final day = i - leadingEmpty + 1;
      if (day < 1 || day > last.day) return null;
      return DateTime(month.year, month.month, day);
    });
  }

  List<_QuestMarker> _markersFor(DateTime day) {
    return _userQuests
        .map((q) => _parseQuestMarker(q))
        .where((m) => m != null && _isSameDate(m!.date, day))
        .cast<_QuestMarker>()
        .toList();
  }

  _QuestMarker? _parseQuestMarker(Map<String, dynamic> q) {
    final type = (q['type'] ?? q['questType'] ?? '').toString().toLowerCase();
    final dateStr = q['date'] ?? q['dueDate'] ?? q['targetDate'] ?? q['createdAt'];
    if (dateStr == null) return null;
    final dt = DateTime.tryParse(dateStr.toString());
    if (dt == null) return null;
    return _QuestMarker(date: dt, type: type);
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void _showQuestsForDate(DateTime date, List<_QuestMarker> markers) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${date.month}월 ${date.day}일 퀘스트",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            ...markers.map((m) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.flag, color: _colorForType(m.type)),
                  title: Text(
                    (m.type.isEmpty ? "퀘스트" : m.type),
                    style: const TextStyle(color: Colors.white),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dotLabel("Daily", _colorForType("daily")),
        const SizedBox(width: 10),
        _dotLabel("Weekly", _colorForType("weekly")),
        const SizedBox(width: 10),
        _dotLabel("Achievement", _colorForType("achievement")),
      ],
    );
  }

  Widget _dotLabel(String text, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return Colors.lightBlueAccent;
      case 'weekly':
        return Colors.greenAccent;
      case 'achievement':
        return Colors.amberAccent;
      default:
        return Colors.white54;
    }
  }

  void _showCreatePlantModal(BuildContext context, ResourceService service) {
    final nicknameCtrl = TextEditingController();
    final plantIdCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("내 식물 등록", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _textField("식물 닉네임", nicknameCtrl),
              const SizedBox(height: 10),
              _textField("Plant ID", plantIdCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final nick = nicknameCtrl.text.trim();
                    final pid = int.tryParse(plantIdCtrl.text.trim());
                    if (nick.isEmpty || pid == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('닉네임과 Plant ID를 입력하세요.')));
                      return;
                    }
                    try {
                      await service.createUserPlant(nickname: nick, plantId: pid);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('등록 성공')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: $e')));
                      }
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("등록", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _textField(String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _Dow extends StatelessWidget {
  const _Dow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _QuestMarker {
  _QuestMarker({required this.date, required this.type});
  final DateTime date;
  final String type;
}
