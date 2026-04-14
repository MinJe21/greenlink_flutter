import 'package:flutter/material.dart';
import 'package:greenlink_front/data/plant_service.dart';
import 'package:greenlink_front/screen/home/widgets/common_glass.dart';

class EncyclopediaTab extends StatefulWidget {
  const EncyclopediaTab({super.key});

  @override
  State<EncyclopediaTab> createState() => _EncyclopediaTabState();
}

class _EncyclopediaTabState extends State<EncyclopediaTab> {
  final PlantService _service = PlantService();
  late Future<List<PlantSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainText = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? Colors.white70 : Colors.black54;
    return SingleChildScrollView(
      key: const ValueKey('encyclopedia_tab'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("식물도감 페이지", style: TextStyle(color: subText, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          FutureBuilder<List<PlantSummary>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text("불러오기 실패: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)),
                );
              }
              final plants = snapshot.data ?? [];
              if (plants.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text("식물 데이터가 없습니다.", style: TextStyle(color: subText)),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: plants.length,
                itemBuilder: (_, idx) {
                  final plant = plants[idx];
                  return GestureDetector(
                    onTap: plant.plantId == null ? null : () => _showDetail(context, plant.plantId!),
                    child: glassCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (plant.imageUrl != null && plant.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                plant.imageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.local_florist, color: Colors.lightGreenAccent, size: 32),
                              ),
                            )
                          else
                            const Icon(Icons.local_florist, color: Colors.lightGreenAccent, size: 32),
                          const SizedBox(height: 8),
                          Text(plant.name, style: TextStyle(color: mainText, fontWeight: FontWeight.w700)),
                          if (plant.category != null)
                            Text(plant.category!, style: TextStyle(color: subText, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDetail(BuildContext context, int plantId) async {
    try {
      final detail = await _service.detail(plantId);
      if (!mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final mainText = isDark ? Colors.white : const Color(0xFF1A1A1A);
      final subText = isDark ? Colors.white70 : Colors.black54;
      showModalBottomSheet(
        context: context,
        backgroundColor: isDark ? Colors.black.withOpacity(0.9) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(detail.name, style: TextStyle(color: mainText, fontSize: 20, fontWeight: FontWeight.w800)),
                    IconButton(
                      icon: Icon(Icons.close, color: subText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (detail.imageUrl != null && detail.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      detail.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 12),
                if (detail.description != null)
                  Text(detail.description!, style: TextStyle(color: subText)),
                const SizedBox(height: 12),
                _kv(context, "카테고리", detail.category),
                _kv(context, "난이도", detail.difficulty),
                _kv(context, "성장기간(일)", detail.growthPeriodDays?.toString()),
                _kv(context, "광량 선호", detail.lightPref),
                _kv(context, "일일 물주기(ml)", detail.waterPreMlPerDay?.toString()),
                _kv(context, "해금 조건", detail.unlockCondition),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상세 불러오기 실패: $e')));
    }
  }

  Widget _kv(BuildContext context, String label, String? value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainText = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subText = isDark ? Colors.white70 : Colors.black54;
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(color: subText, fontWeight: FontWeight.w600)),
          Flexible(child: Text(value, style: TextStyle(color: mainText))),
        ],
      ),
    );
  }
}
