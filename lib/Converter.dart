import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertest/HistoryPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Converter extends StatefulWidget {
  final String userEmail;
  final String userId;

  const Converter({Key? key, required this.userEmail, required this.userId})
      : super(key: key);

  @override
  State<Converter> createState() => _ConverterState();
}

class _ConverterState extends State<Converter> {
  List<String> currencies = ['USD'];
  String selectedCurrency1 = 'USD';
  String selectedCurrency2 = 'USD';
  double exchangeRate = 1.0;
  double amount = 0.0;
  final String appId = 'bccbefbec6c2496f81a608e5e120da79';

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    try {
      final currencyResponse = await http.get(Uri.parse(
          'https://openexchangerates.org/api/currencies.json?app_id=$appId'));

      if (currencyResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(currencyResponse.body);
        List<String> fetchedCurrencies = data.keys.toList();
        setState(() {
          currencies = fetchedCurrencies;
          selectedCurrency1 = fetchedCurrencies.first;
          selectedCurrency2 = fetchedCurrencies.first;
        });
      } else {
        throw Exception('Failed to fetch currencies');
      }

      await fetchExchangeRate();
    } catch (error) {
      print('Error fetching currencies: $error');
    }
  }

  Future<void> fetchExchangeRate() async {
    try {
      final exchangeRateResponse = await http.get(Uri.parse(
          'https://openexchangerates.org/api/latest.json?app_id=$appId'));

      if (exchangeRateResponse.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(exchangeRateResponse.body);
        if (selectedCurrency1 == selectedCurrency2) {
          setState(() {
            exchangeRate = 1.0;
          });
        } else {
          double rate = data['rates'][selectedCurrency2];
          setState(() {
            exchangeRate = rate;
          });
        }
      } else {
        throw Exception('Failed to fetch exchange rates');
      }
    } catch (error) {
      print('Error fetching exchange rates: $error');
    }
  }

  void onCurrency1Changed(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedCurrency1 = newValue;
      });
      fetchExchangeRate();
    }
  }

  void onCurrency2Changed(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedCurrency2 = newValue;
      });
      fetchExchangeRate();
    }
  }

  void onAmountChanged(String value) {
    setState(() {
      amount = double.tryParse(value) ?? 0.0;
    });

    // Store converted amount whenever amount is changed
    storeConvertedAmount(amount, selectedCurrency1, calculateConvertedAmount(),
        selectedCurrency2);
  }

  double calculateConvertedAmount() {
    return amount * exchangeRate;
  }

  void storeConvertedAmount(double originalAmount, String originalCurrency,
      double convertedAmount, String convertedCurrency) {
    FirebaseFirestore.instance
        .collection('ConvertedAmounts')
        .doc(widget.userId)
        .collection('Conversions') // Create a subcollection
        .add({
      'UserEmail': widget.userEmail,
      'OriginalAmount': originalAmount,
      'OriginalCurrency': originalCurrency,
      'ConvertedAmount': convertedAmount,
      'ConvertedCurrency': convertedCurrency,
      'Timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      print("Converted amount stored successfully!");
    }).catchError((error) {
      print("Failed to store converted amount: $error");
    });
  }

  void swapFields() {
    setState(() {
      String tempCurrency = selectedCurrency1;
      selectedCurrency1 = selectedCurrency2;
      selectedCurrency2 = tempCurrency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            const Text("Currency Converter",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    shadows: [
                      Shadow(
                        color: Colors.white,
                        offset: Offset(2, 2),
                        blurRadius: 3,
                      ),
                    ])),
            const Text(
              "We Are Here To Serve You",
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              color: const Color.fromARGB(255, 243, 243, 243),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 0, 100.0, 0),
                          child: SizedBox(
                            width: 50,
                            child: DropdownButton<String>(
                              value: selectedCurrency1,
                              onChanged: onCurrency1Changed,
                              items: currencies.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: onAmountChanged,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color.fromARGB(255, 226, 226, 226),
                              hintText: 'Enter Your Amount',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: swapFields,
                    icon: Icon(Icons.swap_vert),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              color: const Color.fromARGB(255, 243, 243, 243),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 0, 100.0, 0),
                          child: SizedBox(
                            width: 50,
                            child: DropdownButton<String>(
                              value: selectedCurrency2,
                              onChanged: onCurrency2Changed,
                              items: currencies.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: false,
                            controller: TextEditingController(
                                text: calculateConvertedAmount()
                                    .toStringAsFixed(2)),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color.fromARGB(255, 226, 226, 226),
                              hintText: 'Converted Amount',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryPage(
                              userEmail: widget.userEmail,
                              userId: widget.userId),
                        ),
                      );
                    },
                    child: Text("View History"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
