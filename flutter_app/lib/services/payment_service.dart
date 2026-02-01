import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  final String clientId = "DEIN_PAYPAL_CLIENT_ID";
  final String secret = "DEIN_PAYPAL_SECRET";
  final String paypalApi = "https://api.sandbox.paypal.com"; // Für Tests

  Future<String?> getAccessToken() async {
    final response = await http.post(
      Uri.parse('$paypalApi/v1/oauth2/token'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      print("PayPal Auth-Fehler: ${response.body}");
      return null;
    }
  }

  Future<void> createPayment(double amount, String currency) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return;

    final response = await http.post(
      Uri.parse('$paypalApi/v1/payments/payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "intent": "sale",
        "payer": {"payment_method": "paypal"},
        "transactions": [
          {
            "amount": {"total": amount.toStringAsFixed(2), "currency": currency},
            "description": "MukkeApp Zahlung"
          }
        ],
        "redirect_urls": {
          "return_url": "https://example.com/success",
          "cancel_url": "https://example.com/cancel"
        }
      }),
    );

    if (response.statusCode == 201) {
      print("Zahlung erstellt: ${response.body}");
    } else {
      print("Zahlung fehlgeschlagen: ${response.body}");
    }
  }
}
