/// Step length in meters (0.8 m per step).
const double metersPerStep = 0.8;

/// Converts total steps to distance in km.
double stepsToKm(int steps) => steps * metersPerStep / 1000;