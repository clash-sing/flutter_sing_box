package com.clashsiing.flutter_sing_box.aidl;

import com.clashsiing.flutter_sing_box.aidl.IServiceCallback;

interface IService {
  int getStatus();
  void registerCallback(in IServiceCallback callback);
  oneway void unregisterCallback(in IServiceCallback callback);
}