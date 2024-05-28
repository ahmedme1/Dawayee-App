enum MedicationFrequency {
  every_8_hours,
  every_12_hours,
  every_24_hours,
  custom,
}

extension MedicationFrequencyExtension on MedicationFrequency {
  String get displayValue {
    switch (this) {
      case MedicationFrequency.every_8_hours:
        return 'Every 8 hours';
      case MedicationFrequency.every_12_hours:
        return 'Every 12 hours';
      case MedicationFrequency.every_24_hours:
        return 'Every 24 hours';
      case MedicationFrequency.custom:
        return 'Custom';
      default:
        return '';
    }
  }
}
