import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterScreen extends StatelessWidget {
  final DateTime setDate;

  const FilterScreen({Key? key, required this.setDate}) : super(key: key);
  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Filtered Data'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('logs')
            .where('datetime', isGreaterThanOrEqualTo: setDate)
            .where('datetime', isLessThan: setDate.add(Duration(days: 1)))
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('For the chosen date, there are no available data.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Client UID: ${data['client_uid']}'),
                subtitle: Text('Date: ${_formatDateTime(data['datetime'] as Timestamp)}'),
              );
            },
          );
        },
      ),
    );
  }


}
