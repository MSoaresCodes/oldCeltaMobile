// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CustomerSaleBlockadeModel {
  final int Code;
  final String PersonalizedCode;
  final String LegacyCode;
  final String Description;
  final bool AllowSaleRequest;
  final bool AllowSale;
  final bool AllowSaleWithPaymentFinalizationTypeCheckOrPortion;
  CustomerSaleBlockadeModel({
    required this.Code,
    required this.PersonalizedCode,
    required this.LegacyCode,
    required this.Description,
    required this.AllowSaleRequest,
    required this.AllowSale,
    required this.AllowSaleWithPaymentFinalizationTypeCheckOrPortion,
  });

  CustomerSaleBlockadeModel copyWith({
    int? Code,
    String? PersonalizedCode,
    String? LegacyCode,
    String? Description,
    bool? AllowSaleRequest,
    bool? AllowSale,
    bool? AllowSaleWithPaymentFinalizationTypeCheckOrPortion,
  }) {
    return CustomerSaleBlockadeModel(
      Code: Code ?? this.Code,
      PersonalizedCode: PersonalizedCode ?? this.PersonalizedCode,
      LegacyCode: LegacyCode ?? this.LegacyCode,
      Description: Description ?? this.Description,
      AllowSaleRequest: AllowSaleRequest ?? this.AllowSaleRequest,
      AllowSale: AllowSale ?? this.AllowSale,
      AllowSaleWithPaymentFinalizationTypeCheckOrPortion:
          AllowSaleWithPaymentFinalizationTypeCheckOrPortion ??
              this.AllowSaleWithPaymentFinalizationTypeCheckOrPortion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Code': Code,
      'PersonalizedCode': PersonalizedCode,
      'LegacyCode': LegacyCode,
      'Description': Description,
      'AllowSaleRequest': AllowSaleRequest,
      'AllowSale': AllowSale,
      'AllowSaleWithPaymentFinalizationTypeCheckOrPortion':
          AllowSaleWithPaymentFinalizationTypeCheckOrPortion,
    };
  }

  factory CustomerSaleBlockadeModel.fromMap(Map<String, dynamic> map) {
    return CustomerSaleBlockadeModel(
      Code: map['Code'] as int,
      PersonalizedCode: map['PersonalizedCode'] as String,
      LegacyCode: map['LegacyCode'] as String,
      Description: map['Description'] as String,
      AllowSaleRequest: map['AllowSaleRequest'] as bool,
      AllowSale: map['AllowSale'] as bool,
      AllowSaleWithPaymentFinalizationTypeCheckOrPortion:
          map['AllowSaleWithPaymentFinalizationTypeCheckOrPortion'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerSaleBlockadeModel.fromJson(String source) =>
      CustomerSaleBlockadeModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CustomerSaleBlockadeModel(Code: $Code, PersonalizedCode: $PersonalizedCode, LegacyCode: $LegacyCode, Description: $Description, AllowSaleRequest: $AllowSaleRequest, AllowSale: $AllowSale, AllowSaleWithPaymentFinalizationTypeCheckOrPortion: $AllowSaleWithPaymentFinalizationTypeCheckOrPortion)';
  }

  @override
  bool operator ==(covariant CustomerSaleBlockadeModel other) {
    if (identical(this, other)) return true;

    return other.Code == Code &&
        other.PersonalizedCode == PersonalizedCode &&
        other.LegacyCode == LegacyCode &&
        other.Description == Description &&
        other.AllowSaleRequest == AllowSaleRequest &&
        other.AllowSale == AllowSale &&
        other.AllowSaleWithPaymentFinalizationTypeCheckOrPortion ==
            AllowSaleWithPaymentFinalizationTypeCheckOrPortion;
  }

  @override
  int get hashCode {
    return Code.hashCode ^
        PersonalizedCode.hashCode ^
        LegacyCode.hashCode ^
        Description.hashCode ^
        AllowSaleRequest.hashCode ^
        AllowSale.hashCode ^
        AllowSaleWithPaymentFinalizationTypeCheckOrPortion.hashCode;
  }
}
