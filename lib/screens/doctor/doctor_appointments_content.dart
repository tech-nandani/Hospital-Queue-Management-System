import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/queue_patient.dart';
import '../../services/patient_api_service.dart';
import '../../services/verification_service.dart';
import '../../theme/app_colors.dart';

class DoctorAppointmentsContent extends StatefulWidget {
  final int? doctorId;
  final String? doctorName;
  final String? department;
  final void Function(QueuePatient patient)? onStartConsultation;
  final void Function(int tabIndex)? onNavigateToTab;
  final VoidCallback? onNavigateToDashboard;

  const DoctorAppointmentsContent({
    super.key,
    this.doctorId,
    this.doctorName,
    this.department,
    this.onStartConsultation,
    this.onNavigateToTab,
    this.onNavigateToDashboard,
  });

  @override
  State<DoctorAppointmentsContent> createState() => _DoctorAppointmentsContentState();
}

class _DoctorAppointmentsContentState extends State<DoctorAppointmentsContent> {
  // Doctor context
  late int _effectiveDoctorId;
  late String _effectiveDoctorName;
  late String _effectiveDepartment;

  // Appointments data
  List<QueuePatient> _appointments = [];
  List<String> _departments = ['All Departments'];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter States
  String _selectedDateTab = 'Today'; // Today, Tomorrow, This Week, This Month, Custom Date
  DateTime _selectedDate = DateTime.now();
  DateTimeRange? _customDateRange;

  String _statusFilter = 'All Statuses';
  String _priorityFilter = 'All Priorities';
  String _departmentFilter = 'All Departments';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;

  // Mini Calendar State
  late DateTime _calendarDisplayMonth;

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 8;

  // Action state
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _initDoctorContext();
    _calendarDisplayMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _loadDepartments();
    _fetchAppointments();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _initDoctorContext() {
    final staff = VerificationService.instance.currentStaff;
    if (staff != null && staff.role.toLowerCase() == 'doctor') {
      _effectiveDoctorName = staff.name;
      _effectiveDepartment = staff.department;
      _effectiveDoctorId = int.tryParse(staff.id) ?? widget.doctorId ?? 1;
    } else {
      _effectiveDoctorName = widget.doctorName ?? 'Doctor';
      _effectiveDepartment = widget.department ?? 'General Medicine';
      _effectiveDoctorId = widget.doctorId ?? 1;
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final list = await PatientApiService.instance.getDepartments();
      if (mounted && list.isNotEmpty) {
        final names = <String>{'All Departments'};
        for (final item in list) {
          final name = item['name']?.toString();
          if (name != null && name.trim().isNotEmpty) {
            names.add(name.trim());
          }
        }
        setState(() {
          _departments = names.toList();
        });
      }
    } catch (_) {
      // Keep default All Departments
    }
  }

