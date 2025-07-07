// gemc headers
#include "bubble_hitprocess.h"

// CLHEP units
#include "CLHEP/Units/PhysicalConstants.h"
using namespace CLHEP;

map<string, double> bubble_HitProcess :: integrateDgt(MHit* aHit, [[maybe_unused]] int hitn)
{
	map<string, double> dgtz;
	if(aHit->isBackgroundHit == 1) return dgtz;
	rejectHitConditions = false;
	writeHit = true;

	vector<identifier> identity = aHit->GetId();
	int thisPid = aHit->GetPID();
	double totEnergy = aHit->GetE();
	
	if(thisPid == 11 || thisPid == -11) totEnergy -= electron_mass_c2;

	dgtz["detId"] = identity[0].id;
	dgtz["kinE"]  = totEnergy;
	dgtz["pid"]   = thisPid;
	dgtz["hitn"]  = hitn;
	
	// define conditions to reject hit
	if(rejectHitConditions) {
		writeHit = false;
	}
	
	return dgtz;
}

vector<identifier>  bubble_HitProcess :: processID(vector<identifier> id, [[maybe_unused]] G4Step* aStep, [[maybe_unused]] detector Detector)
{
	id[id.size()-1].id_sharing = 1;
	return id;
}

// - electronicNoise: returns a vector of hits generated / by electronics.
vector<MHit*> bubble_HitProcess :: electronicNoise()
{
	vector<MHit*> noiseHits;

	// first, identify the cells that would have electronic noise
	// then instantiate hit with energy E, time T, identifier IDF:
	//
	// MHit* thisNoiseHit = new MHit(E, T, IDF, pid);

	// push to noiseHits collection:
	// noiseHits.push_back(thisNoiseHit)

	return noiseHits;
}


map< string, vector <int> >  bubble_HitProcess :: multiDgt([[maybe_unused]] MHit* aHit, [[maybe_unused]] int hitn)
{
	map< string, vector <int> > MH;
	
	return MH;
}


// - charge: returns charge/time digitized information / step
map< int, vector <double> > bubble_HitProcess :: chargeTime([[maybe_unused]] MHit* aHit, [[maybe_unused]] int hitn)
{
	map< int, vector <double> >  CT;

	return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)
double bubble_HitProcess :: voltage([[maybe_unused]] double charge, [[maybe_unused]] double time, [[maybe_unused]] double forTime)
{
	return 0.0;
}

