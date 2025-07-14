import 'executions.dart';

class ReportScheduleExecutionsModel {
  final int ReportScheduleCode;
  final String LastExecutionStatus;
  final List<ExecutionsModel> Executions;

  ReportScheduleExecutionsModel({
    required this.ReportScheduleCode,
    required this.LastExecutionStatus,
    required this.Executions,
  });

  factory ReportScheduleExecutionsModel.fromJson(Map<String, dynamic> json) {
    return ReportScheduleExecutionsModel(
      ReportScheduleCode: json['ReportScheduleCode'] as int,
      LastExecutionStatus: json['LastExecutionStatus'] as String,
      Executions: (json['Executions'] as List)
          .map((e) => ExecutionsModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "ReportScheduleCode": ReportScheduleCode,
        "LastExecutionStatus": LastExecutionStatus,
        "Executions": Executions.map((e) => e.toJson()).toList(),
      };
}
