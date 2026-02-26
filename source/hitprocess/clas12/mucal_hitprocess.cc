// G4 headers
#include "G4Poisson.hh"
#include "Randomize.hh"

// gemc headers
#include "mucal_hitprocess.h"

// CLHEP units
#include "CLHEP/Units/PhysicalConstants.h"
using namespace CLHEP;

// ccdb
#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>
using namespace ccdb;



static mucalConstants initializeMUCALConstants(int runno, string digiVariation = "default", string digiSnapshotTime = "no", bool accountForHardwareStatus = false)
{
	// all these constants should be read from CCDB
	mucalConstants mucc;
	
	// do not initialize at the beginning, only after the end of the first event,
	// with the proper run number coming from options or run table
	if(runno == -1) return mucc;
	string timestamp = "";
	if(digiSnapshotTime != "no") {
		timestamp = ":"+digiSnapshotTime;
	}
	
	// database
	mucc.runNo = runno;
	if(getenv ("CCDB_CONNECTION") != nullptr)
		mucc.connection = (string) getenv("CCDB_CONNECTION");
	else
		mucc.connection = "mysql://clas12reader@clasdb.jlab.org/clas12";
	
	int icomponent;
	
	vector<vector<double> > data;
	
	unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(mucc.connection));
	cout<<"Connecting to "<<mucc.connection<<"/calibration/ft/ftcal"<<endl;
	
	if(accountForHardwareStatus) {
		
		cout<<"MUCAL:Getting status"<<endl;
		snprintf(mucc.database, sizeof(mucc.database), "/calibration/ft/ftcal/status:%d:%s%s",mucc.runNo, digiVariation.c_str(), timestamp.c_str());
		data.clear(); calib->GetCalib(data,mucc.database);
		for(unsigned row = 0; row < data.size(); row++)
		{
			icomponent   = data[row][2];
			mucc.status[icomponent] = data[row][3];
		}
	}
	
	cout<<"MUCAL:Getting noise"<<endl;
	snprintf(mucc.database, sizeof(mucc.database), "/calibration/ft/ftcal/noise:%d:%s%s",mucc.runNo, digiVariation.c_str(), timestamp.c_str());
	data.clear(); calib->GetCalib(data,mucc.database);
	for(unsigned row = 0; row < data.size(); row++)
	{
		icomponent   = data[row][2];
		mucc.pedestal[icomponent] = data[row][3];         mucc.pedestal[icomponent] = 101.;   // When DB will be filled, I should remove this
		mucc.pedestal_rms[icomponent] = data[row][4];     mucc.pedestal_rms[icomponent] = 2.; // When DB will be filled, I should remove this
		mucc.noise[icomponent] = data[row][5];
		mucc.noise_rms[icomponent] = data[row][6];
		mucc.threshold[icomponent] = data[row][7];
	}
	
	cout<<"MUCAL:Getting charge_to_energy"<<endl;
	snprintf(mucc.database, sizeof(mucc.database), "/calibration/ft/ftcal/charge_to_energy:%d:%s%s",mucc.runNo, digiVariation.c_str(), timestamp.c_str());
	data.clear(); calib->GetCalib(data,mucc.database);
	for(unsigned row = 0; row < data.size(); row++)
	{
		icomponent   = data[row][2];
		mucc.mips_charge[icomponent] = data[row][3];
		mucc.mips_energy[icomponent] = data[row][4];
		mucc.fadc_to_charge[icomponent] = data[row][5];
		mucc.preamp_gain[icomponent] = data[row][6];
		mucc.apd_gain[icomponent] = data[row][7];
	}
	
	cout<<"MUCAL:Getting time_offsets"<<endl;
	snprintf(mucc.database, sizeof(mucc.database), "/calibration/ft/ftcal/time_offsets:%d:%s%s", mucc.runNo, digiVariation.c_str(), timestamp.c_str());
	data.clear(); calib->GetCalib(data,mucc.database);
	for(unsigned row = 0; row < data.size(); row++)
	{
		icomponent   = data[row][2];
		mucc.time_offset[icomponent] = data[row][3];
		mucc.time_rms[icomponent] = data[row][4];
	}
	
	
	cout<<"MUCAL: Getting Translation table"<<endl;
	
	// loading translation table
	mucc.TT = TranslationTable("ftcalTT");
	
	// loads translation table from CLAS12 Database:
	// Translation table for ft cal.
	// Sector is always 1, layer is 0, component is the channel number, and order is always 0.
	
	string database   = "/daq/tt/ftcal:1";
	
	
	data.clear(); calib->GetCalib(data, database);
	cout << "  > " << mucc.TT.getName() << " TT Data loaded from CCDB with " << data.size() << " columns." << endl;
	
	// filling translation table
	for(unsigned row = 0; row < data.size(); row++)
	{
		int crate   = data[row][0];
		int slot    = data[row][1];
		int channel = data[row][2];
		
		int sector  = data[row][3];
		int layer   = data[row][4];
		int crystal = data[row][5];
		int order   = data[row][6];
		
		// order is important as we could have duplicate entries w/o it
		mucc.TT.addHardwareItem({sector, layer, crystal, order}, Hardware(crate, slot, channel));
	}
	cout << "  > Data loaded in translation table " << mucc.TT.getName() << endl;
	
	
	
	// fadc parameters
	mucc.ns_per_sample = 4*ns;
	mucc.time_to_tdc   = 100/mucc.ns_per_sample;// conversion factor from time(ns) to TDC channels)
	mucc.tdc_max       = 8191;               // TDC range
	
	// preamp parameters
	mucc.preamp_input_noise = 5500;     // preamplifier input noise in number of electrons
	mucc.apd_noise          = 0.0033;   // relative noise based on a Voltage and Temperature stability of 10 mV (3.9%/V) and 0.1 C (3.3%/C)
	
	// crystal paramters
	mucc.light_speed = 15*cm/ns;
	
	// setting voltage signal parameters
	mucc.vpar[0] = 20;  // delay, ns
	mucc.vpar[1] = 10;  // rise time, ns
	mucc.vpar[2] = 30;  // fall time, ns
	mucc.vpar[3] = 1;   // amplifier
	
	
	return mucc;
}

