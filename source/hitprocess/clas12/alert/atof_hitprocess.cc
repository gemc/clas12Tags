// G4 headers
#include "G4Poisson.hh"
#include "Randomize.hh"
#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>
using namespace ccdb;
// gemc headers
#include "atof_hitprocess.h"

//CCDB constant initialization
//reading out and storing tables
static atofConstants initializeATOFConstants(int runno, string digiVariation = "default", string digiSnapshotTime = "no",  [[ maybe_unused ]] bool accountForHardwareStatus = false) {

  //Holds all the tables
  atofConstants atc;
	
  // do not initialize at the beginning, only after the end of the first event,
  // with the proper run number coming from options or run table
  if(runno == -1) return atc;
  string timestamp = "";
  if(digiSnapshotTime != "no") {
    timestamp = ":"+digiSnapshotTime;
  }
	
  atc.runNo = runno;
  if (getenv("CCDB_CONNECTION") != nullptr)
    atc.connection = (string) getenv("CCDB_CONNECTION");
  else
    atc.connection = "mysql://clas12reader@clasdb.jlab.org/clas12";	
  
  //table indices
  int isec, ilay, icomponent, iorder;
  //reads out ccdb table
  vector<vector<double>> data;
	
  unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(atc.connection));
  cout << "Connecting to " << atc.connection << "/calibration/alert/atof" << endl;

  //Effective velocity readout
  snprintf(atc.database, sizeof(atc.database),  "/calibration/alert/atof/effective_velocity:%d:%s%s", atc.runNo, digiVariation.c_str(), timestamp.c_str());
  cout << "ATOF:Getting effective_velocity" << endl;
  data.clear();
  calib->GetCalib(data, atc.database);
  for (unsigned row = 0; row < data.size(); row++) {
    isec = data[row][0];
    ilay = data[row][1];
    icomponent = data[row][2];    
    atc.veffTable[isec][ilay][icomponent].value=data[row][3];
    atc.veffTable[isec][ilay][icomponent].dvalue=data[row][4];
  }

  //Time offsets readout, T0 and TUD
  snprintf(atc.database, sizeof(atc.database), "/calibration/alert/atof/time_offsets:%d:%s%s", atc.runNo, digiVariation.c_str(), timestamp.c_str());
  cout << "ATOF:Getting time_offsets" << endl;
  data.clear();
  calib->GetCalib(data, atc.database);
  for (unsigned row = 0; row < data.size(); row++) {
    iorder = data[row][3];
    //There are two entries per order for the bars in the CCDB table
    //But it should not be the case, the convention has been chosen to be
    //that order 0 is used to store the right value.
    //wedges are always order 0
    if(iorder!=0) continue;
    isec = data[row][0];
    ilay = data[row][1];
    icomponent = data[row][2];
    atc.timeOffsetTable[isec][ilay][icomponent].value = data[row][4];
    atc.timeOffsetTable[isec][ilay][icomponent].dvalue = data[row][7];
    atc.timeUDTable[isec][ilay][icomponent].value = data[row][5];
    atc.timeUDTable[isec][ilay][icomponent].dvalue = data[row][8];
  }
  return atc;
}

