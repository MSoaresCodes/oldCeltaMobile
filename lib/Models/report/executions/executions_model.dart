import 'executions.dart';

class ExecutionsModel {
  final DateTime? ExecutionDate;
  final List<AttachmentsModel> Attachments;
  final bool ContainsData;

  ExecutionsModel({
    required this.ExecutionDate,
    required this.Attachments,
    required this.ContainsData,
  });

  factory ExecutionsModel.fromJson(Map<String, dynamic> json) {
    return ExecutionsModel(
      ExecutionDate: json['ExecutionDate'] == null
          ? null
          : DateTime.parse(json['ExecutionDate']),
      ContainsData: json['ContainsData'] == true,
      Attachments: json['Attachments'] == null
          ? []
          : (json['Attachments'] as List)
              .map((e) => AttachmentsModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "ExecutionDate": ExecutionDate,
        "Attachments": Attachments.map((e) => e.toJson()).toList(),
      };
}
