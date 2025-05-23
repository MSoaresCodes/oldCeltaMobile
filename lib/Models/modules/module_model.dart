enum Modules {
  adjustSalePrice,
  adjustStock,
  buyRequest,
  buyQuotation,
  customerRegister,
  inventory,
  priceConference,
  productsConference,
  receipt,
  reports,
  researchPrices,
  saleRequest,
  transferBetweenStocks,
  transferRequest,
}

class ModuleModel {
  final String name;
  final bool enabled;
  final String module;

  ModuleModel({
    required this.name,
    required this.enabled,
    required this.module,
  });

  factory ModuleModel.fromJson(Map data) => ModuleModel(
        name: data["name"],
        enabled: data["enabled"],
        module: data["module"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "enabled": enabled,
        "module": module,
      };
}
