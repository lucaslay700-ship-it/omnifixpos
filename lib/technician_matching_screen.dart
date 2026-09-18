import 'package:flutter/material.dart';
import 'technician_skill_model.dart';

class TechnicianMatchingScreen extends StatefulWidget {
  final String ticketIssue; // e.g., "CPU Reballing & Power IC"
  final String phoneModel;

  const TechnicianMatchingScreen({
    super.key,
    this.ticketIssue = "CPU Reballing & Power IC",
    this.phoneModel = "iPhone 13 Pro",
  });

  @override
  State<TechnicianMatchingScreen> createState() => _TechnicianMatchingScreenState();
}

class _TechnicianMatchingScreenState extends State<TechnicianMatchingScreen> {
  bool _isAnalyzing = false;
  List<AssignmentMatchResult> _matchResults = [];

  // Simulated Shop Technicians Database
  final List<TechnicianProfile> _technicians = [
    TechnicianProfile(
      id: "TECH-01",
      name: "Ko Aung (Master Tech)",
      specializations: ["CPU Reballing", "Power IC", "Face ID", "Water Damage"],
      skillLevel: SkillLevel.master,
      currentActiveJobs: 2,
      rating: 4.9,
    ),
    TechnicianProfile(
      id: "TECH-02",
      name: "Kyaw Kyaw (Senior)",
      specializations: ["Display Assembly", "Glass Change", "Battery"],
      skillLevel: SkillLevel.expert,
      currentActiveJobs: 1,
      rating: 4.7,
    ),
    TechnicianProfile(
      id: "TECH-03",
      name: "Zaw Zaw (Junior)",
      specializations: ["Display Assembly", "Speaker", "Charging Flex"],
      skillLevel: SkillLevel.junior,
      currentActiveJobs: 0,
      rating: 4.3,
    ),
    TechnicianProfile(
      id: "TECH-04",
      name: "Mg Mg (Hardware Expert)",
      specializations: ["Motherboard Repair", "CPU Reballing", "Short Finding"],
      skillLevel: SkillLevel.expert,
      currentActiveJobs: 4, // Heavy workload
      rating: 4.8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _runAISkillMatchingEngine();
  }

  // AI Matching Algorithm Logic
  Future<void> _runAISkillMatchingEngine() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    List<AssignmentMatchResult> results = [];
    final issueLower = widget.ticketIssue.toLowerCase();

    for (var tech in _technicians) {
      double score = 50.0; // Base score
      List<String> reasons = [];

      // 1. Specialization Match Check (+30%)
      bool hasDirectSkill = tech.specializations.any((s) => issueLower.contains(s.toLowerCase()));
      if (hasDirectSkill) {
        score += 30;
        reasons.add("Direct skill match found");
      }

      // 2. Skill Level Weighting (+20%)
      if (tech.skillLevel == SkillLevel.master) score += 20;
      if (tech.skillLevel == SkillLevel.expert) score += 15;
      if (tech.skillLevel == SkillLevel.intermediate) score += 10;

      // 3. Workload Balancing Penalty (-10% per active job)
      double workloadPenalty = tech.currentActiveJobs * 8.0;
      score -= workloadPenalty;
      if (tech.currentActiveJobs == 0) {
        reasons.add("Currently free (0 active jobs)");
      } else {
        reasons.add("${tech.currentActiveJobs} active jobs in queue");
      }

      // Clamp Score between 0 and 100
      score = score.clamp(10.0, 99.0);

      results.add(AssignmentMatchResult(
        technician: tech,
        matchScore: score,
        aiReason: reasons.join(" • "),
      ));
    }

    // Sort by Highest AI Match Score
    results.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    setState(() {
      _isAnalyzing = false;
      _matchResults = results;
    });
  }

  void _assignTechnician(AssignmentMatchResult match) {
    setState(() {
      match.technician.currentActiveJobs++;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),SizedBox(width: 8),
            Text('Auto-Assigned Success'),
          ],
        ),
        content: Text(
          'Ticket [${widget.phoneModel} - ${widget.ticketIssue}] ကို ${match.technician.name} ထံ တာဝန်ပေးအပ်လိုက်ပါပြီ။\n\nAI Match Score: ${match.matchScore.toStringAsFixed(1)}%',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 5: AI Technician Skill-Matching'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Target Job Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade50,
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.build, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Device: ${widget.phoneModel}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Issue: ${widget.ticketIssue}',
                        style: const TextStyle(color: Colors.indigo, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Matching Results List
          Expanded(
            child: _isAnalyzing
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.indigo),
                        SizedBox(height: 16),
                        Text('AI Calculating Technician Skill Match & Workload...'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _matchResults.length,
                    itemBuilder: (context, index) {
                      final item = _matchResults[index];
                      final tech = item.technician;
                      final isBestMatch = index == 0;

                      return Card(
                        elevation: isBestMatch ? 4 : 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isBestMatch ? Colors.green : Colors.grey.shade300,
                            width: isBestMatch ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                      Text(
                                        tech.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isBestMatch) ...[
                                        const SizedBox(width: 8),
                                        const Chip(
                                          label: Text('AI BEST MATCH', style: TextStyle(color: Colors.white, fontSize: 9)),
                                          backgroundColor: Colors.green,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    '${item.matchScore.toStringAsFixed(0)}% Match',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isBestMatch ? Colors.green : Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Skills: ${tech.specializations.join(", ")}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('⭐ Rating: ${tech.rating}', style: const TextStyle(fontSize: 12)),
                                  Text(
                                    '📋 Active Jobs: ${tech.currentActiveJobs}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: tech.currentActiveJobs > 3 ? Colors.red : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Text(
                                '💡 AI Analysis: ${item.aiReason}',
                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.indigo),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isBestMatch ? Colors.green : Colors.indigo,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _assignTechnician(item),
                                  icon: const Icon(Icons.person_add),
                                  label: Text('Assign to ${tech.name}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}