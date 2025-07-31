import 'dart:convert';

class GetStockTypesModel {
  final int CodigoInterno_TipoEstoque; /* : 1, */
  final String Nome_TipoEstoque; /* : "Estoque Atual", */
  final bool FlagInterno_TipoEstoque; /* : true */

  GetStockTypesModel({
    required this.CodigoInterno_TipoEstoque,
    required this.Nome_TipoEstoque,
    required this.FlagInterno_TipoEstoque,
  });

  static resultAsStringToGetStockTypesModel({
    required String resultAsString,
    required List<GetStockTypesModel> listToAdd,
  }) {
    List resultAsList = json.decode(resultAsString);
    resultAsList.forEach((element) {
      listToAdd.add(
        GetStockTypesModel(
          CodigoInterno_TipoEstoque: element["CodigoInterno_TipoEstoque"] ?? -1,
          Nome_TipoEstoque: element["Nome_TipoEstoque"],
          FlagInterno_TipoEstoque: element["FlagInterno_TipoEstoque"],
        ),
      );
    });
  }

  factory GetStockTypesModel.fromJson(Map<String, dynamic> json) {
    return GetStockTypesModel(
      CodigoInterno_TipoEstoque: json['CodigoInterno_TipoEstoque'] ?? -1,
      Nome_TipoEstoque: json['Nome_TipoEstoque'],
      FlagInterno_TipoEstoque: json['FlagInterno_TipoEstoque'],
    );
  }

  Map<String, dynamic> toJson() => {
        "CodigoInterno_TipoEstoque": CodigoInterno_TipoEstoque,
        "Nome_TipoEstoque": Nome_TipoEstoque,
        "FlagInterno_TipoEstoque": FlagInterno_TipoEstoque,
      };
}
