import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:platform_plus/platform_plus.dart';

import '../components/components.dart';
import '../firebase_options.dart';
import '../Models/models.dart';
import '../utils/utils.dart';
import './api.dart';

enum FirebaseCallEnum {
  aboutUs,
  adjustSalePrice,
  adjustStockConfirmQuantity,
  administrativeWhats,
  bsWhats,
  buyQuotation,
  buyRequestSave,
  customerRegister,
  callToCeltaNumber,
  facebook,
  infrastructureWhats,
  instagram,
  inventoryEntryQuantity,
  linkedin,
  pdvWhats,
  priceConferenceGetProductOrSendToPrint,
  receiptEntryQuantity,
  receiptLiberate,
  reports,
  researchPricesInsertPrice,
  saleRequestSave,
  transferBetweenPackageConfirmAdjust,
  transferRequestSave,
  transferBetweenStocksConfirmAdjust,
}

class FirebaseHelper {
  static final FirebaseHelper _instance = FirebaseHelper._internal();

  factory FirebaseHelper() {
    return _instance;
  }

  FirebaseHelper._internal();

  static FirebaseAuth _firebaseauth = FirebaseAuth.instance;

  static FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  static CollectionReference _clientsCollection =
      _firebaseFirestore.collection("clients");

  static CollectionReference _manualsUrl =
      _firebaseFirestore.collection("manualsUrl");

  static CollectionReference _soapActionsCollection =
      _firebaseFirestore.collection("soapActions");

  static CollectionReference _cleckedLinkCollection =
      _firebaseFirestore.collection("clickedLinks");

  static final _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> _updateCcsAndEnterpriseNameByDocument({
    required DocumentSnapshot documentSnapshot,
    required String enterpriseNameControllerText,
  }) async {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    if (data.containsKey('urlCCS')) {
      UserData.urlCCS = data['urlCCS'];
    }

    if (data.containsKey('enterpriseName') &&
        data['enterpriseName'] != "undefined") {
      enterpriseNameControllerText = data['enterpriseName'];
      UserData.enterpriseName = data['enterpriseName'];
    }
  }

  static Future<String> getUrlFromFirebaseAndReturnErrorIfHas(
    String enterpriseNameControllerText,
  ) async {
    String errorMessage = "";
    enterpriseNameControllerText = enterpriseNameControllerText
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ''); //remove espaços em branco

    QuerySnapshot? querySnapshot;

    querySnapshot = await _getQuerySnapshot(
      collection: _clientsCollection,
      fieldToSearch: 'enterpriseName',
      isEqualTo: enterpriseNameControllerText,
    );

    if (querySnapshot.size > 0) {
      await _updateCcsAndEnterpriseNameByDocument(
        documentSnapshot: querySnapshot.docs[0],
        enterpriseNameControllerText: enterpriseNameControllerText,
      );

      errorMessage = "";
    } else {
      errorMessage =
          "A empresa não foi encontrada no banco de dados. Entre em contato com o suporte e peça para cadastrar a empresa";
    }

