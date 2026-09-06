import 'package:flutter/material.dart';
import '../state/app_store.dart';

class CarpentryOrdersScreen extends StatelessWidget {
  const CarpentryOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('سجل الطلبات المتزامنة')),
      body: Builder(
        builder: (context) {
          if (store.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => store.refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('لا توجد طلبات مسجلة حالياً')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => store.refresh(),
            child: ListView.builder(
              itemCount: store.orders.length,
              itemBuilder: (context, index) {
                final order = store.orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.carpenter, color: Colors.brown),
                    title: Text(order.name),
                    subtitle: Text('الخامة: ${order.material} | المقاس: ${order.length}x${order.width}'),
                    trailing: Chip(
                      label: Text(order.status),
                      backgroundColor: Colors.blueGrey.shade50,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}