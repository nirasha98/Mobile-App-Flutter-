//This file is for calculating the value of CAN message
//includes two lists of CAN messages. With packet id and without packet id.
//include a function to calculate CAN value ,according to availability of packet id.

import 'dart:typed_data';

// CAN message list for No Packet Id s.
class CANMessage_NoPacketId {
  final int canId;

  final List<int> data;

  CANMessage_NoPacketId({required this.canId, required this.data});
} // declare the message list without packet ids.

List<CANMessage_NoPacketId> messages_No_PacketId = [
  CANMessage_NoPacketId(
      canId: 0x123, data: [0x45, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), // uint8
  CANMessage_NoPacketId(
      canId: 0x456, data: [0x04, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00]), // uint16
  CANMessage_NoPacketId(
      canId: 0x789,
      data: [0xFF, 0x00, 0x09, 0x08, 0x98, 0x54, 0x46]), // signed int8
  CANMessage_NoPacketId(
      canId: 0x54,
      data: [0xFE, 0x01, 0x01, 0x02, 0x03, 0x04, 0x05]), // signed int16
  CANMessage_NoPacketId(
      canId: 0x98, data: [0x41, 0x48, 0x0F, 0xDB, 0x00, 0x00, 0x00]), // float32
]; // hardcode CAN message list, without Packet ids.

//CAN messages with Packet Ids.
class CANMessage {
  final int canId;
  final int packetId;
  final List<int> data;

  CANMessage({required this.canId, required this.packetId, required this.data});
} // declare the message list

List<CANMessage> messagesByCanId = [
  CANMessage(
      canId: 0x123,
      packetId: 1,
      data: [0x45, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), // uint8
  CANMessage(
      canId: 0x123,
      packetId: 2,
      data: [0x04, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00]), // uint16
  CANMessage(
      canId: 0x123,
      packetId: 0,
      data: [0xFF, 0x00, 0x09, 0x08, 0x98, 0x54, 0x46]), // signed int8
  CANMessage(
      canId: 0x54,
      packetId: 1,
      data: [0xFE, 0x01, 0x01, 0x02, 0x03, 0x04, 0x05]), // signed int16
  CANMessage(
      canId: 0x54,
      packetId: 2,
      data: [0x41, 0x48, 0x0F, 0xDB, 0x00, 0x00, 0x00]), // float32
]; // hardcode CAN messages with Packet id.

// function for calculate the value of CAN message
num calculateCANValue(int canId, int packetId, int highByteIndex,
    int lowByteIndex, String dataType) {
  // filter CAN message according to availability of Packet iD
  if (packetId <= -1) {
    CANMessage_NoPacketId message = messages_No_PacketId
        .firstWhere((m) => m.canId == canId); // for No packet id s.

    // find the values of the high and low bytes
    int lowByte = message.data[lowByteIndex];
    int highByte = message.data[highByteIndex];

    // calculate value of CAN message according to user entered data type.
    switch (dataType) {
      case 'uint_8':
        return lowByte;
      case 'uint_16':
        return (highByte << 8) | lowByte;
      case 'int_8':
        return (lowByte < 128) ? lowByte : lowByte - 256;
      case 'int_16':
        int value = (highByte << 8) | lowByte;
        return (value < 32768) ? value : value - 65536;
      case 'float_32':
        if (highByteIndex < 3) {
          throw RangeError('Invalid value: highByteIndex must be >= 3');
        }
        Uint8List bytes = Uint8List.fromList(message.data);
        ByteData bd = ByteData.view(bytes.buffer);
        return bd.getFloat32(highByteIndex - 3);
      default:
        throw Exception('Unknown data type: $dataType');
    }
  } else {
    // find the message with the given CAN id and packet id
    CANMessage message = messagesByCanId
        .firstWhere((m) => m.canId == canId && m.packetId == packetId);

    // find the values of the high and low bytes
    int lowByte = message.data[lowByteIndex];
    int highByte = message.data[highByteIndex];

    // calculate value of CAN message according to user entered data type.
    switch (dataType) {
      case 'uint_8':
        return lowByte;
      case 'uint_16':
        return (highByte << 8) | lowByte;
      case 'int_8':
        return (lowByte < 128) ? lowByte : lowByte - 256;
      case 'int_16':
        int value = (highByte << 8) | lowByte;
        return (value < 32768) ? value : value - 65536;
      case 'float_32':
        if (highByteIndex < 3) {
          throw RangeError('Invalid value: highByteIndex must be >= 3');
        }
        Uint8List bytes = Uint8List.fromList(message.data);
        ByteData bd = ByteData.view(bytes.buffer);
        return bd.getFloat32(highByteIndex - 3);
      default:
        throw Exception('Unknown data type: $dataType');
    }
  }
}
