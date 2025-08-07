import 'package:flutter/material.dart';

import '../utils/utils.dart';

class ImageComponent {
  static Widget image({
    required String imagePath,
    required String routine,
    required BuildContext context,
    required String nextRoute,
    bool? isNew,
    bool? onlyForValidateModule,
    void Function()? onTap,
    int? freeDays, //TODO manually add free days here
  }) {
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.of(context).pushNamed(
              APPROUTES.ENTERPRISE,
              arguments: {
                "nextRoute": nextRoute,
                "onlyForValidateModule": onlyForValidateModule,
              },
            );
          },
      child: Card(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath,
              width: double.infinity,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              height: double.infinity,
            ),
            if (isNew == true)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Text(
                    'NOVO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (freeDays != null)
              Positioned(
                top: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Container(
                    color: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "$freeDays dias grátis".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.lightGreenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    border: Border.all(
                      style: BorderStyle.none,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 1.0),
                    child: Text(
                      routine,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
