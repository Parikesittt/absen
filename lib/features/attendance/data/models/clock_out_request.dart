class ClockOutRequest {
  final String attendanceDate;
  final String checkOut;
  final double checkOutLat;
  final double checkOutLng;
  final String checkOutLocation;
  final String checkOutAddress;

  ClockOutRequest({
    required this.attendanceDate,
    required this.checkOut,
    required this.checkOutAddress,
    required this.checkOutLat,
    required this.checkOutLng,
    required this.checkOutLocation
  });

  Map<String, dynamic> toJson() => {
    "attendance_date": attendanceDate,
    "check_out": checkOut,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
    "check_out_location": checkOutLocation,
    "check_out_address": checkOutAddress,
  };
}
