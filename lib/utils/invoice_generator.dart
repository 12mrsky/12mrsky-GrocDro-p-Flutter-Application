import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// 🔥 AMAZON / FLIPKART STYLE INVOICE GENERATOR
/// ❌ No cart / order logic changed
/// ✅ Generates downloadable PDF invoice

class InvoiceGenerator {
  static Future<File> generate({
    required Map<String, dynamic> order,
    required List<Map<String, dynamic>> items,
    required Map<String, String> address,
  }) async {
    final pdf = pw.Document();

    final date = DateFormat("dd MMM yyyy")
        .format(DateTime.parse(order['created_at']));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              /// 🧾 HEADER
              pw.Text(
                "GrocDrop Invoice",
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text("Order ID: ${order['id']}"),
              pw.Text("Order Date: $date"),

              pw.Divider(height: 30),

              /// 🏠 ADDRESS
              pw.Text(
                "Delivery Address",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(address['title'] ?? ''),
              pw.Text(address['address'] ?? ''),

              pw.Divider(height: 30),

              /// 📦 ITEMS TABLE
              pw.Text(
                "Order Items",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  _tableHeader(),
                  ...items.map(_tableRow),
                ],
              ),

              pw.SizedBox(height: 20),

              /// 💰 TOTALS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _totalRow("Subtotal", order['subtotal']),
                      _totalRow("Delivery", order['delivery_fee']),
                      _totalRow("Savings", -order['savings']),
                      pw.Divider(),
                      _totalRow(
                        "Total",
                        order['total_amount'],
                        bold: true,
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              /// ✅ FOOTER
              pw.Center(
                child: pw.Text(
                  "Thank you for shopping with GrocDrop!",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/invoice_${order['id']}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ---------------- HELPERS ----------------

  static pw.TableRow _tableHeader() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
      ),
      children: [
        _cell("Item"),
        _cell("Price"),
        _cell("Qty"),
        _cell("Total"),
      ],
    );
  }

  static pw.TableRow _tableRow(Map<String, dynamic> item) {
    return pw.TableRow(
      children: [
        _cell(item['name']),
        _cell("₹${item['price']}"),
        _cell(item['quantity'].toString()),
        _cell("₹${item['price'] * item['quantity']}"),
      ],
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 11),
      ),
    );
  }

  static pw.Widget _totalRow(
    String label,
    int value, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight:
                  bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value >= 0 ? "₹$value" : "-₹${value.abs()}",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight:
                  bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
