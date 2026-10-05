import 'package:flutter/material.dart';

import '../data/event_repository.dart';
import '../models/event.dart';
import '../screens/cart_summary_screen.dart';
import '../screens/directory_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/event_list_screen.dart';
import '../screens/participant_detail_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/route_error_screen.dart';
import 'app_routes.dart';

class EventDetailRouteResolution {
  const EventDetailRouteResolution.event(this.event) : errorMessage = null;

  const EventDetailRouteResolution.error(this.errorMessage) : event = null;

  final Event? event;
  final String? errorMessage;

  bool get isSuccess => event != null;
}

class RouteGenerator {
  RouteGenerator._();

  static EventDetailRouteResolution resolveEventDetailArgs(
    RouteSettings settings,
    EventRepository repository,
  ) {
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

    final event = repository.findById(arguments);
    if (event == null) {
      return EventDetailRouteResolution.error(
        'Aucun événement ne correspond à l\'identifiant « $arguments ».',
      );
    }

    return EventDetailRouteResolution.event(event);
  }

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    EventRepository repository,
  ) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const EventListScreen(),
        );
      case AppRoutes.eventDetail:
        return _buildEventDetailRoute(settings, repository);
      case AppRoutes.cartSummary:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CartSummaryScreen(),
        );
      case AppRoutes.reservations:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CartSummaryScreen(),
        );
      case AppRoutes.directory:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DirectoryScreen(),
        );
      case AppRoutes.participantDetail:
        return _buildParticipantDetailRoute(settings);
      default:
        return _buildNotFoundRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _buildNotFoundRoute(settings);
  }

  static Route<dynamic> onGenerateHomeTabRoute(
    RouteSettings settings,
    EventRepository repository,
  ) {
    switch (settings.name) {
      case AppRoutes.home:
      case null:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.home),
          builder: (_) => const EventListScreen(),
        );
      case AppRoutes.eventDetail:
        return _buildEventDetailRoute(settings, repository);
      case AppRoutes.cartSummary:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CartSummaryScreen(),
        );
      case AppRoutes.directory:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DirectoryScreen(),
        );
      case AppRoutes.participantDetail:
        return _buildParticipantDetailRoute(settings);
      default:
        return _buildNotFoundRoute(settings);
    }
  }

  static Route<dynamic> onGenerateReservationsTabRoute(
    RouteSettings settings,
    EventRepository repository,
  ) {
    switch (settings.name) {
      case AppRoutes.reservations:
      case Navigator.defaultRouteName:
      case null:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.reservations),
          builder: (_) => const CartSummaryScreen(),
        );
      case AppRoutes.eventDetail:
        return _buildEventDetailRoute(settings, repository);
      case AppRoutes.cartSummary:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CartSummaryScreen(),
        );
      default:
        return _buildNotFoundRoute(settings);
    }
  }

  static Route<dynamic> _buildEventDetailRoute(
    RouteSettings settings,
    EventRepository repository,
  ) {
    final resolution = resolveEventDetailArgs(settings, repository);

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

  static Route<dynamic> _buildParticipantDetailRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    if (arguments is! int) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const RouteErrorScreen(
          message: 'Identifiant participant invalide.',
        ),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => ParticipantDetailScreen(participantId: arguments),
    );
  }

  static MaterialPageRoute<void> _buildNotFoundRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => NotFoundScreen(routeName: settings.name),
    );
  }
}
