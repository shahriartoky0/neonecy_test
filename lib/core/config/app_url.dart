class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://qemu-api.billal.space';
  static const String getAirlines = '$baseUrl/airlines';

  static String airlineAssessment = '$baseUrl/assessments/';

  static const String postSubmission = '$baseUrl/submissions';
  static const String makePayment = '$baseUrl/payment/create-payment';
  static const String policy = '$baseUrl/policy';

  static String topAirlinesByPassRate({String? year}) {
    return '$baseUrl/statistics/top-airlines-pass-rate?date=$year';
  }

  static String deleteSubmission({String? submissionId}) {
    return '$baseUrl/submissions/$submissionId';
  }

  static String topAirlinesBySubmission({String? year}) {
    return '$baseUrl/statistics/top-airlines-submission?date=$year';
  }

  static String getMySubmission({String? deviceId}) {
    deviceId ??= '';
    return '$baseUrl/submissions/$deviceId';
  }

  static String statSearchByAirlineAndYear({required String airlineName, required String year}) =>
      '$baseUrl/statistics/airlines-overview?name=$airlineName&date=$year';
}
