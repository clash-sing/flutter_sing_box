package com.clashsing.flutter_sing_box.aidl;

interface IServiceCallback {
  void onServiceStatusChanged(int status);
  void onServiceAlert(int type, String message);
}