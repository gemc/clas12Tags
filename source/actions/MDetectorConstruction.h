/// \file MDetectorConstruction.h
/// Derived from G4VUserDetectorConstruction.\n
/// Contains:
/// - materials map
/// - sensitive detector map
/// - detector map
/// - Hit Process Routine Factory map
/// \n
/// The Construct() function builds the detector
/// from the detector map.
/// \author \n Maurizio Ungaro
/// \author mail: ungaro@jlab.org\n\n\n
#ifndef MDetectorConstruction_h
#define MDetectorConstruction_h 1

// G4 headers
#include "G4VUserDetectorConstruction.hh"
#include "globals.hh"
#include "G4Material.hh"
#include "G4Region.hh"

// gemc headers
#include "gemcOptions.h"
#include "mirrors_factory.h"
#include "detector.h"
#include "field.h"
#include "HitProcess.h"
#include "sensitiveDetector.h"
#include "backgroundHits.h"

// Class definition
class MDetectorConstruction : public G4VUserDetectorConstruction
{
public:
	MDetectorConstruction(goptions Opts);
	~MDetectorConstruction();
	
public:
	goptions gemcOpt;
	
	map<string, G4Material*>        *mats;
	map<string, mirror*>            *mirs;
	map<string, sensitiveDetector*>  SeDe_Map;
	map<string, detector>           *hallMap;
	map<string, gfield>             *fieldsMap;
	map<string, G4Region*>           SeRe_Map;
	map<string, G4ProductionCuts*>   SePC_Map;
	set<string>                      activeFields;
	set<string>                      replicants; // don't build these physical volumes
	
	
private:		
	detector findDetector(string);   // returns map detector
	void buildDetector(string);      // build detector
	void buildCADDetector(string, string, int);   // build CAD detector
	
	void scanDetectors(int VERB, string catch_v);
	void scanCadDetectors(int VERB, string catch_v);
	
	vector<string> nativeRelativesOfCad;
	vector<string> cadRelativesOfNative;
	vector<string> remainingCad;
	vector<string> remainingNative;
	
	vector<string> regions;  // all volumes for which mom is "root"



	
public:
	void isSensitive(detector);
	void assignProductionCuts(vector<string>);         // define a region with name "system_volumename" and assign thresholds based on sensitive detector
	void hasMagfield(detector);
	void buildMirrors();
	void assignRegions();
	void updateGeometry();
	G4VPhysicalVolume* Construct();
	
};

#endif
