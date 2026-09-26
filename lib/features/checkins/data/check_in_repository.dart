// lib/features/checkins/data/check_in_repository.dart
// Submit check-ins directly or via offline queue

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../core/logging/app_logger.dart';
import '../../../core/networking/network_client.dart';
import '../../../core/storage/offline_queue_service.dart';
import '../domain/check_in_model.dart';

abstract class ICheckInRepository {
  Future<CheckInModel> submitCheckIn(CheckInModel checkIn);
  Future<List<CheckInModel>> getRecentCheckIns(String officerId, {int limit = 10});
}

class CheckInRepository implements ICheckInRepository {
  final sp.SupabaseClient? client;
  final IOfflineQueueService offlineQueue;
  final INetworkInfo networkInfo;

  CheckInRepository({
    this.client,
    required this.offlineQueue,
    required this.networkInfo,
  });

  @override
  Future<CheckInModel> submitCheckIn(CheckInModel checkIn) async {
    final isOnline = await networkInfo.isConnected;

    if (!isOnline || client == null) {

      // Queue for later sync
      final offlineCheckIn = CheckInModel(
        officerId: checkIn.officerId,
        phq2Score: checkIn.phq2Score,
        gad2Score: checkIn.gad2Score,
        sleepQualityScore: checkIn.sleepQualityScore,
        workloadScore: checkIn.workloadScore,
        freeTextEncrypted: checkIn.freeTextEncrypted,
        isOfflineSubmission: true,
        checkInDate: checkIn.checkInDate,
      );

      await offlineQueue.enqueue('check_ins', offlineCheckIn.toDbPayload());
      AppLogger.info('Check-in queued for offline sync', data: {
        'phq2': checkIn.phq2Score,
        'gad2': checkIn.gad2Score,
      });
      return offlineCheckIn;
    }

    try {
      final payload = checkIn.toDbPayload();
      final res = await client!
          .from('check_ins')
          .insert(payload)
          .select()
          .single();

      AppLogger.info('Check-in submitted to Supabase', data: {'id': res['id']});
      return CheckInModel.fromMap(res);
    } catch (e, st) {
      AppLogger.error('Check-in submission failed; queuing offline', error: e, stackTrace: st);
      final offlineCheckIn = CheckInModel(
        officerId: checkIn.officerId,
        phq2Score: checkIn.phq2Score,
        gad2Score: checkIn.gad2Score,
        sleepQualityScore: checkIn.sleepQualityScore,
        workloadScore: checkIn.workloadScore,
        freeTextEncrypted: checkIn.freeTextEncrypted,
        isOfflineSubmission: true,
        checkInDate: checkIn.checkInDate,
      );
      await offlineQueue.enqueue('check_ins', offlineCheckIn.toDbPayload());
      return offlineCheckIn;
    }
  }

  @override
  Future<List<CheckInModel>> getRecentCheckIns(String officerId, {int limit = 10}) async {
    if (client == null) return [];

    try {
      final res = await client!
          .from('check_ins')
          .select()
          .eq('officer_id', officerId)
          .order('check_in_date', ascending: false)
          .limit(limit);


      return (res as List).map((m) => CheckInModel.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.warning('Failed to fetch check-in history', error: e);
      return [];
    }
  }
}
