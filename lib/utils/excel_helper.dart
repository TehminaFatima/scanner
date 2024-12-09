import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelHelper {
  static Future<String> saveToExcel(List<Map<String, dynamic>> items) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add header
    sheetObject.appendRow(['Code', 'Item Name', 'Price']);

    // Add data rows
    for (var item in items) {
      sheetObject.appendRow([item['code'], item['itemName'], item['price']]);
    }

    // Save file to device
    var directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/scanned_data.xlsx';
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.save()!);

    return filePath; // Return the saved file path
  }
}
