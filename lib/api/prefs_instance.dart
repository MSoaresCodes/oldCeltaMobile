import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

enum PrefsKeys {
  buyRequest,
  cart,
  cleanSaleRequest,
  customers,
  enterpriseName,
  hasUnreadNotifications,
  mySoaps,
  notifications,
  searchCustomerByPersonalizedCode,
  searchProductByPersonalizedCode,
  showMessageToUseCameraInWebVersion,
  transferBetweenStocksProductslots,
  transferCart,
  urlCCS,
  useAutoScan,
  useLegacyCode,
  user,
  usersInformations,
  userIdentity,
}

class PrefsInstance {
  static late SharedPreferences _prefs;
  static Future<void> removeKeysOnLogout() async {
    _prefs = await SharedPreferences.getInstance();

    await _prefs.remove(PrefsKeys.buyRequest.name);
    await _prefs.remove(PrefsKeys.cart.name);
    await _prefs.remove(PrefsKeys.customers.name);
    await _prefs.remove(PrefsKeys.hasUnreadNotifications.name);
    await _prefs.remove(PrefsKeys.notifications.name);
    await _prefs.remove(PrefsKeys.showMessageToUseCameraInWebVersion.name);
    await _prefs.remove(PrefsKeys.userIdentity.name);
    await _prefs.remove(PrefsKeys.transferBetweenStocksProductslots.name);
    await _prefs.remove(PrefsKeys.transferCart.name);
  }

  static Future<bool> _prefsContainsKey(String key) async {
    _prefs = await SharedPreferences.getInstance();

    return _prefs.containsKey(key);
  }

  static Future<void> setString({
    required PrefsKeys prefsKeys,
    required String value,
  }) async {
    _prefs = await SharedPreferences.getInstance();

    await _prefs.remove(prefsKeys.name);
    await _prefs.setString(prefsKeys.name, value);
  }

  static Future<void> removeKey(PrefsKeys prefsKeys) async {
    _prefs = await SharedPreferences.getInstance();

    await _prefs.remove(prefsKeys.name);
  }

  static Future<void> setObject({
    required PrefsKeys prefsKeys,
    required dynamic object,
  }) async {
    _prefs = await SharedPreferences.getInstance();

    await _prefs.setString(prefsKeys.name, json.encode(object));
  }

  static Future<String> getString(PrefsKeys prefsKeys) async {
    _prefs = await SharedPreferences.getInstance();
    if (await _prefsContainsKey(prefsKeys.name)) {
      return await _prefs.getString(prefsKeys.name)!;
    } else {
      return "";
    }
  }

  static Future<void> setBool({
    required PrefsKeys prefsKeys,
    required bool value,
  }) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(prefsKeys.name, value);
  }

  static Future<bool> getBool({
    required PrefsKeys prefsKeys,
  }) async {
    _prefs = await SharedPreferences.getInstance();
    if (await _prefsContainsKey(prefsKeys.name)) {
      return await _prefs.getBool(prefsKeys.name)!;
    } else {
      return false;
    }
  }

  static Future<void> setSoaps(List<dynamic> mySoaps) async {
    _prefs = await SharedPreferences.getInstance();
    List<String> encodedMySoaps =
        mySoaps.map((item) => json.encode(item)).toList();
    await _prefs.setStringList(PrefsKeys.mySoaps.name, encodedMySoaps);
  }

  static Future<List<dynamic>> getSoaps() async {
    List<dynamic> mySoaps = [];
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getStringList(PrefsKeys.mySoaps.name) != null) {
      List<String> encodedMySoaps =
          await _prefs.getStringList(PrefsKeys.mySoaps.name)!;

      mySoaps = encodedMySoaps.map((item) => json.decode(item)).toList();
    }

    return mySoaps;
  }

  static Future<void> updateUserAndEnterpriseName({
    required TextEditingController enterpriseNameController,
    required TextEditingController userController,
  }) async {
    userController.text = await PrefsInstance.getString(PrefsKeys.user);
    UserData.userName = userController.text;
    UserData.urlCCS = await PrefsInstance.getString(PrefsKeys.urlCCS);
    UserData.enterpriseName = await PrefsInstance.getString(
      PrefsKeys.enterpriseName,
    );

    if (UserData.enterpriseName != "") {
      enterpriseNameController.text = UserData.enterpriseName;
    } else {
      enterpriseNameController.text = UserData.urlCCS;
    }
  }
}
