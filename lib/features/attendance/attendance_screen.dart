// File: features/attendance/presentation/attendance_screen.dart

import 'dart:async';
import 'package:absen/features/attendance/data/attendance_repository.dart';
import 'package:absen/features/attendance/data/models/attendance_request.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

@RoutePage()
class AttendanceScreen extends StatefulWidget {
  final String type; // "check_in" atau "check_out"
  
  const AttendanceScreen({
    super.key,
    @PathParam('type') required this.type,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  GoogleMapController? _googleMapController;
  LatLng _currentPosition = const LatLng(-6.2000, 106.816666);
  String _currentAddress = "Mencari lokasi...";
  
  Marker? _marker;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final attendanceRepo = AttendanceRepository();

  bool get isCheckIn => widget.type == "check_in";
  
  Color get primaryColor => isCheckIn 
      ? const Color(0xFF4A60F0)
      : const Color(0xFFFF5757);
  
  String get title => isCheckIn ? "Check In" : "Check Out";
  String get buttonText => isCheckIn ? "Check In" : "Check Out";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = "Layanan lokasi tidak aktif";
          _isLoading = false;
        });
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = "Izin lokasi ditolak";
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = "Izin lokasi ditolak permanen";
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        
        _marker = Marker(
          markerId: const MarkerId("lokasi_saya"),
          position: _currentPosition,
          infoWindow: InfoWindow(
            title: "Lokasi Anda",
            snippet: "${place.street}, ${place.locality}",
          ),
        );

        _currentAddress = [
          place.street,
          place.locality,
          place.subAdministrativeArea,
          place.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        _isLoading = false;
      });

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 16,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _currentAddress = "Gagal mendapatkan lokasi: $e";
        _isLoading = false;
      });
      print("Error getting location: $e");
    }
  }

  // Format waktu ke HH:mm
  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Method untuk submit attendance
  Future<void> _submitAttendance() async {
    if (_isLoading || _isSubmitting) return;

    try {
      setState(() => _isSubmitting = true);

      final now = DateTime.now();
      final currentTime = _formatTime(now);

      AttendanceRequest request;

      if (isCheckIn) {
        // Buat request check in
        request = AttendanceRequest.checkIn(
          time: currentTime,
          latitude: _currentPosition.latitude,
          longitude: _currentPosition.longitude,
          address: _currentAddress,
        );

        print("📍 CHECK IN REQUEST: ${request.toJson()}");

        // Call API check in
        final response = await attendanceRepo.checkIn(request: request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? "Check In berhasil!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Buat request check out
        request = AttendanceRequest.checkOut(
          time: currentTime,
          latitude: _currentPosition.latitude,
          longitude: _currentPosition.longitude,
          address: _currentAddress,
        );

        print("📍 CHECK OUT REQUEST: ${request.toJson()}");

        // Call API check out
        final response = await attendanceRepo.checkOut(request: request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? "Check Out berhasil!"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Kembali ke dashboard setelah delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.router.pop();
      }

    } catch (e) {
      print("❌ ERROR SUBMIT ATTENDANCE: $e");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===================== MAP CARD =====================
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          GoogleMap(
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition,
                              zoom: 16,
                            ),
                            markers: _marker != null ? {_marker!} : {},
                            onMapCreated: (GoogleMapController controller) {
                              _googleMapController = controller;
                              
                              if (!_isLoading) {
                                controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: _currentPosition,
                                      zoom: 16,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          
                          if (_isLoading)
                            Container(
                              color: Colors.white.withOpacity(0.8),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ===================== LOCATION INFO =====================
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: _isLoading ? Colors.grey : primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Your Location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: (_isLoading || _isSubmitting) ? null : () {
                                setState(() => _isLoading = true);
                                _getCurrentLocation();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Text(
                          _currentAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: _isLoading ? Colors.grey : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 3),
                        Text(
                          _isLoading 
                              ? "Mencari koordinat..."
                              : "${_currentPosition.latitude.toStringAsFixed(6)}, ${_currentPosition.longitude.toStringAsFixed(6)}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ===================== TIME BOX =====================
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCheckIn ? Icons.login : Icons.logout,
                                color: primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _currentTime(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ===================== BUTTON =====================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: (_isLoading || _isSubmitting) 
                                ? null 
                                : _submitAttendance,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    buttonText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===================== WARNING BOX =====================
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Pastikan lokasi Anda aktif untuk melakukan absensi.\nAplikasi memerlukan akses lokasi untuk memverifikasi kehadiran Anda.",
                      style: TextStyle(fontSize: 13, color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    return DateFormat('HH:mm').format(now);
  }
}