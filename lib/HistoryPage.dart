import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final String userEmail;
  final String userId;

  const HistoryPage({Key? key, required this.userEmail, required this.userId})
      : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('ConvertedAmounts')
        .doc(widget.userId)
        .collection('Conversions')
        .orderBy('Timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion History'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'History for ${widget.userEmail}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      DateTime timestamp = data['Timestamp'].toDate();
                      String formattedDate =
                          DateFormat.yMMMd().format(timestamp);
                      String formattedTime = DateFormat.jm().format(timestamp);
                      return ConversionTile(
                        originalAmount: data['OriginalAmount'].toString(),
                        originalCurrency: data['OriginalCurrency'],
                        convertedAmount: data['ConvertedAmount'].toString(),
                        convertedCurrency: data['ConvertedCurrency'],
                        formattedDate: formattedDate,
                        formattedTime: formattedTime,
                        onDelete: () async {
                          await deleteConversion(widget.userId, doc.id);
                          setState(() {});
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteConversion(String userId, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('ConvertedAmounts')
          .doc(userId)
          .collection('Conversions')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversion deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete conversion: $error')),
      );
    }
  }
}

class ConversionTile extends StatefulWidget {
  final String originalAmount;
  final String originalCurrency;
  final String convertedAmount;
  final String convertedCurrency;
  final String formattedDate;
  final String formattedTime;
  final VoidCallback onDelete;

  const ConversionTile({
    Key? key,
    required this.originalAmount,
    required this.originalCurrency,
    required this.convertedAmount,
    required this.convertedCurrency,
    required this.formattedDate,
    required this.formattedTime,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ConversionTileState createState() => _ConversionTileState();
}

class _ConversionTileState extends State<ConversionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return SlideTransition(
          position: _offsetAnimation,
          child: Opacity(
            opacity: 1 - _controller.value,
            child: buildTile(),
          ),
        );
      },
    );
  }

  Widget buildTile() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.originalAmount} ${widget.originalCurrency} = ${widget.convertedAmount} ${widget.convertedCurrency}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () {
                    _controller.forward().then((value) {
                      widget.onDelete();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.formattedDate} at ${widget.formattedTime}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
