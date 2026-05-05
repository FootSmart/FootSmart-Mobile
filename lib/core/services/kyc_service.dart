import '../constants/api_constants.dart';
import 'api_service.dart';

class KycStartResponse {
  final String? clientSecret;
  final String? url;

  KycStartResponse({required this.clientSecret, required this.url});

  factory KycStartResponse.fromJson(Map<String, dynamic> json) {
    return KycStartResponse(
      clientSecret: json['clientSecret'] as String?,
      url: json['url'] as String?,
    );
  }
}

class KycStatusResponse {
  final String accountStatus;
  final String kycStatus;
  final String? provider;
  final String? verifiedAt;
  final String? rejectionReason;

  KycStatusResponse({
    required this.accountStatus,
    required this.kycStatus,
    this.provider,
    this.verifiedAt,
    this.rejectionReason,
  });

  factory KycStatusResponse.fromJson(Map<String, dynamic> json) {
    return KycStatusResponse(
      accountStatus: (json['accountStatus'] as String?) ?? 'inactive',
      kycStatus: (json['kycStatus'] as String?) ?? 'not_started',
      provider: json['provider'] as String?,
      verifiedAt: json['verifiedAt'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

class KycService {
  final ApiService _apiService;

  KycService(this._apiService);

  Future<KycStartResponse> startKyc() async {
    final response = await _apiService.post(ApiConstants.kycStart);
    return KycStartResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<KycStatusResponse> getStatus() async {
    final response = await _apiService.get(ApiConstants.kycStatus);
    return KycStatusResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<KycStatusResponse> skipKyc() async {
    final response = await _apiService.post(ApiConstants.kycSkip);
    return KycStatusResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
