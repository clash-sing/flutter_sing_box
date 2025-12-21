enum LogLevel {
  /// 最详细的调试信息：协议握手过程、数据包头解析
  trace('TRACE'),
  /// 开发调试信息：连接建立/断开、配置加载过程
  debug('DEBUG'),
  /// 常规运行状态：服务启动成功、端口监听信息
  info('INFO'),
  /// 非致命异常：连接超时重试、配置项弃用警告
  warn('WARN'),
  /// 功能异常：认证失败、端口占用错误
  error('ERROR'),
  /// 严重错误：核心模块初始化失败
  fatal('FATAL'),
  /// 系统崩溃：内存溢出、关键资源不可用
  panic('PANIC');

  final String name;
  const LogLevel(this.name);

}