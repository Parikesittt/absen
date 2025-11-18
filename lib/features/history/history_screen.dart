import 'package:absen/core/constant/spacing.dart';
import 'package:absen/core/services/auth_manager.dart';
import 'package:absen/core/services/http_service.dart';
import 'package:absen/data/models/presence_history_model.dart';
import 'package:absen/features/dashboard/data/dashboard_repository.dart';
import 'package:absen/features/history/data/history_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final repo = DashboardRepository();
  final historyRepo = HistoryRepository();
  bool _loading = true;
  String? _error;
  List<Presence> _histories = [];

  // track deleting state per id
  final Map<int, bool> _deleting = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resp = await repo.getPresenceHistory();
      setState(() {
        _histories = resp.data;
      });
    } on UnauthorizedException {
      await AuthManager.handleUnauthorized(loginRoute: '/login');
      return;
    } on NetworkException catch (e) {
      setState(() => _error = e.message);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      debugPrint('History load error: $e');
      setState(() => _error = 'Terjadi kesalahan saat memuat riwayat');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDateReadable(DateTime? d) {
    if (d == null) return '-';
    try {
      return DateFormat('EEE, dd MMM yyyy').format(d);
    } catch (_) {
      return d.toIso8601String();
    }
  }

  Future<void> _confirmAndDelete(int id) async {
    final should = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Absen'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data absen ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (should != true) return;

    await _deleteHistory(id);
  }

  Future<void> _deleteHistory(int id) async {
    // set deleting flag
    setState(() {
      _deleting[id] = true;
    });

    try {
      await historyRepo.deleteHistory(id: id);
      Fluttertoast.showToast(msg: 'Berhasil menghapus absen');
      await _loadHistory();
    } on UnauthorizedException {
      await AuthManager.handleUnauthorized(loginRoute: '/login');
    } on ApiException catch (e) {
      final msg = e.message ?? 'Gagal menghapus absen';
      Fluttertoast.showToast(msg: msg);
    } catch (e) {
      debugPrint('Delete history error: $e');
      Fluttertoast.showToast(msg: 'Terjadi kesalahan saat menghapus');
    } finally {
      if (mounted) {
        setState(() {
          _deleting.remove(id);
        });
      }
    }
  }

  Color _badgeBackground(String statusValue) {
    switch (statusValue) {
      case 'masuk':
        return Colors.green.shade50;
      case 'izin':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _badgeTextColor(String statusValue) {
    switch (statusValue) {
      case 'masuk':
        return Colors.green.shade700;
      case 'izin':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal membuka maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHistory,
          child: _loading
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 20),
                    Center(child: CircularProgressIndicator()),
                    SizedBox(height: 20),
                  ],
                )
              : (_error != null)
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  children: [
                    _buildHeader(context),
                    h(20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _error!,
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadHistory,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: _histories.length + 1, // +1 untuk header
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildHeader(context);
                    final history = _histories[index - 1];
                    return _buildHistoryItem(history);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, left: 0, right: 0, bottom: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A60F0), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: const [
              Text(
                "History Absensi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Presence history) {
    final statusValue = history.status.value; // 'masuk' / 'izin' / 'unknown'
    final statusLabel = history.status.label; // display label
    final deleting = _deleting[history.id] == true;

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // date + status + menu
          Row(
            children: [
              Expanded(
                child: Text(
                  history.attendanceDate != null
                      ? _formatDateReadable(history.attendanceDate)
                      : '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeBackground(statusValue),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: _badgeTextColor(statusValue),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // popup menu: delete / view map / copy
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmAndDelete(history.id);
                  } else if (value == 'open_checkin' &&
                      history.checkInLat != null &&
                      history.checkInLng != null) {
                    _openMaps(history.checkInLat!, history.checkInLng!);
                  } else if (value == 'open_checkout' &&
                      history.checkOutLat != null &&
                      history.checkOutLng != null) {
                    _openMaps(history.checkOutLat!, history.checkOutLng!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'open_checkin',
                    enabled:
                        history.checkInLat != null &&
                        history.checkInLng != null,
                    child: const Text('Buka lokasi Check-in'),
                  ),
                  PopupMenuItem(
                    value: 'open_checkout',
                    enabled:
                        history.checkOutLat != null &&
                        history.checkOutLng != null,
                    child: const Text('Buka lokasi Check-out'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: deleting
                        ? Row(
                            children: const [
                              SizedBox(width: 6),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Menghapus...'),
                            ],
                          )
                        : const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // time range
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Color(0xFF374151)),
              const SizedBox(width: 8),
              Text(
                history.timeRangeDisplay(),
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // check-in location
          if ((history.checkInAddress != null &&
                  history.checkInAddress!.isNotEmpty) ||
              history.checkInLat != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF0EA5E9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    history.checkInAddress ??
                        history.checkInLatLng?.toString() ??
                        '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                if (history.checkInLat != null && history.checkInLng != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    splashRadius: 20,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        _openMaps(history.checkInLat!, history.checkInLng!),
                    icon: const Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: Color(0xFF4A60F0),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // check-out location
          if ((history.checkOutAddress != null &&
                  history.checkOutAddress!.isNotEmpty) ||
              history.checkOutLat != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Color(0xFFFF5757),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    history.checkOutAddress ??
                        history.checkOutLatLng?.toString() ??
                        '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                if (history.checkOutLat != null && history.checkOutLng != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    splashRadius: 20,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        _openMaps(history.checkOutLat!, history.checkOutLng!),
                    icon: const Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: Color(0xFF4A60F0),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
