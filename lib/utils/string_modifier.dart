extension StringModifier on String {
  String toBrazilianNumber(
      [int decimalHouses = 2, bool hideDecimalIfWhole = false]) {
    double value = double.parse(this);

    if (hideDecimalIfWhole && value % 1 == 0) {
      return value
          .toInt()
          .toString()
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    }

    String formatted = value.toStringAsFixed(decimalHouses);
    List<String> parts = formatted.split('.');
    parts[0] = parts[0]
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');

    return parts.join(',');
  }

  String addBrazilianCoin() {
    return "R\$ $this";
  }

  String removeWhiteSpaces() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  double toDouble() {
    try {
      if (this.isEmpty) {
        return -1;
      }

      String string = replaceAll(RegExp(r','), '.');
      final quantidadeDePontos = '.'.allMatches(string).length;

      quantidadeDePontos.toString();
      if (quantidadeDePontos > 1) {
        for (var x = 1; x < quantidadeDePontos; x++) {
          if (x < quantidadeDePontos) {
            string = string.replaceFirst(RegExp(r'\.'), '');
          }
        }
      }

      return double.parse(string);
    } catch (e) {
      return -1.0;
    }
  }

  int toInt([bool removePoints = false]) {
    try {
      if (removePoints) {
        return int.parse(
            replaceAll(RegExp(r','), '').replaceAll(RegExp(r'\.'), ''));
      } else {
        return int.parse(this);
      }
    } catch (e) {
      return -1;
    }
  }

  String removeBreakLines() {
    String newValue = this;
    newValue = newValue.replaceAll(RegExp(r'\\r\\'), '');
    newValue = newValue.replaceAll(RegExp(r'\\n'), '');
    newValue = newValue.replaceAll(RegExp(r'\\'), '');

    return newValue;
  }

  String? formatPackingQuantity() {
    final doubleValue = this.toDouble();
    bool? isInt = doubleValue >= 1 && doubleValue % 1 == 0.0;

    if (isInt == true) {
      return (this.toInt() % 2).toString();
    }

    String? packingQuantity = this.replaceAll(RegExp(r'.0000'), '');

    if (packingQuantity.endsWith("000") == true) {
      packingQuantity = packingQuantity.replaceAll(RegExp(r'000'), '');
    }
    if (packingQuantity.endsWith("00") == true) {
      packingQuantity = packingQuantity.replaceAll(RegExp(r'00'), '');
    }
    if (packingQuantity.endsWith("0") == true) {
      packingQuantity = packingQuantity.replaceAll(RegExp(r'0'), '');
    }

    return packingQuantity.replaceAll(RegExp(r'\.'), ',');
  }
}
