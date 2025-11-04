// G4 headers
#include "G4Poisson.hh"
#include "Randomize.hh"

#include <math.h>
#include <random>

#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>

#define PI 3.1415926535

using namespace ccdb;

// gemc headers
#include "ahdc_hitprocess.h"

// CLHEP units
#include "CLHEP/Units/PhysicalConstants.h"
using namespace CLHEP;

// V. Sergeyeva, started on 29 May 2020


// this method is for connection to calibration database and extraction of calibration parameters
static ahdcConstants initializeAHDCConstants(int runno, string digiVariation = "default", string digiSnapshotTime = "no") {
	ahdcConstants ahdcc;
	
	// do not initialize at the beginning, only after the end of the first event,
	// with the proper run number coming from options or run table
	if (runno == -1) return ahdcc;

	string timestamp = "";
	if(digiSnapshotTime != "no") {
		timestamp = ":"+digiSnapshotTime;
	}
	
	ahdcc.runNo = runno;
	if (getenv("CCDB_CONNECTION") != nullptr)
		ahdcc.connection = (string) getenv("CCDB_CONNECTION");
	else
		ahdcc.connection = "mysql://clas12reader@clasdb.jlab.org/clas12";
	
	unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(ahdcc.connection));
	
	/////////////////////////////////////////////////
	// The following code is inspired by dcConstants
	/////////////////////////////////////////////////
	
	// read the t0 table
	snprintf(ahdcc.database, sizeof(ahdcc.database), "/calibration/alert/ahdc/time_offsets:%d:%s%s", ahdcc.runNo, digiVariation.c_str(), timestamp.c_str());
	vector<vector<double> > data;
	calib->GetCalib(data, ahdcc.database);
	for(unsigned row = 0; row < data.size(); row++)
	{
		int sector = data[row][0];
		int layer  = data[row][1];
		int component  = data[row][2]; // wire id
		ahdcc.T0Correction[ahdcConstants::getUniqueId(sector, layer, component)] = data[row][3];
	}
	data.clear();

	// read the time2distance table
	snprintf(ahdcc.database, sizeof(ahdcc.database), "/calibration/alert/ahdc/time_to_distance:%d:%s%s", ahdcc.runNo, digiVariation.c_str(), timestamp.c_str());
	calib->GetCalib(data, ahdcc.database);
	for(unsigned row = 0; row < data.size(); row++) {
		//int sector = data[row][0];
		//int layer  = data[row][1];
		//int component  = data[row][2]; // wire id
		ahdcc.T2D[0] = data[row][3];	
		ahdcc.T2D[1] = data[row][4];	
		ahdcc.T2D[2] = data[row][5];	
		ahdcc.T2D[3] = data[row][6];	
		ahdcc.T2D[4] = data[row][7];	
		ahdcc.T2D[5] = data[row][8];
		std::cout << "p0 : " << ahdcc.T2D[0] << std::endl;
		std::cout << "p1 : " << ahdcc.T2D[1] << std::endl;
		std::cout << "p2 : " << ahdcc.T2D[2] << std::endl;
		std::cout << "p3 : " << ahdcc.T2D[3] << std::endl;
		std::cout << "p4 : " << ahdcc.T2D[4] << std::endl;
		std::cout << "p5 : " << ahdcc.T2D[5] << std::endl;
		// for now we only have one row this table
		// I add this condition in case the t2d table grows to act channel by channel
		// If this happens, I will need to change the structure of the T2D
		if (row > 1) break;
	}
	data.clear();
	// inverse the time2distance
	for (int i = 0; i < 50; i++) {
		ahdcc.xi[i] = i*(350.0/50);
		ahdcc.yi[i] = ahdcc.eval_t2d(ahdcc.xi[i]);
	}
	
	return ahdcc;
}


