import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_management_app/services/app_state.dart';
import 'contract_detail_screen.dart';

class ContractHistoryScreen extends StatelessWidget {
  const ContractHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.contractHistory;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Lịch sử hợp đồng',
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: history.isEmpty
            ? const _EmptyHistory()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _ContractHistoryCard(data: history[index]),
              ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 80, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              'Chưa có lịch sử hợp đồng',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Các hợp đồng bạn từng thuê (đang hiệu lực, đã hết hạn hoặc đã ngưng) sẽ được lưu lại tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractHistoryCard extends StatelessWidget {
  const _ContractHistoryCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final contract = data['contract'] as Map<String, dynamic>;
    final room = data['room'] as Map<String, dynamic>?;

    final contractId = contract['id'] as int? ?? 0;
    final roomNumber = room?['room_number'] as String? ?? '—';
    final startDate = contract['start_date'] as String? ?? '';
    final endDate = contract['end_date'] as String? ?? '';
    final status = contract['status'] as String? ?? 'active';

    final badge = _statusBadge(status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContractPdfPreviewScreen(activeData: data),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Phòng $roomNumber',
                      style: const TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badge.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge.label,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 11,
                        color: badge.fg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Mã HĐ: #LUMIERE-HĐ-$contractId',
                style: const TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.black38,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$startDate  →  $endDate',
                    style: const TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.black38,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusBadge _statusBadge(String status) {
    switch (status) {
      case 'active':
        return const _StatusBadge(
          'Đang hiệu lực',
          Color(0xFFD1FAE5),
          Color(0xFF065F46),
        );
      case 'terminated':
        return const _StatusBadge(
          'Đã ngưng',
          Color(0xFFFEE2E2),
          Color(0xFFB91C1C),
        );
      case 'expired':
      default:
        return const _StatusBadge(
          'Đã hết hạn',
          Color(0xFFF1F5F9),
          Color(0xFF64748B),
        );
    }
  }
}

class _StatusBadge {
  const _StatusBadge(this.label, this.bg, this.fg);

  final String label;
  final Color bg;
  final Color fg;
}
