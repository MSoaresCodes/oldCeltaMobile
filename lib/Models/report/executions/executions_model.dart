import 'executions.dart';

class ExecutionsModel {
  final String ExecutionDate;
  final List<AttachmentsModel> Attachments;

  ExecutionsModel({
    required this.ExecutionDate,
    required this.Attachments,
  });

  factory ExecutionsModel.fromJson(Map<String, dynamic> json) {
    return ExecutionsModel(
      ExecutionDate: json['ExecutionDate'] as String,
      Attachments: (json['Attachments'] as List)
          .map((e) => AttachmentsModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "ExecutionDate": ExecutionDate,
        "Attachments": Attachments.map((e) => e.toJson()).toList(),
      };
}
