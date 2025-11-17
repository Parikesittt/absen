// File: features/attendance/data/models/attendance_request.dart

class AttendanceRequest {
  final String attendanceDate;
  final String? checkIn;
  final double? checkInLat;
  final double? checkInLng;
  final String? checkInAddress;
  final String? checkOut;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkOutAddress;
  final String status;
  final String? alasanIzin;

  AttendanceRequest({
    required this.attendanceDate,
    this.checkIn,
    this.checkInLat,
    this.checkInLng,
    this.checkInAddress,
    this.checkOut,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutAddress,
    required this.status,
    this.alasanIzin,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'attendance_date': attendanceDate,
      'status': status,
    };

    // Check In fields
    if (checkIn != null) data['check_in'] = checkIn;
    if (checkInLat != null) data['check_in_lat'] = checkInLat;
    if (checkInLng != null) data['check_in_lng'] = checkInLng;
    if (checkInAddress != null) data['check_in_address'] = checkInAddress;

    // Check Out fields
    if (checkOut != null) data['check_out'] = checkOut;
    if (checkOutLat != null) data['check_out_lat'] = checkOutLat;
    if (checkOutLng != null) data['check_out_lng'] = checkOutLng;
    if (checkOutAddress != null) data['check_out_address'] = checkOutAddress;

    // Alasan izin (optional)
    if (alasanIzin != null) data['alasan_izin'] = alasanIzin;

    return data;
  }

  // Factory untuk Check In
  factory AttendanceRequest.checkIn({
    required String time,
    required double latitude,
    required double longitude,
    required String address,
  }) {
    return AttendanceRequest(
      attendanceDate: DateTime.now().toIso8601String().split('T')[0],
      checkIn: time,
      checkInLat: latitude,
      checkInLng: longitude,
      checkInAddress: address,
      status: 'masuk',
    );
  }

  // Factory untuk Check Out
  factory AttendanceRequest.checkOut({
    required String time,
    required double latitude,
    required double longitude,
    required String address,
  }) {
    return AttendanceRequest(
      attendanceDate: DateTime.now().toIso8601String().split('T')[0],
      checkOut: time,
      checkOutLat: latitude,
      checkOutLng: longitude,
      checkOutAddress: address,
      status: 'masuk',
    );
  }

  // Factory untuk Izin
  factory AttendanceRequest.izin({
    required String alasan,
  }) {
    return AttendanceRequest(
      attendanceDate: DateTime.now().toIso8601String().split('T')[0],
      status: 'izin',
      alasanIzin: alasan,
    );
  }
}