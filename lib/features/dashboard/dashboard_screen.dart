import 'package:absen/core/config/app_router.dart';
import 'package:absen/core/constant/spacing.dart';
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/presence_history_model.dart'; // model Presence
import 'package:absen/data/models/presence_stats.dart';
import 'package:absen/data/models/user_model.dart';
import 'package:absen/features/dashboard/data/dashboard_repository.dart';
import 'package:absen/shared/widgets/real_time_clock.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Presence>> presenceList;
  final dashRepo = DashboardRepository();
  UserModel? _user;
  Presence? _todayPresence;
  PresenceStats? _stats;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    loadData();
    _loadCachedUser();
  }

  Future<void> _loadCachedUser() async {
    final u = await PrefsService.getUserModel();

    if (!mounted) {
      debugPrint('>>> not mounted, abort');
      return;
    }

    setState(() {
      _user = u;
    });
  }

  void loadData() {
    // Fetch history and today's presence

    // presenceList (history)
    presenceList = dashRepo.getPresenceHistory().then((resp) => resp.data);

    // today's presence (async, set state when done)
    dashRepo
        .getTodayPresence(DateTime.now())
        .then((p) {
          if (!mounted) return;
          setState(() {
            _todayPresence = p;
            print(_todayPresence);
          });
        })
        .catchError((e) {
          debugPrint('Error loading today presence: $e');
          // don't block UI; leave _todayPresence as null
        });

    setState(() {
      _loadingStats = true;
    });
    dashRepo
        .getPresenceStats()
        .then((s) {
          if (!mounted) return;
          setState(() {
            _stats = s;
            _loadingStats = false;
          });
        })
        .catchError((e) {
          debugPrint('Error loading stats: $e');
          if (!mounted) return;
          setState(() {
            _loadingStats = false;
          });
        });
  }

  String _formatDateReadable(DateTime? d) {
    if (d == null) return '-';
    try {
      return DateFormat('EEE, dd MMMM yyyy').format(d);
    } catch (_) {
      return d.toString();
    }
  }

  String _formatTimeShort(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final s = raw.trim();
    final regex = RegExp(r'(\d{2}:\d{2})');
    final m = regex.firstMatch(s);
    if (m != null) return m.group(1)!;
    if (s.length >= 5) return s.substring(0, 5);
    return s;
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

  @override
  Widget build(BuildContext context) {
    final bool hasCheckedIn =
        _todayPresence?.checkInTime != null &&
        _todayPresence!.checkInTime!.isNotEmpty;
    final bool hasCheckedOut =
        _todayPresence?.checkOutTime != null &&
        _todayPresence!.checkOutTime!.isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEDE38),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?.name ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      PrefsService.clear();
                      context.router.replace(const LoginRoute());
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // LIVE ATTENDANCE CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Live Attendance",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  // Realtime clock (big)
                  RealtimeClock(
                    showSeconds: false,
                    timeStyle: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066FF),
                    ),
                    dateStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --- HERE: show today's check-in / check-out times side by side ---
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Check In',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatTimeShort(_todayPresence?.checkInTime),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Check Out',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatTimeShort(_todayPresence?.checkOutTime),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // OFFICE HOURS
                  // Container(
                  //   padding: const EdgeInsets.symmetric(vertical: 12),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFF2F5FF),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: const Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [Text("08:00 AM"), Text("-"), Text("05:00 PM")],
                  //   ),
                  // ),
                  const SizedBox(height: 20),

                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasCheckedIn
                                ? Colors.grey
                                : const Color(0xFF0066FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: hasCheckedIn
                              ? null
                              : () async {
                                  await context.router.push(
                                    AttendanceRoute(type: 'check_in'),
                                  );
                                  loadData();
                                },
                          child: Text(
                            hasCheckedIn ? "Sudah CheckIn" : "Check In",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (!hasCheckedIn || hasCheckedOut)
                                ? Colors.grey
                                : const Color(0xFFFF5757),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: (!hasCheckedIn || hasCheckedOut)
                              ? null
                              : () async {
                                  await context.router.push(
                                    AttendanceRoute(type: 'check_out'),
                                  );
                                  loadData();
                                },
                          child: Text(
                            hasCheckedOut ? "Sudah CheckOut" : "Check Out",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: _loadingStats
                  ? const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _stats == null
                  ? const SizedBox(
                      height: 80,
                      child: Center(child: Text('Gagal memuat statistik')),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total Absen
                        _statItem(
                          title: 'Total Absen',
                          value: _stats!.totalAbsen.toString(),
                          color: const Color(0xFF4A60F0),
                        ),
                        // Total Masuk
                        _statItem(
                          title: 'Masuk',
                          value: _stats!.totalMasuk.toString(),
                          color: const Color(0xFF3B82F6),
                        ),
                        // Total Izin
                        _statItem(
                          title: 'Izin',
                          value: _stats!.totalIzin.toString(),
                          color: const Color(0xFFFACC15),
                        ),
                        // Sudah Absen Hari Ini
                        // _statItem(
                        //   title: 'Hari ini',
                        //   value: _stats!.sudahAbsenHariIni ? 'Ya' : 'Belum',
                        //   color: _stats!.sudahAbsenHariIni
                        //       ? const Color(0xFF10B981)
                        //       : const Color(0xFFEF4444),
                        // ),
                      ],
                    ),
            ),

            h(30),

            // ATTENDANCE HISTORY TITLE
            const Text(
              "Attendance History",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Presence>>(
              future: presenceList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Belum ada riwayat absensi'),
                    ),
                  );
                }

                final histories = snapshot.data!;
                final displayList = histories.take(5).toList();

                return Column(
                  children: displayList.map((history) {
                    final statusValue = history.status.value;
                    final alasanText = history.alasanIzin;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  history.attendanceDate != null
                                      ? _formatDateReadable(
                                          history.attendanceDate,
                                        )
                                      : '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _badgeBackground(statusValue),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  history.status.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _badgeTextColor(statusValue),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            history.timeRangeDisplay(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),

                          if (alasanText != null && alasanText.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      alasanText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade900,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = _user?.profilePhoto;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        foregroundImage: NetworkImage(url),
        child: ClipOval(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            errorBuilder: (context, error, stack) {
              return Center(
                child: Text(
                  _initials(_user?.name),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: Text(
          _initials(_user?.name),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    return name
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }
}

Widget _statItem({
  required String title,
  required String value,
  required Color color,
}) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.bar_chart, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    ),
  );
}
