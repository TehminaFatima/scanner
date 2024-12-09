import 'dart:io';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../utils/excel_helper.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<Map<String, dynamic>> scannedItems = [];
  String? savedExcelPath;

  Future<void> scanCode() async {
    var result = await BarcodeScanner.scan();
    if (result.rawContent.isNotEmpty) {
      setState(() {
        scannedItems.add({
          "code": result.rawContent,
          "itemName": "Item ${scannedItems.length + 1}",
          "price": 10.0, // Example price
        });
      });
    }
  }

  Future<void> saveDataToExcel() async {
    savedExcelPath = await ExcelHelper.saveToExcel(scannedItems);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved to $savedExcelPath')),
    );
  }

  Future<void> openExcelFile() async {
    if (savedExcelPath != null && File(savedExcelPath!).existsSync()) {
      await OpenFilex.open(savedExcelPath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No saved Excel file found!')),
      );
    }
  }

  Future<void> printItems() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Scanned Items',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Code', 'Item Name', 'Price'],
              data: scannedItems
                  .map(
                      (item) => [item['code'], item['itemName'], item['price']])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Price: \$${scannedItems.fold<int>(0, (sum, item) => sum + item['price'] as int)}',
              style: pw.TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scanner"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: scanCode,
            child: Text("Scan Barcode/QR Code"),
          ),
          ElevatedButton(
            onPressed: saveDataToExcel,
            child: Text("Save to Excel"),
          ),
          ElevatedButton(
            onPressed: openExcelFile,
            child: Text("Open Excel File"),
          ),
          ElevatedButton(
            onPressed: printItems,
            child: Text("Print Items"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scannedItems.length,
              itemBuilder: (context, index) {
                final item = scannedItems[index];
                return ListTile(
                  title: Text(item['itemName']),
                  subtitle: Text("Code: ${item['code']}"),
                  trailing: Text("\$${item['price']}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
