// G4 headers
#include "G4Poisson.hh"
#include "Randomize.hh"

#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>
using namespace ccdb;

// gemc headers
#include "recoil_tof_hitprocess.h"

// CLHEP units
#include "CLHEP/Units/PhysicalConstants.h"
using namespace CLHEP;

static recoil_tofConstants initializeRECOILTOFConstants(int runno, string digiVariation = "default") {
	recoil_tofConstants atc;
	
	// do not initialize at the beginning, only after the end of the first event,
	// with the proper run number coming from options or run table
	if (runno == -1) return atc;
	
	atc.runNo = runno;
	if (getenv("CCDB_CONNECTION") != nullptr)
		atc.connection = (string) getenv("CCDB_CONNECTION");
	else
		atc.connection = "mysql://clas12reader@clasdb.jlab.org/clas12";
	
	return atc;
}


// this methos is for implementation of digitized outputs and the first one that needs to be implemented.
map<string, double> recoil_tof_HitProcess::integrateDgt(MHit* aHit, int hitn) {
	
	// digitized output
	map<string, double> dgtz;
	vector<identifier> identity = aHit->GetId();
	rejectHitConditions = false;
	writeHit = true;

	
	int recoil_tof_sector     = identity[0].id;
	int recoil_tof_row        = identity[1].id; 
	int recoil_tof_column     = identity[2].id;
	int recoil_tof_order      = identity[3].id;
	//cout << "sector " << recoil_tof_sector << " row "<< recoil_tof_row << " column " << recoil_tof_column << " order " << recoil_tof_order << endl; 
	double time_to_tdc = 1./0.015625;
	
	if(aHit->isBackgroundHit == 1) {
		
		double totEdep  = aHit->GetEdep()[0];
		double stepTime = aHit->GetTime()[0];
		double tdc      = stepTime * time_to_tdc;

		dgtz["hitn"]      = hitn;
		dgtz["sector"]    = recoil_tof_sector; //Sector ranges from 1 to 2
		dgtz["row"]     = recoil_tof_row; //Row ranges from 1 to 5
		dgtz["column"] = recoil_tof_column; //Column ranges from 1 to 63 
		dgtz["TDC_order"] = recoil_tof_order; //order is 0/1 for front(upstream)/back(downstream)
		dgtz["TDC_ToT"]   = (int) totEdep;
		dgtz["TDC_TDC"]  = tdc; 
		return dgtz;
	}
	
	trueInfos tInfos(aHit);
	
	double length = aHit->GetDetector().dimensions[1]; // half length of bar along y direction
	double thickness = 2 * aHit->GetDetector().dimensions[2]; // thickness of bar
	//cout << "half length = " << length << " mm " << "thickness = " << thickness << " mm" << endl;
	
	vector<G4double>      Edep  = aHit->GetEdep();
	vector<G4ThreeVector> Lpos  = aHit->GetLPos(); // local position at each step
	vector<double>        times = aHit->GetTime();
	
	double adc_CC_front, adc_CC_back, tdc_CC_front, tdc_CC_back;
	
	double LposX=0.0;
	double LposY=0.0;
	double LposZ=0.0;
	
	// Simple output not equal to real physics, just to feel the adc, time values
	// Should be: double energy = tInfos.eTot*att;
	
	double totEdep=0.0;
	
	//Distance calculation from the hit to the front or back SIPM
	double dFront = 0.0;
	double dBack = 0.0; 
	double e_Front = 0.0;
	double e_Back = 0.0;
	double E_tot_Front = 0.0;
	double E_tot_Back = 0.0;
		
	double attlength = 1600.0; // here in mm! because all lengths from the volume are in mm!! EJ-204 160 cm
	double pmtPEYld = 10400.0; // EJ-204 10400 (photons / [1MeV*e-])
	double dEdxMIP = 1.956; // energy deposited by MIP per cm of scintillator material, to be adapted for SiPM case, it is a function of ?
	
	//Variables for tdc calculation (time)
	double EtimesTime_Front=0.0;
	double EtimesTime_Back=0.0;
	double  v_eff_Front = 200.0; // mm/ns! CND v_eff = 16 cm/ns
	double  v_eff_Back = 200.0;

	/*
	double dist_h_SiPMFront =0.0;
	double dist_h_SiPMBack =0.0;
	*/
	// cout << "First loop on steps begins" << endl;
	
	
	// notice these calculations are done both for front and back
	// this can be optimized to have just one calculation using order as discriminating value
	for(unsigned int s=0; s<tInfos.nsteps; s++)
	{
		LposX = Lpos[s].x();
		LposY = Lpos[s].y();
		LposZ = Lpos[s].z();
		
		dFront = length - LposY;
		dBack = length + LposY;
		e_Front = Edep[s] *exp(-dFront/attlength); // value for just one step, in MeV!
		e_Back = Edep[s] *exp(-dBack/attlength);
		E_tot_Front = E_tot_Front + e_Front; // to sum over all the steps of the hit
		E_tot_Back = E_tot_Back + e_Back;
			
		// to check the totEdep MC truth value
		totEdep = totEdep + Edep[s];
			
		// times[s] is in ns!
		EtimesTime_Front = EtimesTime_Front + (times[s] + dFront/v_eff_Front)*e_Front;
		EtimesTime_Back = EtimesTime_Back + (times[s] + dBack/v_eff_Back)*e_Back;
			
		//cout << "Distance from hit to Front SIPM, to Back SiPM (mm): " << dFront << ", "<< dBack << endl;
		/*
		  if ( dist_h_SiPMFront <= dFront )
		  {
		  dist_h_SiPMFront = dFront; // cm!!!
		  }
		  if ( dist_h_SiPMBack <= dBack )
		  {
		  dist_h_SiPMBack = dBack; // cm!!!
		  }
		*/
	}
	// cout << "First loop on steps ends" << endl;
	
	// test factor for calibration coeff. conversion
	adc_CC_front = 10.0;	
	adc_CC_back = 10.0;
	tdc_CC_front = 1.0;	
	tdc_CC_back = 1.0;
	
	double adc_front = 0.00000;
	double adc_back = 0.00000;
	double tdc_front = 0.00000;
	double tdc_back = 0.00000;
	double time_front = 0.00000;
	double time_back = 0.00000;
	double sigma_time = 0.00000; // in ns! 100 ps = 0.1 ns

	if(recoil_tof_row == 3) sigma_time = 0.05; // better time resolution for shorter bars
	else sigma_time = 0.1;
	
	///////ALL OF THIS PART WILL NEED TO BE UPDATED WITH ACTUAL CALIBRATION	
	if ((E_tot_Front > 0.0) || (E_tot_Back > 0.0)) 
	{
		double nphe_fr = G4Poisson(E_tot_Front*pmtPEYld);
		double energy_fr = nphe_fr/pmtPEYld;
		
		double nphe_bck = G4Poisson(E_tot_Back*pmtPEYld);
		double energy_bck = nphe_bck/pmtPEYld;	

		adc_front = energy_fr *adc_CC_front *(1/(dEdxMIP * thickness * 0.1)); // thickness of bar (mm -> cm) 
		adc_back = energy_bck *adc_CC_back *(1/(dEdxMIP * thickness * 0.1));
		
		
		time_front = EtimesTime_Front/E_tot_Front;
		time_back = EtimesTime_Back/E_tot_Back;
		tdc_front = G4RandGauss::shoot(time_front, sigma_time) / tdc_CC_front; 
		tdc_back = G4RandGauss::shoot(time_back, sigma_time) / tdc_CC_back;
	}
		
	double adc = 0;
	double time = 0;

	if ( recoil_tof_order == 0 )
	  {
	    adc  = adc_front;
	    time = tdc_front;
	  }
	else
	  {
	    adc = adc_back;
	    time = tdc_back;
	  }

	
	dgtz["hitn"]      = hitn;
	dgtz["sector"]    = recoil_tof_sector; //Sector ranges from 1 to 2                                                           
	dgtz["row"]     = recoil_tof_row; //Row ranges from 1 to 5
	dgtz["column"] = recoil_tof_column; //Column ranges from 1 to 63
	dgtz["TDC_order"] = recoil_tof_order; //order is 0/1 for front(upstream)/back(downstream) 
	dgtz["TDC_ToT"]   = (int)adc*100;
	dgtz["TDC_TDC"]  = time * time_to_tdc;
	
	// define conditions to reject hit
	if (rejectHitConditions) {
		writeHit = false;
	}
	
	return dgtz;
}