//Making the digitized output
map<string, double> atof_HitProcess::integrateDgt(MHit* aHit, int hitn) {
	
  // digitized output
  map<string, double> dgtz;
  vector<identifier> identity = aHit->GetId();
  rejectHitConditions = false;
  writeHit = true;
  
  int atof_sector     = identity[0].id;
  int atof_superlayer = identity[1].id; //bar: SL = 0; wedge: SL=1
  int atof_layer      = identity[2].id;
  int atof_component  = identity[3].id;
  int atof_order      = identity[4].id;
  
  double time_to_tdc = 1./0.015625;
  
  if(aHit->isBackgroundHit == 1) {
    
    double totEdep  = aHit->GetEdep()[0];
    double stepTime = aHit->GetTime()[0];
    double tdc      = stepTime * time_to_tdc;
    
    dgtz["hitn"]      = hitn;
    dgtz["sector"]    = atof_sector; //Sector ranges from 0 to 14 counterclockwise when z is pointing towards us
    dgtz["layer"]     = atof_layer; //Layer is the index for the wedge+bar (quarter of sector) ranging 0 to 3
    dgtz["component"] = atof_component; //z slice ranging 0 to 9 for the wedge or 10 if it is the long bar
    dgtz["TDC_order"] = atof_order; //order for the bar is 0/1 for downstream/upstream and 0 for the wedge
    dgtz["TDC_ToT"]   = (int) totEdep;
    dgtz["TDC_TDC"]  = tdc; 
    return dgtz;
  }
  
  trueInfos tInfos(aHit);

  //Half length of the atof
  double halfLength = aHit->GetDetector().dimensions[0];
  //For the position of the SiPM on top of the wedges
  double dim_3 = aHit->GetDetector().dimensions[3];
  double dim_4 = aHit->GetDetector().dimensions[4];
  double dim_5 = aHit->GetDetector().dimensions[5];
  double dim_6 = aHit->GetDetector().dimensions[6];
  double l_topXY = sqrt( pow((dim_3 - dim_5),2) + pow((dim_4 - dim_6),2) );

  //True hit info
  vector<G4double>      Edep  = aHit->GetEdep();
  vector<G4ThreeVector> Lpos  = aHit->GetLPos(); // local position at each step
  vector<double>        times = aHit->GetTime();
      
  //Total energy deposited for that hit
  double eTot = 0.0;
  //times weighted by energy deposit at each step
  double weightedTime=0.0;
  
  //Att length and energy to be calibrated!
  double attlength = 1600.0; // here in mm! because all lengths from the volume are in mm!! EJ-204 160 cm
  double pmtPEYld = 10400.0; // EJ-204 10400 (photons / [1MeV*e-])
  double dEdxMIP = 1.956; // energy deposited by MIP per cm of scintillator material, to be adapted for SiPM case, it is a function of ?
  
  //---Calibration constants---//
  //effective velocity
  //mean and sigma from ccdb fit
  double effVelocity = G4RandGauss::shoot(atc.veffTable[atof_sector][atof_layer][atof_component].value,
					  atc.veffTable[atof_sector][atof_layer][atof_component].dvalue);//mm.ns-1 
  //Global time offset
  double t0 = G4RandGauss::shoot(atc.timeOffsetTable[atof_sector][atof_layer][atof_component].value,
				 atc.timeOffsetTable[atof_sector][atof_layer][atof_component].dvalue);
  //For the bars the time offset stored in CCDB is 2*(t0+L/veff) where L is the length of the ATOF
  if(atof_component==10) t0 = t0/2 - halfLength/effVelocity;

  //Time offset between up/downstream bar channels
  double tUD = G4RandGauss::shoot(atc.timeUDTable[atof_sector][atof_layer][atof_component].value,
				  atc.timeUDTable[atof_sector][atof_layer][atof_component].dvalue);

  //---Looping over steps---//
  for(unsigned int s=0; s<tInfos.nsteps; s++)
    {
      //Local coordinate of this step      
      double LposZ = Lpos[s].z();

      //distance to the SiPM
      double distance = halfLength;
                  
      if(atof_superlayer == 0 && atof_order==1) distance += LposZ;
      else if (atof_superlayer == 0 && atof_order==0) distance += - LposZ;
      else {
	double LposX = Lpos[s].x();
	double LposY = Lpos[s].y();
	double l_a = sqrt( pow((dim_3 - LposX),2) + pow((dim_4 - LposY),2) );
	double l_b = sqrt( pow((dim_5 - LposX),2) + pow((dim_6 - LposY),2) );
	if((l_a + l_b) == l_topXY) distance = 0;
	else distance = l_a * sqrt( 1 - ((l_topXY*l_topXY + l_a*l_a - l_b*l_b)/(2*l_a*l_topXY)) );
      }
      
      //Energy arriving at the SiPM [MeV]
      double eToSiPM = Edep[s] *exp(-distance/attlength);
      
      //Total energy deposited for this hit
      eTot += eToSiPM;
      //time in ns, weighted by energy deposit
      if(atof_superlayer == 0) weightedTime += (times[s] + distance/effVelocity)*eToSiPM;
      else weightedTime += (times[s])*eToSiPM;//we ignore effective velocity for wedges for now
    }

  //total energy for this hit, adding resolution from photo-electron counting
  double energy = G4Poisson(eTot*pmtPEYld)/pmtPEYld;

  //for attenuation
  double thickness = 0.3;//bars 3mm
  if(atof_component<10) thickness = 2.0;//wedges 2cm

  //should be converted to an adc value with the proper factor here
  double adc = energy  *(1/(dEdxMIP*thickness));

  //hit time as mean step time, applying global offset
  double time = weightedTime/eTot + t0;
  //for bars we also have time up/down offset
  if(atof_component == 10){
    if(atof_order==1) time += tUD/2;
    else time += -tUD/2;
  }
  
  dgtz["hitn"]      = hitn;
  dgtz["sector"]    = atof_sector; //Sector ranges from 0 to 14 counterclockwise when z is pointing towards us
  dgtz["layer"]     = atof_layer; //Layer is the index for the wedge+bar (quarter of sector) ranging 0 to 3
  dgtz["component"] = atof_component; //z slice ranging 0 to 9 for the wedge or 10 if it is the long bar
  dgtz["TDC_order"] = atof_order;
  dgtz["TDC_ToT"]   = (int)adc*100;
  dgtz["TDC_TDC"]   = time * time_to_tdc;//time to tdc conversion
  
  // define conditions to reject hit
  if (rejectHitConditions) {
    writeHit = false;
  }
  
  return dgtz;
}

