// A central place for all domain lists used across UI

class DataLists {
  // Soil types with optional weight/fertility factor (you can extend)
  static const List<String> soils = [
    'Alluvial Soil',
    'Black Soil (Regur)',
    'Red Soil',
    'Laterite Soil',
    'Loamy Soil',
    'Sandy Soil',
    'Marshy Soil',
    'Arid Soil',
    'Mountain Soil'
  ];

  // Common crops grouped roughly by category
  static const List<String> foodGrains = [
    'Rice',
    'Wheat',
    'Maize',
    'Millets',
    'Pulses'
  ];

  static const List<String> cashCrops = [
    'Cotton',
    'Sugarcane',
    'Jute',
    'Tea',
    'Coffee',
    'Oilseeds',
    'Tobacco'
  ];

  static const List<String> horticulture = [
    'Fruits',
    'Vegetables',
    'Flowers'
  ];

  static List<String> allCrops() {
    return [...foodGrains, ...cashCrops, ...horticulture];
  }

  // Seasons with typical Indian cropping seasons
  static const Map<String, List<String>> seasonMonths = {
    'Kharif (Jun–Sep)': ['June', 'July', 'August', 'September'],
    'Rabi (Oct–Mar)': ['October', 'November', 'December', 'January', 'February', 'March'],
    'Zaid (Apr–Jun)': ['April', 'May', 'June']
  };

  // Flattened list for season selection
  static List<String> seasons() => seasonMonths.keys.toList();
}
