/// `GET/PUT /v1/consents` body (contract draft §2, CLD-12).
class ConsentModel {
  const ConsentModel({
    required this.aggregateMetrics,
    required this.experienceEvents,
    required this.conversationText,
    required this.version,
  });

  /// Throws [FormatException] when a field is missing or has the wrong type.
  factory ConsentModel.fromJson(Map<String, dynamic> json) {
    final aggregateMetrics = json['aggregateMetrics'];
    final experienceEvents = json['experienceEvents'];
    final conversationText = json['conversationText'];
    final version = json['version'];
    if (aggregateMetrics is! bool ||
        experienceEvents is! bool ||
        conversationText is! bool ||
        version is! int ||
        version < 0) {
      throw const FormatException('Invalid consents');
    }
    return ConsentModel(
      aggregateMetrics: aggregateMetrics,
      experienceEvents: experienceEvents,
      conversationText: conversationText,
      version: version,
    );
  }

  static const schemaVersion = 1;

  final bool aggregateMetrics;
  final bool experienceEvents;
  final bool conversationText;
  final int version;

  /// `PUT` body: [version] becomes `expectedVersion`.
  Map<String, dynamic> toUpdateJson() => {
        'schemaVersion': schemaVersion,
        'aggregateMetrics': aggregateMetrics,
        'experienceEvents': experienceEvents,
        'conversationText': conversationText,
        'expectedVersion': version,
      };
}
