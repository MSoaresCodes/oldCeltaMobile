import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import 'components.dart';

class EnterpriseItems extends StatelessWidget {
  final String nextPageRoute;
  const EnterpriseItems({
    required this.nextPageRoute,
    Key? key,
  }) : super(key: key);

  bool moduleIsEnabled(Modules module, SubEnterpriseModel subEnterprise) {
    int? indexOfModule =
        subEnterprise.modules?.indexWhere((e) => e.module == module.name);
    return indexOfModule != -1 &&
        subEnterprise.modules![indexOfModule!].enabled;
  }

  bool _enterpriseIsEnabled(
    EnterpriseProvider enterpriseProvider,
    EnterpriseModel enterprise,
  ) {
    final subEnterprises =
        enterpriseProvider.firebaseEnterpriseModel?.subEnterprises;

    int? indexOfSameCnpj = subEnterprises
        ?.indexWhere((e) => e.cnpj == enterprise.CnpjNumber.toString());

    if (subEnterprises == null) {
      return false;
    } else if (indexOfSameCnpj == -1) {
      return false;
    } else {
      SubEnterpriseModel? subEnterprise = subEnterprises[indexOfSameCnpj!];

      if (nextPageRoute == APPROUTES.ADJUST_SALE_PRICE_PRODUCTS) {
        return moduleIsEnabled(Modules.adjustSalePrice, subEnterprise);
      } else if (nextPageRoute == APPROUTES.ADJUST_STOCK) {
        return moduleIsEnabled(Modules.adjustStock, subEnterprise);
      } else if (nextPageRoute == APPROUTES.CUSTOMER_REGISTER) {
        return moduleIsEnabled(Modules.customerRegister, subEnterprise);
      } else if (nextPageRoute ==
          APPROUTES.EXPEDITION_CONFERENCE_CONTROLS_TO_CONFERENCE) {
        return moduleIsEnabled(Modules.productsConference, subEnterprise);
      } else if (nextPageRoute == APPROUTES.PRICE_CONFERENCE) {
        return moduleIsEnabled(Modules.priceConference, subEnterprise);
      } else if (nextPageRoute == APPROUTES.BUY_QUOTATION) {
        return moduleIsEnabled(Modules.buyQuotation, subEnterprise);
      } else if (nextPageRoute == APPROUTES.INVENTORY) {
        return moduleIsEnabled(Modules.inventory, subEnterprise);
      } else if (nextPageRoute == APPROUTES.BUYERS) {
        return moduleIsEnabled(Modules.buyRequest, subEnterprise);
      } else if (nextPageRoute == APPROUTES.TRANSFER_REQUEST_MODEL) {
        return moduleIsEnabled(Modules.transferRequest, subEnterprise);
      } else if (nextPageRoute == APPROUTES.SALE_REQUEST_MODEL) {
        return moduleIsEnabled(Modules.saleRequest, subEnterprise);
      } else if (nextPageRoute == APPROUTES.RESEARCH_PRICES) {
        return moduleIsEnabled(Modules.researchPrices, subEnterprise);
      } else if (nextPageRoute == APPROUTES.RECEIPT) {
        return moduleIsEnabled(Modules.receipt, subEnterprise);
      } else if (nextPageRoute == APPROUTES.REPORTS) {
        return moduleIsEnabled(Modules.reports, subEnterprise);
      } else if (nextPageRoute == APPROUTES.TRANSFER_BETWEEN_STOCK) {
        return moduleIsEnabled(Modules.transferBetweenStocks, subEnterprise);
      }
    }

    return false;
  }

  bool _hasMinimumVersion(EnterpriseProvider enterpriseProvider) {
    if (nextPageRoute == APPROUTES.REPORTS) {
      //TODO fix this date after the Júnior fix the problem to get schedules
      return enterpriseProvider.bsDate?.isAfter(DateTime(2025, 07, 17)) == true;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    EnterpriseProvider enterpriseProvider = Provider.of(context);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: enterpriseProvider.enterpriseCount,
      itemBuilder: (ctx, index) {
        final enterprise = enterpriseProvider.enterprises[index];
        return Card(
          child: ListTile(
            title: Text(
              enterprise.Name,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            leading: Text(
              enterprise.PersonalizedCode.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
              ),
            ),
            subtitle: Text(
              "Cnpj: " + enterprise.CnpjNumber.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
              ),
            ),
            onTap: () {
              if (!_enterpriseIsEnabled(enterpriseProvider, enterprise)) {
                ShowSnackbarMessage.show(
                  message:
                      "Esse módulo não está habilitado para essa empresa. Caso queira habilitar, entre em contato com o setor administrativo da Celta Ware pelo número (11) 3125-6767",
                  context: context,
                );
              } else if (!_hasMinimumVersion(enterpriseProvider)) {
                ShowSnackbarMessage.show(
                  message:
                      "Entre em contato com o suporte técnico e solicite a atualização do CeltaBS",
                  context: context,
                );
              } else {
                Navigator.of(context).pushNamed(
                  nextPageRoute,
                  arguments: enterprise,
                );
              }
            },
          ),
        );
      },
    );
  }
}