// this methos is for implementation of digitized outputs and the first one that needs to be implemented.
map<string, double> ahdc_HitProcess::integrateDgt(MHit* aHit, int hitn) {
	
	// digitized output
	map<string, double> dgtz;
	vector<identifier> identity = aHit->GetId();
	rejectHitConditions = false;
	writeHit = true;

	int sector    = 1;
	int layer     = 10 * identity[0].id + identity[1].id ; // 10*superlayer + layer
	int component = identity[2].id;

	if(aHit->isBackgroundHit == 1) {

		// double totEdep  = aHit->GetEdep()[0];
		// double stepTime = aHit->GetTime()[0];
		// double tdc      = stepTime;

		dgtz["hitn"]      = hitn;
		dgtz["sector"]    = sector;
		dgtz["layer"]     = layer;
		dgtz["component"] = component;
		// dgtz["ADC_order"] = 1;
		// dgtz["ADC_ADC"]   = (int) totEdep;
		// dgtz["ADC_time"]  = tdc;
		// dgtz["ADC_ped"]   = 0;
 
		// dgtz["TDC_order"] = 0;
		// dgtz["TDC_TDC"]   = tdc;

		return dgtz;

	}
	// the t0 is our timeOffset
	double t0 = ahdcc.get_T0(sector, layer, component);	
	ahdcSignal *Signal = new ahdcSignal(aHit,hitn,0,1000,t0,48,115.75803, &ahdcc);
	Signal->SetElectronYield(25000);
	Signal->Digitize();

	dgtz["hitn"]      = hitn;
	dgtz["sector"]    = sector;
	dgtz["layer"]     = layer;
	dgtz["component"] = component;

	// WF
	dgtz["wf_timestamp"] = 0;

	for(unsigned t=0; t<30; t++) {
		string dname = "wf_s" + to_string(t+1);
		if (t < 20) {
			dgtz[dname] = Signal->GetDgtz().at(t);
		}
		else {
			dgtz[dname] = 0;
		}
		//if (t == 27) { dgtz[dname] = (int) (Signal->GetDocaValue()*1000);}
		//if (t == 28) { dgtz[dname] = Signal->GetNSteps();}
		//if (t == 29) { dgtz[dname] = (int) (Signal->GetMeanTimeValue()*100);}
	}
	delete Signal;

	
	// define conditions to reject hit
	if (rejectHitConditions) {
		writeHit = false;
	}
	
	return dgtz;
}



vector<identifier> ahdc_HitProcess::processID(vector<identifier> id, G4Step* aStep, detector Detector) {

	id[id.size()-1].id_sharing = 1;
	return id;
}



// - electronicNoise: returns a vector of hits generated / by electronics.
// additional method, can be implemented later
vector<MHit*> ahdc_HitProcess::electronicNoise() {
	vector<MHit*> noiseHits;
	
	// first, identify the cells that would have electronic noise
	// then instantiate hit with energy E, time T, identifier IDF:
	//
	// MHit* thisNoiseHit = new MHit(E, T, IDF, pid);
	
	// push to noiseHits collection:
	// noiseHits.push_back(thisNoiseHit)
	
	return noiseHits;
}

map< string, vector <int> > ahdc_HitProcess::multiDgt(MHit* aHit, int hitn) {
	map< string, vector <int> > MH;
	
	return MH;
}

// - charge: returns charge/time digitized information / step
// this method is implemented in ftof, but information from this bank is not translated into the root format right now (29/05/2020)
// the output is only visible in .txt output of gemc simulation + <option name="SIGNALVT" value="ftof"/> into gcard
map< int, vector <double> > ahdc_HitProcess::chargeTime(MHit* aHit, int hitn) {
	map< int, vector <double> >  CT;
	
	return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)

double ahdc_HitProcess::voltage(double charge, double time, double forTime) {
	return 0.0;
}

void ahdc_HitProcess::initWithRunNumber(int runno)
{
	string digiVariation = gemcOpt.optMap["DIGITIZATION_VARIATION"].args;
	string digiSnapshotTime = gemcOpt.optMap["DIGITIZATION_TIMESTAMP"].args;
	
	if (ahdcc.runNo != runno) {
		cout << " > Initializing " << HCname << " digitization for run number " << runno << endl;
		ahdcc = initializeAHDCConstants(runno, digiVariation, digiSnapshotTime);
		ahdcc.runNo = runno;
	}
}

// this static function will be loaded first thing by the executable
ahdcConstants ahdc_HitProcess::ahdcc = initializeAHDCConstants(-1);


// -------------
// ahdcSignal
// -------------

