//This file is for output the requested bit of the given Byte of a CAN message
//includes two lists of CAN messages. with and without packet ids.
//function to output the relevant flag bit, according to user request.

import 'dart:typed_data';

// CAN message list for No Packet Id s.
class CANMessage_NoPacketId {
  final int canId;

  final List<int> data;

  CANMessage_NoPacketId({required this.canId, required this.data});
} // declare the message list

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
]; // hardcode CAN message without Packet ids.

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
];

//function to output the value of requested flag bit
int getBitValue(int canId, int packetId, int byteIndex, int bitIndex) {
  if (packetId <= -1) {
    CANMessage_NoPacketId message =
        messages_No_PacketId.firstWhere((m) => m.canId == canId);

    // find the value of the byte
    int byteValue = message.data[byteIndex];

    // check the value of the requested bit
    int bitValue = byteValue & (1 << bitIndex);

    // return the user requested bit value
    return (bitValue > 0) ? 1 : 0;
  } else {
    // find the message with the given CAN id and packet id
    CANMessage message = messagesByCanId
        .firstWhere((m) => m.canId == canId && m.packetId == packetId);

    // find the value of the byte
    int byteValue = message.data[byteIndex];

    // check the value of the requested bit
    int bitValue = byteValue & (1 << bitIndex);

    // return the user requested bit value
    return (bitValue > 0) ? 1 : 0;
  }
}
