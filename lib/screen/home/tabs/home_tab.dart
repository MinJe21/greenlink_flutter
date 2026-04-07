import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:greenlink_front/data/auth_service.dart';
import 'package:greenlink_front/data/resource_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<String?> _nicknameFuture;
  late Future<_PlantCardData?> _plantFuture;

  @override
  void initState() {
    super.initState();
    _nicknameFuture = _loadNickname();
    _plantFuture = _loadMyPlant();
  }

  Future<String?> _loadNickname() async {
    final service = AuthService();
    try {
      return await service.fetchNickname();
    } catch (_) {
      return null;
    }
  }

  Future<_PlantCardData?> _loadMyPlant() async {
    try {
      final res = await ResourceService().fetchUserPlants();
      if (res.isEmpty) return null;
      final first = res.first;
      return _PlantCardData(
        title: first['nickname']?.toString() ?? first['plantName']?.toString() ?? '내 식물',
        subtitle: first['plantName']?.toString(),
        imageUrl: first['lastPhotoUrl']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('home_tab'),
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              // 프로필 영역
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: const Icon(Icons.person, color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 10),
              FutureBuilder<String?>(
                future: _nicknameFuture,
                builder: (context, snapshot) {
                  final name = snapshot.data;
                  return Text(
                    name ?? "닉네임?",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  );
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                onPressed: () {
                  // TODO: 설정 페이지 연결 시 갱신
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<_PlantCardData?>(
                      future: _plantFuture,
                      builder: (context, snapshot) {
                        final plant = snapshot.data;
                        return Text(
                          plant?.title ?? "내 식물",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: const [
                      _PillButton(text: "빛", color: Color(0xFFE4F3A3)),
                      SizedBox(width: 8),
                      _PillButton(text: "물", color: Color(0xFFB6D7FF)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _GlassButton(
                text: "식물설명",
                onTap: _showPlantInfo,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Center(
            child: FutureBuilder<_PlantCardData?>(
              future: _plantFuture,
              builder: (context, snapshot) {
                final plant = snapshot.data;
                return Container(
                  width: 240,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE4F3A3).withOpacity(0.35),
                        blurRadius: 45,
                        spreadRadius: -10,
                        offset: const Offset(0, 24),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: plant != null && plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                        ? Image.network(
                            plant.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _missingImagePlaceholder("plant image", size: const Size(240, 320)),
                          )
                        : Image.asset(
                            'assets/images/plant.jpeg',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                _missingImagePlaceholder("plant.jpeg", size: const Size(240, 320)),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TogglePills extends StatelessWidget {
  const _TogglePills();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _CircleToggle(label: "빛", activeColor: Color(0xFFE4F3A3), active: true),
        SizedBox(width: 10),
        _CircleToggle(label: "물", activeColor: Color(0xFFB6D7FF), active: true),
      ],
    );
  }
}

class _CircleToggle extends StatelessWidget {
  const _CircleToggle({required this.label, required this.activeColor, required this.active});
  final String label;
  final Color activeColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : Colors.white24;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: active
            ? [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2),
              ]
            : [],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 16, spreadRadius: -2),
        ],
      ),
      child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.text, this.onTap});
  final String text;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _missingImagePlaceholder(String name, {Size? size}) {
  return Container(
    width: size?.width,
    height: size?.height,
    color: Colors.black12,
    child: Center(
      child: Text("$name 추가 필요", style: const TextStyle(color: Colors.white54)),
    ),
  );
}

class _PlantCardData {
  _PlantCardData({required this.title, this.subtitle, this.imageUrl});
  final String title;
  final String? subtitle;
  final String? imageUrl;
}

extension on _HomeTabState {
  Future<void> _showPlantInfo() async {
    final plant = await _plantFuture;
    if (!mounted) return;
    if (plant == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('내 식물 정보가 없습니다.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plant.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (plant.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(plant.subtitle!, style: const TextStyle(color: Colors.white70)),
            ],
            const SizedBox(height: 12),
            if (plant.imageUrl != null && plant.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  plant.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            if (plant.imageUrl == null || plant.imageUrl!.isEmpty)
              const Text("이미지 없음", style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
