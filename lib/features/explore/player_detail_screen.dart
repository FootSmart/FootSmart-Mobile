import 'package:flutter/material.dart';
import '../../core/models/player.dart';
import '../../core/services/api_service.dart';
import '../../core/services/team_service.dart';

class PlayerDetailScreen extends StatefulWidget {
  final Player player;

  const PlayerDetailScreen({super.key, required this.player});

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  late final TeamService _teamService;
  PlayerStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _teamService = TeamService(ApiService());
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await _teamService.getPlayerStats(widget.player.id);
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Player get _player => widget.player;

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  // ─── App Bar with player photo ──────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF0A0E27),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1F3A), Color(0xFF0A0E27)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00D9A3).withValues(alpha: 0.08),
                ),
              ),
            ),
            // Player info overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Player photo
                  _buildPlayerAvatar(90),
                  const SizedBox(width: 16),
                  // Player name & info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_player.shirtNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${_player.shirtNumber}',
                              style: const TextStyle(
                                color: Color(0xFF6C63FF),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          _player.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (_player.position != null) ...[
                              _positionBadge(_player.position!),
                              const SizedBox(width: 8),
                            ],
                            if (_player.nationality != null)
                              Text(
                                _player.nationality!,
                                style: const TextStyle(
                                  color: Color(0xFF8E92BC),
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Player avatar (photo or initials) ──────────────────────────────────────

  Widget _buildPlayerAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00D9A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A2F4A),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _player.photoUrl != null && _player.photoUrl!.isNotEmpty
            ? Image.network(
                _player.photoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsWidget(size),
              )
            : _initialsWidget(size),
      ),
    );
  }

  Widget _initialsWidget(double size) {
    final parts = _player.name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : _player.name
            .substring(0, _player.name.length.clamp(0, 2))
            .toUpperCase();
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9A3)),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.error_outline, color: Color(0xFF8E92BC), size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFF8E92BC), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9A3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player bio info
          _buildBioCard(),
          const SizedBox(height: 20),
          // Main stats grid
          _buildSectionTitle('Season Statistics', Icons.bar_chart_rounded),
          const SizedBox(height: 12),
          _buildMainStatsGrid(),
          const SizedBox(height: 20),
          // Performance metrics
          _buildSectionTitle('Performance', Icons.speed_rounded),
          const SizedBox(height: 12),
          _buildPerformanceCards(),
          const SizedBox(height: 20),
          // Discipline
          _buildSectionTitle('Discipline', Icons.gavel_rounded),
          const SizedBox(height: 12),
          _buildDisciplineRow(),
        ],
      ),
    );
  }

  // ─── Bio card ──────────────────────────────────────────────────────────────

  Widget _buildBioCard() {
    final items = <_BioItem>[
      if (_stats?.teamName != null)
        _BioItem(Icons.shield_outlined, 'Team', _stats!.teamName!),
      if (_stats?.league != null)
        _BioItem(Icons.emoji_events_outlined, 'League', _stats!.league!),
      if (_stats?.season != null)
        _BioItem(
            Icons.calendar_today_outlined, 'Season', _stats!.season.toString()),
      if (_player.age != null)
        _BioItem(Icons.cake_outlined, 'Age', '${_player.age} yrs'),
      if (_player.heightCm != null)
        _BioItem(Icons.height, 'Height', '${_player.heightCm} cm'),
      if (_player.weightKg != null)
        _BioItem(
            Icons.fitness_center_outlined, 'Weight', '${_player.weightKg} kg'),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F4A)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: items
            .map((item) => SizedBox(
                  width: (MediaQuery.of(context).size.width - 72) / 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: const Color(0xFF6C63FF), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Color(0xFF8E92BC),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              item.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ─── Section title ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00D9A3), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ─── Main stats grid ───────────────────────────────────────────────────────

  Widget _buildMainStatsGrid() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    final statItems = [
      _StatItem(
        icon: Icons.calendar_today_outlined,
        label: 'Appearances',
        value: stats.appearances.toString(),
        color: const Color(0xFF00B4D8),
      ),
      _StatItem(
        icon: Icons.timer_outlined,
        label: 'Minutes',
        value: _formatMinutes(stats.minutesPlayed),
        color: const Color(0xFFFFB74D),
      ),
      _StatItem(
        icon: Icons.sports_soccer,
        label: 'Goals',
        value: stats.goals.toString(),
        color: const Color(0xFF00D9A3),
      ),
      _StatItem(
        icon: Icons.assistant,
        label: 'Assists',
        value: stats.assists.toString(),
        color: const Color(0xFF6C63FF),
      ),
      _StatItem(
        icon: Icons.star_rounded,
        label: 'G+A',
        value: stats.goalContributions.toString(),
        color: const Color(0xFFFF6B6B),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: statItems.length,
      itemBuilder: (_, i) => _buildStatTile(statItems[i]),
    );
  }

  Widget _buildStatTile(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 22),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: TextStyle(
              color: item.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF8E92BC),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Performance cards ─────────────────────────────────────────────────────

  Widget _buildPerformanceCards() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildPerfCard(
            'Goals / Game',
            stats.goalsPerGame.toStringAsFixed(2),
            Icons.sports_soccer,
            const Color(0xFF00D9A3),
            _perfDescription(stats.goalsPerGame, 'goals per game'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPerfCard(
            'Goals / 90 min',
            stats.goalsPer90.toStringAsFixed(2),
            Icons.timer_outlined,
            const Color(0xFF6C63FF),
            _perfDescription(stats.goalsPer90, 'goals per 90'),
          ),
        ),
      ],
    );
  }

  Widget _buildPerfCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF8E92BC),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF4A4F6A),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Discipline row ────────────────────────────────────────────────────────

  Widget _buildDisciplineRow() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildDisciplineTile(
            'Yellow Cards',
            stats.yellowCards.toString(),
            Icons.square_rounded,
            const Color(0xFFFFD600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDisciplineTile(
            'Red Cards',
            stats.redCards.toString(),
            Icons.square_rounded,
            const Color(0xFFFF5252),
          ),
        ),
      ],
    );
  }

  Widget _buildDisciplineTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8E92BC),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Position badge ──────────────────────────────────────────────────────

  Widget _positionBadge(String position) {
    final abbr = _positionAbbr(position);
    final color = _positionColor(position);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        abbr,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Utils ───────────────────────────────────────────────────────────────

  String _positionAbbr(String position) {
    final p = position.toLowerCase();
    if (p.contains('goalkeeper') || p.contains('gk')) return 'GK';
    if (p.contains('defender') || p.contains('back') || p.contains('def')) {
      return 'DEF';
    }
    if (p.contains('midfielder') || p.contains('mid')) return 'MID';
    if (p.contains('forward') ||
        p.contains('striker') ||
        p.contains('winger') ||
        p.contains('fwd') ||
        p.contains('attacker')) {
      return 'FWD';
    }
    return position.substring(0, position.length.clamp(0, 3)).toUpperCase();
  }

  Color _positionColor(String position) {
    final p = position.toLowerCase();
    if (p.contains('goalkeeper') || p.contains('gk')) {
      return const Color(0xFFFFB74D);
    }
    if (p.contains('defender') || p.contains('back') || p.contains('def')) {
      return const Color(0xFF00B4D8);
    }
    if (p.contains('midfielder') || p.contains('mid')) {
      return const Color(0xFF6C63FF);
    }
    return const Color(0xFF00D9A3);
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 1000) {
      return '${(minutes / 1000).toStringAsFixed(1)}k';
    }
    return minutes.toString();
  }

  String _perfDescription(double value, String metric) {
    if (value >= 0.8) return 'Elite $metric';
    if (value >= 0.5) return 'Strong $metric';
    if (value >= 0.25) return 'Moderate $metric';
    return 'Developing';
  }
}

// ─── Helper data classes ──────────────────────────────────────────────────────

class _BioItem {
  final IconData icon;
  final String label;
  final String value;
  const _BioItem(this.icon, this.label, this.value);
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
