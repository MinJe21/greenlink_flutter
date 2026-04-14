import 'package:flutter/material.dart';
import 'package:greenlink_front/data/auth_service.dart';
import 'package:greenlink_front/data/auth_session.dart';
import 'package:greenlink_front/data/resource_service.dart';
import 'package:greenlink_front/screen/home/tabs/home_tab.dart';
import 'package:greenlink_front/screen/home/tabs/sub_tab.dart';
import 'package:greenlink_front/screen/home/tabs/encyclopedia_tab.dart';

/// 홈(메인)/부/도감 3개 탭 하단 네비 컨테이너
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // 0: 홈, 1: 부, 2: 도감
  int _homeRefreshTick = 0;
  int _subRefreshTick = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _authService = AuthService();
  final _nicknameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _resourceService = ResourceService();
  String _headerNickname = "닉네임?";
  String? _profileImageUrl;
  bool _notifications = true;
  bool _compactCalendar = false;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadHeaderProfile();
    _autoAttendToday();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(key: ValueKey(_homeRefreshTick)),
      SubTab(key: ValueKey(_subRefreshTick)),
      const EncyclopediaTab(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: widget.isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF3F5F7),
      drawer: _buildProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildGlobalHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: IndexedStack(
                  key: ValueKey(_tabIndex),
                  index: _tabIndex,
                  children: pages,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildGlobalHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: _openProfileDrawer,
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: widget.isDarkMode ? Colors.white24 : Colors.black12,
                  backgroundImage: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                      ? Icon(Icons.person, color: widget.isDarkMode ? Colors.white70 : Colors.black54, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  _headerNickname,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.settings, color: widget.isDarkMode ? Colors.white70 : Colors.black54),
            onPressed: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItem(icon: Icons.home, label: "홈"),
      _NavItem(icon: Icons.nature, label: "부"),
      _NavItem(icon: Icons.menu_book, label: "도감"),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
        border: Border(
          top: BorderSide(
            color: widget.isDarkMode ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _navPill(
                  icon: items[i].icon,
                  label: items[i].label,
                  active: _tabIndex == i,
                  onTap: () => setState(() => _tabIndex = i),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navPill({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    final bg = active
        ? (widget.isDarkMode ? const Color(0xFF2A2E2A) : const Color(0xFFE8EED8))
        : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04));
    final color = active ? const Color(0xFF8EA86C) : (widget.isDarkMode ? Colors.white38 : Colors.black54);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.isDarkMode ? Colors.white10 : Colors.black12),
          boxShadow: const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Future<void> _openProfileDrawer() async {
    setState(() => _loadingProfile = true);
    try {
      final data = await _authService.fetchMyProfile();
      _nicknameCtrl.text = data['nickname']?.toString() ?? '';
      _phoneCtrl.text = data['phoneNumber']?.toString() ?? '';
      _addressCtrl.text = data['address']?.toString() ?? '';
      _profileImageUrl =
          data['profileImageUrl']?.toString() ??
          data['imageUrl']?.toString() ??
          data['avatarUrl']?.toString();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _loadingProfile = false);
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _loadHeaderProfile() async {
    try {
      final data = await _authService.fetchMyProfile();
      if (!mounted) return;
      setState(() {
        _headerNickname = data['nickname']?.toString() ?? "닉네임?";
        _profileImageUrl =
            data['profileImageUrl']?.toString() ??
            data['imageUrl']?.toString() ??
            data['avatarUrl']?.toString();
      });
    } catch (_) {}
  }

  Future<void> _autoAttendToday() async {
    try {
      await _resourceService.checkAttendToday();
    } catch (_) {
      // 이미 출석했거나 네트워크 오류 시 조용히 무시
    } finally {
      if (mounted) {
        setState(() {
          _subRefreshTick++;
        });
      }
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "설정",
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: widget.isDarkMode,
                  onChanged: (v) {
                    widget.onDarkModeChanged(v);
                    setSheetState(() {});
                    setState(() {});
                  },
                  title: Text(
                    "다크 모드",
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                ),
                SwitchListTile(
                  value: _notifications,
                  onChanged: (v) => setSheetState(() => _notifications = v),
                  title: Text(
                    "알림 받기",
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                ),
                SwitchListTile(
                  value: _compactCalendar,
                  onChanged: (v) => setSheetState(() => _compactCalendar = v),
                  title: Text(
                    "캘린더 간격 축소",
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.refresh, color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                  title: Text(
                    "데이터 새로고침",
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("로그아웃", style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    AuthSession.accessToken = null;
                    AuthSession.refreshToken = null;
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(this.context, '/login');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileDrawer() {
    return Drawer(
      backgroundColor: widget.isDarkMode ? const Color(0xFF161616) : Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "내 프로필",
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: widget.isDarkMode ? Colors.white12 : Colors.black12,
                  backgroundImage: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                      ? Icon(Icons.person, size: 36, color: widget.isDarkMode ? Colors.white70 : Colors.black54)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              if (_loadingProfile)
                const Center(child: CircularProgressIndicator())
              else ...[
                _field("닉네임", _nicknameCtrl),
                const SizedBox(height: 10),
                _field("전화번호", _phoneCtrl),
                const SizedBox(height: 10),
                _field("주소", _addressCtrl),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                  ),
                  onPressed: _loadingProfile
                      ? null
                      : () async {
                          try {
                            await _authService.updateMyProfile(
                              nickname: _nicknameCtrl.text.trim(),
                              phoneNumber: _phoneCtrl.text.trim(),
                              address: _addressCtrl.text.trim(),
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필 저장 완료')));
                            Navigator.pop(context);
                            setState(() {
                              _homeRefreshTick++;
                            });
                            _loadHeaderProfile();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('프로필 저장 실패: $e')));
                          }
                        },
                  child: const Text("저장"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: widget.isDarkMode ? Colors.white : const Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: widget.isDarkMode ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