map<string, double> mucal_HitProcess :: integrateDgt(MHit* aHit, int hitn)
{
	map<string, double> dgtz;
	vector<identifier> identity = aHit->GetId();
	rejectHitConditions = false;
	writeHit = true;

	// use Crystal ID to define IDX and IDY
	int IDX = identity[0].id;
	int IDY = identity[1].id;
        int iCrystal = 245; //(IDY-1)*22+IDX-1;
        int component = (IDY-1)*44+IDX-1;
	
	if(aHit->isBackgroundHit == 1) {
		
		// background hit has all the energy in the first step. Time is also first step
		double totEdep = aHit->GetEdep()[0];
		double stepTime = aHit->GetTime()[0];
		double charge   = totEdep*mucc.mips_charge[iCrystal]/mucc.mips_energy[iCrystal];
		
		dgtz["hitn"]      = hitn;
		dgtz["sector"]    = 1;
		dgtz["layer"]     = 1;
		dgtz["component"] = iCrystal;
		dgtz["ADC_order"] = 0;
		dgtz["ADC_ADC"]   = (int) (charge/mucc.fadc_to_charge[iCrystal]);
		dgtz["ADC_time"]  = (int) stepTime*mucc.time_to_tdc/25;
		dgtz["ADC_ped"]   = 0;
		
		return dgtz;
	}
	
	trueInfos tInfos(aHit);
	
	
	// R.De Vita (November 2016)
	
	// Get the crystal length: in the MUCAL crystal are trapezoid and the half-length is the 3rd element
	double length = 2 * aHit->GetDetector().dimensions[4];
	// Get the crystal width (rear face): in the FT crystal are BOXes and the half-length is the 2th element
	//	double width  = 2 * aHit->GetDetector().dimensions[1];
	
	
	// initialize ADC and TDC
	int ADC = 0;
	//int TDC = 8191;
    double FADC_TIME = 8191;
	
	if(tInfos.eTot>0)
	{
		/*
		 // commented out to use average time instead of minimum time in TDC calculation
		 for(int s=0; s<nsteps; s++)
		 {
		 double dRight = length/2 - Lpos[s].z();              // distance along z between the hit position and the end of the crystal
		 double timeR  = times[s] + dRight/cm/light_speed;    // arrival time of the signal at the end of the crystal (speed of light in the crystal=15 cm/ns)
		 if(Edep[s]>1*MeV) Tmin=min(Tmin,timeR);              // signal time is set to first hit time with energy above 1 MeV
		 }
		 TDC=int(Tmin*tdc_time_to_channel);
		 if(TDC>tdc_max) TDC=(int)tdc_max;
		 */
		double dRight = length/2 - tInfos.lz;                 // distance along z between the hit position and the end of the crystal
		double timeR  = tInfos.time + dRight/mucc.light_speed;  // arrival time of the signal at the end of the crystal (speed of light in the crystal=15 cm/ns)
		// adding shift and spread on time
		timeR=timeR+mucc.time_offset[iCrystal]+G4RandGauss::shoot(0., mucc.time_rms[iCrystal]);
        
        FADC_TIME = timeR;
		//TDC=int(timeR*mucc.time_to_tdc);
        //if(TDC>mucc.tdc_max) TDC=(int)mucc.tdc_max;
        
        
		// calculate number of photoelectrons detected by the APD considering the light yield, the q.e., and the size of the sensor
		//old!!		double npe=G4Poisson(tInfos.eTot*PbWO4_light_yield*0.5*APD_qe*APD_size/width/width);
		// for PMT, an addition factor of 0.5625 is needed to reproduce the 13.5 photoelectrons with a 20% QE
		//   double npe=G4Poisson(Etot*PbWO4_light_yield*0.5*0.5625*APD_qe*APD_size/width/width);
		double charge   = tInfos.eTot*mucc.mips_charge[iCrystal]/mucc.mips_energy[iCrystal];
		
		// add spread due to photoelectron statistics
		double npe_mean = charge/1.6E-7/mucc.preamp_gain[iCrystal]/mucc.apd_gain[iCrystal];
		double npe      = G4Poisson(npe_mean);
		
		// calculating APD output charge (in number of electrons) and adding noise
		double nel=npe*mucc.apd_gain[iCrystal];
		nel=nel*G4RandGauss::shoot(1.,mucc.apd_noise);
		if(nel<0) nel=0;
		// adding preamplifier input noise
		nel=nel+mucc.preamp_input_noise*G4RandGauss::shoot(0.,1.);
		if(nel<0) nel=0;
		
		// converting to charge (in picoCoulomb)
		//old!		double crg=nel*AMP_gain*1.6e-7;
		//        double crg = charge * nel/(npe_mean*mucc.apd_gain[iCrystal]);
		ADC = (int) (charge/mucc.fadc_to_charge[iCrystal]);
		//old! ADC= (int) (crg*adc_charge_tochannel);
		
	}
	
	// Status flags
	if(accountForHardwareStatus) {
		
		switch (mucc.status[iCrystal])
		{
			case 0:
				break;
			case 1:
				break;
			case 3:
				ADC = 0;
                FADC_TIME = 0;
				break;
				
			case 5:
				break;
				
			default:
				cout << " > Unknown MUCAL status: " << mucc.status[iCrystal] << " for component " << iCrystal << endl;
		}
	}
	
	//int fadc_time = convert_to_precision(TDC/25);
	
	dgtz["hitn"]      = hitn;
	dgtz["sector"]    = 1;
	dgtz["layer"]     = 1;
	dgtz["component"] = component;
	dgtz["ADC_order"] = 0;
	dgtz["ADC_ADC"]   = ADC;
	dgtz["ADC_time"]  = convert_to_precision(FADC_TIME);
	dgtz["ADC_ped"]   = 0;
	
	
	// define conditions to reject hit
	if(rejectHitConditions) {
		writeHit = false;
	}
	
	return dgtz;
}

