// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../models.dart';

class CustomerModel {
  final int? Code; // 2697,
  final String? PersonalizedCode; // "999",
  final String? Name; // "JavaScript Object Notation - JSON",
  final String? ReducedName; // "JSON Obj",
  final String? CpfCnpjNumber; // "23696428078",
  final String? RegistrationNumber; // "258842246",
  final String? DateOfBirth; // "2001-01-01T00:00:00",
  final String? SexType; // "F",
  final String? PersonType; // "F",
  final List<String>? Emails;
  final List<CustomerTelephoneModel>? Telephones;
  final List<CustomerCovenantModel>? CustomerCovenants;
  final List<AddressModel>? Addresses;
  bool selected;
  final String? password;
  final CustomerSaleBlockadeInstructionModel? saleBlockadeInstructionModel;
  final CustomerSaleBlockadeModel? saleBlockadeModel;
// "Covenants": null

  CustomerModel({
    required this.Name,
    required this.Code,
    required this.PersonalizedCode,
    required this.ReducedName,
    required this.CpfCnpjNumber,
    required this.RegistrationNumber,
    required this.DateOfBirth,
    required this.SexType,
    required this.PersonType,
    required this.Emails,
    required this.Telephones,
    required this.Addresses,
    required this.selected,
    required this.password,
    required this.CustomerCovenants,
    required this.saleBlockadeInstructionModel,
    required this.saleBlockadeModel,
  });

  factory CustomerModel.fromJson(Map json) => CustomerModel(
        Name: json["Name"],
        Code: json["Code"],
        PersonalizedCode: json["PersonalizedCode"],
        ReducedName: json["ReducedName"],
        CpfCnpjNumber: json["CpfCnpjNumber"],
        RegistrationNumber: json["RegistrationNumber"],
        DateOfBirth: json["DateOfBirth"],
        SexType: json["SexType"],
        PersonType: json["PersonType"],
        Emails: json["Emails"] == null || json["Emails"]?.isEmpty == true
            ? null
            : (json["Emails"] as List).map((e) => e.toString()).toList(),
        Telephones:
            json["Telephones"] == null || json["Telephones"]?.isEmpty == true
                ? null
                : (json["Telephones"] as List)
                    .map((e) => CustomerTelephoneModel.fromJson(e))
                    .toList(),
        Addresses:
            json["Addresses"] == null || json["Addresses"]?.isEmpty == true
                ? null
                : (json["Addresses"] as List)
                    .map((e) => AddressModel.fromJson(e))
                    .toList(),
        selected: json["selected"] ?? false,
        password: json["password"],
        CustomerCovenants: json["CustomerCovenants"] == null
            ? null
            : (json["CustomerCovenants"] as List)
                .map((e) => CustomerCovenantModel.fromJson(e))
                .cast<CustomerCovenantModel>()
                .toList(),
        saleBlockadeInstructionModel: json["SaleBlockadeInstruction"] == null
            ? null
            : CustomerSaleBlockadeInstructionModel.fromMap(
                json["SaleBlockadeInstruction"]),
        saleBlockadeModel: json["SaleBlockade"] == null
            ? null
            : CustomerSaleBlockadeModel.fromMap(json["SaleBlockade"]),
      );

  Map<String, dynamic> toJson() => {
        "Name": Name,
        "Code": Code,
        "PersonalizedCode": PersonalizedCode,
        "ReducedName": ReducedName,
        "CpfCnpjNumber": CpfCnpjNumber,
        "RegistrationNumber": RegistrationNumber,
        "DateOfBirth": DateOfBirth,
        "SexType": SexType,
        "PersonType": PersonType,
        "Emails": Emails?.map((e) => e).toList(),
        "Telephones": Telephones?.map((e) => e.toJson()).toList(),
        "Addresses": Addresses?.map((e) => e.toJson()).toList(),
        "selected": selected,
        "password": password,
        "CustomerCovenants": CustomerCovenants?.map((e) => e.toJson()).toList(),
        "SaleBlockadeInstruction": saleBlockadeInstructionModel?.toJson(),
        "SaleBlockade": saleBlockadeModel?.toJson(),
      };

  CustomerModel copyWith({
    int? Code,
    String? PersonalizedCode,
    String? Name,
    String? ReducedName,
    String? CpfCnpjNumber,
    String? RegistrationNumber,
    String? DateOfBirth,
    String? SexType,
    String? PersonType,
    List<String>? Emails,
    List<CustomerTelephoneModel>? Telephones,
    List<CustomerCovenantModel>? CustomerCovenants,
    List<AddressModel>? Addresses,
    bool? selected,
    String? password,
    CustomerSaleBlockadeInstructionModel? saleBlockadeInstructionModel,
    CustomerSaleBlockadeModel? saleBlockadeModel,
  }) {
    return CustomerModel(
      Code: Code ?? this.Code,
      PersonalizedCode: PersonalizedCode ?? this.PersonalizedCode,
      Name: Name ?? this.Name,
      ReducedName: ReducedName ?? this.ReducedName,
      CpfCnpjNumber: CpfCnpjNumber ?? this.CpfCnpjNumber,
      RegistrationNumber: RegistrationNumber ?? this.RegistrationNumber,
      DateOfBirth: DateOfBirth ?? this.DateOfBirth,
      SexType: SexType ?? this.SexType,
      PersonType: PersonType ?? this.PersonType,
      Emails: Emails ?? this.Emails,
      Telephones: Telephones ?? this.Telephones,
      CustomerCovenants: CustomerCovenants ?? this.CustomerCovenants,
      Addresses: Addresses ?? this.Addresses,
      selected: selected ?? this.selected,
      password: password ?? this.password,
      saleBlockadeInstructionModel:
          saleBlockadeInstructionModel ?? this.saleBlockadeInstructionModel,
      saleBlockadeModel: saleBlockadeModel ?? this.saleBlockadeModel,
    );
  }
}
