import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'service_item.dart';
import 'create_ticket_model.dart';

class DashboardScreen extends StatefulWidget {
  final String tenantId;
  const DashboardScreen({super.key, required this.tenantId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Keep this nullable while allowing the database layer to provide its
  // profile model, even when that model is not exported as `ShopProfile`.
  dynamic _currentProfile;
  List<ServiceItem> _serviceItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTenantData();
  }

  Future<void> _loadTenantData() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper();
    
    // Dynamic Tenant Data Fetching
    final profile = await db.getShopProfile(widget.tenantId);
    final items = await db.getServiceItems(widget.tenantId);

    setState(() {
      _currentProfile = profile;
      _serviceItems = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currency = _currentProfile?.currencySymbol ?? 'MMK';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentProfile?.shopName ?? 'OmniFix POS',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tenant ID: ${widget.tenantId.length > 8 ? widget.tenantId.substring(0, 8) : widget.tenantId}...',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTenantData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repair Status Summary Cards
            Row(
              children: [
                _buildStatusCard('Total Jobs', _serviceItems.length.toString(), Colors.blue),
                const SizedBox(width: 8),
                _buildStatusCard(
                  'Pending',
                  _serviceItems.where((i) => i.status == 'Pending').length.toString(),
                  Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildStatusCard(
                  'Done',
                  _serviceItems.where((i) => i.status == 'Completed').length.toString(),
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Service Tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Ticket ListView
            Expanded(
              child: _serviceItems.isEmpty
                  ? const Center(child: Text('No active repair tickets found.'))
                  : ListView.builder(
                      itemCount: _serviceItems.length,
                      itemBuilder: (context, index) {
                        final item = _serviceItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(item.phoneModel.isNotEmpty ? item.phoneModel[0].toUpperCase() : 'P'),
                            ),title: Text('${item.customerName} - ${item.phoneModel}'),
                            subtitle: Text('${item.issueDescription}\nCost: ${item.estimatedCost} $currency'),
                            trailing: Chip(
                              label: Text(
                                item.status,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: item.status == 'Completed' ? Colors.green : Colors.orange,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => CreateTicketModal(
              tenantId: widget.tenantId,
              onTicketCreated: _loadTenantData,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Service Job'),
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}