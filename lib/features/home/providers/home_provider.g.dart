// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'52c86bb0bb6e3507c64c8f968286356d115166e8';

/// See also [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeProvider<DashboardRepository>.internal(
  dashboardRepository,
  name: r'dashboardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DashboardRepositoryRef = AutoDisposeProviderRef<DashboardRepository>;
String _$sseClientServiceHash() => r'8621ab707708adfde0aafaacfd6ba92613aa7c95';

/// See also [sseClientService].
@ProviderFor(sseClientService)
final sseClientServiceProvider = AutoDisposeProvider<SseClientService>.internal(
  sseClientService,
  name: r'sseClientServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sseClientServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SseClientServiceRef = AutoDisposeProviderRef<SseClientService>;
String _$dashboardSseServiceHash() =>
    r'540456a0e539ca97e4dd8d3b13f50ca467b3e8f4';

/// See also [dashboardSseService].
@ProviderFor(dashboardSseService)
final dashboardSseServiceProvider =
    AutoDisposeProvider<DashboardSseService>.internal(
  dashboardSseService,
  name: r'dashboardSseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardSseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DashboardSseServiceRef = AutoDisposeProviderRef<DashboardSseService>;
String _$dashboardUpdatesHash() => r'b317a3e23f772951143bce98d9797a3411d2a8ec';

/// See also [dashboardUpdates].
@ProviderFor(dashboardUpdates)
final dashboardUpdatesProvider =
    AutoDisposeStreamProvider<DashboardModel>.internal(
  dashboardUpdates,
  name: r'dashboardUpdatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardUpdatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DashboardUpdatesRef = AutoDisposeStreamProviderRef<DashboardModel>;
String _$dashboardControllerHash() =>
    r'67a3032366805c3e9f1c5778b7b3d0f5bfc4c986';

/// See also [DashboardController].
@ProviderFor(DashboardController)
final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardModel>.internal(
  DashboardController.new,
  name: r'dashboardControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DashboardController = AsyncNotifier<DashboardModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
