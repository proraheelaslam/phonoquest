import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import 'classroom_models.dart';
import 'classroom_repository.dart';
import 'teacher_dashboard_models.dart';
import 'teacher_dashboard_repository.dart';
import 'teacher_reports_models.dart';
import 'teacher_reports_repository.dart';

/// Shared teacher home/reports/classes cache with deduplicated API calls.
class TeacherWorkspaceController extends ChangeNotifier {
  TeacherWorkspaceController._();

  static final TeacherWorkspaceController instance = TeacherWorkspaceController._();

  static const Duration staleAfter = Duration(seconds: 40);
  static const Duration autoRefreshInterval = Duration(seconds: 45);

  final TeacherDashboardRepository _dashboardRepo = TeacherDashboardRepository();
  final ClassroomRepository _classesRepo = ClassroomRepository();
  final TeacherReportsRepository _reportsRepo = TeacherReportsRepository();

  TeacherDashboardPayload? dashboard;
  bool dashboardLoading = false;
  String? dashboardError;
  DateTime? _dashboardFetchedAt;
  Future<void>? _dashboardInflight;

  List<TeacherClassItem> classes = const [];
  bool classesLoading = false;
  String? classesError;
  DateTime? _classesFetchedAt;
  Future<void>? _classesInflight;

  TeacherReportsPayload? reports;
  String reportsQuery = '';
  bool reportsLoading = false;
  String? reportsError;
  DateTime? _reportsFetchedAt;
  String? _reportsCachedQuery;
  Future<void>? _reportsInflight;

  bool _isStale(DateTime? fetchedAt) {
    if (fetchedAt == null) return true;
    return DateTime.now().difference(fetchedAt) > staleAfter;
  }

  void invalidateAll() {
    _dashboardFetchedAt = null;
    _classesFetchedAt = null;
    _reportsFetchedAt = null;
  }

  void reset() {
    dashboard = null;
    dashboardLoading = false;
    dashboardError = null;
    _dashboardFetchedAt = null;
    _dashboardInflight = null;

    classes = const [];
    classesLoading = false;
    classesError = null;
    _classesFetchedAt = null;
    _classesInflight = null;

    reports = null;
    reportsQuery = '';
    reportsLoading = false;
    reportsError = null;
    _reportsFetchedAt = null;
    _reportsCachedQuery = null;
    _reportsInflight = null;

    notifyListeners();
  }

  Future<void> loadDashboard({bool force = false}) async {
    if (!force && _dashboardFetchedAt != null && !_isStale(_dashboardFetchedAt)) return;
    if (_dashboardInflight != null) {
      await _dashboardInflight;
      return;
    }

    final showSpinner = dashboard == null;
    if (showSpinner) {
      dashboardLoading = true;
      notifyListeners();
    }

    _dashboardInflight = _fetchDashboard(showSpinner: showSpinner);
    try {
      await _dashboardInflight;
    } finally {
      _dashboardInflight = null;
    }
  }

  Future<void> _fetchDashboard({required bool showSpinner}) async {
    try {
      dashboard = await _dashboardRepo.fetchDashboard();
      dashboardError = null;
      _dashboardFetchedAt = DateTime.now();
    } on ApiException catch (e) {
      dashboardError = e.message;
    } catch (_) {
      dashboardError = 'Could not load dashboard.';
    } finally {
      if (showSpinner) dashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClasses({bool force = false}) async {
    if (!force && _classesFetchedAt != null && !_isStale(_classesFetchedAt)) return;
    if (_classesInflight != null) {
      await _classesInflight;
      return;
    }

    final showSpinner = classes.isEmpty;
    if (showSpinner) {
      classesLoading = true;
      classesError = null;
      notifyListeners();
    }

    _classesInflight = _fetchClasses(showSpinner: showSpinner);
    try {
      await _classesInflight;
    } finally {
      _classesInflight = null;
    }
  }

  Future<void> _fetchClasses({required bool showSpinner}) async {
    try {
      classes = await _classesRepo.listClasses();
      classesError = null;
      _classesFetchedAt = DateTime.now();
    } on ApiException catch (e) {
      classesError = e.message;
    } catch (_) {
      classesError = 'Could not load classes. Please try again.';
    } finally {
      if (showSpinner) classesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReports({
    bool force = false,
    String? query,
    int studentLimit = 100,
  }) async {
    final q = (query ?? reportsQuery).trim();
    reportsQuery = q;

    if (!force &&
        _reportsFetchedAt != null &&
        _reportsCachedQuery == q &&
        !_isStale(_reportsFetchedAt)) {
      return;
    }
    if (_reportsInflight != null) {
      await _reportsInflight;
      return;
    }

    final showSpinner = reports == null;
    if (showSpinner) {
      reportsLoading = true;
      reportsError = null;
      notifyListeners();
    }

    _reportsInflight = _fetchReports(
      query: q,
      studentLimit: studentLimit,
      showSpinner: showSpinner,
    );
    try {
      await _reportsInflight;
    } finally {
      _reportsInflight = null;
    }
  }

  Future<void> _fetchReports({
    required String query,
    required int studentLimit,
    required bool showSpinner,
  }) async {
    try {
      reports = await _reportsRepo.fetchReports(
        query: query.isEmpty ? null : query,
        studentLimit: studentLimit,
      );
      reportsError = null;
      _reportsCachedQuery = query;
      _reportsFetchedAt = DateTime.now();
    } on ApiException catch (e) {
      reportsError = e.message;
    } catch (_) {
      reportsError = 'Could not load reports.';
    } finally {
      if (showSpinner) reportsLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncTab(int index, {bool force = false}) {
    switch (index) {
      case 0:
        return loadDashboard(force: force);
      case 1:
        return loadClasses(force: force);
      case 2:
        return loadReports(force: force);
      default:
        return Future.value();
    }
  }

  Future<void> syncVisitedTabs(Set<int> visited, {bool force = false}) async {
    final tasks = <Future<void>>[];
    if (visited.contains(0)) tasks.add(loadDashboard(force: force));
    if (visited.contains(1)) tasks.add(loadClasses(force: force));
    if (visited.contains(2)) tasks.add(loadReports(force: force));
    if (tasks.isEmpty) return;
    await Future.wait(tasks);
  }
}
