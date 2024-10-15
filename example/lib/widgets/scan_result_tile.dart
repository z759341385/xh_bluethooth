import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:convert/convert.dart';

class ScanResultTile extends StatefulWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription = widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  String getNiceManufacturerDataString(List<List<int>> data) {
    return data.map((val) => '${getNiceHexArray(val)}').join(', ').toUpperCase();
  }

  String getNiceManufacturerData(List<List<int>> data) {
    return data.map((val) => '${getNiceHexArray(val)}').join(', ').toUpperCase();
  }

  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries.map((v) => '${v.key}: ${getNiceHexArray(v.value)}').join(', ').toUpperCase();
  }

  String getNiceServiceUuids(List<Guid> serviceUuids) {
    return serviceUuids.join(', ').toUpperCase();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.platformName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.result.device.platformName,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            widget.result.device.remoteId.str,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    } else {
      return Text(widget.result.device.remoteId.str);
    }
  }

  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      child: isConnected ? const Text('OPEN') : const Text('CONNECT'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      onPressed: (widget.result.advertisementData.connectable) ? widget.onTap : null,
    );
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  List<String> bytesToHex(List<int> bytes) {
    return bytes.map((byte) => '0x' + byte.toRadixString(16).padLeft(4, '0').toUpperCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    var adv = widget.result.advertisementData;
    List haxList = bytesToHex(widget.result.advertisementData.manufacturerData[257]!);
    List haxList2 = bytesToHex(widget.result.advertisementData.manufacturerData[1025]!);
    List haxList4 = bytesToHex([257]);
    List haxList3 = bytesToHex([1025]);
    String haxStr = haxList.toString();
    String haxStr2 = haxList2.toString();
    print("---haxList3: ${haxList3}--->");
    print("---haxList4: ${haxList4}--->");
    print("---长度: ${haxList.length}--->" + haxStr);
    print("---2长度: ${haxList2.length}--->" + haxStr2);
    // print("---msd:${adv.msd[0].length} --->" + adv.msd[0].toString());
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(widget.result.rssi.toString()),
      trailing: _buildConnectButton(context),
      children: <Widget>[
        if (adv.advName.isNotEmpty) _buildAdvRow(context, 'Name', adv.advName),
        // if (adv.txPowerLevel != null) _buildAdvRow(context, 'Tx Power Level', '${adv.txPowerLevel}'),
        // if ((adv.appearance ?? 0) > 0) _buildAdvRow(context, 'Appearance', '0x${adv.appearance!.toRadixString(16)}'),
        // if (adv.msd.isNotEmpty) _buildAdvRow(context, 'Manufacturer Data', getNiceManufacturerDataString(adv.msd)),
        if (adv.msd.isNotEmpty) _buildTimeStr(bytesToHex(widget.result.advertisementData.manufacturerData[1025]!)),
        if (adv.msd.isNotEmpty) _buildHardwareVersion(bytesToHex(widget.result.advertisementData.manufacturerData[1025]!)),
        if (adv.msd.isNotEmpty) _buildBottoleType(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty) getMaskMode(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty) getIsVertical(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty) getIsShaking(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty) getIsOverloading(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty) getUsingFlag(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty) getBottleIndex(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty) getCoordinate(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty)
          _buildCurWeightString(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty)
          _buildDropRateString(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty) _buildVoltageString(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.msd.isNotEmpty)
          _buildMinVoltageString(bytesToHex(widget.result.advertisementData.manufacturerData[257]!)),
        if (adv.serviceUuids.isNotEmpty) _buildAdvRow(context, 'Service UUIDs', getNiceServiceUuids(adv.serviceUuids)),
        if (adv.serviceData.isNotEmpty) _buildAdvRow(context, 'Service Data', getNiceServiceData(adv.serviceData)),
      ],
    );
  }

  ///16进制 --> 2进制
  String hexToBinary(String hex) {
    // 去掉0x前缀，如果存在的话
    if (hex.startsWith("0x")) {
      hex = hex.substring(2);
    }
    // 将16进制数转换为整数
    int decimal = int.parse(hex, radix: 16);
    // 将整数转换为2进制字符串
    String binary = decimal.toRadixString(2);

    return binary;
  }

  ///2进制--> 10进制
  int binaryToDecimal(String binary) {
    // 将二进制数转换为整数
    int decimal = int.parse(binary, radix: 2);

    return decimal;
  }

  ///16进制--> 10进制
  int hexToDecimal(String hex) {
    if (hex.startsWith("0x")) {
      hex = hex.substring(2);
    }
    // 将二进制数转换为整数
    int decimal = int.parse(hex, radix: 16);
    return decimal;
  }

  ///瓶子类型
  _buildBottoleType(List values) {
    String hexStr = values[0];
    String typeCode = hexToBinary(hexStr).substring(6, 8);
    String typeValue = '--';
    switch (typeCode) {
      case '01':
        typeValue = '塑料袋';
        break;
      case '10':
        typeValue = '塑料瓶';
        break;
      case '11':
        typeValue = '玻璃瓶';
        break;
    }
    String startTime = '瓶子类型：${typeValue}';
    return Text(startTime);
  }

  ///遮罩模式
  getMaskMode(List values) {
    String hexStr = values[2];
    String typeCode = hexToBinary(hexStr).padLeft(8, '0').substring(5, 6);
    String statusValue = '--';
    switch (typeCode) {
      //关闭
      case '0':
        statusValue = '关闭';
        break;
      //开启
      case '1':
        statusValue = '开启';
        break;
    }
    String maskStatusStr = '遮罩模式：${statusValue}';
    return Text(maskStatusStr);
  }

  ///是否垂直
  getIsVertical(List values) {
    String hexStr = values[2];
    String typeCode = hexToBinary(hexStr).padLeft(8, '0').substring(6, 7);
    String statusValue = '--';
    switch (typeCode) {
      //关闭
      case '0':
        statusValue = '否';
        break;
      //开启
      case '1':
        statusValue = '是';
        break;
    }
    String maskStatusStr = '是否垂直：${statusValue}';
    return Text(maskStatusStr);
  }

  ///是否晃动
  getIsShaking(List values) {
    String hexStr = values[2];
    String typeCode = hexToBinary(hexStr).padLeft(8, '0').substring(7, 8);
    String statusValue = '--';
    switch (typeCode) {
      //关闭
      case '0':
        statusValue = '否';
        break;
      //开启
      case '1':
        statusValue = '是';
        break;
    }
    String maskStatusStr = '是否晃动：${statusValue}';
    return Text(maskStatusStr);
  }

  ///是否过载
  getIsOverloading(List values) {
    String hexStr = values[2];
    String typeCode = hexToBinary(hexStr).padLeft(8, '0').substring(5, 6);
    String statusValue = '--';
    switch (typeCode) {
      //关闭
      case '0':
        statusValue = '否';
        break;
      //开启
      case '1':
        statusValue = '是';
        break;
    }
    String maskStatusStr = '是否过载：${statusValue}';
    return Text(maskStatusStr);
  }

  ///使用标识
  getUsingFlag(List values) {
    String hexStr = values[2];
    String typeCode = hexToBinary(hexStr).padLeft(8, '0').substring(4, 5);
    String statusValue = '--';
    switch (typeCode) {
      //关闭
      case '0':
        statusValue = '否';
        break;
      //开启
      case '1':
        statusValue = '是';
        break;
    }
    String maskStatusStr = '使用标识：${statusValue}';
    return Text(maskStatusStr);
  }

  ///当前瓶子序号
  getBottleIndex(List values) {
    String hexStr = values[3];
    String typeCode = hexToBinary(hexStr).padLeft(8, '0');
    String statusValue = binaryToDecimal(typeCode).toString();
    String maskStatusStr = '当前瓶子的序号：${statusValue}';
    return Text(maskStatusStr);
  }

  /// 当前称的x坐标值
  getCoordinate(List values) {
    String hexStr = values[4];
    String hexStr2 = values[5];
    String typeCode = hexToBinary(hexStr).padLeft(8, '0') + ',' + hexToBinary(hexStr2).padLeft(8, '0');
    // print('当前称的x坐标值:' + hexStr + '，' + hexStr2);
    String statusValue = typeCode.toString();
    String maskStatusStr = '称的x坐标值：${statusValue}';
    return Text(maskStatusStr);
  }

  ///  当前重量
  _buildCurWeightString(List values) {
    List hexArray = [values[10], values[11], values[12], values[13]];
    // print('重量hex-->${hexArray}');
    // 创建一个长度为 4 字节的字节缓冲区
    ByteData byteData = ByteData(4);
    // 按大端顺序设置字节
    for (int i = 0; i < hexArray.length; i++) {
      byteData.setUint8(i, int.parse(hexArray[i]));
    }
    // 读取缓冲区中的浮点数
    double floatValue = byteData.getFloat32(0, Endian.big);
    String value = '当前重量： ${floatValue}';
    return Text(value);
  }

  ///  滴速
  _buildDropRateString(List values) {
    double decimalValue = 0;
    List hexArray = [values[14], values[15]];
    for (int i = 0; i < hexArray.length; i++) {
      decimalValue = (decimalValue * 256 + int.parse(hexArray[i]));
    }
    String value = '滴速：${decimalValue / 100} ';
    return Text(value);
  }

  ///  电压
  _buildVoltageString(List values) {
    double decimalValue = 0;
    List hexArray = [values[16], values[17]];
    for (int i = 0; i < hexArray.length; i++) {
      decimalValue = (decimalValue * 256 + int.parse(hexArray[i]));
    }
    String value = '电压：${decimalValue / 100}v';
    return Text(value);
  }

  ///  最小电压
  _buildMinVoltageString(List values) {
    double decimalValue = 0;
    List hexArray = [values[18], values[19]];
    for (int i = 0; i < hexArray.length; i++) {
      decimalValue = (decimalValue * 256 + int.parse(hexArray[i]));
    }
    String value = '最小电压：${decimalValue / 100}v ';
    return Text(value);
  }

  ///硬件版本
  _buildHardwareVersion(List values) {
    print(values);
    double decimalValue = 0;
    List hexArray = [ values[3], values[4], values[5]];

    String startTime = '硬件版本：${values[3]}';
    return Text(startTime);
  }

  ///开机时间
  _buildTimeStr(List values) {
    double decimalValue = 0;
    List hexArray = [values[7], values[8], values[9], values[10]];
    for (int i = 0; i < hexArray.length; i++) {
      decimalValue = (decimalValue * 256 + int.parse(hexArray[i]));
    }
    String startTime = '设备已经开机${decimalValue}秒';
    return Text(startTime);
  }

  int _hexToInt(String hex) {
    int val = 0;
    int len = hex.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = hex.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException("Invalid hexadecimal value");
      }
    }
    return val;
  }
}
