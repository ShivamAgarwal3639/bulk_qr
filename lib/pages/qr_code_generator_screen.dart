import 'package:all_test/widget/form_fields.dart';
import 'package:all_test/service/pdf_service.dart';
import 'package:all_test/models/query_param.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGeneratorScreen extends StatefulWidget {
  const QRCodeGeneratorScreen({Key? key}) : super(key: key);

  @override
  _QRCodeGeneratorScreenState createState() => _QRCodeGeneratorScreenState();
}

class _QRCodeGeneratorScreenState extends State<QRCodeGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final PDFService _pdfService = PDFService();

  String baseUrl = 'https://tipsybullwhitefield.web.app';
  int numberOfTables = 10;
  double qrSize = 120.0;
  int qrPerRow = 2;
  double qrSpacing = 20.0;
  bool isGenerating = false;
  double topMargin = 20.0;
  double bottomMargin = 20.0;
  double leftMargin = 20.0;
  double rightMargin = 20.0;
  Color qrColor = Colors.black;
  String bottomText = '';
  bool includeTableNumber = false;
  List<QueryParam> queryParams = [QueryParam()];

  List<bool> _isExpanded = List.generate(5, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePDF,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isExpanded[index] = !isExpanded;
                  });
                },
                children: [
                  _buildExpansionPanel(
                    0,
                    'Basic Settings',
                    _buildBasicSettings(),
                  ),
                  _buildExpansionPanel(
                    1,
                    'QR Code Settings',
                    _buildQRCodeSettings(),
                  ),
                  _buildExpansionPanel(
                    2,
                    'Margin Settings',
                    _buildMarginSettings(),
                  ),
                  _buildExpansionPanel(
                    3,
                    'Appearance Settings',
                    _buildAppearanceSettings(),
                  ),
                  _buildExpansionPanel(
                    4,
                    'Query Parameters',
                    _buildQueryParametersSettings(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generateQRCodes,
                child: const Text('Generate QR Codes'),
              ),
              if (isGenerating)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!isGenerating && numberOfTables > 0)
                SizedBox(
                  height: 300,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: qrPerRow,
                      childAspectRatio: 1,
                      crossAxisSpacing: qrSpacing,
                      mainAxisSpacing: qrSpacing,
                    ),
                    itemCount: numberOfTables,
                    itemBuilder: (context, index) {
                      final tableNumber = index + 1;
                      final url = _buildUrl(tableNumber);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QrImageView(
                            data: url,
                            version: QrVersions.auto,
                            size: qrSize,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square, color: qrColor),
                            dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: qrColor),
                          ),
                          const SizedBox(height: 4),
                          Text(includeTableNumber
                              ? '$bottomText$tableNumber'
                              : bottomText),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  ExpansionPanel _buildExpansionPanel(int index, String title, Widget content) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(title),
          onTap: () {
            setState(() {
              _isExpanded[index] = !_isExpanded[index];
            });
          },
        );
      },
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
      isExpanded: _isExpanded[index],
    );
  }

  Widget _buildBasicSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormFieldWithLabel(
          label: 'Base URL',
          initialValue: baseUrl,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a base URL';
            }
            return null;
          },
          onSaved: (value) => baseUrl = value!,
        ),
        const SizedBox(height: 16),
        NumberFormFieldWithLabel(
          label: 'Number of Tables (max 500)',
          initialValue: numberOfTables.toDouble(),
          validator: (value) {
            if (value == null || value <= 0 || value > 500) {
              return 'Please enter a valid number between 1 and 500';
            }
            return null;
          },
          onSaved: (value) => numberOfTables = value!.toInt(),
        ),
      ],
    );
  }

  Widget _buildQRCodeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumberFormFieldWithLabel(
          label: 'QR Codes per Row',
          initialValue: qrPerRow.toDouble(),
          validator: (value) {
            if (value == null || value <= 0) {
              return 'Please enter a valid number greater than 0';
            }
            return null;
          },
          onSaved: (value) => qrPerRow = value!.toInt(),
        ),
        const SizedBox(height: 16),
        NumberFormFieldWithLabel(
          label: 'QR Code Spacing',
          initialValue: qrSpacing,
          validator: (value) {
            if (value == null || value < 0) {
              return 'Please enter a valid number greater than or equal to 0';
            }
            return null;
          },
          onSaved: (value) => qrSpacing = value!,
        ),
        const SizedBox(height: 16),
        NumberFormFieldWithLabel(
          label: 'QR Code Size',
          initialValue: qrSize,
          validator: (value) {
            if (value == null || value <= 0) {
              return 'Please enter a valid number greater than 0';
            }
            return null;
          },
          onSaved: (value) => qrSize = value!,
        ),
      ],
    );
  }

  Widget _buildMarginSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: NumberFormFieldWithLabel(
                label: 'Top Margin',
                initialValue: topMargin,
                onSaved: (value) => topMargin = value!,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: NumberFormFieldWithLabel(
                label: 'Bottom Margin',
                initialValue: bottomMargin,
                onSaved: (value) => bottomMargin = value!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: NumberFormFieldWithLabel(
                label: 'Left Margin',
                initialValue: leftMargin,
                onSaved: (value) => leftMargin = value!,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: NumberFormFieldWithLabel(
                label: 'Right Margin',
                initialValue: rightMargin,
                onSaved: (value) => rightMargin = value!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickColor,
              child: const Text('Pick QR Color'),
            ),
            const SizedBox(width: 16),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: qrColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormFieldWithLabel(
          label: 'Bottom Text',
          onChanged: (value) => setState(() => bottomText = value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: includeTableNumber,
              onChanged: (value) {
                setState(() {
                  includeTableNumber = value!;
                });
              },
            ),
            const Text('Include Table Number in Bottom Text'),
          ],
        ),
      ],
    );
  }

  Widget _buildQueryParametersSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "if you keep the value field empty it will automatically fill it with the table number 1 to (number provided)",
        ),
        const SizedBox(
          height: 12,
        ),
        ..._buildQueryParamFields(),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            setState(() {
              queryParams.add(QueryParam());
            });
          },
          child: const Text('Add Query Parameter'),
        ),
      ],
    );
  }

  List<Widget> _buildQueryParamFields() {
    return queryParams.asMap().entries.map((entry) {
      int idx = entry.key;
      QueryParam param = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormFieldWithLabel(
                label: 'Query Param Name ${idx + 1}',
                onChanged: (value) => param.name = value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormFieldWithLabel(
                label: 'Query Param Value ${idx + 1}',
                onChanged: (value) => param.value = value,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  queryParams.removeAt(idx);
                });
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  String _buildUrl(int tableNumber) {
    String url = baseUrl;
    bool isFirstParam = true;
    for (var param in queryParams) {
      if (param.name.isNotEmpty) {
        url += isFirstParam ? '?' : '&';
        url += '${param.name}=';
        url += param.value.isNotEmpty ? param.value : tableNumber.toString();
        isFirstParam = false;
      }
    }
    return url;
  }

  void _generateQRCodes() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isGenerating = true;
      });
      // Simulate a delay to show loading indicator
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          isGenerating = false;
        });
      });
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: qrColor,
              onColorChanged: (Color color) {
                setState(() => qrColor = color);
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generatePDF() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      isGenerating = true;
    });

    try {
      await _pdfService.generatePDF(
        baseUrl: baseUrl,
        numberOfTables: numberOfTables,
        qrSize: qrSize,
        qrPerRow: qrPerRow,
        qrSpacing: qrSpacing,
        topMargin: topMargin,
        bottomMargin: bottomMargin,
        leftMargin: leftMargin,
        rightMargin: rightMargin,
        qrColor: qrColor,
        bottomText: bottomText,
        includeTableNumber: includeTableNumber,
        queryParams: queryParams,
        buildUrl: _buildUrl,
      );

      setState(() {
        isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated and shared successfully')),
      );
    } catch (e) {
      setState(() {
        isGenerating = false;
      });
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }
}