vector<identifier>  mucal_HitProcess :: processID(vector<identifier> id, G4Step* aStep, detector Detector)
{
	id[id.size()-1].id_sharing = 1;
	return id;
}



// - electronicNoise: returns a vector of hits generated / by electronics.
vector<MHit*> mucal_HitProcess :: electronicNoise()
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



map< string, vector <int> >  mucal_HitProcess :: multiDgt(MHit* aHit, int hitn)
{
	map< string, vector <int> > MH;
	
	return MH;
}




// - charge: returns charge/time digitized information / step
map< int, vector <double> > mucal_HitProcess :: chargeTime(MHit* aHit, int hitn) {
	map< int, vector <double> > CT;
	
	vector<double> hitNumbers;
	vector<double> stepIndex;
	vector<double> chargeAtElectronics;
	vector<double> timeAtElectronics;
	vector<double> identifiers;
	vector<double> hardware;
	hitNumbers.push_back(hitn);
	
	// getting identifiers
	vector<identifier> identity = aHit->GetId();
	
	int sector = 1; // Always 1
	int layer = 0; // Always 0;
	int iX = identity[0].id;
	int iY = identity[1].id;
	int crystal = (iY - 1) * 22 + iX - 1;
	int order = 0; // Always 0
	
	identifiers.push_back(sector); // sector Always 1
	identifiers.push_back(layer); // layer Always 0
	identifiers.push_back(crystal); // component This is the crystal index
	identifiers.push_back(order); // Always 0
	
	// getting hardware
	Hardware thisHardware = mucc.TT.getHardware({sector, layer, crystal, 0});
	hardware.push_back(thisHardware.getCrate());
	hardware.push_back(thisHardware.getSlot());
	hardware.push_back(thisHardware.getChannel());
	
	// Adding pedestal mean and sigma into the hardware as well
	// All of these variables start from 1, therefore -1 is subtracted, e.g. sector-1
	hardware.push_back(mucc.pedestal[crystal]);
	hardware.push_back(mucc.pedestal_rms[crystal]);
	
	
	trueInfos tInfos(aHit);
	
	// Get the crystal length: in the FT crystal are BOXes and the half-length is the 3rd element
	double length = 2 * aHit->GetDetector().dimensions[2];
	
	vector<G4ThreeVector> Lpos = aHit->GetLPos();
	
	vector<G4double> Edep = aHit->GetEdep();
	vector<G4double> time = aHit->GetTime();
	
	for (unsigned int s = 0; s < tInfos.nsteps; s++) {
		
		double dRight = length / 2 - Lpos[s].z(); // distance along z between the hit position and the end of the crystal
		double stepTime = time[s] + dRight / mucc.light_speed; // arrival time of the signal at the end of the crystal (speed of light in the crystal=15 cm/ns)
		// adding shift and spread on time
		stepTime = stepTime + mucc.time_offset[crystal] + G4RandGauss::shoot(0., mucc.time_rms[crystal]);
		
		//cout<<"stepTime = "<<stepTime<<endl;
		//        if( stepTime > 400 ){
		//            //cout<<"==================== STEPTIME > 400 ns"<<endl;
		//            cout<<"Step = "<<s<<"   stepTime = "<<stepTime<<"     Energy = "<<Edep[s]<<endl;
		//        }
		
		
		// calculate number of photoelectrons detected by the APD considering the light yield, the q.e., and the size of the sensor
		//old!!		double npe=G4Poisson(tInfos.eTot*PbWO4_light_yield*0.5*APD_qe*APD_size/width/width);
		// for PMT, an addition factor of 0.5625 is needed to reproduce the 13.5 photoelectrons with a 20% QE
		//   double npe=G4Poisson(Etot*PbWO4_light_yield*0.5*0.5625*APD_qe*APD_size/width/width);
		double stepCharge = Edep[s] * mucc.mips_charge[crystal] / mucc.mips_energy[crystal];
		
		// add spread due to photoelectron statistics
		double npe_mean = stepCharge / 1.6E-7 / mucc.preamp_gain[crystal] / mucc.apd_gain[crystal];
		double npe = G4Poisson(npe_mean);
		
		// calculating APD output charge (in number of electrons) and adding noise
		double nel = npe * mucc.apd_gain[crystal];
		nel = nel * G4RandGauss::shoot(1., mucc.apd_noise);
		if (nel < 0) nel = 0;
		// adding preamplifier input noise
		nel = nel + mucc.preamp_input_noise * G4RandGauss::shoot(0., 1.);
		if (nel < 0) nel = 0;
		
		// converting to charge (in picoCoulomb)
		//old!		double crg=nel*AMP_gain*1.6e-7;
		//        double crg = charge * nel/(npe_mean*mucc.apd_gain[iCrystal]);
		
		// It is better to have it double at tis moment, it will be converted to in the MeventAction
		double ADC = (stepCharge / mucc.fadc_to_charge[crystal]);
		//old! ADC= (int) (crg*adc_charge_tochannel);
		
		stepIndex.push_back(s);
		chargeAtElectronics.push_back(ADC);
		timeAtElectronics.push_back(stepTime);
		
		
		
	}
	
	// === Testing =======
	//    double tot_adc = 0;
	//    for( int ii = 0; ii < chargeAtElectronics.size(); ii++ ){
	//        tot_adc = tot_adc + chargeAtElectronics.at(ii);
	//        cout<<"cur_adc and time = "<<chargeAtElectronics.at(ii)<<"   "<<timeAtElectronics.at(ii);
	//    }
	//    cout<<"\n Tot adc = "<<tot_adc<<endl;
	
	CT[0] = hitNumbers;
	CT[1] = stepIndex;
	CT[2] = chargeAtElectronics;
	CT[3] = timeAtElectronics;
	CT[4] = identifiers;
	CT[5] = hardware;
	
	
	return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)
double mucal_HitProcess :: voltage(double charge, double time, double forTime)
{
	return PulseShape(forTime, mucc.vpar, charge, time);
}

void mucal_HitProcess::initWithRunNumber(int runno)
{
	string digiVariation    = gemcOpt.optMap["DIGITIZATION_VARIATION"].args;
	string digiSnapshotTime = gemcOpt.optMap["DIGITIZATION_TIMESTAMP"].args;
	
	if(mucc.runNo != runno) {
		cout << " > Initializing " << HCname << " digitization for run number " << runno << endl;
		mucc = initializeMUCALConstants(runno, digiVariation, digiSnapshotTime, accountForHardwareStatus);
		mucc.runNo = runno;
	}
}

// this static function will be loaded first thing by the executable
mucalConstants mucal_HitProcess::mucc = initializeMUCALConstants(-1);






