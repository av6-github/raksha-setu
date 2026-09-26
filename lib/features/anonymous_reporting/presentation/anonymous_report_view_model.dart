// lib/features/anonymous_reporting/presentation/anonymous_report_view_model.dart
// Presentation ViewModel managing anonymous whistleblower submissions and case tracking

import 'package:flutter/foundation.dart';
import '../data/anonymous_report_repository.dart';
import '../domain/anonymous_report.dart';
import '../domain/report_category.dart';

class AnonymousReportViewModel extends ChangeNotifier {
  final IAnonymousReportRepository repository;

  ReportCategory _selectedCategory = ReportCategory.unsafeConditions;
  String _reportText = '';
  String _unitIdentifier = '';
  String? _generatedTrackingToken;

  AnonymousReport? _trackedReport;
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String? _successMessage;

  AnonymousReportViewModel({required this.repository});

  ReportCategory get selectedCategory => _selectedCategory;
  String get reportText => _reportText;
  String get unitIdentifier => _unitIdentifier;
  String? get generatedTrackingToken => _generatedTrackingToken;
  AnonymousReport? get trackedReport => _trackedReport;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void setCategory(ReportCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setReportText(String text) {
    _reportText = text;
    notifyListeners();
  }

  void setUnitIdentifier(String unit) {
    _unitIdentifier = unit;
    notifyListeners();
  }

  Future<String?> submitReport() async {
    if (_reportText.trim().isEmpty) {
      _errorMessage = 'Please provide details of the concern or incident.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final token = await repository.submitReport(
        category: _selectedCategory,
        reportText: _reportText.trim(),
        unitIdentifierGeneral: _unitIdentifier.trim().isEmpty ? null : _unitIdentifier.trim(),
      );

      _generatedTrackingToken = token;
      _reportText = '';
      _unitIdentifier = '';
      _successMessage = 'Anonymous report submitted securely.';
      return token;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchReport(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) {
      _errorMessage = 'Please enter a valid tracking token.';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await repository.trackReport(cleanToken);
      _trackedReport = report;
      if (report == null) {
        _errorMessage = 'No report found matching token "$cleanToken". Please check and try again.';
      }
    } catch (e) {
      _errorMessage = 'Error retrieving report: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _generatedTrackingToken = null;
    notifyListeners();
  }
}
