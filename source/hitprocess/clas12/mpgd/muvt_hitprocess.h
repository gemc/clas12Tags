#ifndef muvt_HITPROCESS_H
#define muvt_HITPROCESS_H 1

// gemc headers
#include "HitProcess.h"

// geant4
// #include "G4Step.hh"

// generic strip digitizer
#include "StripDigitizer.h"
#include "StripConstants.h"

class muvt_HitProcess : public HitProcess
{
public:
	~muvt_HitProcess() { ; }

	// - integrateDgt: returns digitized information integrated over the hit
	map<string, double> integrateDgt(MHit *, int);

	// - multiDgt: returns multiple digitized information / hit
	map<string, vector<int>> multiDgt(MHit *, int);

	// - charge: returns charge/time digitized information / step
	virtual map<int, vector<double>> chargeTime(MHit *, int);

	// - voltage: returns a voltage value for a given time. The input are charge value, time
	virtual double voltage(double, double, double);

	// The pure virtual method processID returns a (new) identifier
	// containing hit sharing information
	vector<identifier> processID(vector<identifier>, G4Step *, detector);

	// creates the HitProcess
	static HitProcess *createHitClass() { return new muvt_HitProcess; }

private:
	std::unordered_map<int, StripDigitizer> digi_byLayer;
	void initWithRunNumber(int runno);
	// constants initialized with initWithRunNumber
	static StripConstants muvtC;
	bool constantsLoaded = false;

	// cache digitizer per layer + view
	static std::unordered_map<int, StripDigitizer> digiU_byLayer;
	static std::unordered_map<int, StripDigitizer> digiV_byLayer;

	// - electronicNoise: returns a vector of hits generated / by electronics.
	vector<MHit *> electronicNoise();
};

#endif
