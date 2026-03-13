#ifndef mucal_HITPROCESS_H
#define mucal_HITPROCESS_H 1

// gemc headers
#include "HitProcess.h"

// constants to be used in the digitization routine
class mucalConstants
{
public:
	
	// database
	int    runNo;
	string date;
	string connection;
	char   database[80];
	
	// translation table
	TranslationTable TT;
	
	// For crystal dependent constants read from CCDB
	// Array [332] -> sector,layer,component
	
	//static const int calo_size = 22;
	
	// status:
	//	0 - fully functioning
	//	1 - noisy channel
	//	3 - dead channel
	//  5 - any other issue
	int status[484];
	
	// noise
	double pedestal[484];
	double pedestal_rms[484];
	double noise[484];
	double noise_rms[484];
	double threshold[484];
	
	// energy
	double mips_charge[484];
	double mips_energy[484];
	double fadc_to_charge[484];
	double preamp_gain[484];
	double apd_gain[484];
	
	// time
	double time_offset[484];
	double time_rms[484];
	
	// fadc parameters
	double ns_per_sample;
	double fadc_input_impedence;
	double time_to_tdc;
	double tdc_max;
	
	// preamp parameter
	double preamp_input_noise;
	double apd_noise ;
	
	// crystal paramters
	double light_speed;
	
	//	voltage signal parameters, using double gaussian + delay (function DGauss, need documentation for it)
	double vpar[4];
	
};



// Class definition
class mucal_HitProcess : public HitProcess
{
public:
	
	~mucal_HitProcess(){;}
	
	// - integrateDgt: returns digitized information integrated over the hit
	map<string, double> integrateDgt(MHit*, int);
	
	// - multiDgt: returns multiple digitized information / hit
	map< string, vector <int> > multiDgt(MHit*, int);
	
	// - charge: returns charge/time digitized information / step
	virtual map< int, vector <double> > chargeTime(MHit*, int);
	
	// - voltage: returns a voltage value for a given time. The input are charge value, time
	virtual double voltage(double, double, double);
	
	// The pure virtual method processID returns a (new) identifier
	// containing hit sharing information
	vector<identifier> processID(vector<identifier>, G4Step*, detector);
	
	// creates the HitProcess
	static HitProcess *createHitClass() {return new mucal_HitProcess;}
	
private:
	
	// constants initialized with initWithRunNumber
	static mucalConstants mucc;
	
	void initWithRunNumber(int runno);
	
	// - electronicNoise: returns a vector of hits generated / by electronics.
	vector<MHit*> electronicNoise();
	
	double fadc_precision = 0.0625;  // 62 picoseconds resolution
	double convert_to_precision(double time) {
		return (int( time / fadc_precision ) * fadc_precision);
	}
	

};

#endif
