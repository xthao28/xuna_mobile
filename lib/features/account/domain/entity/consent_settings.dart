import 'package:equatable/equatable.dart';

/// Owner data-sharing choices on XUNA Cloud (D23). Every class is a separate
/// opt-in and off by default (U0: nothing is uploaded).
class ConsentSettings extends Equatable {
  const ConsentSettings({
    this.aggregateMetrics = false,
    this.experienceEvents = false,
    this.conversationText = false,
    this.version = 0,
  });

  /// U1: aggregate, content-free usage numbers.
  final bool aggregateMetrics;

  /// U2: device experience events (future projections).
  final bool experienceEvents;

  /// U3: conversation text may be sent to the AI provider for a reply.
  final bool conversationText;

  /// Server version; an update must name the version it was based on.
  final int version;

  ConsentSettings copyWith({
    bool? aggregateMetrics,
    bool? experienceEvents,
    bool? conversationText,
  }) =>
      ConsentSettings(
        aggregateMetrics: aggregateMetrics ?? this.aggregateMetrics,
        experienceEvents: experienceEvents ?? this.experienceEvents,
        conversationText: conversationText ?? this.conversationText,
        version: version,
      );

  @override
  List<Object?> get props =>
      [aggregateMetrics, experienceEvents, conversationText, version];
}
