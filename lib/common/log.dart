import 'package:logger/logger.dart';

class Log extends Logger {
  static final _logger = Logger(
    printer: PrettyPrinter(

    )
  );

  Log._internal();

  static late final _instance = Log._internal();

  factory Log() => _instance;

  @override
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message, error, stackTrace);
  }

  @override
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  @override
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  @override
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  @override
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  @override
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error, stackTrace);
  }
}
