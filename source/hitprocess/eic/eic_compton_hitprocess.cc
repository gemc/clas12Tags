// G4 headers
#include "G4UnitsTable.hh"
#include "G4Poisson.hh"
#include "Randomize.hh"
#include "G4SystemOfUnits.hh"
#include "G4PhysicalConstants.hh"
#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>
using namespace ccdb;

// gemc headers
#include "eic_compton_hitprocess.h"

map<string, double> eic_compton_HitProcess :: integrateDgt(MHit* aHit, [[maybe_unused]] int hitn)
{
	map<string, double> dgtz;	
	vector<identifier> identity = aHit->GetId();

	trueInfos tInfos(aHit);

	int id = identity[0].id;
	
	dgtz["hitn"] = hitn;
	dgtz["id"]  =  id;
	
	dgtz["pid"]     = (double) aHit->GetPID();
	dgtz["mpid"]    = (double) aHit->GetmPID();
	dgtz["tid"]     = (double) aHit->GetTId();
	dgtz["mtid"]    = (double) aHit->GetmTrackId();
	dgtz["otid"]    = (double) aHit->GetoTrackId();
	dgtz["trackE"]  = aHit->GetE();
	dgtz["totEdep"] = tInfos.eTot;
	dgtz["avg_x"]   = tInfos.x;
	dgtz["avg_y"]   = tInfos.y;
	dgtz["avg_z"]   = tInfos.z;
	dgtz["avg_lx"]  = tInfos.lx;
	dgtz["avg_ly"]  = tInfos.ly;
	dgtz["avg_lz"]  = tInfos.lz;
	dgtz["avg_t"]   = tInfos.time;
	dgtz["px"]      = aHit->GetMom().getX();
	dgtz["py"]      = aHit->GetMom().getY();
	dgtz["pz"]      = aHit->GetMom().getZ();
	dgtz["vx"]      = aHit->GetVert().getX();
	dgtz["vy"]      = aHit->GetVert().getY();
	dgtz["vz"]      = aHit->GetVert().getZ();
	dgtz["mvx"]     = aHit->GetmVert().getX();
	dgtz["mvy"]     = aHit->GetmVert().getY();
	dgtz["mvz"]     = aHit->GetmVert().getZ();		
		
	return dgtz;
}

vector<identifier>  eic_compton_HitProcess :: processID(vector<identifier> id, [[maybe_unused]] G4Step* aStep, [[maybe_unused]] detector Detector)
{
	id[id.size()-1].id_sharing = 1;
	return id;
}

// - electronicNoise: returns a vector of hits generated / by electronics.
vector<MHit*> eic_compton_HitProcess :: electronicNoise()
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


map< string, vector <int> >  eic_compton_HitProcess :: multiDgt([[maybe_unused]] MHit* aHit, [[maybe_unused]] int hitn)
{
	map< string, vector <int> > MH;
	return MH;
}


// - charge: returns charge/time digitized information / step
map< int, vector <double> > eic_compton_HitProcess :: chargeTime([[maybe_unused]] MHit* aHit, [[maybe_unused]] int hitn)
{
	map< int, vector <double> >  CT;

	return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)
double eic_compton_HitProcess :: voltage([[maybe_unused]] double charge, [[maybe_unused]] double time, [[maybe_unused]] double forTime)
{
	return 0.0;
}

