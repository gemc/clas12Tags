#ifndef StripDigitizer_H
#define StripDigitizer_H 1

#include <vector>
#include <unordered_map>
#include <array>
#include <utility>
#include <ostream>
#include <string>

using namespace std;

#include "G4ThreeVector.hh"
#include "G4AffineTransform.hh"
#include "StripConstants.h"

struct StripHit
{
	int stripID = 0; // 1..N, where 1 is most negative GLOBAL X
	int electrons = 0;
	double time = 0.0; // ns
};

class StripDigitizer
{
public:
	std::vector<StripHit> FindStrips(const G4ThreeVector &localPos,
									 double Edep,
									 const StripConstants &c,
									 double t0);

	int GetNumberOfStrips(const StripConstants &c,
						  const G4AffineTransform &globalToLocal);

	// Debug helper: dump cached strip endpoints

	void DumpStripsDebug(std::ostream &os,
						 int layer,
						 const G4AffineTransform &globalToLocal) const;

	void GetStripInfoByStripID(int stripID, const G4AffineTransform &globalToLocal);

private:
	struct CacheSignature
	{
		double pitch, width, stereoAngle;
		double xHalfSmall, xHalfLarge, yHalf;
		double zReadoutLocal;
	};

	struct StripGeom
	{
		int internalIndex = 0; // mathematical index
		int stripID = 0;	   // 1..N

		// Endpoints on the readout plane
		G4ThreeVector p1_local, p2_local; // in GAS local frame

		// Cached rectangle in strip frame (x_s along strip, y_s across strip)
		double centerXs = 0.0;
		double centerYs = 0.0;
		double halfLenXs = 0.0;

		// Ordering key: local X of strip midpoint (stripID=1 => most negative global X)
		double orderX_local = 0.0;
	};

	bool cacheBuilt = false;
	int cacheVersion = 0;
	CacheSignature sig{};

	// cache signature (rebuild if any changes)
	double sig_xSmall = 0, sig_xLarge = 0, sig_y = 0, sig_z = 0;
	double sig_zReadout = 0, sig_pitch = 0, sig_width = 0, sig_stereoY = 0;
	std::array<double, 9> sig_rot{{0, 0, 0, 0, 0, 0, 0, 0, 0}};

	std::vector<StripGeom> strips;		  // index = stripID-1
	std::unordered_map<int, int> idxToID; // internalIndex -> stripID

	bool SameSignature(const StripConstants &c) const;
	void EnsureCache(const StripConstants &c);
	void BuildCache(const StripConstants &c);

	// --- Geometry (trapezoid at z=zReadoutLocal)
	struct Trap2D
	{
		G4ThreeVector bl, br, tr, tl;
		static Trap2D FromConstants(const StripConstants &c);
		std::array<std::pair<G4ThreeVector, G4ThreeVector>, 4> edges() const;
	};

	static bool IntersectEdgeWithLineNormal(const G4ThreeVector &A,
											const G4ThreeVector &B,
											const G4ThreeVector &n_xy,
											double rhs,
											G4ThreeVector &out);

	bool BuildStripSegment(int internalIndex,
						   const StripConstants &c,
						   G4ThreeVector &out_p1,
						   G4ThreeVector &out_p2) const;

	// --- Strip frame transform (stereoAngleY is w.r.t +Y)
	// x_s: along strip direction
	// y_s: perpendicular to strip (pitch direction)
	static std::pair<double, double> ToStripFrameXY(double x, double y,
													const StripConstants &c);

	static G4ThreeVector ToStripFrame(const G4ThreeVector &p,
									  const StripConstants &c);

	// Weight / charge sharing
	static double WeightFraction(const StripGeom &s,
								 const G4ThreeVector &hit_s,
								 const StripConstants &c);
};
#endif