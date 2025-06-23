import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';

class CustomerRegisterBottomNavigationItems extends StatelessWidget {
  final void Function(int) updateSelectedIndex;
  final int selectedIndex;
  const CustomerRegisterBottomNavigationItems({
    required this.updateSelectedIndex,
    required this.selectedIndex,
    super.key,
  });

  Stack iconAccordingFormIsValid({
    required IconData icon,
    required bool hasDataAndIsValid,
    required BuildContext context,
  }) {
    return Stack(
      children: [
        Icon(
          icon,
          size: 35,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            maxRadius: 6,
            child: FittedBox(
              child: Icon(
                hasDataAndIsValid ? Icons.check_circle : Icons.cancel_rounded,
                color: hasDataAndIsValid
                    ? Theme.of(context).colorScheme.primary
                    : Colors.red,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    CustomerRegisterProvider customerRegisterProvider = Provider.of(context);

    final bool personIsValid =
        customerRegisterProvider.customer?.Name != null &&
            customerRegisterProvider.customer?.CpfCnpjNumber != null &&
            customerRegisterProvider.customer?.PersonType != null;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      unselectedFontSize: 11,
      selectedFontSize: 11,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: iconAccordingFormIsValid(
            context: context,
            icon: Icons.person,
            hasDataAndIsValid: personIsValid,
          ),
          label: 'Dados',
        ),
        BottomNavigationBarItem(
          label: 'Endereço',
          icon: iconAccordingFormIsValid(
            context: context,
            icon: Icons.room_outlined,
            hasDataAndIsValid:
                (customerRegisterProvider.customer?.Addresses?.length ?? 0) > 0,
          ),
        ),
        BottomNavigationBarItem(
          icon: iconAccordingFormIsValid(
            context: context,
            icon: Icons.email_rounded,
            hasDataAndIsValid:
                (customerRegisterProvider.customer?.Emails?.length ?? 0) > 0,
          ),
          label: 'E-mail',
        ),
        BottomNavigationBarItem(
          icon: iconAccordingFormIsValid(
            context: context,
            icon: Icons.phone,
            hasDataAndIsValid:
                (customerRegisterProvider.customer?.Telephones?.length ?? 0) >
                    0,
          ),
          label: 'Telefone',
        ),
        BottomNavigationBarItem(
          icon: iconAccordingFormIsValid(
            context: context,
            icon: Icons.payment,
            hasDataAndIsValid:
                (customerRegisterProvider.customer?.CustomerCovenants?.length ??
                        0) >
                    0,
          ),
          label: 'Convênios',
        ),
        BottomNavigationBarItem(
          icon: iconAccordingFormIsValid(
            context: context,
            icon: Icons.check,
            hasDataAndIsValid: personIsValid,
          ),
          label: 'Salvar',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: updateSelectedIndex,
    );
  }
}
