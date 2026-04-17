import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showAllProjects = false;
  bool _showFullScore = false;

  Color get coalitionAccentColor {
    if (widget.user.coalition == null) return AppColors.pink;
    final name = widget.user.coalition!.name.toLowerCase();
    if (name.contains('arrakis')) return AppColors.arrakisAccent;
    if (name.contains('coruscant')) return AppColors.coruscantAccent;
    if (name.contains('asgard')) return AppColors.asgardAccent;
    // fallback for other campuses
    try {
      final hex = widget.user.coalition!.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppColors.pink;
    }
  }

  Color get coalitionBgColor {
    if (widget.user.coalition == null) return const Color(0xFF1A0F14);
    final name = widget.user.coalition!.name.toLowerCase();
    if (name.contains('arrakis')) return AppColors.arrakisBg;
    if (name.contains('coruscant')) return AppColors.coruscantBg;
    if (name.contains('asgard')) return AppColors.asgardBg;
    // fallback for other campuses
    try {
      final hex = widget.user.coalition!.color.replaceAll('#', '');
      final base = Color(int.parse('FF$hex', radix: 16));
      return Color.fromRGBO(
        (base.red * 0.2).round(),
        (base.green * 0.2).round(),
        (base.blue * 0.2).round(),
        1,
      );
    } catch (e) {
      return const Color(0xFF1A0F14);
    }
  }

  String _formatScore(int score) {
    if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}k';
    }
    return '$score';
  }

  @override
  Widget build(BuildContext context) {
    final color = coalitionAccentColor;
    final bgColor = coalitionBgColor;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(context, color, bgColor),
            _buildInfo(color),
            _buildLevelBar(color),
            _buildStats(color),
            _buildProjects(color),
            _buildSkills(color),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, Color color, Color bgColor) {
    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 44),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: color, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
          Row(
            children: [
              Text(
                '42 Network',
                style: TextStyle(
                  color: color.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              if (widget.user.location != null &&
                  widget.user.location!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 0.5,
                    ),
                  ),
                  child: Text(
                    widget.user.location!,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Transform.translate(
            offset: const Offset(0, -28),
            child: _buildAvatar(color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.displayName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.user.login,
                    style: TextStyle(color: color, fontSize: 14),
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      color: AppColors.textHint, fontSize: 12,
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

  Widget _buildAvatar(Color color) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: AppColors.surface,
      ),
      child: ClipOval(
        child: widget.user.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.user.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _avatarFallback(color),
                errorWidget: (context, url, error) => _avatarFallback(color),
              )
            : _avatarFallback(color),
      ),
    );
  }

  Widget _avatarFallback(Color color) {
    return Center(
      child: Text(
        widget.user.login[0].toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 26,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLevelBar(Color color) {
    final levelInt = widget.user.level.floor();
    final levelPct = widget.user.level - levelInt;
    final pctDisplay =
        (levelPct * 100).toStringAsFixed(0).padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LEVEL',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  levelInt.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: color,
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = constraints.maxWidth;
                        final pctOffset = barWidth * levelPct;
                        return SizedBox(
                          height: 20,
                          child: Stack(
                            children: [
                              Positioned(
                                left: (pctOffset - 16)
                                    .clamp(0, barWidth - 32),
                                child: Text(
                                  '$pctDisplay%',
                                  style: TextStyle(
                                    color: color, fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: levelPct,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '/ 21',
                        style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.surfaceLight, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildStats(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              _buildStat('wallet', '${widget.user.wallet}₳', color),
              _buildStat('rank', widget.user.rank ?? '-', color),
              _buildStat('score',
                _showFullScore ? '${widget.user.score}' : _formatScore(widget.user.score),
                color,
                onTap: () => setState(() => _showFullScore = !_showFullScore),
              ),
              _buildStat('ev.p', '${widget.user.correctionPoints}', color),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.surfaceLight, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textHint, fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkills(Color color) {
    if (widget.user.skills.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SKILLS',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ...widget.user.skills.map((skill) => _buildSkillRow(skill, color)),
          const SizedBox(height: 8),
          Divider(color: AppColors.surfaceLight, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildSkillRow(Skill skill, Color color) {
    final maxLevel = 21.0;
    final pct = (skill.level / maxLevel).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              skill.name,
              style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              '${skill.level.toStringAsFixed(2)} · ${(pct * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.textHint, fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjects(Color color) {
    final allProjects = widget.user.projects
        .where((p) => p.cursusIds.contains(21) && p.status != 'parent')
        .toList();

    if (allProjects.isEmpty) return const SizedBox();

    final displayed =
        _showAllProjects ? allProjects : allProjects.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROJECTS',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ...displayed.map((p) => _buildProjectRow(p, color)),
          if (allProjects.length > 5)
            GestureDetector(
              onTap: () => setState(() => _showAllProjects = !_showAllProjects),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showAllProjects
                          ? 'show less'
                          : 'show all ${allProjects.length} projects',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showAllProjects
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: color,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          Divider(color: AppColors.surfaceLight, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildProjectRow(Project project, Color color) {
    final bool isInProgress = project.status == 'in_progress';
    final bool hasPreviousScore = isInProgress && project.finalMark != null;

    Color mainBadgeColor;
    String mainBadgeText;

    if (isInProgress) {
      mainBadgeColor = AppColors.pastelBlue;
      mainBadgeText = 'in progress';
    } else if (project.validated) {
      mainBadgeColor = AppColors.pastelGreen;
      mainBadgeText = '${project.finalMark}';
    } else if (project.finalMark != null) {
      mainBadgeColor = const Color(0xFFE8A8A8);
      mainBadgeText = '${project.finalMark}';
    } else {
      mainBadgeColor = AppColors.textHint;
      mainBadgeText = '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surface, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              project.name,
              style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: mainBadgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: mainBadgeColor.withValues(alpha: 0.3), width: 0.5,
                  ),
                ),
                child: Text(
                  mainBadgeText,
                  style: TextStyle(color: mainBadgeColor, fontSize: 12),
                ),
              ),

              if (hasPreviousScore) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: project.validated
                        ? AppColors.pastelGreen.withValues(alpha: 0.1)
                        : const Color(0xFFE8A8A8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: project.validated
                          ? AppColors.pastelGreen.withValues(alpha: 0.3)
                          : const Color(0xFFE8A8A8).withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${project.finalMark}',
                    style: TextStyle(
                      color: project.validated
                          ? AppColors.pastelGreen
                          : const Color(0xFFE8A8A8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}