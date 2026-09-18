enum SkillLevel { junior, intermediate, expert, master }

class TechnicianProfile {
  final String id;
  final String name;
  final List<String> specializations; // e.g., ["CPU Reballing", "Display", "Glass"]
  final SkillLevel skillLevel;
  int currentActiveJobs;
  final double rating;

  TechnicianProfile({
    required this.id,
    required this.name,
    required this.specializations,
    required this.skillLevel,
    required this.currentActiveJobs,
    required this.rating,
  });
}

class AssignmentMatchResult {
  final TechnicianProfile technician;
  final double matchScore; // 0 to 100%
  final String aiReason;

  AssignmentMatchResult({
    required this.technician,
    required this.matchScore,
    required this.aiReason,
  });
}