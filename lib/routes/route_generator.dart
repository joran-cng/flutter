import 'package:flutter/material.dart';

import '../data/sample_events.dart';
import '../models/event.dart';
import '../models/participation_package.dart';
import '../screens/confirmation_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/event_wall_screen.dart';
import '../screens/my_reservations_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/package_selection_screen.dart';
import '../screens/route_error_screen.dart';
import 'app_routes.dart';

class ConfirmationRouteArgs {
  const ConfirmationRouteArgs({
    required this.event,
    required this.package,
  });

  final Event event;
  final ParticipationPackage package;
}

class EventDetailRouteResolution {
  const EventDetailRouteResolution.event(this.event)
      : errorMessage = null;

  const EventDetailRouteResolution.error(this.errorMessage) : event = null;

  final Event? event;
  final String? errorMessage;

  bool get isSuccess => event != null;
}

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const EventWallScreen(),
        );
      case AppRoutes.eventDetail:
        return _buildEventDetailRoute(settings);
      case AppRoutes.packageSelection:
        return _buildPackageSelectionRoute(settings);
      case AppRoutes.confirmation:
        return _buildConfirmationRoute(settings);
      case AppRoutes.reservations:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MyReservationsScreen(),
        );
      default:
        return _buildNotFoundRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _buildNotFoundRoute(settings);
  }

  static Route<dynamic> onGenerateHomeTabRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
      case null:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.home),
          builder: (_) => const EventWallScreen(),
        );
      case AppRoutes.eventDetail:
        return _buildEventDetailRoute(settings);
      case AppRoutes.packageSelection:
        return _buildPackageSelectionRoute(settings);
      case AppRoutes.confirmation:
        return _buildConfirmationRoute(settings);
      default:
        return _buildNotFoundRoute(settings);
    }
  }

  static Route<dynamic> onGenerateReservationsTabRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.reservations:
      case Navigator.defaultRouteName:
      case null:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.reservations),
          builder: (_) => const MyReservationsScreen(),
        );
      case AppRoutes.eventDetail:
        return _buildEventDetailRoute(settings);
      default:
        return _buildNotFoundRoute(settings);
    }
  }

  static EventDetailRouteResolution resolveEventDetailArgs(RouteSettings settings) {
    final arguments = settings.arguments;

    if (arguments == null) {
      return const EventDetailRouteResolution.error(
        'Aucun identifiant d\'événement n\'a été transmis à cette route.',
      );
    }

    if (arguments is! String) {
      return EventDetailRouteResolution.error(
        'Type d\'argument inattendu (${arguments.runtimeType}) : '
        'un identifiant textuel (String) est requis.',
      );
    }

    final event = findEventById(arguments);
    if (event == null) {
      return EventDetailRouteResolution.error(
        'Aucun événement ne correspond à l\'identifiant « $arguments ».',
      );
    }

    return EventDetailRouteResolution.event(event);
  }

  static Route<dynamic> _buildEventDetailRoute(RouteSettings settings) {
    final resolution = resolveEventDetailArgs(settings);

    if (resolution.isSuccess) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => EventDetailScreen(event: resolution.event!),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => RouteErrorScreen(message: resolution.errorMessage!),
    );
  }

  static Route<dynamic> _buildPackageSelectionRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    if (arguments is! String) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const RouteErrorScreen(
          message:
              'Impossible d\'ouvrir la sélection : identifiant d\'événement manquant ou invalide.',
        ),
      );
    }

    final event = findEventById(arguments);
    if (event == null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => RouteErrorScreen(
          message: 'Événement introuvable pour l\'identifiant « $arguments ».',
        ),
      );
    }

    return MaterialPageRoute<ParticipationPackage?>(
      settings: settings,
      builder: (_) => PackageSelectionScreen(event: event),
    );
  }

  static Route<dynamic> _buildConfirmationRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    if (arguments is! ConfirmationRouteArgs) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const RouteErrorScreen(
          message:
              'Impossible d\'afficher la confirmation : arguments de route invalides.',
        ),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => ConfirmationScreen(
        event: arguments.event,
        package: arguments.package,
      ),
    );
  }

  static MaterialPageRoute<void> _buildNotFoundRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => NotFoundScreen(routeName: settings.name),
    );
  }
}