  String _formatDateYMD(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDisplayDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return _formatDisplayDate(dt);
      }
    } catch (_) {}
    return dateStr;
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        int h = int.parse(parts[0]);
        final m = parts[1];
        final ampm = h >= 12 ? 'PM' : 'AM';
        if (h == 0) {
          h = 12;
        } else if (h > 12) {
          h -= 12;
        }
        return '${h.toString().padLeft(2, '0')}:$m $ampm';
      }
    } catch (_) {}
    return raw;
  }

  Future<void> _fetchAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Determine date range
      String? queryDate;
      String? startDate;
      String? endDate;

      final now = DateTime.now();

      switch (_selectedDateTab) {
        case 'Today':
          queryDate = _formatDateYMD(_selectedDate);
          break;
        case 'Tomorrow':
          final tomorrow = now.add(const Duration(days: 1));
          queryDate = _formatDateYMD(tomorrow);
          break;
        case 'This Week':
          final monday = now.subtract(Duration(days: (now.weekday - 1) % 7));
          final sunday = monday.add(const Duration(days: 6));
          startDate = _formatDateYMD(monday);
          endDate = _formatDateYMD(sunday);
          break;
        case 'This Month':
          final firstDay = DateTime(now.year, now.month, 1);
          final lastDay = DateTime(now.year, now.month + 1, 0);
          startDate = _formatDateYMD(firstDay);
          endDate = _formatDateYMD(lastDay);
          break;
        case 'Custom Date':
          if (_customDateRange != null) {
            startDate = _formatDateYMD(_customDateRange!.start);
            endDate = _formatDateYMD(_customDateRange!.end);
          } else {
            queryDate = _formatDateYMD(_selectedDate);
          }
          break;
        default:
          queryDate = _formatDateYMD(_selectedDate);
      }

      final data = await PatientApiService.instance.getStaffAppointments(
        doctorId: _effectiveDoctorId,
        department: _departmentFilter == 'All Departments' ? null : _departmentFilter,
        date: queryDate,
        startDate: startDate,
        endDate: endDate,
        status: _statusFilter == 'All Statuses' ? null : _statusFilter,
        priority: _priorityFilter == 'All Priorities' ? null : _priorityFilter,
        search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
      );

      final list = data.map((json) => QueuePatient.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          _appointments = list;
          _isLoading = false;
          _currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load appointments. Please check network or try again.';
        });
      }
    }
  }

  // Summary Metrics
  int get _totalAppointmentsCount => _appointments.length;

  int get _upcomingCount => _appointments.where((p) {
        final s = p.status.toLowerCase();
        return s == 'upcoming' || s == 'waiting' || s == 'checked-in' || s == 'calling';
      }).length;

  int get _completedCount => _appointments.where((p) {
        return p.status.toLowerCase() == 'completed';
      }).length;

  int get _cancelledOrNoShowCount => _appointments.where((p) {
        final s = p.status.toLowerCase();
        return s == 'cancelled' || s == 'no show';
      }).length;

  // Paginated list
  List<QueuePatient> get _paginatedAppointments {
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _appointments.length) return [];
    final end = (start + _pageSize).clamp(0, _appointments.length);
    return _appointments.sublist(start, end);
  }

  int get _totalPages => (_appointments.isEmpty) ? 1 : ((_appointments.length - 1) ~/ _pageSize) + 1;

  void _onDateTabSelected(String tab) async {
    if (tab == 'Custom Date') {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialDateRange: _customDateRange ??
            DateTimeRange(
              start: _selectedDate,
              end: _selectedDate.add(const Duration(days: 7)),
            ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: Color(0xFF0F172A),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        setState(() {
          _selectedDateTab = tab;
          _customDateRange = picked;
          _selectedDate = picked.start;
          _calendarDisplayMonth = DateTime(picked.start.year, picked.start.month, 1);
        });
        _fetchAppointments();
      }
    } else {
      setState(() {
        _selectedDateTab = tab;
        _customDateRange = null;
        if (tab == 'Today') {
          _selectedDate = DateTime.now();
        } else if (tab == 'Tomorrow') {
          _selectedDate = DateTime.now().add(const Duration(days: 1));
        }
        _calendarDisplayMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      });
      _fetchAppointments();
    }
  }

  void _onCalendarDateSelected(DateTime dt) {
    setState(() {
      _selectedDate = dt;
      _selectedDateTab = _isSameDay(dt, DateTime.now())
          ? 'Today'
          : (_isSameDay(dt, DateTime.now().add(const Duration(days: 1))) ? 'Tomorrow' : 'Custom Date');
      _customDateRange = null;
    });
    _fetchAppointments();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onSearchChanged(String val) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _searchQuery = val);
        _fetchAppointments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;

    return Container(
      color: const Color(0xFFF4F7FC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PAGE HEADER
            _buildPageHeader(),
            const SizedBox(height: 20),

            // 2. 4 DYNAMIC SUMMARY CARDS
            _buildSummaryCards(isDesktop),
            const SizedBox(height: 20),

            // 3. MAIN SECTION: TABLE & RIGHT SIDEBAR
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildAppointmentsMainPanel(),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 320,
                    child: Column(
                      children: [
                        _buildMiniCalendarCard(),
                        const SizedBox(height: 18),
                        _buildQuickActionsCard(),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _buildAppointmentsMainPanel(),
              const SizedBox(height: 20),
              _buildMiniCalendarCard(),
              const SizedBox(height: 18),
              _buildQuickActionsCard(),
            ],

            const SizedBox(height: 20),

            // 4. BOTTOM TIPS BANNER
            _buildTipsBanner(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 1. PAGE HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Blue rounded circle icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'View and manage your scheduled appointments',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        // Breadcrumb: Dashboard > Appointments
        InkWell(
          onTap: widget.onNavigateToDashboard,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                const Text(
                  'Appointments',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 2. 4 DYNAMIC SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards(bool isDesktop) {
    final cards = [
      _buildSummaryCard(
        title: 'Total Appointments',
        count: _totalAppointmentsCount,
        subtext: 'For selected period',
        icon: Icons.people_alt_rounded,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFEFF6FF),
      ),
      _buildSummaryCard(
        title: 'Upcoming',
        count: _upcomingCount,
        subtext: 'Scheduled appointments',
        icon: Icons.access_time_filled_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBg: const Color(0xFFFFFBEB),
      ),
      _buildSummaryCard(
        title: 'Completed',
        count: _completedCount,
        subtext: 'Consultations completed',
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFECFDF5),
      ),
      _buildSummaryCard(
        title: 'Cancelled / No Show',
        count: _cancelledOrNoShowCount,
        subtext: 'Cancelled or missed',
        icon: Icons.cancel_rounded,
        iconColor: const Color(0xFFEF4444),
        iconBg: const Color(0xFFFEF2F2),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: card,
                  ),
                ))
            .toList(),
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards.map((card) => SizedBox(width: itemWidth > 200 ? itemWidth : constraints.maxWidth, child: card)).toList(),
          );
        },
      );
    }
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3. APPOINTMENTS MAIN PANEL (TABS + FILTERS + TABLE)
  // ============================================================

  Widget _buildAppointmentsMainPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DATE RANGE TABS
          _buildDateRangeTabs(),
          const SizedBox(height: 18),

          // SEARCH & FILTER BAR
          _buildSearchAndFiltersBar(),
          const SizedBox(height: 18),

          // TABLE CONTENT / STATES
          if (_isLoading)
            _buildLoadingState()
          else if (_errorMessage != null)
            _buildErrorState()
          else if (_appointments.isEmpty)
            _buildEmptyState()
          else ...[
            _buildAppointmentTable(),
            const SizedBox(height: 16),
            _buildTableFooter(),
          ],
        ],
      ),
    );
  }

  // DATE RANGE TABS
  Widget _buildDateRangeTabs() {
    final tabs = ['Today', 'Tomorrow', 'This Week', 'This Month', 'Custom Date'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedDateTab == tab;
          final isCustom = tab == 'Custom Date';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _onDateTabSelected(tab),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCustom) ...[
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      isCustom && _customDateRange != null
                          ? '${_formatDisplayDate(_customDateRange!.start)} - ${_formatDisplayDate(_customDateRange!.end)}'
                          : tab,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // SEARCH AND FILTERS BAR
  Widget _buildSearchAndFiltersBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 750;

        final searchField = SizedBox(
          width: isNarrow ? constraints.maxWidth : 300,
          height: 40,
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Search patient name, appointment ID or token...',
              hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
        );

        final statusDropdown = _buildFilterDropdown<String>(
          value: _statusFilter,
          items: const [
            'All Statuses',
            'Upcoming',
            'Checked-in',
            'Waiting',
            'In Consultation',
            'Completed',
            'Cancelled',
            'No Show',
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _statusFilter = val);
              _fetchAppointments();
            }
          },
        );

        final priorityDropdown = _buildFilterDropdown<String>(
          value: _priorityFilter,
          items: const [
            'All Priorities',
            'Normal',
            'Urgent',
            'Emergency',
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _priorityFilter = val);
              _fetchAppointments();
            }
          },
        );

        final departmentDropdown = _buildFilterDropdown<String>(
          value: _departments.contains(_departmentFilter) ? _departmentFilter : 'All Departments',
          items: _departments,
          onChanged: (val) {
            if (val != null) {
              setState(() => _departmentFilter = val);
              _fetchAppointments();
            }
          },
        );

        final refreshBtn = OutlinedButton.icon(
          onPressed: _isLoading ? null : _fetchAppointments,
          icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF2563EB)),
          label: const Text(
            'Refresh',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFF8FAFC),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  statusDropdown,
                  priorityDropdown,
                  departmentDropdown,
                  refreshBtn,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 10),
            statusDropdown,
            const SizedBox(width: 8),
            priorityDropdown,
            const SizedBox(width: 8),
            departmentDropdown,
            const SizedBox(width: 8),
            refreshBtn,
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================
  // 4. MAIN APPOINTMENTS TABLE
  // ============================================================

  Widget _buildAppointmentTable() {
    final list = _paginatedAppointments;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 700),
        child: DataTable(
          horizontalMargin: 8,
          columnSpacing: 14,
          headingRowHeight: 42,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 62,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          headingTextStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.2,
          ),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Patient Name')),
            DataColumn(label: Text('Age / Gender')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Department')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')),
          ],
          rows: List.generate(list.length, (index) {
            final patient = list[index];
            final globalIndex = (_currentPage - 1) * _pageSize + index + 1;

            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (index.isOdd) return const Color(0xFFFAFCFF);
                return Colors.white;
              }),
              cells: [
                // # Index
                DataCell(
                  Text(
                    '$globalIndex',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                ),
                // Patient Name with token tag
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Token #${patient.token} • ID: ${patient.id}',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Age / Gender
                DataCell(
                  Text(
                    '${patient.age > 0 ? patient.age : "--"} / ${patient.gender.isNotEmpty ? (patient.gender.startsWith("M") ? "M" : (patient.gender.startsWith("F") ? "F" : "O")) : "--"}',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                  ),
                ),
                // Date
                DataCell(
                  Text(
                    _formatDisplayDateString(patient.date),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                  ),
                ),
                // Time
                DataCell(
                  Text(
                    _formatTime(patient.time),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                  ),
                ),
                // Department
                DataCell(
                  Text(
                    patient.department,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                  ),
                ),
                // Priority Badge
                DataCell(_buildPriorityBadge(patient.priority)),
                // Status Badge
                DataCell(_buildStatusBadge(patient.status)),
                // Action Buttons
                DataCell(_buildActionButtons(patient)),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Priority Pill Badge
  Widget _buildPriorityBadge(String priority) {
    Color bg;
    Color text;
    String label = priority;

    switch (priority.toLowerCase()) {
      case 'emergency':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        label = 'Emergency';
        break;
      case 'urgent':
      case 'high':
        bg = const Color(0xFFFFEDD5);
        text = const Color(0xFFEA580C);
        label = 'Urgent';
        break;
      default:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
        label = 'Normal';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  // Status Pill Badge
  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status.toLowerCase()) {
      case 'upcoming':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF2563EB);
        break;
      case 'checked-in':
      case 'checked_in':
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0284C7);
        break;
      case 'waiting':
        bg = const Color(0xFFEEF2FF);
        text = const Color(0xFF4F46E5);
        break;
      case 'in consultation':
      case 'in_consultation':
        bg = const Color(0xFFF3E8FF);
        text = const Color(0xFF9333EA);
        break;
      case 'completed':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        break;
      case 'no show':
      case 'no_show':
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF64748B);
        break;
      default:
        bg = const Color(0xFFF8FAFC);
        text = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons(QueuePatient patient) {
    final status = patient.status.toLowerCase();
    final canStartConsult = status == 'waiting' || status == 'checked-in' || status == 'checked_in' || status == 'calling' || status == 'upcoming';
    final isInConsult = status == 'in consultation' || status == 'in_consultation';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Details Button
        OutlinedButton(
          onPressed: () => _showAppointmentDetailsModal(patient),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
            backgroundColor: const Color(0xFFEFF6FF),
            side: const BorderSide(color: Color(0xFFBFDBFE), width: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(0, 30),
          ),
          child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        if (canStartConsult) ...[
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: _isActionInProgress ? null : () => _startConsultation(patient),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(0, 30),
            ),
            child: const Text('Consult', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ] else if (isInConsult) ...[
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () {
              widget.onStartConsultation?.call(patient);
              widget.onNavigateToTab?.call(4);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF7C5CFC),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(0, 30),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }

  // TABLE PAGINATION FOOTER
  Widget _buildTableFooter() {
    final start = (_currentPage - 1) * _pageSize + 1;
    final end = (_currentPage * _pageSize).clamp(0, _appointments.length);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing $start to $end of ${_appointments.length} appointments',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous button
            IconButton(
              onPressed: _currentPage > 1
                  ? () => setState(() => _currentPage--)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded, size: 20),
              color: const Color(0xFF2563EB),
              disabledColor: const Color(0xFFCBD5E1),
              tooltip: 'Previous Page',
            ),
            // Page Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_currentPage',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            // Next button
            IconButton(
              onPressed: _currentPage < _totalPages
                  ? () => setState(() => _currentPage++)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              color: const Color(0xFF2563EB),
              disabledColor: const Color(0xFFCBD5E1),
              tooltip: 'Next Page',
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY, LOADING & ERROR STATES
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No appointments scheduled',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Appointments for the selected date will appear here.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _fetchAppointments,
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF2563EB)),
            label: const Text('Refresh', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 3),
            SizedBox(height: 16),
            Text('Loading appointments...', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 40),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unable to load appointments.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchAppointments,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 5. RIGHT SIDEBAR: INTERACTIVE MINI CALENDAR
  // ============================================================

  Widget _buildMiniCalendarCard() {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final monthStr = '${monthNames[_calendarDisplayMonth.month - 1]} ${_calendarDisplayMonth.year}';

    // Calendar Grid Calculation
    final firstDayOfMonth = DateTime(_calendarDisplayMonth.year, _calendarDisplayMonth.month, 1);
    final daysInMonth = DateTime(_calendarDisplayMonth.year, _calendarDisplayMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0, Mon = 1...
    final prevMonthLastDay = DateTime(_calendarDisplayMonth.year, _calendarDisplayMonth.month, 0).day;

    final List<Widget> dayWidgets = [];

    // Weekday headers
    const weekHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final headerRow = Row(
      children: weekHeaders.map((d) => Expanded(
        child: Center(
          child: Text(
            d,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
          ),
        ),
      )).toList(),
    );

    // Days from prev month
    for (int i = startWeekday - 1; i >= 0; i--) {
      final day = prevMonthLastDay - i;
      dayWidgets.add(
        Center(
          child: Text(
            '$day',
            style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w400),
          ),
        ),
      );
    }

    // Days in current month
    for (int day = 1; day <= daysInMonth; day++) {
      final dt = DateTime(_calendarDisplayMonth.year, _calendarDisplayMonth.month, day);
      final isSelected = _isSameDay(dt, _selectedDate);
      final isToday = _isSameDay(dt, DateTime.now());

      dayWidgets.add(
        InkWell(
          onTap: () => _onCalendarDateSelected(dt),
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              shape: BoxShape.circle,
              border: (isToday && !isSelected) ? Border.all(color: const Color(0xFF2563EB), width: 1.2) : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : (isToday ? FontWeight.w700 : FontWeight.w500),
                  color: isSelected ? Colors.white : (isToday ? const Color(0xFF2563EB) : const Color(0xFF1E293B)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fill trailing days to complete rows (multiples of 7)
    final remainder = (dayWidgets.length % 7);
    if (remainder != 0) {
      final needed = 7 - remainder;
      for (int i = 1; i <= needed; i++) {
        dayWidgets.add(
          Center(
            child: Text(
              '$i',
              style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w400),
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Calendar Icon + "Select Date"
          const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Color(0xFF2563EB), size: 16),
              SizedBox(width: 8),
              Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Month navigation: < September 2026 >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                onPressed: () {
                  setState(() {
                    _calendarDisplayMonth = DateTime(_calendarDisplayMonth.year, _calendarDisplayMonth.month - 1, 1);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
                color: const Color(0xFF64748B),
                tooltip: 'Previous Month',
              ),
              Expanded(
                child: Text(
                  monthStr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                onPressed: () {
                  setState(() {
                    _calendarDisplayMonth = DateTime(_calendarDisplayMonth.year, _calendarDisplayMonth.month + 1, 1);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
                color: const Color(0xFF64748B),
                tooltip: 'Next Month',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday headers
          headerRow,
          const SizedBox(height: 8),

          // Days Grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 2,
            childAspectRatio: 1.1,
            children: dayWidgets,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 6. RIGHT SIDEBAR: QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 16),
              SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action 1: Start Consultation
          _buildQuickActionTile(
            title: 'Start Consultation',
            subtitle: 'Begin patient consultation',
            icon: Icons.medical_services_outlined,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFFEFF6FF),
            onTap: () {
              final nextEligible = _appointments.firstWhere(
                (p) => p.status.toLowerCase() != 'completed' && p.status.toLowerCase() != 'cancelled',
                orElse: () => _appointments.firstOrNull ?? QueuePatient(
                  id: '0',
                  token: 0,
                  name: 'Next Patient',
                  age: 0,
                  gender: '',
                  phone: '',
                  reason: 'General Consultation',
                  priority: 'Normal',
                  time: 'Now',
                ),
              );
              if (nextEligible.id != '0') {
                widget.onStartConsultation?.call(nextEligible);
              }
              widget.onNavigateToTab?.call(4); // Consultation tab
            },
          ),
          const SizedBox(height: 10),

          // Action 2: View Patient History
          _buildQuickActionTile(
            title: 'View Patient History',
            subtitle: 'Access medical records',
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF7C5CFC),
            iconBg: const Color(0xFFF3E8FF),
            onTap: () => widget.onNavigateToTab?.call(3), // Patients Directory
          ),
          const SizedBox(height: 10),

          // Action 3: Write Prescription
          _buildQuickActionTile(
            title: 'Write Prescription',
            subtitle: 'Create & manage prescriptions',
            icon: Icons.receipt_long_outlined,
            iconColor: const Color(0xFF10B981),
            iconBg: const Color(0xFFECFDF5),
            onTap: () => widget.onNavigateToTab?.call(6), // Prescriptions module
          ),
          const SizedBox(height: 10),

          // Action 4: Manage Schedule
          _buildQuickActionTile(
            title: 'Manage Schedule',
            subtitle: 'View and manage your schedule',
            icon: Icons.calendar_month_outlined,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFEF3C7),
            onTap: () => widget.onNavigateToTab?.call(7), // Schedule module
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 7. BOTTOM TIPS BANNER
  // ============================================================

  Widget _buildTipsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointment Management Tips',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'View your scheduled appointments, check patient status, and start consultations directly. Use filters to find specific appointments quickly.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _showTipsModal,
            label: const Text('Learn more', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
            icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }

  void _showTipsModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Appointment Management Tips', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Quick Start: Click "Consult" to jump directly into clinical examination and prescription writing.'),
            SizedBox(height: 8),
            Text('• Live Calendar: Click any date on the right calendar to load scheduled patient slots for that day.'),
            SizedBox(height: 8),
            Text('• Dynamic Searching: Enter patient name, appointment ID, or queue token to search live records instantaneously.'),
            SizedBox(height: 8),
            Text('• Queue Integration: When patients check in at reception, they seamlessly appear in your queue roster.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }

  // ============================================================
  // 8. ACTIONS: START CONSULTATION & DETAILS DIALOGS
  // ============================================================

  Future<void> _startConsultation(QueuePatient patient) async {
    final apptId = int.tryParse(patient.id);
    if (apptId == null) {
      widget.onStartConsultation?.call(patient);
      widget.onNavigateToTab?.call(4);
      return;
    }

    setState(() => _isActionInProgress = true);
    try {
      await PatientApiService.instance.startConsultation(apptId);
      patient.status = 'In Consultation';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consultation started for ${patient.name}'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onStartConsultation?.call(patient);
        widget.onNavigateToTab?.call(4);
      }
    } catch (e) {
      if (mounted) {
        widget.onStartConsultation?.call(patient);
        widget.onNavigateToTab?.call(4);
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  void _showAppointmentDetailsModal(QueuePatient patient) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Token and Status
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        '#${patient.token}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB), fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Appointment ID: ${patient.id} • ${patient.department.isNotEmpty ? patient.department : _effectiveDepartment}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    _buildPriorityBadge(patient.priority),
                    const SizedBox(width: 8),
                    _buildStatusBadge(patient.status),
                  ],
                ),
                const Divider(height: 28),

                // Details Grid
                Wrap(
                  spacing: 24,
                  runSpacing: 14,
                  children: [
                    _buildDetailItem('Age / Gender', '${patient.age > 0 ? patient.age : "--"} yrs / ${patient.gender}'),
                    _buildDetailItem('Phone', patient.phone.isNotEmpty ? patient.phone : 'Not provided'),
                    _buildDetailItem('Email', patient.email.isNotEmpty ? patient.email : 'Not provided'),
                    _buildDetailItem('Date', _formatDisplayDateString(patient.date)),
                    _buildDetailItem('Time', _formatTime(patient.time)),
                    _buildDetailItem('Doctor', patient.doctorName.isNotEmpty ? patient.doctorName : _effectiveDoctorName),
                  ],
                ),
                const SizedBox(height: 18),

                // Reason for visit
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reason for Visit / Symptoms',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient.reason.isNotEmpty ? patient.reason : 'General Medical Consultation',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                if (patient.clinicalNotes != null && patient.clinicalNotes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clinical Notes',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patient.clinicalNotes!,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Footer
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showPatientHistoryModal(patient);
                      },
                      icon: const Icon(Icons.history_edu_rounded, size: 16),
                      label: const Text('Patient History'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _startConsultation(patient);
                      },
                      icon: const Icon(Icons.medical_services_rounded, size: 16),
                      label: const Text('Start Consultation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showPatientHistoryModal(QueuePatient patient) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 650),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3E8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.folder_shared_rounded, color: Color(0xFF7C5CFC), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medical History: ${patient.name}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            'Phone: ${patient.phone.isNotEmpty ? patient.phone : "N/A"} • Gender: ${patient.gender} • Age: ${patient.age}y',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'Patient Visits & Consultation Records',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      // Active/Current record
                      Card(
                        elevation: 0,
                        color: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Current Visit • ${_formatDisplayDateString(patient.date)}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2563EB)),
                                  ),
                                  const Spacer(),
                                  _buildStatusBadge(patient.status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Reason: ${patient.reason}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A))),
                              if (patient.diagnosis != null && patient.diagnosis!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('Diagnosis: ${patient.diagnosis}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                              ],
                              if (patient.prescription != null && patient.prescription!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('Prescription: ${patient.prescription}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                              ],
                              if (patient.treatmentAdvice != null && patient.treatmentAdvice!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('Advice: ${patient.treatmentAdvice}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // General history guidance
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Complete longitudinal EHR records, lab diagnostics, and radiology images are synchronized in the Clinical Directory.',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onNavigateToTab?.call(3); // Patients Directory
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Open Clinical Directory'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
