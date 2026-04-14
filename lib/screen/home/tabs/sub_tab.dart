import 'package:flutter/material.dart';
import 'package:greenlink_front/data/resource_service.dart';
import 'package:greenlink_front/screen/home/pages/inventory_page.dart';
import 'package:greenlink_front/screen/home/pages/quest_page.dart';
import 'package:greenlink_front/screen/home/widgets/common_glass.dart';

class SubTab extends StatefulWidget {
  const SubTab({super.key});

  @override
  State<SubTab> createState() => _SubTabState();
}

class _SubTabState extends State<SubTab> {
  final ResourceService _resourceService = ResourceService();

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  Set<String> _attendDates = {};

  @override
  void initState() {
    super.initState();
    _refreshAttendMonth();
  }

  Future<void> _refreshAttendMonth() async {
    try {
      final result = await _resourceService.fetchAttendMonth(
        year: _focusedMonth.year,
        month: _focusedMonth.month,
      );
      if (!mounted) return;
      setState(() {
        _attendDates = result.dates.toSet();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _attendDates = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainText = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? Colors.white70 : Colors.black54;
    return SingleChildScrollView(
      key: const ValueKey('sub_tab'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text("부 페이지", style: TextStyle(color: subText, fontSize: 18, fontWeight: FontWeight.w600)),
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
                  Row(
                    children: [
                      Text("출석 캘린더", style: TextStyle(color: subText, fontSize: 16)),
                      const Spacer(),
                      Text(
                        "출석 ${_attendDates.length}일",
                        style: TextStyle(color: subText, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB6E3FF).withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
                    ),
                    child: Text(
                      "오늘 첫 진입 시 자동 출석 처리됩니다.",
                      style: TextStyle(color: mainText, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _pillButton("퀘스트 보기", const Color(0xFFDDF8A5), () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestPage()));
                    }),
                  ),
                  const SizedBox(height: 18),
                  _buildCalendar(),
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
        child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildCalendar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainText = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? Colors.white70 : Colors.black54;
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
                  icon: Icon(Icons.chevron_left, color: subText),
                  onPressed: () async {
                    setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                    });
                    await _refreshAttendMonth();
                  },
                ),
                Text(
                  "${_focusedMonth.year}년 ${_focusedMonth.month}월",
                  style: TextStyle(color: mainText, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: subText),
                  onPressed: () async {
                    setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                    });
                    await _refreshAttendMonth();
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: const [
                _Dow("일"),
                _Dow("월"),
                _Dow("화"),
                _Dow("수"),
                _Dow("목"),
                _Dow("금"),
                _Dow("토"),
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

                final dateKey = _ymd(day);
                final isAttended = _attendDates.contains(dateKey);
                final isToday = _isSameDate(day, DateTime.now());

                return Container(
                  decoration: BoxDecoration(
                    color: isAttended
                        ? const Color(0xFFFFC7E2).withOpacity(0.22)
                        : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday ? const Color(0xFFFF6FAE) : (isDark ? Colors.white10 : Colors.black12),
                      width: isToday ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${day.day}",
                        style: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1A1A1A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isAttended)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6FAE),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
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

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _ymd(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "${d.year}-$m-$day";
  }

  void _showCreatePlantModal(BuildContext context, ResourceService service) {
    final nicknameCtrl = TextEditingController();
    final plantIdCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.black.withOpacity(0.9) : Colors.white,
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
              Text(
                "내 식물 등록",
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _textField("식물 닉네임", nicknameCtrl, isDark: isDark),
              const SizedBox(height: 10),
              _textField("Plant ID", plantIdCtrl, keyboardType: TextInputType.number, isDark: isDark),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    foregroundColor: isDark ? Colors.black : Colors.white,
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

  Widget _textField(
    String hint,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool isDark = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
