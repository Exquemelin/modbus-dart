import 'dart:async';
import 'dart:typed_data';
import 'src/client.dart';
import 'src/tcp_connector.dart';
export 'src/exceptions.dart';
export 'src/tcp_connector.dart';

typedef void FunctionCallback(int function, Uint8List data);
typedef void ErrorCallback(error, stackTrace);
typedef void CloseCallback();

class ModbusFunctions {
  static const readCoils = 0x01;
  static const readDiscreteInputs = 0x02;
  static const readHoldingRegisters = 0x03;
  static const readInputRegisters = 0x04;
  static const writeSingleCoil = 0x05;
  static const writeSingleRegister = 0x06;
  static const readExceptionStatus = 0x07;
  static const writeMultipleCoils = 0x0f;
  static const writeMultipleRegisters = 0x10;
  static const reportSlaveId = 0x11;
}

/// MODBUS Connector.
abstract class ModbusConnector {
  /// Connect will be called from the [ModbusClient] to establish connection
  Future connect();

  /// Will be called from the [ModbusClientImpl]
  Future close();

  /// Write function with data over connector. Will be called from the [ModbusClientImpl]
  void write(int function, Uint8List data, [int unitId]);

  /// This should be called by the Connector implementation when response comes from the device
  FunctionCallback onResponse;

  /// This should be called by the Connector implementation when any error occurs
  ErrorCallback onError;

  /// This should be called by the Connector implementation after closing connection (socket close, etc)
  CloseCallback onClose;
}

enum ModbusMode { rtu, ascii }

/// MODBUS client
abstract class ModbusClient {
  Future<void> connect();
  Future<void> close();

  /// Execute custom modbus function
  Future<Uint8List> executeFunction(int function, [Uint8List data, int unitId]);

  /// Report slave ID, function 0x11
  Future<Uint8List> reportSlaveId();

  /// Read exception status, function 0x07
  Future<int> readExceptionStatus();

  /// Read coils, function 0x01
  Future<List<bool>> readCoils(int address, int amount, [int unitId]);

  /// Read discrete inputs, function 0x02
  Future<List<bool>> readDiscreteInputs(int address, int amount, [int unitId]);

  /// Read holding registers, function 0x03
  Future<Uint16List> readHoldingRegisters(int address, int amount, [int unitId]);

  /// Read input registers, function 0x04
  Future<Uint16List> readInputRegisters(int address, int amount, [int unitId]);

  /// Read single coil, function 0x05
  Future<bool> writeSingleCoil(int address, bool to_write, [int unitId]);

  /// Read single register, function 0x06
  Future<int> writeSingleRegister(int address, int value, [int unitId]);

  /// Read multiply coils, function 0x0f
  Future<void> writeMultipleCoils(int address, List<bool> values, [int unitId]);

  /// Read multiply registers, function 0x10
  Future<void> writeMultipleRegisters(int address, Uint16List values, [int unitId]);
}

ModbusClient createClient(TcpConnector connector) => ModbusClientImpl(connector);
ModbusClient createTcpClient(address, {int port = 502, ModbusMode mode = ModbusMode.rtu}) =>
    ModbusClientImpl(TcpConnector(address, port, mode));
