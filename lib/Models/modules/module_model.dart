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

extension ModuleExtension on Modules {
  String get description {
    switch (this) {
      case Modules.adjustSalePrice:
        return "Ajuste de preço";
      case Modules.adjustStock:
        return "Ajuste de estoque";
      case Modules.buyRequest:
        return "Pedido de compra";
      case Modules.buyQuotation:
        return "Cotação de compra";
      case Modules.customerRegister:
        return "Cadastro de clientes";
      case Modules.inventory:
        return "Inventário";
      case Modules.priceConference:
        return "Conferencia de preços";
      case Modules.productsConference:
        return "Conferencia de produtos";
      case Modules.receipt:
        return "Recebimento";
      case Modules.reports:
        return "Relatórios";
      case Modules.researchPrices:
        return "Pesquisa de preços";
      case Modules.saleRequest:
        return "Pedido de venda";
      case Modules.transferBetweenStocks:
        return "Transferência entre estoques";
      case Modules.transferRequest:
        return "Transferência de produtos";
      default:
        return "";
    }
  }
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
