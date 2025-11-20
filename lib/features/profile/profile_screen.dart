import 'package:absen/core/config/app_router.dart';
import 'package:absen/core/services/auth_manager.dart';
import 'package:absen/core/services/http_service.dart'; // untuk exception types
import 'package:absen/core/services/prefs_service.dart';
import 'package:absen/data/models/profile_model.dart';
import 'package:absen/features/profile/data/profile_repository.dart';
import 'package:absen/shared/widgets/app_footer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileModel? profile;
  final repo = ProfileRepository();

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await repo.getProfile();
      if (!mounted) return;
      setState(() {
        profile = response;
      });
    } on UnauthorizedException catch (e) {
      // token invalid -> auto logout & redirect to login
      debugPrint('Unauthorized: $e');
      await AuthManager.handleUnauthorized(loginRoute: '/login');
      return;
    } on NetworkException catch (e) {
      debugPrint('NetworkException: ${e.message}');
      if (!mounted) return;
      setState(() {
        _error = e.message;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } on ApiException catch (e) {
      debugPrint('ApiException: ${e.message}');
      if (!mounted) return;
      setState(() {
        _error = e.message;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      debugPrint('Unknown error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan, coba lagi.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _isLoading
                        ? const SizedBox(
                            height: 160,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : (_error != null)
                        ? _buildErrorCard()
                        : _buildProfileCard(),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuList(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // logout manual: clear + go to login
                          PrefsService.clear();
                          context.router.replace(const LoginRoute());
                        },
                        child: const Text(
                          "Keluar",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [AppFooter()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error ?? 'Gagal memuat data',
            style: TextStyle(color: Colors.orange.shade900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: loadData, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  // ========================= HEADER =========================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            "Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ========================= PROFILE CARD =========================
  Widget _buildProfileCard() {
    final user = profile?.data;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(user?.profilePhotoUrl ?? user?.profilePhoto, user?.name),
          const SizedBox(width: 16),
          // Name & Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? "No Name",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "-",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                if (user?.batch != null || user?.training != null) ...[
                  Text(
                    'Batch: ${user?.batch?.batchKe ?? "-"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Training: ${user?.training?.title ?? "-"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? maybeUrl, String? name) {
    final initials = _initials(name);

    if (maybeUrl != null && maybeUrl.isNotEmpty) {
      // try use Image.network with errorBuilder
      return SizedBox(
        width: 68,
        height: 68,
        child: ClipOval(
          child: Image.network(
            maybeUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stack) {
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 34,
      backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.15),
      child: Text(
        initials,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  // ========================= MENU LIST =========================
  Widget _buildMenuList() {
    return Column(
      children: [
        _menuItem(Icons.person, "Edit Profile", () async {
          // navigate to edit page and refresh on return
          context.router.pushPath('/profile/edit').then((value) {
            // if returned true (updated) or null, in both case we refresh
            loadData();
          });
        }),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A60F0)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, color: Color(0xFF374151)),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
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
