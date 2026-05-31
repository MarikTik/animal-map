/// The category of a detected road incident.
///
/// Carries both the wire format (`jsonValue`) used when decoding the
/// backend payload, an optional `assetPath` used to render the marker icon,
/// and an `alertPhrase` spoken via TTS when the incident is detected nearby.
enum IncidentType {
  animalOnRoad(
    'animal_on_road',
    assetPath: 'assets/markers/deer.png',
    alertPhrase: 'Animal on the road ahead',
  ),
  personOnRoad(
    'person_on_road',
    assetPath: 'assets/markers/deer.png',
    alertPhrase: 'Person on the road ahead',
  ),
  stoppedVehicle('stopped_vehicle', alertPhrase: 'Stopped vehicle ahead'),
  roadObstruction('road_obstruction', alertPhrase: 'Road obstruction ahead'),
  unknown('unknown', alertPhrase: 'Hazard ahead');

  const IncidentType(
    this.jsonValue, {
    this.assetPath,
    required this.alertPhrase,
  });

  /// JSON-wire identifier as used in the backend incident contract.
  final String jsonValue;

  /// Path to the marker icon asset, or `null` if no icon is mapped
  /// (caller should fall back to the default marker).
  final String? assetPath;

  /// Short spoken phrase announced via TTS when this incident type is detected.
  final String alertPhrase;

  /// Human-readable label derived from [jsonValue] — e.g.
  /// `animal_on_road` → `Animal on road`. Used in UI surfaces like
  /// the info bar.
  String get label {
    if (jsonValue.isEmpty) return '';
    final words = jsonValue.split('_');
    return '${words.first[0].toUpperCase()}${words.first.substring(1)}'
        '${words.length > 1 ? ' ${words.sublist(1).join(' ')}' : ''}';
  }

  /// Resolves an [IncidentType] from its JSON wire value.
  ///
  /// Throws [FormatException] if [value] does not match any known type.
  static IncidentType fromJson(String value) {
    for (final type in values) {
      if (type.jsonValue == value) return type;
    }
    throw FormatException('Unsupported incident type: $value');
  }
}
