#ifndef MYATOF_HITPROCESS_H
#define MYATOF_HITPROCESS_H 1

// gemc headers
#include "HitProcess.h"

//Holding value values from CCDB
struct entryWithError {
  double value;
  double dvalue;
};

//CCDB constants
class atofConstants
{
public:
  
  // Database parameters
  int    runNo;
  string date;
  string connection;
  char   database[80];
  
  //Table indices ranges
  static constexpr unsigned NSECT = 15;
  static constexpr unsigned NLAY  = 4;
  static constexpr unsigned NCOMP = 11;
  static constexpr unsigned NORDER = 2;
  
  //time offsets
  //sector,layer,component,(T0,dT0)
  entryWithError timeOffsetTable[NSECT][NLAY][NCOMP];
  //sector,layer,component,order,(TUD,dTUD)
  entryWithError timeUDTable[NSECT][NLAY][NCOMP][NORDER];
  // value: effective velocity
  //sector,layer,component,(value,dvalue)
  entryWithError veffTable[NSECT][NLAY][NCOMP];
  // translation table TBD
  //TranslationTable TT;
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
};

#endif




