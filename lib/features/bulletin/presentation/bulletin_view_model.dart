// lib/features/bulletin/presentation/bulletin_view_model.dart
// ViewModel for Bulletin Board, Tailored Recommendations, Recognitions, and Testimonials

import 'package:flutter/material.dart';
import '../data/bulletin_recognition_repository.dart';
import '../domain/bulletin_event.dart';
import '../../recognition/domain/recognition_award.dart';

class BulletinViewModel extends ChangeNotifier {
  final IBulletinRecognitionRepository repository;
  final String officerId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Filter state
  EventCategory? _selectedCategory;
  EventCategory? get selectedCategory => _selectedCategory;

  String _locationQuery = '';
  String get locationQuery => _locationQuery;

  bool _freeTimeOnly = false;
  bool get freeTimeOnly => _freeTimeOnly;

  // Recognition tab mode: 0 = Public Wall of Commendation, 1 = My Honors & Badges
  int _recognitionSubTab = 0;
  int get recognitionSubTab => _recognitionSubTab;

  // Data collections
  List<BulletinEvent> _events = [];
  List<BulletinEvent> get events => _events;

  EventInterestPreference? _preferences;
  EventInterestPreference? get preferences => _preferences;

  List<RecognitionAward> _myRecognitions = [];
  List<RecognitionAward> get myRecognitions => _myRecognitions;

  List<RecognitionAward> _publicRecognitions = [];
  List<RecognitionAward> get publicRecognitions => _publicRecognitions;

  List<Testimonial> _testimonials = [];
  List<Testimonial> get testimonials => _testimonials;

  BulletinViewModel({
    required this.repository,
    required this.officerId,
  }) {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await repository.getPreferences(officerId);
      await _loadEvents();
      await _loadRecognitions();
      await _loadTestimonials();
    } catch (e) {
      _errorMessage = 'Failed to load bulletin data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadEvents() async {
    _events = await repository.getEvents(
      category: _selectedCategory,
      location: _locationQuery.isNotEmpty ? _locationQuery : null,
      freeTimeOnly: _freeTimeOnly,
      officerId: officerId,
    );
  }

  Future<void> _loadRecognitions() async {
    _myRecognitions = await repository.getOfficerRecognitions(officerId);
    _publicRecognitions = await repository.getPublicWallRecognitions();
  }

  Future<void> _loadTestimonials() async {
    _testimonials = await repository.getApprovedTestimonials();
  }

  void filterByCategory(EventCategory? category) async {
    _selectedCategory = category;
    _isLoading = true;
    notifyListeners();

    await _loadEvents();
    _isLoading = false;
    notifyListeners();
  }

  void filterByLocation(String query) async {
    _locationQuery = query;
    _isLoading = true;
    notifyListeners();

    await _loadEvents();
    _isLoading = false;
    notifyListeners();
  }

  void toggleFreeTimeOnly(bool value) async {
    _freeTimeOnly = value;
    _isLoading = true;
    notifyListeners();

    await _loadEvents();
    _isLoading = false;
    notifyListeners();
  }

  void setRecognitionSubTab(int index) {
    _recognitionSubTab = index;
    notifyListeners();
  }

  Future<void> toggleRsvp(String eventId) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    final newRsvp = !event.isRsvpd;
    await repository.rsvpEvent(eventId, officerId, newRsvp);
    await _loadEvents();
    notifyListeners();
  }

  Future<void> updatePublicConsent(String recognitionId, bool consent) async {
    try {
      await repository.updatePublicConsent(recognitionId, consent);
      _successMessage = consent
          ? 'Consent granted. Recognition is now visible on the public Wall of Commendation.'
          : 'Consent revoked. Recognition is now private to your profile.';
      await _loadRecognitions();
    } catch (e) {
      _errorMessage = 'Failed to update consent: $e';
    }
    notifyListeners();
  }

  Future<bool> submitPeerAppreciation({
    required String recipientName,
    required String title,
    required String citation,
    required RecognitionCategory category,
    required bool consentForPublic,
  }) async {
    try {
      _errorMessage = null;

      final award = RecognitionAward(
        id: 'rec-${DateTime.now().millisecondsSinceEpoch}',
        officerId: 'officer-recipient-${DateTime.now().millisecondsSinceEpoch}',
        recipientName: recipientName.trim(),
        awardedByName: 'Insp. Rajesh Kumar (Peer)',
        title: title.trim(),
        citation: citation.trim(),
        category: category,
        isInstitutionLevel: false,
        officerConsentForPublic: consentForPublic,
        opsecCleared: true,
        awardedAt: DateTime.now(),
      );

      await repository.submitRecognition(award);
      _successMessage = 'Appreciation sent successfully and cleared OPSEC review.';
      await _loadRecognitions();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
