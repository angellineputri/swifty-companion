class User {
  final String login;
  final String email;
  final String displayName;
  final String? imageUrl;
  final String? location;
  final int wallet;
  final int correctionPoints;
  final double level;
  final List<Skill> skills;
  final List<Project> projects;

  User({
    required this.login,
    required this.email,
    required this.displayName,
    this.imageUrl,
    this.location,
    required this.wallet,
    required this.correctionPoints,
    required this.level,
    required this.skills,
    required this.projects,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    double level = 0.0;
    List<Skill> skills = [];
    final cursusUsers = json['cursus_users'] as List?;
    if (cursusUsers != null && cursusUsers.isNotEmpty) {
      final cursus = cursusUsers.firstWhere(
        (c) => c['cursus']['slug'] == '42cursus',
        orElse: () => cursusUsers.last,
      );
      level = (cursus['level'] as num).toDouble();
      skills = (cursus['skills'] as List)
          .map((s) => Skill.fromJson(s))
          .toList();
    }

    final projectsUsers = json['projects_users'] as List?;
    List<Project> projects = [];
    if (projectsUsers != null) {
      projects = projectsUsers
          .map((p) => Project.fromJson(p))
          .toList();
    }

    return User(
      login: json['login'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayname'] ?? '',
      imageUrl: json['image']?['link'],
      location: json['location'],
      wallet: json['wallet'] ?? 0,
      correctionPoints: json['correction_point'] ?? 0,
      level: level,
      skills: skills,
      projects: projects,
    );
  }
}

class Skill {
  final String name;
  final double level;

  Skill({required this.name, required this.level});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] ?? '',
      level: (json['level'] as num).toDouble(),
    );
  }
}

class Project {
  final String name;
  final String status;
  final bool validated;
  final int? finalMark;

  Project({
    required this.name,
    required this.status,
    required this.validated,
    this.finalMark,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['project']['name'] ?? '',
      status: json['status'] ?? '',
      validated: json['validated?'] ?? false,
      finalMark: json['final_mark'],
    );
  }
}