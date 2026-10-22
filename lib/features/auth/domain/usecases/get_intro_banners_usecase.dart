import '../entities/intro_banner.dart';
import '../repositories/auth_repository.dart';

/// Use case to fetch introductory screen banners configured in driver settings.
class GetIntroBannersUseCase {
  final AuthRepository repository;

  const GetIntroBannersUseCase(this.repository);

  Future<List<IntroBanner>> call() async {
    return await repository.getIntroBanners();
  }
}
