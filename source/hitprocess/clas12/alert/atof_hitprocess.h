#ifndef MYATOF_HITPROCESS_H
#define MYATOF_HITPROCESS_H 1

// gemc headers
#include "HitProcess.h"

class atofConstants
{
public:
  
  // Database parameters
  int    runNo;
  string date;
  string connection;
  char   database[80];

  static constexpr unsigned NSECT = 15;
  static constexpr unsigned NLAY  = 4;
  static constexpr unsigned NCOMP = 11;
  static constexpr unsigned NORDER = 2;  
  //time offsets
  //sector,layer,component,(T0,dT0)
  vector<double> timeOffset[NSECT][NLAY][NCOMP][2];
  //sector,layer,component,order,(TUD,dTUD)
  vector<double> timeUD[NSECT][NLAY][NCOMP][NORDER][2];
  // veff: effective velocity
  //sector,layer,component,(veff,dveff)
  vector<double> veff[NSECT][NLAY][NCOMP][2];
  
  // translation table
  TranslationTable TT;
};


// Class definition
/// \class atof_HitProcess
/// <b> Alert Time of Flight Hit Process Routine</b>\n\n

class atof_HitProcess : public HitProcess
{
public:
	
	~atof_HitProcess(){;}
	
	// constants initialized with initWithRunNumber
	static atofConstants atc;
	
	void initWithRunNumber(int runno);
	
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
	static HitProcess *createHitClass() {return new atof_HitProcess;}
	
	// - electronicNoise: returns a vector of hits generated / by electronics.
	vector<MHit*> electronicNoise();

        //time offsets
        //sector,layer,component,order,(T0,dT0)
	vector<double> timeOffset[1][1][1][1][2];
        vector<double> tUD[1][1][1][1][2];
	// veff: effective velocity
        //sector,layer,component,(veff,dveff)
	vector<double> veff[1][1][1][2];
  
};



#endif




