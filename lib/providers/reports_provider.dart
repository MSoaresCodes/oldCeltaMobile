import 'package:flutter/material.dart';

import '../Models/models.dart';

class ReportsProvider with ChangeNotifier {
  List<ReceiptModel> _receipts = [];
  List<ReceiptModel> get receipts => [..._receipts];
  int get receiptCount => _receipts.length;
  bool _isLoadingReceipt = false;
  //TODO change to reports model

  bool get isLoadingReceipt => _isLoadingReceipt;
  bool _isLoadingLiberateCheck = false;
}
