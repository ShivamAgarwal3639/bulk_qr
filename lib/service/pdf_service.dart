import 'dart:io';
import 'package:all_test/models/query_param.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PDFService {
  Future<void> generatePDF({
    required String baseUrl,
    required int numberOfTables,
    required double qrSize,
    required int qrPerRow,
    required double qrSpacing,
    required double topMargin,
    required double bottomMargin,
    required double leftMargin,
    required double rightMargin,
    required Color qrColor,
    required String bottomText,
    required bool includeTableNumber,
    required List<QueryParam> queryParams,
    required String Function(int) buildUrl,
  }) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4.copyWith(
      marginTop: topMargin,
      marginBottom: bottomMargin,
      marginLeft: leftMargin,
      marginRight: rightMargin,
    );

    final availableWidth = pageFormat.availableWidth;
    final availableHeight = pageFormat.availableHeight;

    final qrSizePdf = (availableWidth - (qrPerRow - 1) * qrSpacing) / qrPerRow;
    final qrPerColumn = (availableHeight / (qrSizePdf + qrSpacing)).floor();
    final itemsPerPage = qrPerRow * qrPerColumn;

    for (var i = 0; i < numberOfTables; i += itemsPerPage) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: List.generate(qrPerColumn, (row) {
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: List.generate(qrPerRow, (col) {
                      final index = i + row * qrPerRow + col;
                      if (index >= numberOfTables) return pw.Container();
                      final tableNumber = index + 1;
                      final url = buildUrl(tableNumber);
                      return pw.Padding(
                        padding: pw.EdgeInsets.all(qrSpacing / 2),
                        child: pw.Column(
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: url,
                              width: qrSizePdf,
                              height: qrSizePdf,
                              color: PdfColor.fromInt(qrColor.value),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(includeTableNumber
                                ? '$bottomText$tableNumber'
                                : bottomText),
                          ],
                        ),
                      );
                    }),
                  );
                }),
              ),
            );
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/qr_codes.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'QR Codes PDF');
  }
}