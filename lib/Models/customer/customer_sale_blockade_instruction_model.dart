import 'dart:convert';

class CustomerSaleBlockadeInstructionModel {
  final int Code;
  final String PersonalizedCode;
  final String LegacyCode;
  final String Description;
  CustomerSaleBlockadeInstructionModel({
    required this.Code,
    required this.PersonalizedCode,
    required this.LegacyCode,
    required this.Description,
  });

  CustomerSaleBlockadeInstructionModel copyWith({
    int? Code,
    String? PersonalizedCode,
    String? LegacyCode,
    String? Description,
  }) {
    return CustomerSaleBlockadeInstructionModel(
      Code: Code ?? this.Code,
      PersonalizedCode: PersonalizedCode ?? this.PersonalizedCode,
      LegacyCode: LegacyCode ?? this.LegacyCode,
      Description: Description ?? this.Description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Code': Code,
      'PersonalizedCode': PersonalizedCode,
      'LegacyCode': LegacyCode,
      'Description': Description,
    };
  }

  factory CustomerSaleBlockadeInstructionModel.fromMap(
      Map<String, dynamic> map) {
    return CustomerSaleBlockadeInstructionModel(
      Code: map['Code'] as int,
      PersonalizedCode: map['PersonalizedCode'] as String,
      LegacyCode: map['LegacyCode'] as String,
      Description: map['Description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerSaleBlockadeInstructionModel.fromJson(String source) =>
      CustomerSaleBlockadeInstructionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CustomerSaleBlockadeInstructionModel(Code: $Code, PersonalizedCode: $PersonalizedCode, LegacyCode: $LegacyCode, Description: $Description)';
  }

  @override
  bool operator ==(covariant CustomerSaleBlockadeInstructionModel other) {
    if (identical(this, other)) return true;

    return other.Code == Code &&
        other.PersonalizedCode == PersonalizedCode &&
        other.LegacyCode == LegacyCode &&
        other.Description == Description;
  }

  @override
  int get hashCode {
    return Code.hashCode ^
        PersonalizedCode.hashCode ^
        LegacyCode.hashCode ^
        Description.hashCode;
  }
}
