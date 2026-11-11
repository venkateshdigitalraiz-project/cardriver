import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../data/datasources/referral_remote_datasource.dart';
import '../../data/repositories/referral_repository_impl.dart';
import '../../domain/usecases/get_referral_info_usecase.dart';
import 'referral_event.dart';
import 'referral_state.dart';

class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final GetReferralInfoUseCase getReferralInfoUseCase;

  ReferralBloc({required this.getReferralInfoUseCase})
      : super(ReferralInitial()) {
    on<LoadReferralInfoEvent>(_onLoadReferralInfo);
    on<CopyReferralCodeEvent>(_onCopyReferralCode);
    on<ShareReferralEvent>(_onShareReferral);
  }

  factory ReferralBloc.createDefault({http.Client? client}) {
    final remoteDataSource = ReferralRemoteDataSourceImpl(client: client);
    final repository = ReferralRepositoryImpl(remoteDataSource: remoteDataSource);
    final useCase = GetReferralInfoUseCase(repository);
    return ReferralBloc(getReferralInfoUseCase: useCase);
  }

  Future<void> _onLoadReferralInfo(
    LoadReferralInfoEvent event,
    Emitter<ReferralState> emit,
  ) async {
    emit(ReferralLoading());
    try {
      final referral = await getReferralInfoUseCase(token: event.token);
      emit(ReferralLoaded(referral: referral));
    } catch (e) {
      emit(ReferralError('Failed to load referral details: ${e.toString()}'));
    }
  }

  Future<void> _onCopyReferralCode(
    CopyReferralCodeEvent event,
    Emitter<ReferralState> emit,
  ) async {
    await Clipboard.setData(ClipboardData(text: event.code));
    if (state is ReferralLoaded) {
      final current = state as ReferralLoaded;
      emit(current.copyWith(
        isCopied: true,
        message: 'Referral code copied to clipboard!',
      ));
    }
  }

  Future<void> _onShareReferral(
    ShareReferralEvent event,
    Emitter<ReferralState> emit,
  ) async {
    final text = event.text;
    await Clipboard.setData(ClipboardData(text: text));

    final encoded = Uri.encodeComponent(text);
    final whatsappUri = Uri.parse('whatsapp://send?text=$encoded');
    final webWhatsappUri = Uri.parse('https://wa.me/?text=$encoded');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webWhatsappUri)) {
        await launchUrl(webWhatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    if (state is ReferralLoaded) {
      final current = state as ReferralLoaded;
      emit(current.copyWith(
        message: 'Share message copied & ready to send!',
      ));
    }
  }
}

