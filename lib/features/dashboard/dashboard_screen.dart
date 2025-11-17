import 'package:absen/core/config/app_router.dart';
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/presence_history_model.dart'; // model baru (Presence / PresenceHistoryModel)
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
  // bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    loadData();
    _loadCachedUser();
  }

  Future<void> _loadCachedUser() async {
    debugPrint('>>> _loadCachedUser START ${DateTime.now()}');
    final u = await PrefsService.getUserModel();
    debugPrint('>>> PrefsService.getUserModel returned: ${u?.toJson()}');

    if (!mounted) {
      debugPrint('>>> not mounted, abort');
      return;
    }

    setState(() {
      _user = u;
    });
    debugPrint('>>> _user set in state: ${_user?.profilePhoto}');
  }

  void loadData() {
    // asumsi: getPresenceHistory mengembalikan Future<PresenceHistoryModel>
    debugPrint('>>> before getPresenceHistory - user: ${_user?.profilePhoto}');
    presenceList = dashRepo.getPresenceHistory().then((resp) => resp.data);
    // kita tidak panggil setState() di sini karena FutureBuilder akan rebuild ketika future selesai
    debugPrint('>>> after getPresenceHistory - user: ${_user?.profilePhoto}');
  }

  // jika masih mau format dengan intl
  String _formatDateReadable(DateTime? d) {
    if (d == null) return '-';
    try {
      return DateFormat('EEE, dd MMMM yyyy').format(d);
    } catch (_) {
      return d.toString();
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

  @override
  Widget build(BuildContext context) {
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
                  // CircleAvatar(
                  //   radius: 30,
                  //   backgroundColor: Colors.grey[200],
                  //   backgroundImage: _user?.profilePhotoUrl != null
                  //       ? NetworkImage(_user!.profilePhotoUrl!)
                  //       : null,
                  //   child: _user?.profilePhotoUrl == null
                  //       ? Text(
                  //           _user?.name
                  //                   .split(' ')
                  //                   .map((s) => s.isNotEmpty ? s[0] : '')
                  //                   .take(2)
                  //                   .join() ??
                  //               'U',
                  //         )
                  //       : null,
                  // ),
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
                      // logout: clear prefs and go to login (replace so user can't back)
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
                children: [
                  const Text(
                    "Live Attendance",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  // const Text(
                  //   "09:41 AM",
                  //   style: TextStyle(
                  //     fontSize: 42,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color(0xFF0066FF),
                  //   ),
                  // ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  //   style: const TextStyle(fontSize: 12, color: Colors.black54),
                  // ),
                  RealtimeClock(
                    showSeconds: false, // true kalau mau detik juga
                    // optionally override styles to match your theme
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

                  const SizedBox(height: 20),

                  // OFFICE HOURS
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [Text("08:00 AM"), Text("-"), Text("05:00 PM")],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // navigate to attendance screen for check_in; after pop refresh data
                            context.router
                                .push(AttendanceRoute(type: 'check_in'))
                                .then((_) => loadData());
                          },
                          child: const Text("Check In"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5757),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.router
                                .push(AttendanceRoute(type: 'check_out'))
                                .then((_) => loadData());
                          },
                          child: const Text("Check Out"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

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

                // Ambil max 5 data terakhir
                final displayList = histories.take(5).toList();

                return Column(
                  children: displayList.map((history) {
                    final statusValue =
                        history.status.value; // 'masuk' / 'izin' / 'unknown'
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
                          // Row: date + status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  // gunakan helper formattedDate pada model
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
                              // Status badge
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

                          // Time range (check-in - check-out) menggunakan model helper
                          Text(
                            history.timeRangeDisplay(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),

                          // Tampilkan alasan izin jika ada
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
        // foregroundImage doesn't provide errorBuilder - use Image.network wrapped
        child: ClipOval(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            errorBuilder: (context, error, stack) {
              // show initials on error
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
