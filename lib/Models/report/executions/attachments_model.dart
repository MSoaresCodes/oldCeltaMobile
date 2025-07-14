class AttachmentsModel {
  final String FileExtension;
  final String AttachmentBase64;

  AttachmentsModel({
    required this.FileExtension,
    required this.AttachmentBase64,
  });

  factory AttachmentsModel.fromJson(Map<String, dynamic> json) {
    return AttachmentsModel(
      FileExtension: json['FileExtension'] as String,
      AttachmentBase64: json['AttachmentBase64'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        "FileExtension": FileExtension,
        "AttachmentBase64": AttachmentBase64,
      };
}