void ahdcSignal::ComputeDocaAndTime(MHit * aHit){
	vector<G4ThreeVector> Lpos        = aHit->GetLPos();
	int nsteps = Lpos.size();
	double LposX, LposY, LposZ;
	
	// ALERT geometry
	double X_sigwire_top = 0; // [mm]
	double Y_sigwire_top = 0;
	double Z_sigwire_top = -150; 
	double X_sigwire_bot = 0; // [mm]
	double Y_sigwire_bot = 0;
	double Z_sigwire_bot = 150;
	
	// Compute Y_sigwire_top, Z_sigwire_top, Y_sigwire_bot, Z_sigwire_bot
	double xV0 = 0.0;
	double yV0 = 0.0;
	double xV3 = 0.0;
	double yV3 = 0.0;
	double xV4 = 0.0;
	double yV4 = 0.0;
	double xV7 = 0.0;
	double yV7 = 0.0;
	double dim_id_2, dim_id_8;
	
	dim_id_2 = aHit->GetDetector().dimensions[2];
	dim_id_8 = aHit->GetDetector().dimensions[8];

	yV3 = aHit->GetDetector().dimensions[8];
	xV3 = aHit->GetDetector().dimensions[7];
	yV0 = aHit->GetDetector().dimensions[2];
	xV0 = aHit->GetDetector().dimensions[1];

	yV7 = aHit->GetDetector().dimensions[16];
	xV7 = aHit->GetDetector().dimensions[15];
	yV4 = aHit->GetDetector().dimensions[10];
	xV4 = aHit->GetDetector().dimensions[9];

	if ( abs(dim_id_2) > abs(dim_id_8)) {
		// subcell = 1;
		X_sigwire_top = xV3 + (xV0 - xV3)/2;
		Y_sigwire_top = yV3 + (yV0 - yV3)/2; // z=-150 mm
		X_sigwire_bot = xV7 + (xV4 - xV7)/2;
		Y_sigwire_bot = yV7 + (yV4 - yV7)/2; // z=+150 mm
	}
	else {
		// subcell = 2;
		X_sigwire_top = xV0 + (xV3 - xV0)/2;
		Y_sigwire_top = yV0 + (yV3 - yV0)/2; // z=-150 mm
		X_sigwire_bot = xV4 + (xV7 - xV4)/2;
		Y_sigwire_bot = yV4 + (yV7 - yV4)/2; // z=+150 mm
	}

	// Triangle abh
	// a (sigwire_top), b (sigwire_bot), h (hit position)
	// H_abh is the distance between hit and the wire and perpendicular to the wire
	double L_ab, L_ah, L_bh, H_abh;
	// Compute the distance between top and bottom of the wire
	L_ab = sqrt(pow(X_sigwire_top-X_sigwire_bot,2) + pow(Y_sigwire_top-Y_sigwire_bot,2) + pow(Z_sigwire_top-Z_sigwire_bot,2));
	doca = 1e10; // arbitray big number
	docaTime = -99; // arbitrary negative value
	for (int s=0;s<nsteps;s++) {
		// Load current hit positions
		LposX = Lpos[s].x();
		LposY = Lpos[s].y();
		LposZ = Lpos[s].z();
		// Compute distance
		L_ah = sqrt(pow(X_sigwire_top-LposX,2) + pow(Y_sigwire_top-LposY,2) + pow(Z_sigwire_top-LposZ,2));
		L_bh = sqrt(pow(X_sigwire_bot-LposX,2) + pow(Y_sigwire_bot-LposY,2) + pow(Z_sigwire_bot-LposZ,2));
		// Compute the height of a triangular (see documentation for the demonstration of the formula)
		H_abh = L_ah*sqrt(1 - pow((L_ah*L_ah + L_ab*L_ab - L_bh*L_bh)/(2*L_ah*L_ab),2)); // this is the d.o.c.a of a given hit (!= MHit)
		Doca.push_back(H_abh);
		// Add a resolution on doca
		//double docasig = 337.3-210.3*H_abh+34.7*pow(H_abh,2); // um // fit sigma vs distance // Fig 4.14 (right), L. Causse's thesis
		//docasig = docasig/1000; // mm
		//std::default_random_engine dseed(time(0)); //seed
		//std::normal_distribution<double> docadist(H_abh, docasig);
		//double new_H_abh = docadist(dseed);
		//std::cout << "H_abh : " << H_abh << ", docasig : " << docasig << " ";
		// Compute time
		double driftTime = ahdcc_ptr->eval_inv_t2d(H_abh);
		DriftTime.push_back(driftTime);
		if (H_abh < doca) { 
			doca = H_abh;
			docaTime = driftTime;
		}
	}
}

void ahdcSignal::GenerateNoise(double mean, double stdev){
	int Npts = (int) floor( (tmax-tmin)/samplingTime );
	std::random_device rd;      // Create a random device to seed the generator
	std::mt19937 gen(rd());     // Create a random number engine (e.g., Mersenne Twister)
	for (int i=0;i<Npts;i++){
		std::normal_distribution<double> draw(mean,stdev);
		double value = draw(gen);
		if (value < 0) value = 0;
		Noise.push_back(value);
	}
}

void ahdcSignal::Digitize(){
	this->GenerateNoise(300,15);
	int Npts = (int) floor( (tmax-tmin)/samplingTime );
	for (int i=0;i<Npts;i++) {
		double value = this->operator()(tmin + i*samplingTime); //in keV/ns
		value = (int) floor(electronYield*value + Noise.at(i)); //convert in ADC +  noise
		short adc = (value < ADC_LIMIT) ? value : ADC_LIMIT; // saturation effect 
		Dgtz.push_back(adc);
	}
}
double ahdcSignal::GetDocaTimeValue() {
	return docaTime;
}

double ahdcSignal::GetDocaValue() {
	return doca;
}

double ahdcSignal::GetMeanTimeValue(){
	if (nsteps == 0){ return 0; }
	double mctime = 0;
	double Etot = 0;
	for (int s=0;s<nsteps;s++){
		mctime += DriftTime.at(s)*Edep.at(s);
		Etot += Edep.at(s);
	}
	mctime = mctime/Etot;
	return mctime;
}

double ahdcSignal::GetEtotValue(){
	return Etot;
}

