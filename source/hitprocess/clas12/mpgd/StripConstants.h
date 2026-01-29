#ifndef StripConstants_H
#define StripConstants_H 1

class StripConstants
{
public:
  // database
  int runNo = -1;
  string date;
  string connection;
  char database[80];

  std::string digiVariation = "";
  std::string digiSnapshotTime = "";

  // --- Trapezoid geometry in LOCAL frame of GAS volume
  // y = -yHalf: small base; y = +yHalf: large base
  double xHalfSmall = 0.0; // mm
  double xHalfLarge = 0.0; // mm
  double yHalf = 0.0;      // mm
  double zHalf = 0.0;      // mm

  // Readout plane position in GAS LOCAL frame (mm).
  double zReadoutLocal = 0.0;

  // --- Strip parameters
  // stereoAngleY: angle of STRIP DIRECTION measured from +Y toward +X (radians).
  double stereoAngleY = 0.0; // rad
  double stereoAngle = 0.0;

  double pitch = 0.0; // mm (spacing in the perpendicular-to-strip direction)
  double width = 0.0; // mm (strip width, in perpendicular-to-strip direction)

  // --- Ionization/amplification model
  double w_i = 26.0; // eV
  double gain = 6000.0;

  // --- Charge sharing / diffusion (in strip frame)
  double sigma_td = 0.15; // mm (sigma for transverse charge spread on readout)

  // --- Timing
  double v_drift = 0.005;   // cm/ns
  double sigma_time = 10.0; // ns

  void SetStripParams(double stereoAngleY_rad, double pitch_mm, double width_mm)
  {
    stereoAngle = stereoAngleY_rad;
    pitch = pitch_mm;
    width = width_mm;
  }
};
#endif