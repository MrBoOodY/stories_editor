class FilterConstants {
  //Filters
  static List<String> filterTitle = [
    "None",
    "Pop",
    "B&W",
    "Cool",
    "Chrome",
    "Film"
  ];
  static List<List<double>> filters = [
    FilterConstants.NONE,
    FilterConstants.FILTER_3,
    FilterConstants.GREYSCALE_MATRIX,
    FilterConstants.FILTER_4,
    FilterConstants.FILTER_5,
    FilterConstants.VINTAGE_MATRIX,
    FilterConstants.SEPIA_MATRIX,
    FilterConstants.FILTER_1,
    FilterConstants.FILTER_2,
  ];

  static List<double> NONE = [
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0
  ];

  static List<double> SEPIA_MATRIX = [
    0.39,
    0.769,
    0.189,
    0.0,
    0.0,
    0.349,
    0.686,
    0.168,
    0.0,
    0.0,
    0.272,
    0.534,
    0.131,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0
  ];

  static List<double> GREYSCALE_MATRIX = [
    0.2126,
    0.7152,
    0.0722,
    0.0,
    0.0,
    0.2126,
    0.7152,
    0.0722,
    0.0,
    0.0,
    0.2126,
    0.7152,
    0.0722,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0
  ];

  static List<double> VINTAGE_MATRIX = [
    0.9,
    0.5,
    0.1,
    0.0,
    0.0,
    0.3,
    0.8,
    0.1,
    0.0,
    0.0,
    0.2,
    0.3,
    0.5,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0
  ];

  static List<double> FILTER_1 = [
    1.0,
    0.0,
    0.2,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0
  ];

  static List<double> FILTER_2 = [
    0.4,
    0.4,
    -0.3,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.2,
    0.0,
    0.0,
    -1.2,
    0.6,
    0.7,
    1.0,
    0.0
  ];

  static List<double> FILTER_3 = [
    0.8,
    0.5,
    0.0,
    0.0,
    0.0,
    0.0,
    1.1,
    0.0,
    0.0,
    0.0,
    0.0,
    0.2,
    1.1,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0
  ];

  static List<double> FILTER_4 = [
    1.1,
    0.0,
    0.0,
    0.0,
    0.0,
    0.2,
    1.0,
    -0.4,
    0.0,
    0.0,
    -0.1,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0
  ];

  static List<double> FILTER_5 = [
    1.2,
    0.1,
    0.5,
    0.0,
    0.0,
    0.1,
    1.0,
    0.05,
    0.0,
    0.0,
    0.0,
    0.1,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0
  ];
}
