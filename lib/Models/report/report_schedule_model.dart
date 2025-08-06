class ReportScheduleModel {
  final int? Code;
  final String? Name;
  final String? Type;
  final int? CategoryCode;
  final String? CategoryName;
  final int? SubCategoryCode;
  final String? SubCategoryName;
  final int? ReportCode;
  final String? ReportName;
  final int? ReportModelCode;
  final String? ReportModelName;
  final DateTime? LastExecutionDate;
  final DateTime? LastExecutionStartDateTime;
  final bool? IsExecuting;
  final bool? ExecutionStatus;
  final bool? LastExecutionContainsData;

  ReportScheduleModel({
    required this.Code,
    required this.Name,
    required this.Type,
    required this.CategoryCode,
    required this.CategoryName,
    required this.SubCategoryCode,
    required this.SubCategoryName,
    required this.ReportCode,
    required this.ReportName,
    required this.ReportModelCode,
    required this.ReportModelName,
    required this.LastExecutionDate,
    required this.LastExecutionStartDateTime,
    required this.IsExecuting,
    required this.ExecutionStatus,
    required this.LastExecutionContainsData,
  });

  factory ReportScheduleModel.fromJson(Map<String, dynamic> json) {
    return ReportScheduleModel(
      Code: json["Code"],
      Name: json["Name"],
      Type: json["Type"],
      CategoryCode: json["CategoryCode"],
      CategoryName: json["CategoryName"],
      SubCategoryCode: json["SubCategoryCode"],
      SubCategoryName: json["SubCategoryName"],
      ReportCode: json["ReportCode"],
      ReportName: json["ReportName"],
      ReportModelCode: json["ReportModelCode"],
      ReportModelName: json["ReportModelName"],
      LastExecutionDate: json["LastExecutionDate"] != null
          ? DateTime.parse(json["LastExecutionDate"])
          : null,
      LastExecutionStartDateTime: json["LastExecutionStartDateTime"] != null
          ? DateTime.parse(json["LastExecutionStartDateTime"])
          : null,
      IsExecuting: json["IsExecuting"],
      ExecutionStatus: json["ExecutionStatus"],
      LastExecutionContainsData: json["LastExecutionContainsData"],
    );
  }

  Map<String, dynamic> toJson() => {
        "Code": Code,
        "Name": Name,
        "Type": Type,
        "CategoryCode": CategoryCode,
        "CategoryName": CategoryName,
        "SubCategoryCode": SubCategoryCode,
        "SubCategoryName": SubCategoryName,
        "ReportCode": ReportCode,
        "ReportName": ReportName,
        "ReportModelCode": ReportModelCode,
        "ReportModelName": ReportModelName,
        "LastExecutionDate": LastExecutionDate,
        "LastExecutionStartDateTime": LastExecutionStartDateTime,
        "IsExecuting": IsExecuting,
        "ExecutionStatus": ExecutionStatus,
        "LastExecutionContainsData": LastExecutionContainsData,
      };
}
