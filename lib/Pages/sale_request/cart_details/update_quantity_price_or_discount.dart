import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';

class UpdateQuantityPriceOrDiscount extends StatefulWidget {
  final GetProductJsonModel product;
  final double? controllerInDouble;
  final FocusNode quantityFocusNode;
  final GlobalKey<FormState> quantityFormKey;
  final TextEditingController newQuantityController;
  final int enterpriseCode;
  final void Function() callSetState;
  final void Function() clearSelectedIndex;
  final int productIndex;

  const UpdateQuantityPriceOrDiscount({
    required this.product,
    required this.controllerInDouble,
    required this.quantityFocusNode,
    required this.quantityFormKey,
    required this.newQuantityController,
    required this.enterpriseCode,
    required this.callSetState,
    required this.clearSelectedIndex,
    required this.productIndex,
    super.key,
  });

  @override
  State<UpdateQuantityPriceOrDiscount> createState() =>
      _UpdateQuantityPriceOrDiscountState();
}

class _UpdateQuantityPriceOrDiscountState
    extends State<UpdateQuantityPriceOrDiscount> {
  final manualPriceController = TextEditingController();
  final manualDiscountController = TextEditingController();
  String? discountType;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.newQuantityController.text = widget.product.quantity
            .toString()
            .toBrazilianNumber()
            .replaceAll(RegExp(r'\.'), '');

        if (widget.product.DiscountValue != null &&
            widget.product.DiscountValue! > 0) {
          discountType = widget.product.DiscountPercentageOrValue;
          if (discountType == "R\$") {
            manualDiscountController.text =
                widget.product.DiscountValue.toString().toBrazilianNumber();
            discountType = "R\$";
          } else {
            manualDiscountController.text = widget.product.DiscountValue
                .toString()
                .toDouble()
                .toInt()
                .toString();
            discountType = "%";
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    manualPriceController.dispose();
    manualDiscountController.dispose();
  }

  Future<void> updateProductInCart({
    required SaleRequestProvider saleRequestProvider,
    required GetProductJsonModel product,
    required int index,
  }) async {
    bool? isValid = widget.quantityFormKey.currentState!.validate();

    double? controllerInDouble = double.tryParse(
      widget.newQuantityController.text.replaceAll(RegExp(r'\,'), '.'),
    );

    if (controllerInDouble == null || controllerInDouble == 0) return;

    if (isValid) {
      final updated = await saleRequestProvider.updateProductInCart(
        enterpriseCode: widget.enterpriseCode.toString(),
        quantity: controllerInDouble,
        updateToNeedProcessCartAgain: true,
        index: index,
        manualDiscountController: manualDiscountController,
        manualPriceController: manualPriceController,
        discountType: discountType,
      );

      if (updated) {
        widget.newQuantityController.clear();
        widget.clearSelectedIndex();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SaleRequestProvider saleRequestProvider = Provider.of(context);
    final arguments = ModalRoute.of(context)!.settings.arguments! as Map;
    final code = arguments["SaleRequestTypeCode"];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Preço venda",
                      subtitle: ConvertString.convertToBRL(
                        widget.product.retailPracticedPrice,
                      ),
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Mín. atacado",
                      subtitle: widget.product.minimumWholeQuantity
                          .toString()
                          .toBrazilianNumber(),
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Preço atacado",
                      subtitle: ConvertString.convertToBRL(
                        widget.product.wholePracticedPrice,
                      ),
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Preço mínimo",
                      subtitle: ConvertString.convertToBRL(
                        widget.product.priceCost?.RetailMinimumPrice ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: widget.controllerInDouble == null ||
                        widget.controllerInDouble == 0
                    ? null
                    : () {
                        updateProductInCart(
                          saleRequestProvider: saleRequestProvider,
                          product: widget.product,
                          index: widget.productIndex,
                        );
                      },
                child: const Text("ATUALIZAR"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 55,
                child: Column(
                  children: [
                    InsertQuantityTextFormField(
                      lengthLimitingTextInputFormatter: 8,
                      focusNode: widget.quantityFocusNode,
                      formKey: widget.quantityFormKey,
                      newQuantityController: widget.newQuantityController,
                      onFieldSubmitted: (_) {
                        updateProductInCart(
                          saleRequestProvider: saleRequestProvider,
                          product: widget.product,
                          index: widget.productIndex,
                        );
                      },
                      onChanged: (_) {
                        widget.callSetState();
                      },
                      labelText: "Digite a nova quantidade",
                      hintText: "Nova quantidade",
                    ),
                    if (saleRequestProvider.userCanChangePrices)
                      Column(
                        children: [
                          manualPrice(saleRequestProvider, context),
                          if (saleRequestProvider.requests
                              .where((e) =>
                                  e.Code == code && e.AllowDiscount == true)
                              .isNotEmpty)
                            manualDiscount(context)
                        ],
                      ),
                  ],
                ),
              ),
              totalAmount(saleRequestProvider, context),
            ],
          ),
        ],
      ),
    );
  }

  Padding totalAmount(
      SaleRequestProvider saleRequestProvider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        children: [
          const FittedBox(
            child: Text(
              "TOTAL",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          FittedBox(
            child: Text(
              (saleRequestProvider.getNewItemPrice(
                          product: widget.product,
                          newQuantity:
                              widget.newQuantityController.text.toDouble(),
                          enterpriseCode: widget.enterpriseCode.toString(),
                          discountType: discountType,
                          manualDiscountController: manualDiscountController,
                          manualPriceController: manualPriceController) *
                      widget.newQuantityController.text.toDouble())
                  .toString()
                  .toBrazilianNumber()
                  .addBrazilianCoin(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row manualDiscount(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              controller: manualDiscountController,
              enabled: manualPriceController.text.isEmpty,
              inputFormatters: [LengthLimitingTextInputFormatter(8)],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: FormFieldStyle.style(),
              onChanged: (_) {
                widget.callSetState();
              },
              onTap: () {
                manualDiscountController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: manualDiscountController.text.length,
                );
              },
              decoration: FormFieldDecoration.decoration(
                context: context,
                hintText: "Desconto manual R\$",
                labelText: "Desconto manual R\$",
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            isDense: true,
            hint: Text(discountType ?? "Tipo"),
            items: [
              DropdownMenuItem(
                value: "R\$",
                onTap: () {
                  discountType = "R\$";
                },
                child: Text("R\$"),
              ),
              DropdownMenuItem(
                value: "%",
                onTap: () {
                  discountType = "%";
                },
                child: Text("%"),
              ),
            ],
            onChanged: (value) {},
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.info,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip:
              "Essa opção só fica disponível quando o modelo de pedido de vendas permite desconto e não há um preço manual informado. Se o desconto for maior do que o permitido, o BS vai inserir o pedido no processo de autorizações",
        )
      ],
    );
  }

  Padding manualPrice(
    SaleRequestProvider saleRequestProvider,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: manualPriceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: FormFieldStyle.style(),
              enabled: manualDiscountController.text.isEmpty,
              onFieldSubmitted: (_) {
                updateProductInCart(
                  saleRequestProvider: saleRequestProvider,
                  product: widget.product,
                  index: widget.productIndex,
                );
              },
              onChanged: (_) {
                widget.callSetState();
              },
              onTap: () {
                manualPriceController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: manualPriceController.text.length,
                );
              },
              decoration: FormFieldDecoration.decoration(
                context: context,
                hintText: "Preço manual R\$",
                labelText: "Preço manual R\$",
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip:
                "Essa opção só fica disposnível quando o usuário possui permissão para alterar o preço e não há um desconto manual informado",
          )
        ],
      ),
    );
  }
}