vector<identifier> atof_HitProcess::processID(vector<identifier> id,  [[ maybe_unused ]] G4Step* aStep,  [[ maybe_unused ]] detector Detector) {
  
  vector<identifier> yid = id;
  
  // top components do not modify order
  if (yid[1].id == 1) {
    id[id.size()-1].id_sharing = 1;
    return id;
  }
  
  yid[0].id_sharing = 1; // sector
  yid[1].id_sharing = 1; // superlayer
  yid[2].id_sharing = 1; // layer
  yid[3].id_sharing = 1; // component
  yid[4].id_sharing = 1; // order
  
  if (yid[4].id != 0) {
    cout << "*****WARNING***** in ahdc_HitProcess :: processID, order of the original hit should be 0 " << endl;
    cout << "yid[4].id = " << yid[4].id << endl;
  }
  
  // Now we want to have similar identifiers, but the only difference be id order to be 1, instead of 0
  identifier this_id = yid[0];
  yid.push_back(this_id);
  this_id = yid[1];
  yid.push_back(this_id);
  this_id = yid[2];
  yid.push_back(this_id);
  this_id = yid[3];
  yid.push_back(this_id);
  this_id = yid[4];
  this_id.id = 1;
  yid.push_back(this_id);
  
  return yid;
}

// - electronicNoise: returns a vector of hits generated / by electronics.

vector<MHit*> atof_HitProcess::electronicNoise() {
  vector<MHit*> noiseHits;
  
  // first, identify the cells that would have electronic noise
  // then instantiate hit with energy E, time T, identifier IDF:
  //
  // MHit* thisNoiseHit = new MHit(E, T, IDF, pid);
  
  // push to noiseHits collection:
  // noiseHits.push_back(thisNoiseHit)
	
  return noiseHits;
}

map< string, vector <int> > atof_HitProcess::multiDgt( [[ maybe_unused ]] MHit* aHit,  [[ maybe_unused ]] int hitn) {
  map< string, vector <int> > MH;
  
  return MH;
}

// - charge: returns charge/time digitized information / step

map< int, vector <double> > atof_HitProcess::chargeTime( [[ maybe_unused ]] MHit* aHit,  [[ maybe_unused ]] int hitn) {
  map< int, vector <double> >  CT;
  
  return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)

double atof_HitProcess::voltage( [[ maybe_unused ]] double charge,  [[ maybe_unused ]] double time,  [[ maybe_unused ]] double forTime) {
  return 0.0;
}

void atof_HitProcess::initWithRunNumber(int runno)
{
  string digiVariation = gemcOpt.optMap["DIGITIZATION_VARIATION"].args;
  
  if (atc.runNo != runno) {
    cout << " > Initializing " << HCname << " digitization for run number " << runno << endl;
    atc = initializeATOFConstants(runno, digiVariation);
    atc.runNo = runno;
  }
}

// this static function will be loaded first thing by the executable
atofConstants atof_HitProcess::atc = initializeATOFConstants(-1);
