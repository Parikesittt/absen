class ClockInRequest {
  final String attendanceDate;
  final String checkIn;
  final double checkInLat;
  final double checkInLng;
  final String checkInAddress;
  final String status;

  ClockInRequest({
    required this.attendanceDate,
    required this.checkIn,
    required this.checkInAddress,
    required this.checkInLat,
    required this.checkInLng,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    "attendance_date": attendanceDate,
    "check_in": checkIn,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_address": checkInAddress,
    "status": status,
  };
}
