import 'dart:convert';
import 'dart:typed_data';

class AttachmentsModel {
  final String FileExtension;
  final Uint8List AttachmentBase64;

  AttachmentsModel({
    required this.FileExtension,
    required this.AttachmentBase64,
  });

  factory AttachmentsModel.fromJson(Map<String, dynamic> json) {
    return AttachmentsModel(
      FileExtension: json['FileExtension'] as String,
      AttachmentBase64: base64Decode(json['AttachmentBase64']),
    );
  }

  Map<String, dynamic> toJson() => {
        "FileExtension": FileExtension,
        "AttachmentBase64": AttachmentBase64,
      };
}
