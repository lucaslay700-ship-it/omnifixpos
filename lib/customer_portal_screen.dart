import 'package:flutter/material.dart';
import 'customer_portal_model.dart';

class CustomerPortalScreen extends StatefulWidget {
  const CustomerPortalScreen({super.key});

  @override
  State<CustomerPortalScreen> createState() => _CustomerPortalScreenState();
}

class _CustomerPortalScreenState extends State<CustomerPortalScreen> {
  final TextEditingController _chatController = TextEditingController();

  // Simulated Active Customer Ticket (Privacy View Enabled)
  final CustomerPortalTicket _activeTicket = CustomerPortalTicket(
    ticketId: "TCK-2026-8821",
    customerName: "Ko Aung Myo",
    customerPhone: "09450000000",
    deviceModel: "Xiaomi Redmi Note 10 Pro",
    serialOrIMEI: "864201059281726",
    currentStage: RepairStage.partsAwaitingApproval,
    internalPartCost: 35000.0, // Hidden from Customer
    internalLaborCharge: 15000.0, // Hidden from Customer
    totalEstimatedRepairFeeMMK: 50000.0, 
    aiGeneratedExplanation:
        "AI Diagnostic Check: Battery degradation detected along with PMI632 Power IC heating. Micro-soldering and battery replacement required for optimal stability.",
    chatHistory: [
      CustomerChatMessage(
        messageId: "MSG-1",
        sender: ChatMessageSender.aiBot,
        text: "မင်္ဂလာပါ Ko Aung Myo။ လူကြီးမင်း၏ Redmi Note 10 Pro ဖုန်းအား ဆိုင်မှ လက်ခံရရှိပြီး AI မှ စစ်ဆေးမှု ပြုလုပ်ပြီးပါပြီ။",
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
  );

  void _handleCustomerMessageSubmit(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _activeTicket.chatHistory.add(
        CustomerChatMessage(
          messageId: "MSG-${DateTime.now().millisecondsSinceEpoch}",
          sender: ChatMessageSender.customer,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
    });

    _chatController.clear();

    // AI Dynamic Auto-Response Logic
    Future.delayed(const Duration(milliseconds: 1200), () {
      String aiReply = "လူကြီးမင်း၏ ဖုန်းပြင်ဆင်မှုမှာ လက်ရှိတွင် အပိုပစ္စည်းလဲလှယ်ရန် အတည်ပြုချက် စောင့်ဆိုင်းနေပါသည် [Estimated Fee: ${_activeTicket.totalEstimatedRepairFeeMMK.toStringAsFixed(0)} MMK]။";
      
      if (text.contains("ဘယ်တော့ရမလဲ") || text.contains("ကြာမလား")) {
        aiReply = "ပြုပြင်စရိတ် အတည်ပြုပြီးပါက နာရီပိုင်းအတွင်း QC စစ်ဆေးပြီး ဖုန်းလာရောက်ထုတ်ယူနိုင်ပါမည်။";
      } else if (text.contains("စျေး") || text.contains("ကုန်မလဲ")) {
        aiReply = "စုစုပေါင်း ပြုပြင်စရိတ်နှင့် ဝန်ဆောင်ခမှာ ${_activeTicket.totalEstimatedRepairFeeMMK.toStringAsFixed(0)} MMK ကျသင့်ပါမည်။";
      }

      setState(() {
        _activeTicket.chatHistory.add(
          CustomerChatMessage(
            messageId: "MSG-AI-${DateTime.now().millisecondsSinceEpoch}",
            sender: ChatMessageSender.aiBot,
            text: aiReply,
            timestamp: DateTime.now(),
          ),
        );
      });
    });
  }

  void _approveRepairEstimate() {
    setState(() {
      _activeTicket.isEstimateApprovedByCustomer = true;
      _activeTicket.currentStage = RepairStage.repairInProcess;
      _activeTicket.chatHistory.add(
        CustomerChatMessage(
          messageId: "MSG-SYS-${DateTime.now().millisecondsSinceEpoch}",
          sender: ChatMessageSender.aiBot,
          text: "✅ ပြုပြင်စရိတ် အတည်ပြုချက် ရရှိပါသည်။ နည်းပညာရှင်မှ စတင်ပြင်ဆင်ပေးနေပါပြီ။",
          timestamp: DateTime.now(),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Estimate Approved! Ticket moved to Repair Queue.'), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
        title: Text('Customer Live Portal - Ticket: ${_activeTicket.ticketId}'),
        backgroundColor: Colors.teal.shade900,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Left Side: Live Progress Tracker & Privacy Invoice Card
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey.shade50,
              child: ListView(
                children: [
                  // Device & Customer Summary Header
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.phone_android, color: Colors.white)),
                      title: Text(_activeTicket.deviceModel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text('Owner: ${_activeTicket.customerName} | IMEI: ${_activeTicket.serialOrIMEI}'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Real-Time Repair Stage Progress Bar
                  const Text('📊 Live Repair Status Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  _buildProgressTimeline(),
                  const SizedBox(height: 20),

                  // Privacy View Invoice Card (Total Fee Only)
                  Card(
                    color: Colors.teal.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade200)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('🧾 ESTIMATED SERVICE INVOICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal)),
                              Chip(label: Text('Privacy Safe View', style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.teal),
                            ],
                          ),
                          const Divider(),
                          Text(_activeTicket.aiGeneratedExplanation, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Estimated Repair Fee:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(
                                '${_activeTicket.totalEstimatedRepairFeeMMK.toStringAsFixed(0)} MMK',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepOrange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (!_activeTicket.isEstimateApprovedByCustomer)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),onPressed: _approveRepairEstimate,
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Approve Repair & Start Service'),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(6)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified, color: Colors.green, size: 18),
                                  SizedBox(width: 6),
                                  Text('Repair Estimate Approved by Customer', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side: AI Multi-Channel Autonomous Messenger Bot
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.teal.shade800,
                    child: const Row(
                      children: [
                        Icon(Icons.smart_toy, color: Colors.white),
                        SizedBox(width: 8),
                        Text('AI Automated Support Bot (Viber / Messenger)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _activeTicket.chatHistory.length,
                      itemBuilder: (context, index) {
                        final msg = _activeTicket.chatHistory[index];
                        bool isCustomer = msg.sender == ChatMessageSender.customer;

                        return Align(
                          alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isCustomer ? Colors.teal.shade700 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.text,
                                  style: TextStyle(color: isCustomer ? Colors.white : Colors.black87, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(color: isCustomer ? Colors.white70 : Colors.grey, fontSize: 9),),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: const InputDecoration(
                              hintText: "Type message to AI Bot (e.g. ဘယ်လောက်ကျမလဲ)...",
                              border: InputBorder.none,
                            ),
                            onSubmitted: _handleCustomerMessageSubmit,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.teal),
                          onPressed: () => _handleCustomerMessageSubmit(_chatController.text),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline() {
    List<RepairStage> stages = RepairStage.values;
    int currentIndex = stages.indexOf(_activeTicket.currentStage);

    return Row(
      children: stages.map((stage) {
        int stageIndex = stages.indexOf(stage);
        bool isPassed = stageIndex <= currentIndex;

        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isPassed ? Colors.teal : Colors.grey.shade300,
                child: Icon(isPassed ? Icons.check : Icons.circle, size: 14, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                stage.name.replaceAll("partsAwaitingApproval", "Approval Needed"),
                style: TextStyle(
                  fontSize: 9,
                  color: isPassed ? Colors.teal.shade900 : Colors.grey,
                  fontWeight: isPassed ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}