    return errorMessage;
  }

  static Future<void> addSoapCallInFirebase(
    FirebaseCallEnum firebaseCallEnum,
  ) async {
    Map<String, dynamic> newSoapAction = {
      "typeOfSearch": firebaseCallEnum.name,
    };
    List mySoaps = await PrefsInstance.getSoaps();
    mySoaps.add(newSoapAction);

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (mySoaps.length < 5) {
      await PrefsInstance.setSoaps(mySoaps);
    } else {
      try {
        await _addUserInformations();
        WriteBatch batch = firestore.batch();

        mySoaps.forEach((soapAction) {
          DocumentReference docRef = _soapActionsCollection
              .doc(DateFormat('yyyy-MM').format(DateTime.now()))
              .collection("soapInformations")
              .doc(UserData.enterpriseName);

          batch.set(
            docRef,
            {
              firebaseCallEnum.name: {
                PlatformPlus.platform.isIOSNative ||
                        PlatformPlus.platform.isIOSWeb
                    ? "iOS"
                    : "android": FieldValue.increment(1),
              },
              'users': null,
              'datesUsed': FieldValue.arrayUnion(
                  [DateFormat('yyyy-MM-dd').format(DateTime.now())]),
            },
            SetOptions(merge: true),
          );
        });

        batch.commit().then(
          (value) async {
            await PrefsInstance.removeKey(PrefsKeys.mySoaps);
            ////print("soapInformation adicionada");
          },
        ).catchError((error) {
          ////print("Erro para adicionar a soapInformation: $error");
        });
      } catch (e) {
        //print(e);
      }
    }
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the background!');
    print("title: ${message.notification?.title}");
    print("body: ${message.notification?.body}");
    print("data: ${message.data}");
  }

  static Future<void> initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _initNotifications();
  }

  static Future<void> _initNotifications() async {
    if (kIsWeb || PlatformPlus.platform.isWindowsNative) {
      return;
    }
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User denied permissions.');
      return; // Don't continue if permissions are denied.
    }
    String? fcmToken;

    if (Platform.isAndroid) {
      fcmToken = await _firebaseMessaging.getToken();
    } else if (Platform.isIOS) {
      fcmToken = await _firebaseMessaging.getAPNSToken();
    }
    print("Token: $fcmToken"); //precisa usar esse token pra fazer testes de
    // mensagens pelo site do firebase
    UserData.fcmToken = fcmToken;

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("Mensagem inicial: ${initialMessage}");
    }

    //quando clica na notificação pra abrir o aplicativo
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   Navigator.of(NavigatorKey.key.currentState!.context)
    //       .pushNamed(APPROUTES.NOTIFICATIONS);
    // });

    //mensagens em segundo plano
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    //abaixo recebe a notificação em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        ShowAlertDialog.show(
          context: NavigatorKey.key.currentState!.context,
          title: message.notification?.title ?? "",
          content: Text(
            message.notification?.body ?? "",
            textAlign: TextAlign.center,
          ),
          function: () async {},
          showConfirmAndCancelMessage: false,
          showCloseAlertDialogButton: true,
          closeMessage: "OK",
        );
        debugPrint(message.notification!.title);
        debugPrint(message.notification!.body);
      } catch (e) {
        print(e);
      }
    });
  }

  static Future<void> addClickedInLink(
    FirebaseCallEnum firebaseCallEnum,
  ) async {
    DocumentReference docRef =
        _cleckedLinkCollection.doc(UserData.enterpriseName);

    await docRef
        .set(
          {
            firebaseCallEnum.name: {
              "timesClicked": FieldValue.increment(1),
              'users': FieldValue.arrayUnion([UserData.userName.toLowerCase()]),
              'datesClicked': FieldValue.arrayUnion(
                  [DateFormat('yyyy-MM-dd').format(DateTime.now())]),
            },
          },
          SetOptions(merge: true),
        )
        .then((value) => value)
        .catchError((error) => error);
  }

  static Future<QuerySnapshot<Object?>> _getQuerySnapshot({
    required CollectionReference<Object?> collection,
    Object? fieldToSearch,
    String? isEqualTo,
  }) async {
    if (fieldToSearch != null && isEqualTo != null) {
      return await collection
          .where(
            fieldToSearch,
            isEqualTo: isEqualTo
                .toLowerCase()
                .replaceAll(RegExp(r'\s+'), ''), //remove espaços em branco
          )
          .get();
    } else {
      return await collection.get();
    }
  }

  static Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseauth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<List<QueryDocumentSnapshot<Object?>>> getAllClients() async {
    try {
      final value = await _clientsCollection.get();

      return value.docs;
    } catch (e) {
      throw Exception();
    }
  }

  static Future<void> _addUserInformations() async {
    if (UserData.alreadyInsertedUsersInformations) return;

    try {
      final value = await PrefsInstance.getString(PrefsKeys.usersInformations);

      if (value.isNotEmpty) {
        final userInformations = UserInformationsModel.fromJson(
          json.decode(value),
        );
        int diferenceBetweenAtualDateAndLastUpdated = userInformations
            .dateOfLastUpdatedInFirebase
            .difference(DateTime.now())
            .inDays;
        if (diferenceBetweenAtualDateAndLastUpdated <= 3) {
          return;
        }
      }

      final result = await _clientsCollection
          .where(
            "enterpriseName",
            isEqualTo: UserData.enterpriseName,
          )
          .get();

      if (result.docs.isNotEmpty) {
        final userInformations = UserInformationsModel(
          fcmToken: UserData.fcmToken,
          userName: UserData.userName,
          deviceType: PlatformPlus.platform.isIOSNative ? "iOS" : "android",
          dateOfLastUpdatedInFirebase: DateTime.now(),
        );

        await _clientsCollection.doc(result.docs.first.id).set(
          {UserData.userName: userInformations.toJson()},
          SetOptions(merge: true),
        );

        UserData.alreadyInsertedUsersInformations = true;

        await PrefsInstance.setObject(
          prefsKeys: PrefsKeys.usersInformations,
          object: userInformations,
        );
      }
    } catch (e) {
      print("erro para adicionar as informações do usuário ==== $e");
    }
  }

  static Future<List<QueryDocumentSnapshot>?> getAllSoapActions(
      yearAndMonth) async {
    try {
      final soapActions = await _firebaseFirestore
          .collection("soapActions")
          .doc(yearAndMonth)
          .collection("soapInformations")
          .get();

      if (soapActions.docs.isNotEmpty) {
        return soapActions.docs;
      }
    } catch (e) {
      debugPrint("Erro para obter as requisições: $e");
    }
    return null;
  }

  static Future<void> deleteEnterprise(String id) async {
    try {
      await _clientsCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateUrlCcs({
    required String newUrl,
    required FirebaseEnterpriseModel client,
  }) async {
    try {
      if (client.urlCCS == newUrl) {
        throw "Ajuda aí poxa kkkk tá colocando a mesma URL";
      }
      await _clientsCollection.doc(client.id).update({"urlCCS": newUrl});
    } catch (e) {
      rethrow;
    }
  }

  static Future<FirebaseEnterpriseModel?> addUpdateEnterprise({
    required FirebaseEnterpriseModel enterpriseToAdd,
  }) async {
    try {
      final newEnterprise = FirebaseEnterpriseModel(
        enterpriseName:
            enterpriseToAdd.enterpriseName.toLowerCase().removeWhiteSpaces(),
        urlCCS: enterpriseToAdd.urlCCS.toLowerCase().removeWhiteSpaces(),
        id: enterpriseToAdd.id,
        usersInformations: enterpriseToAdd.usersInformations,
        subEnterprises: enterpriseToAdd.subEnterprises!
            .map(
              (e) => SubEnterpriseModel(
                cnpj: e.cnpj?.toInt().toString(),
                surname: e.surname,
                modules: e.modules,
              ),
            )
            .toList(),
      );

      await _clientsCollection.doc(enterpriseToAdd.id).set(
            newEnterprise.toJson(),
            SetOptions(merge: true),
          );

      return newEnterprise;
    } catch (e) {
      return null;
    }
  }

  static Future<void> enableOrDisableModule({
    required FirebaseEnterpriseModel client,
    required List<ModuleModel> updatedModules,
  }) async {
    try {
      await _clientsCollection.doc(client.id).set(
        {
          "modules": updatedModules.map((e) => e.toJson()).toList(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<FirebaseEnterpriseModel?> getFirebaseEnterpriseModel() async {
    try {
      QuerySnapshot<Object?> value;

      value = await _getQuerySnapshot(
        collection: _clientsCollection,
        fieldToSearch: "enterpriseName",
        isEqualTo: UserData.enterpriseName,
      );

      if (value.docs.isNotEmpty) {
        return FirebaseEnterpriseModel.fromJson(
          json: value.docs.first.data() as Map<String, dynamic>,
          id: value.docs.first.id,
        );
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  static Future<void> updateAllEnterprisesParameters() async {
    final enterprises = await getAllClients();

    try {
      for (var enterprise in enterprises) {
        await _clientsCollection.doc(enterprise.id).set(
          {
            "modules": [
              ModuleModel(
                module: Modules.adjustStock.name,
                enabled: true,
                name: "Ajuste de estoques",
              ),
              ModuleModel(
                module: Modules.adjustSalePrice.name,
                enabled: true,
                name: "Ajuste de preços",
              ),
              ModuleModel(
                module: Modules.customerRegister.name,
                enabled: true,
                name: "Cadastro de cliente",
              ),
              ModuleModel(
                module: Modules.productsConference.name,
                enabled: true,
                name: "Conferência de produtos (expedição)",
              ),
              ModuleModel(
                module: Modules.priceConference.name,
                enabled: true,
                name: "Consulta de preços",
              ),
              ModuleModel(
                module: Modules.researchPrices.name,
                enabled: true,
                name: "Consulta de preços concorrentes",
              ),
              ModuleModel(
                module: Modules.buyQuotation.name,
                enabled: true,
                name: "Cotação de compras",
              ),
              ModuleModel(
                module: Modules.inventory.name,
                enabled: true,
                name: "Inventário",
              ),
              ModuleModel(
                module: Modules.buyRequest.name,
                enabled: true,
                name: "Pedido de compra",
              ),
              ModuleModel(
                module: Modules.transferRequest.name,
                enabled: true,
                name: "Pedido de transferência",
              ),
              ModuleModel(
                module: Modules.saleRequest.name,
                enabled: true,
                name: "Pedido de vendas",
              ),
              ModuleModel(
                module: Modules.receipt.name,
                enabled: true,
                name: "Recebimento",
              ),
              ModuleModel(
                module: Modules.transferBetweenStocks.name,
                enabled: true,
                name: "Transferência entre estoques",
              ),
            ].map((e) => e.toJson()).toList()
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<String?> getManualsUrl() async {
    try {
      final value = await _getQuerySnapshot(collection: _manualsUrl);

      if (value.docs.isNotEmpty) {
        return (value.docs.first.data() as Map)["url"];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
