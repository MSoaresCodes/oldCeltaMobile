import 'dart:convert';

import '../../Models/models.dart';

class GetJustificationsModel {
  final int CodigoInterno_JustMov; /*  37, */
  final String Descricao_JustMov; /*  "SUBTRAIR", */
  final String FlagTipo_JustMov; /*  "Saída", */
  final String TypeOperator; /*  "(-)", */
  final String Nome_TipoEstoque; /*  "", */
  final GetStockTypesModel CodigoInterno_TipoEstoque;

  GetJustificationsModel({
    required this.CodigoInterno_JustMov,
    required this.Descricao_JustMov,
    required this.FlagTipo_JustMov,
    required this.TypeOperator,
    required this.Nome_TipoEstoque,
    required this.CodigoInterno_TipoEstoque,
  });

  factory GetJustificationsModel.fromJson(Map<String, dynamic> json) {
    return GetJustificationsModel(
      CodigoInterno_JustMov: json["CodigoInterno_JustMov"],
      Descricao_JustMov: json["Descricao_JustMov"],
      FlagTipo_JustMov: json["FlagTipo_JustMov"],
      TypeOperator: json["TypeOperator"],
      Nome_TipoEstoque: json["Nome_TipoEstoque"],
      CodigoInterno_TipoEstoque:
          GetStockTypesModel.fromJson(json["CodigoInterno_TipoEstoque"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "CodigoInterno_JustMov": CodigoInterno_JustMov,
      "Descricao_JustMov": Descricao_JustMov,
      "FlagTipo_JustMov": FlagTipo_JustMov,
      "TypeOperator": TypeOperator,
      "Nome_TipoEstoque": Nome_TipoEstoque,
      "CodigoInterno_TipoEstoque": CodigoInterno_TipoEstoque.toJson(),
    };
  }

  static resultAsStringToJustificationsModel({
    required String resultAsString,
    required List listToAdd,
  }) {
    List resultAsList = json.decode(resultAsString);

// Code = o["CodigoInterno_JustMov"],
// Description = o["Descricao_JustMov"],
// Type = Convert.ToInt32(o["FlagTipo_JustMov"]) == 1 ? "Entrada" : "Saída",
// TypeOperator = Convert.ToInt32(o["FlagTipo_JustMov"]) == 1 ? "(+)" : "(-)",
// StockTypeString = !Convert.IsDBNull(o["Nome_TipoEstoque"]) ? Convert.ToString(o["Nome_TipoEstoque"]) : "",
// StockType = new
// {
//     Code = o["CodigoInterno_TipoEstoque"],
//     Name = o["Nome_TipoEstoque"],
//     IsInternal = o["FlagInterno_TipoEstoque"]
// }
    resultAsList.forEach((element) {
      listToAdd.add(
        GetJustificationsModel(
          CodigoInterno_JustMov: element["CodigoInterno_JustMov"],
          Descricao_JustMov: element["Descricao_JustMov"],
          FlagTipo_JustMov:
              element["FlagTipo_JustMov"] == 1 ? "Entrada" : "Saída",
          TypeOperator: element["FlagTipo_JustMov"] == 1 ? "(+)" : "(-)",
          Nome_TipoEstoque: element["Nome_TipoEstoque"] ?? "",
          CodigoInterno_TipoEstoque: element["CodigoInterno_TipoEstoque"] ==
                  null
              ? GetStockTypesModel(
                  CodigoInterno_TipoEstoque: -1,
                  Nome_TipoEstoque: "",
                  FlagInterno_TipoEstoque: false,
                )
              : GetStockTypesModel(
                  CodigoInterno_TipoEstoque:
                      element["CodigoInterno_TipoEstoque"],
                  Nome_TipoEstoque: element["Nome_TipoEstoque"],
                  FlagInterno_TipoEstoque: element["FlagInterno_TipoEstoque"],
                ),
        ),
      );
    });
  }
}