vector<identifier> recoil_tof_HitProcess::processID(vector<identifier> id, G4Step* aStep, detector Detector) {
	
	vector<identifier> yid = id;
		
	yid[0].id_sharing = 1; // sector
	yid[1].id_sharing = 1; // row
	yid[2].id_sharing = 1; // column
	yid[3].id_sharing = 1; // order

	if (yid[3].id != 0) {
		cout << "*****WARNING***** in recoil_tof_HitProcess :: processID, order of the original hit should be 0 " << endl;
		cout << "yid[3].id = " << yid[3].id << endl;
	}
	
	// Now we want to have similar identifiers, but the only difference be id order to be 1, instead of 0
	identifier this_id = yid[0];
	yid.push_back(this_id);
	this_id = yid[1];
	yid.push_back(this_id);
	this_id = yid[2];
	yid.push_back(this_id);
	this_id = yid[3];
	this_id.id = 1;
	yid.push_back(this_id);

	return yid;
}

// - electronicNoise: returns a vector of hits generated / by electronics.

vector<MHit*> recoil_tof_HitProcess::electronicNoise() {
	vector<MHit*> noiseHits;
	
	// first, identify the cells that would have electronic noise
	// then instantiate hit with energy E, time T, identifier IDF:
	//
	// MHit* thisNoiseHit = new MHit(E, T, IDF, pid);
	
	// push to noiseHits collection:
	// noiseHits.push_back(thisNoiseHit)
	
	return noiseHits;
}

map< string, vector <int> > recoil_tof_HitProcess::multiDgt(MHit* aHit, int hitn) {
	map< string, vector <int> > MH;
	
	return MH;
}

// - charge: returns charge/time digitized information / step

map< int, vector <double> > recoil_tof_HitProcess::chargeTime(MHit* aHit, int hitn) {
	map< int, vector <double> >  CT;
	
	return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)

double recoil_tof_HitProcess::voltage(double charge, double time, double forTime) {
	return 0.0;
}

void recoil_tof_HitProcess::initWithRunNumber(int runno)
{
	string digiVariation = gemcOpt.optMap["DIGITIZATION_VARIATION"].args;
	
	if (atc.runNo != runno) {
		cout << " > Initializing " << HCname << " digitization for run number " << runno << endl;
		atc = initializeRECOILTOFConstants(runno, digiVariation);
		atc.runNo = runno;
	}
}

// this static function will be loaded first thing by the executable
recoil_tofConstants recoil_tof_HitProcess::atc = initializeRECOILTOFConstants(-1);




