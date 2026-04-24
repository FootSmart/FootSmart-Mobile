import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footsmart_pro/core/constants/app_colors.dart';
import 'package:footsmart_pro/core/constants/app_text_styles.dart';
import 'package:footsmart_pro/core/extensions/theme_context.dart';
import 'package:footsmart_pro/core/routes/app_routes.dart';
import 'package:footsmart_pro/core/services/admin_dashboard_service.dart';
import 'package:footsmart_pro/core/services/api_service.dart';
import 'package:footsmart_pro/core/services/auth_service.dart';

enum _AdminSection { dashboard, users, statistics, wallet }

class AdminWebDashboardScreen extends StatefulWidget {
  const AdminWebDashboardScreen({super.key});

  @override
  State<AdminWebDashboardScreen> createState() =>
      _AdminWebDashboardScreenState();
}

class _AdminWebDashboardScreenState extends State<AdminWebDashboardScreen> {
  final AdminDashboardService _service = AdminDashboardService(ApiService());
  final AuthService _authService = AuthService(ApiService());
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFmt = NumberFormat.currency(symbol: '\$');

  bool _checkingAccess = true;
  bool _isLoading = true;
  String? _error;
  bool _usedFallback = false;
  Map<String, dynamic> _stats = const {};
  List<AdminBettor> _bettors = const [];
  _AdminSection _selectedSection = _AdminSection.dashboard;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _authService.syncTokenToApi();
    final user = await _authService.getUser();

    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.signIn);
      return;
    }

    if (user.role != 'admin') {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    setState(() => _checkingAccess = false);
    await _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getDashboardData(limit: 100);
      if (!mounted) return;
      setState(() {
        _stats = data.stats;
        _bettors = data.bettors;
        _usedFallback = data.usedFallback;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.signIn);
  }

  List<AdminBettor> get _filteredBettors {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _bettors;
    return _bettors
        .where(
          (b) =>
              b.displayName.toLowerCase().contains(q) ||
              b.email.toLowerCase().contains(q),
        )
        .toList();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1080;

    if (_checkingAccess) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF071126),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071126), Color(0xFF0A1630), Color(0xFF071126)],
          ),
        ),
        child: SafeArea(
          child: isDesktop
              ? Row(
                  children: [
                    _buildSidebar(),
                    Expanded(child: _buildMainContent(isDesktop: true)),
                  ],
                )
              : _buildMainContent(isDesktop: false),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1D3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A2D54)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icons/logorb.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.sports_soccer_rounded,
                      color: AppColors.accentGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'FOOTSMART',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sideItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            section: _AdminSection.dashboard,
          ),
          _sideItem(
            icon: Icons.people_alt_rounded,
            label: 'Users',
            section: _AdminSection.users,
          ),
          _sideItem(
            icon: Icons.analytics_rounded,
            label: 'Statistics',
            section: _AdminSection.statistics,
          ),
          _sideItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Wallet',
            section: _AdminSection.wallet,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.accentGreen),
              label: Text(
                'Logout',
                style: AppTextStyles.buttonMedium
                    .copyWith(color: AppColors.accentGreen),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.accentGreen.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideItem({
    required IconData icon,
    required String label,
    required _AdminSection section,
  }) {
    final active = _selectedSection == section;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (_selectedSection == section) return;
        setState(() => _selectedSection = section);
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: active ? AppColors.accentGreen.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? AppColors.accentGreen.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: active ? AppColors.accentGreen : Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: active ? AppColors.accentGreen : Colors.white70,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMainContent({required bool isDesktop}) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentGreen),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 44),
              const SizedBox(height: 10),
              Text(
                'Dashboard indisponible',
                style: AppTextStyles.h4.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final content = _buildSectionContent(isDesktop);

    return Padding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 8 : 14, 16, 16, 16),
      child: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: AppColors.accentGreen,
        child: ListView(children: [content]),
      ),
    );
  }

  Widget _buildSectionContent(bool isDesktop) {
    final children = <Widget>[
      _buildHeader(isDesktop),
    ];

    if (_usedFallback) {
      children.add(
        _banner(
          'Mode fallback actif: branchement endpoint admin incomplet. Les donnees proviennent du fallback.',
        ),
      );
      children.add(const SizedBox(height: 14));
    } else {
      children.add(const SizedBox(height: 14));
    }

    switch (_selectedSection) {
      case _AdminSection.dashboard:
        children.addAll([
          _buildStatsStrip(),
          const SizedBox(height: 16),
          _buildAnalyticsPanels(isDesktop),
          const SizedBox(height: 16),
          _buildBettorsPanel(isDesktop),
        ]);
        break;
      case _AdminSection.users:
        children.add(_buildBettorsPanel(isDesktop));
        break;
      case _AdminSection.statistics:
        children.addAll([
          _buildStatsStrip(),
          const SizedBox(height: 16),
          _buildAnalyticsPanels(isDesktop),
        ]);
        break;
      case _AdminSection.wallet:
        children.add(_buildWalletPanel(isDesktop));
        break;
    }

    return Column(children: children);
  }

  Widget _buildHeader(bool isDesktop) {
    final title = switch (_selectedSection) {
      _AdminSection.dashboard => 'Admin Dashboard',
      _AdminSection.users => 'Users',
      _AdminSection.statistics => 'Statistics',
      _AdminSection.wallet => 'Wallet',
    };

    final subtitle = switch (_selectedSection) {
      _AdminSection.dashboard => 'Web control center for users and performance',
      _AdminSection.users => 'All bettors and account statuses',
      _AdminSection.statistics => 'Global KPIs and outcomes',
      _AdminSection.wallet => 'Wallet volume and user balances',
    };

    final canSearch =
        _selectedSection == _AdminSection.dashboard || _selectedSection == _AdminSection.users;

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
        if (isDesktop && canSearch)
          SizedBox(
            width: 290,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search user',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF101F3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF223A69)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF223A69)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        IconButton(
          onPressed: _loadDashboard,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _banner(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2F220E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF725123)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFFFCF8A)),
      ),
    );
  }

  Widget _buildStatsStrip() {
    final totalBettors = _toInt(_stats['totalBettors']);
    final activeBettors = _toInt(_stats['activeBettors']);
    final totalBets = _toInt(_stats['totalBets']);
    final avgWin = _toDouble(_stats['averageWinRate']);
    final wallet = _toDouble(_stats['totalBalance']);

    final cards = [
      _metric('Total Bettors', '$totalBettors', Icons.groups_2_rounded),
      _metric('Active', '$activeBettors', Icons.verified_user_rounded),
      _metric('Total Bets', '$totalBets', Icons.ssid_chart_rounded),
      _metric('Avg Win Rate', '${avgWin.toStringAsFixed(1)}%', Icons.percent_rounded),
      _metric('Wallet Volume', _currencyFmt.format(wallet), Icons.account_balance_wallet_rounded),
    ];

    return Wrap(spacing: 12, runSpacing: 12, children: cards);
  }

  Widget _metric(String label, String value, IconData icon) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F3661)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accentGreen, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPanels(bool isDesktop) {
    final won = _toInt(_stats['wonBets']);
    final lost = _toInt(_stats['lostBets']);

    final trendCard = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F3661)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Betting Trend',
            style: AppTextStyles.h4.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _WavePainter(
                lineColor: AppColors.accentGreen,
                fillColor: AppColors.accentGreen.withValues(alpha: 0.12),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );

    final pieLikeCard = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F3661)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Outcomes', style: AppTextStyles.h4.copyWith(color: Colors.white)),
          const SizedBox(height: 10),
          _bar('Won', won, AppColors.accentGreen),
          const SizedBox(height: 8),
          _bar('Lost', lost, AppColors.error),
        ],
      ),
    );

    if (!isDesktop) {
      return Column(
        children: [
          trendCard,
          const SizedBox(height: 12),
          pieLikeCard,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 2, child: trendCard),
        const SizedBox(width: 12),
        Expanded(child: pieLikeCard),
      ],
    );
  }

  Widget _bar(String label, int value, Color color) {
    final maxValue = math.max(1, _toInt(_stats['totalBets']));
    final ratio = (value / maxValue).clamp(0, 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
            const Spacer(),
            Text('$value', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.white10,
          ),
        ),
      ],
    );
  }

  Widget _buildBettorsPanel(bool isDesktop) {
    final bettors = _filteredBettors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F3661)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Bettors', style: AppTextStyles.h3.copyWith(color: Colors.white)),
              const Spacer(),
              if (!isDesktop)
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0C1933),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (bettors.isEmpty)
            Text(
              'Aucun bettor disponible.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            )
          else if (isDesktop)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 22,
                headingTextStyle:
                    AppTextStyles.label.copyWith(color: AppColors.accentGreen),
                dataTextStyle:
                    AppTextStyles.bodySmall.copyWith(color: Colors.white),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Balance')),
                  DataColumn(label: Text('Bets')),
                  DataColumn(label: Text('Win Rate')),
                ],
                rows: bettors
                    .map(
                      (b) => DataRow(
                        cells: [
                          DataCell(Text(b.displayName)),
                          DataCell(Text(b.email)),
                          DataCell(_statusChip(b.accountStatus)),
                          DataCell(Text(_currencyFmt.format(b.balance))),
                          DataCell(Text('${b.totalBets}')),
                          DataCell(Text('${b.winRate.toStringAsFixed(1)}%')),
                        ],
                      ),
                    )
                    .toList(),
              ),
            )
          else
            Column(
              children: bettors
                  .map(
                    (b) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1933),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1D315A)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.displayName,
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  b.email,
                                  style: AppTextStyles.caption
                                      .copyWith(color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _statusChip(b.accountStatus),
                              const SizedBox(height: 6),
                              Text(
                                '${b.totalBets} bets',
                                style: AppTextStyles.caption
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildWalletPanel(bool isDesktop) {
    final bettors = _filteredBettors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F3661)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wallet Balances', style: AppTextStyles.h3.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Total wallet volume: ${_currencyFmt.format(_toDouble(_stats['totalBalance']))}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentGreen),
          ),
          const SizedBox(height: 12),
          if (bettors.isEmpty)
            Text(
              'No wallet data available.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            )
          else if (isDesktop)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 22,
                headingTextStyle:
                    AppTextStyles.label.copyWith(color: AppColors.accentGreen),
                dataTextStyle:
                    AppTextStyles.bodySmall.copyWith(color: Colors.white),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Balance')),
                ],
                rows: bettors
                    .map(
                      (b) => DataRow(
                        cells: [
                          DataCell(Text(b.displayName)),
                          DataCell(Text(b.email)),
                          DataCell(Text(_currencyFmt.format(b.balance))),
                        ],
                      ),
                    )
                    .toList(),
              ),
            )
          else
            Column(
              children: bettors
                  .map(
                    (b) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      title: Text(
                        b.displayName,
                        style: AppTextStyles.label.copyWith(color: Colors.white),
                      ),
                      subtitle: Text(
                        b.email,
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                      ),
                      trailing: Text(
                        _currencyFmt.format(b.balance),
                        style:
                            AppTextStyles.label.copyWith(color: AppColors.accentGreen),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? AppColors.accentGreen : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color lineColor;
  final Color fillColor;

  _WavePainter({required this.lineColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.72),
      Offset(size.width * 0.12, size.height * 0.66),
      Offset(size.width * 0.25, size.height * 0.7),
      Offset(size.width * 0.38, size.height * 0.58),
      Offset(size.width * 0.52, size.height * 0.36),
      Offset(size.width * 0.66, size.height * 0.44),
      Offset(size.width * 0.79, size.height * 0.32),
      Offset(size.width, size.height * 0.24),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final control = Offset((prev.dx + curr.dx) / 2, prev.dy);
      linePath.quadraticBezierTo(control.dx, control.dy, curr.dx, curr.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = lineColor;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor || oldDelegate.fillColor != fillColor;
  }
}
