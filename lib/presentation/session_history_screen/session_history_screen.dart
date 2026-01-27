import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/session_card_widget.dart';
import './widgets/session_filter_widget.dart';

/// Session History Screen - Displays chronological list of completed cricket sessions
/// with date-wise organization, replay functionality, and comprehensive performance tracking.
///
/// Features:
/// - Date-wise session listing with card-based layout
/// - Pull-to-refresh for local database sync
/// - Swipe actions for quick operations (replay, export, delete, share)
/// - Search and filter by date range or performance criteria
/// - Multi-select mode for batch operations
/// - Empty state with call-to-action
/// - Infinite scroll with skeleton loading
/// - Accessibility support with VoiceOver
class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isMultiSelectMode = false;
  bool _isSearchActive = false;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  Set<int> _selectedSessions = {};

  // Mock session data with comprehensive metrics
  List<Map<String, dynamic>> _allSessions = [];
  List<Map<String, dynamic>> _filteredSessions = [];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    _allSessions = [
      {
        "id": 1,
        "date": DateTime(2026, 1, 26, 14, 30),
        "duration": "45 min",
        "playerName": "Virat Kohli",
        "playerRole": "Batsman",
        "totalSwings": 87,
        "peakBatSpeed": 142.5,
        "peakImpactSpeed": 156.8,
        "avgBatSpeed": 128.3,
        "avgImpactSpeed": 141.2,
        "consistency": 0.89,
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1730d2460-1764771416491.png",
        "semanticLabel":
            "Cricket batsman in white uniform executing cover drive shot on grass pitch",
        "sessionType": "Batting Practice",
        "insights":
            "Excellent consistency with peak performance in final 15 minutes",
        "isViewed": false,
      },
      {
        "id": 2,
        "date": DateTime(2026, 1, 25, 16, 15),
        "duration": "38 min",
        "playerName": "Jasprit Bumrah",
        "playerRole": "Bowler",
        "totalSwings": 64,
        "peakReleaseSpeed": 148.2,
        "peakRotationSpeed": 2850.0,
        "avgReleaseSpeed": 142.7,
        "avgRotationSpeed": 2680.0,
        "consistency": 0.92,
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_18603f7fb-1764692187655.png",
        "semanticLabel":
            "Fast bowler in blue jersey mid-delivery stride with arm raised high",
        "sessionType": "Bowling Practice",
        "insights":
            "Outstanding consistency with controlled release angles throughout session",
        "isViewed": true,
      },
      {
        "id": 3,
        "date": DateTime(2026, 1, 24, 10, 45),
        "duration": "52 min",
        "playerName": "Rohit Sharma",
        "playerRole": "Batsman",
        "totalSwings": 103,
        "peakBatSpeed": 138.9,
        "peakImpactSpeed": 152.3,
        "avgBatSpeed": 125.6,
        "avgImpactSpeed": 138.7,
        "consistency": 0.85,
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_153ad4c62-1764781444747.png",
        "semanticLabel":
            "Batsman in blue helmet playing pull shot with bat horizontal",
        "sessionType": "Power Hitting",
        "insights":
            "Strong power hitting phase with gradual fatigue in final 10 minutes",
        "isViewed": true,
      },
      {
        "id": 4,
        "date": DateTime(2026, 1, 23, 15, 20),
        "duration": "41 min",
        "playerName": "Ravindra Jadeja",
        "playerRole": "All-rounder",
        "totalSwings": 76,
        "peakBatSpeed": 135.4,
        "peakImpactSpeed": 148.6,
        "avgBatSpeed": 122.8,
        "avgImpactSpeed": 136.2,
        "consistency": 0.87,
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_137af7d96-1766600651209.png",
        "semanticLabel":
            "All-rounder in green jersey playing defensive shot with straight bat",
        "sessionType": "Technical Practice",
        "insights":
            "Balanced session with focus on technique and timing consistency",
        "isViewed": false,
      },
      {
        "id": 5,
        "date": DateTime(2026, 1, 22, 9, 30),
        "duration": "35 min",
        "playerName": "Mohammed Shami",
        "playerRole": "Bowler",
        "totalSwings": 58,
        "peakReleaseSpeed": 145.8,
        "peakRotationSpeed": 2720.0,
        "avgReleaseSpeed": 140.3,
        "avgRotationSpeed": 2590.0,
        "consistency": 0.90,
        "thumbnail":
            "https://images.unsplash.com/photo-1599982973590-2de8279c6114",
        "semanticLabel":
            "Pace bowler in white uniform at point of ball release with intense focus",
        "sessionType": "Speed Training",
        "insights":
            "Consistent pace maintenance with excellent seam position control",
        "isViewed": true,
      },
    ];

    _filteredSessions = List.from(_allSessions);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreSessions();
    }
  }

  Future<void> _loadMoreSessions() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);
  }

  Future<void> _refreshSessions() async {
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _allSessions = List.from(_allSessions);
      _applyFilters();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Session history updated'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _searchQuery = '';
        _applyFilters();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredSessions = _allSessions.where((session) {
        bool matchesSearch = true;
        bool matchesDateRange = true;

        if (_searchQuery.isNotEmpty) {
          matchesSearch =
              (session["playerName"] as String).toLowerCase().contains(
                _searchQuery,
              ) ||
              (session["sessionType"] as String).toLowerCase().contains(
                _searchQuery,
              );
        }

        if (_selectedDateRange != null) {
          final sessionDate = session["date"] as DateTime;
          matchesDateRange =
              sessionDate.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1)),
              ) &&
              sessionDate.isBefore(
                _selectedDateRange!.end.add(const Duration(days: 1)),
              );
        }

        return matchesSearch && matchesDateRange;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionFilterWidget(
        selectedDateRange: _selectedDateRange,
        onDateRangeSelected: (range) {
          setState(() {
            _selectedDateRange = range;
            _applyFilters();
          });
          Navigator.pop(context);
        },
        onClearFilters: () {
          setState(() {
            _selectedDateRange = null;
            _applyFilters();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedSessions.clear();
      }
    });
  }

  void _toggleSessionSelection(int sessionId) {
    setState(() {
      _selectedSessions.contains(sessionId)
          ? _selectedSessions.remove(sessionId)
          : _selectedSessions.add(sessionId);
    });
  }

  void _selectAllSessions() {
    setState(() {
      _selectedSessions = _filteredSessions.map((s) => s["id"] as int).toSet();
    });
  }

  void _deselectAllSessions() {
    setState(() {
      _selectedSessions.clear();
    });
  }

  void _deleteSelectedSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sessions'),
        content: Text(
          'Are you sure you want to delete ${_selectedSessions.length} session(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allSessions.removeWhere(
                  (s) => _selectedSessions.contains(s["id"]),
                );
                _applyFilters();
                _selectedSessions.clear();
                _isMultiSelectMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sessions deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportSelectedSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedSessions.length} session(s)...'),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _selectedSessions.clear();
      _isMultiSelectMode = false;
    });
  }

  void _navigateToSessionSummary(Map<String, dynamic> session) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/session-summary-screen', arguments: session);
  }

  void _navigateToNewSession() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/live-session-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unviewedCount = _allSessions
        .where((s) => !(s["isViewed"] as bool))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search sessions...',
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                style: theme.textTheme.bodyMedium,
                onChanged: _onSearchChanged,
              )
            : Row(
                children: [
                  Text(
                    'Session History',
                    style: theme.appBarTheme.titleTextStyle,
                  ),
                  if (unviewedCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unviewedCount.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        actions: [
          if (_isMultiSelectMode) ...[
            if (_selectedSessions.length == _filteredSessions.length)
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'deselect',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: _deselectAllSessions,
                tooltip: 'Deselect All',
              )
            else
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'select_all',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: _selectAllSessions,
                tooltip: 'Select All',
              ),
            IconButton(
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: _toggleMultiSelect,
              tooltip: 'Cancel',
            ),
          ] else ...[
            IconButton(
              icon: CustomIconWidget(
                iconName: _isSearchActive ? 'close' : 'search',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: _toggleSearch,
              tooltip: _isSearchActive ? 'Close Search' : 'Search',
            ),
            IconButton(
              icon: CustomIconWidget(
                iconName: 'filter_list',
                color: _selectedDateRange != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: _showFilterDialog,
              tooltip: 'Filter',
            ),
          ],
        ],
      ),
      body: _filteredSessions.isEmpty
          ? EmptyStateWidget(onStartSession: _navigateToNewSession)
          : Column(
              children: [
                if (_isMultiSelectMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: theme.colorScheme.primaryContainer,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedSessions.length} selected',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _selectedSessions.isEmpty
                              ? null
                              : _exportSelectedSessions,
                          icon: CustomIconWidget(
                            iconName: 'file_download',
                            color: _selectedSessions.isEmpty
                                ? theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.4,
                                  )
                                : theme.colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                          label: Text(
                            'Export',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: _selectedSessions.isEmpty
                                  ? theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4)
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _selectedSessions.isEmpty
                              ? null
                              : _deleteSelectedSessions,
                          icon: CustomIconWidget(
                            iconName: 'delete',
                            color: _selectedSessions.isEmpty
                                ? theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.4,
                                  )
                                : theme.colorScheme.error,
                            size: 20,
                          ),
                          label: Text(
                            'Delete',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: _selectedSessions.isEmpty
                                  ? theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4)
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedDateRange != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'date_range',
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDateRange = null;
                              _applyFilters();
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshSessions,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount:
                          _filteredSessions.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredSessions.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final session = _filteredSessions[index];
                        final isSelected = _selectedSessions.contains(
                          session["id"],
                        );

                        return SessionCardWidget(
                          session: session,
                          isMultiSelectMode: _isMultiSelectMode,
                          isSelected: isSelected,
                          onTap: () {
                            _isMultiSelectMode
                                ? _toggleSessionSelection(session["id"] as int)
                                : _navigateToSessionSummary(session);
                          },
                          onLongPress: () {
                            if (!_isMultiSelectMode) {
                              _toggleMultiSelect();
                              _toggleSessionSelection(session["id"] as int);
                            }
                          },
                          onReplay: () => _navigateToSessionSummary(session),
                          onExport: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Exporting ${session["playerName"]} session...',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Session'),
                                content: const Text(
                                  'Are you sure you want to delete this session?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _allSessions.removeWhere(
                                          (s) => s["id"] == session["id"],
                                        );
                                        _applyFilters();
                                      });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Session deleted'),
                                        ),
                                      );
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onShare: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              '/export-and-share-screen',
                              arguments: session,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _navigateToNewSession,
              icon: CustomIconWidget(
                iconName: 'add',
                color:
                    theme.floatingActionButtonTheme.foregroundColor ??
                    Colors.white,
                size: 24,
              ),
              label: Text(
                'New Session',
                style: theme.textTheme.labelLarge?.copyWith(
                  color:
                      theme.floatingActionButtonTheme.foregroundColor ??
                      Colors.white,
                ),
              ),
            ),
    );
  }
}
