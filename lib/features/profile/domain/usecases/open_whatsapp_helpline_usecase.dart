import 'package:url_launcher/url_launcher.dart';

const String _kHelphoneNumber = '8686234434';
const String _kCountryCode = '91';
const String _kFormattedNumber = '+91 8686234434';

/// Clean Architecture UseCase to open WhatsApp Helpline for Driver App
class OpenWhatsAppHelplineUseCase {
  static const String helplineNumber = _kHelphoneNumber;
  static const String countryCode = _kCountryCode;
  static const String formattedNumber = _kFormattedNumber;

  final String defaultMessage;

  OpenWhatsAppHelplineUseCase({
    this.defaultMessage =
        'Hello, I am a Driver on the Car Driver app and need support.',
  });

  Future<bool> execute({String? message}) async {
    final msg = message ?? defaultMessage;
    final fullNumber = '$_kCountryCode$_kHelphoneNumber';
    final encodedMessage = Uri.encodeComponent(msg);
    final whatsappAppUri = Uri.parse(
      'whatsapp://send?phone=$fullNumber&text=$encodedMessage',
    );
    final whatsappWebUri = Uri.parse(
      'https://wa.me/$fullNumber?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(whatsappAppUri)) {
        return await launchUrl(
          whatsappAppUri,
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(whatsappWebUri)) {
        return await launchUrl(
          whatsappWebUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return await launchUrl(
          whatsappWebUri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (_) {
      try {
        return await launchUrl(
          whatsappWebUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        return false;
      }
    }
  }
}
