// gemc headers
#include "mirror_hitprocess.h"

map<string, double> mirror_HitProcess :: integrateDgt(MHit* aHit, [[maybe_unused]] int hitn)
{
	map<string, double> dgtz;
	vector<identifier> identity = aHit->GetId();
	
	int id  = identity[0].id;
	
	if(verbosity>4)
		cout << log_msg << " mirror detector id: " << id << endl;
	
	dgtz["hitn"] = hitn;
	dgtz["id"]   = id;
	
	return dgtz;
}

vector<identifier>  mirror_HitProcess :: processID(vector<identifier> id, [[maybe_unused]] G4Step* aStep, [[maybe_unused]] detector Detector)
{
	id[id.size()-1].id_sharing = 1;
	return id;
}


// - electronicNoise: returns a vector of hits generated / by electronics.
vector<MHit*> mirror_HitProcess :: electronicNoise()
{
	vector<MHit*> noiseHits;
	return noiseHits;
}



map< string, vector <int> >  mirror_HitProcess :: multiDgt([[maybe_unused]] MHit* aHit, [[maybe_unused]] int hitn)
{
	map< string, vector <int> > MH;
	
	return MH;
}



// - charge: returns charge/time digitized information / step
map< int, vector <double> > mirror_HitProcess :: chargeTime([[maybe_unused]] MHit* aHit, [[maybe_unused]] int hitn)
{
	map< int, vector <double> >  CT;
	
	return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)
double mirror_HitProcess :: voltage([[maybe_unused]] double charge, [[maybe_unused]] double time, [[maybe_unused]] double forTime)
{
	return 0.0;
}












