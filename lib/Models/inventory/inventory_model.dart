class InventoryModel {
  final int codigoInternoInventario;
  final DateTime dataCriacaoInventario;
  final DateTime dataCongelamentoInventario;
  final int codigoInternoEmpresa;
  final String nomeTipoEstoque;
  final String obsInventario;
  final String nomefuncionario;
  final String nomeempresa;
  final String codigoEmpresa;

  InventoryModel({
    required this.codigoInternoInventario,
    required this.dataCriacaoInventario,
    required this.dataCongelamentoInventario,
    required this.nomeTipoEstoque,
    required this.obsInventario,
    required this.nomefuncionario,
    required this.nomeempresa,
    required this.codigoInternoEmpresa,
    required this.codigoEmpresa,
  });

  static void responseAsStringToInventoryModel({
    required dynamic data,
    required List listToAdd,
  }) {
    if (data == null) {
      return;
    }
    List dataList = [];
    if (data is Map) {
      dataList.add(data);
    } else {
      dataList = data;
    }

    dataList.forEach((element) {
      listToAdd.add(
        InventoryModel(
          codigoInternoInventario:
              int.parse(element['CodigoInterno_Inventario']),
          dataCriacaoInventario:
              DateTime.parse(element['DataCriacao_Inventario']).toLocal(),
          dataCongelamentoInventario:
              DateTime.parse(element['DataCongelamento_Inventario']).toLocal(),
          nomeTipoEstoque: element['Nome_TipoEstoque'],
          obsInventario: element['Obs_Inventario'] ?? '',
          nomefuncionario: element['Nome_Funcionario'],
          nomeempresa: element['Nome_Empresa'],
          codigoInternoEmpresa: int.parse(element['CodigoInterno_Empresa1']),
          codigoEmpresa: element['Codigo_Empresa'],
        ),
      );
    });
  }
}
