// gemc headers
#include "BMT_hitprocess.h"

// geant4 headers
#include "G4FieldManager.hh"
#include "G4Field.hh"
#include "CLHEP/Vector/ThreeVector.h"
#include "Randomize.hh"
#include "G4ChargedGeantino.hh"
#include "G4Poisson.hh"

#include <cmath>
#include <sstream>
#include <stdexcept>
#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>
using namespace ccdb;


// found is false when the run has no efficiency assignment and every tile defaults to 1
static bmtConstants::TileEfficiencies loadTileEfficiencies(Calibration& calib, const string& request, bool& found)
{
	vector<vector<string>> rows;
	bmtConstants::TileEfficiencies efficiencies;
	found = false;
	if (!calib.GetCalib(rows, request)) {
		// Older snapshots and runs without an assignment retain the original BMT response.
		cerr << " > BMT: no efficiency assignment for " << request << ", using 1 for all tiles" << endl;
		for (auto& layer : efficiencies) layer.fill(1);
		return efficiencies;
	}
	if (rows.size() != bmtConstants::NLAYERS * bmtConstants::NSECTORS)
		throw runtime_error("Expected one CCDB row per BMT tile in " + request);

	for (auto& layer : efficiencies) layer.fill(-1);
	for (const auto& row : rows) {
		if (row.size() != 4) throw runtime_error("Expected sector layer component efficiency in " + request);
		int sector, layer, component;
		double efficiency;
		// Parse the complete fields so malformed constants cannot silently turn a tile off.
		istringstream fields(row[0] + " " + row[1] + " " + row[2] + " " + row[3]);
		if (!(fields >> sector >> layer >> component >> efficiency) || !(fields >> ws).eof()
		    || sector < 1 || sector > bmtConstants::NSECTORS || layer < 1 || layer > bmtConstants::NLAYERS
		    || component != 0 || !std::isfinite(efficiency) || efficiency < 0 || efficiency > 1)
			throw runtime_error("Invalid BMT tile row in " + request);
		double& value = efficiencies[layer-1][sector-1];
		if (value >= 0) throw runtime_error("Duplicate BMT tile in " + request);
		value = efficiency;
	}
	cout << " > BMT tile efficiencies loaded from " << request << endl;
	found = true;
	return efficiencies;
}

static bmtConstants initializeBMTConstants(int runno, const string& digiVariation, const string& digiSnapshotTime, bool applyInefficiencies)
{
	bmtConstants bmtc{};
	string timestamp = "";
	if(digiSnapshotTime != "no") {
		timestamp = ":"+digiSnapshotTime;
	}
	
	bmtc.runNo = runno;
	
	if(getenv ("CCDB_CONNECTION") != nullptr) {
		bmtc.connection = (string) getenv("CCDB_CONNECTION");
	} else {
		bmtc.connection = "mysql://clas12reader@clasdb.jlab.org/clas12";
	}
	
	vector<vector<double> > data;
	unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(bmtc.connection));
	
	bool efficienciesFound = false;
	string efficiencyRequest;
	if (applyInefficiencies) {
		efficiencyRequest = "/calibration/mvt/bmt_tile_efficiency:" + to_string(runno) + ":" + digiVariation + timestamp;
		bmtc.tileEfficiency = loadTileEfficiencies(*calib, efficiencyRequest, efficienciesFound);
	}

	// Load the geometrical constant for each layer
    snprintf(bmtc.database, sizeof(bmtc.database), "/geometry/cvt/mvt/bmt_layer_noshim:%d:%s%s", bmtc.runNo, digiVariation.c_str(), timestamp.c_str());
	data.clear(); calib->GetCalib(data,bmtc.database);
	
	for(unsigned row = 0; row < data.size(); row++) {
		bmtc.AXIS[row] = data[row][1];
		bmtc.RADIUS[row] = data[row][3];
		bmtc.ZMIN[row]   = data[row][4];
		bmtc.ZMAX[row] = data[row][5];
		bmtc.EDGE1[row] = (data[row][6]-30)*degree;
		bmtc.EDGE2[row] = (data[row][7]-30)*degree;
		bmtc.NSTRIPS[row] = data[row][8];
		bmtc.hDrift =  data[row][9];
	}
	
	// Load the strip structure of each layer, compute PITCH
	bmtc.GROUP.resize(bmtc.NLAYERS); // 6 Layers
	bmtc.PITCH.resize(bmtc.NLAYERS);
	
	for (int layer=0; layer<bmtc.NLAYERS;layer++){
        snprintf(bmtc.database, sizeof(bmtc.database), "/geometry/cvt/mvt/bmt_strip_L%d:%d:%s%s", layer+1, bmtc.runNo, digiVariation.c_str(), timestamp.c_str());
		data.clear(); calib->GetCalib(data,bmtc.database);
		
		bmtc.GROUP[layer].resize(data.size());
		bmtc.PITCH[layer].resize(data.size());
		for(unsigned row = 0; row < data.size(); row++)
		{
			bmtc.GROUP[layer][row] = data[row][0];
			bmtc.PITCH[layer][row] = data[row][1];
			
			if (bmtc.AXIS[layer]==1) {//Compute angular pitch and redefine the phi angular coverage to be consistent with the pitch
				bmtc.PITCH[layer][row] = bmtc.PITCH[layer][row]/bmtc.RADIUS[layer]; //Get an angular pitch
				for (int j = 0; j <bmtc.NSECTORS ; ++j)
				{
					double middle=(bmtc.EDGE1[layer]+bmtc.EDGE2[layer])/2.;
					bmtc.EDGE1[layer] = middle-bmtc.GROUP[layer][row]*bmtc.PITCH[layer][row]/2.;
					bmtc.EDGE2[layer] = middle+bmtc.GROUP[layer][row]*bmtc.PITCH[layer][row]/2.;
				}
			}
		}
	}

	// load drift HV for Lorentz angle calculation
	snprintf(bmtc.database, sizeof(bmtc.database), "/calibration/mvt/bmt_voltage:%d:%s%s", bmtc.runNo,
			 digiVariation.c_str(), timestamp.c_str());
	data.clear();
	calib->GetCalib(data, bmtc.database);
	for(unsigned row = 0; row < data.size(); row++)
	{
		int sector = data[row][0];
		int layer  = data[row][1];
		bmtc.HV_DRIFT[layer-1][sector-1] = data[row][3];
		bmtc.HV_STRIPS[layer-1][sector-1] = 520;
	}

	// GEMC already gives no signal on a tile with zero drift or strip voltage. Its efficiency must be 0,
	// otherwise the table describes a tile that is not in the state the simulation will use.
	if (efficienciesFound) {
		for (int layer = 0; layer < bmtc.NLAYERS; layer++) {
			for (int sector = 0; sector < bmtc.NSECTORS; sector++) {
				const double efficiency = bmtc.tileEfficiency[layer][sector];
				if ((bmtc.HV_DRIFT[layer][sector] == 0 || bmtc.HV_STRIPS[layer][sector] == 0) && efficiency > 0)
					throw runtime_error("BMT sector " + to_string(sector+1) + " layer " + to_string(layer+1)
					                    + " has zero drift or strip voltage but efficiency " + to_string(efficiency)
					                    + " > 0 in " + efficiencyRequest);
			}
		}
	}

	// all dimensions are in mm
	bmtc.SigmaDrift = 0.036; //mm-1
	bmtc.hStrip2Det = bmtc.hDrift/2.;
	bmtc.nb_sigma=4;
	//bmtc.changeFieldScale(-1);  // this needs to be read from DB
	
	bmtc.Lor_Angle.Initialize(runno);


	// get hit time distribution parameters
    snprintf(bmtc.database, sizeof(bmtc.database), "/calibration/mvt/bmt_time:%d:%s%s", bmtc.runNo, digiVariation.c_str(), timestamp.c_str());
	data.clear(); calib->GetCalib(data,bmtc.database);
	bmtc.Twindow  = data[0][3]*ns;
	bmtc.Tmean    = data[0][4]*ns;
	bmtc.Tsigma   = data[0][5]*ns;
	
	// now connecting to target geometry to get its position
    snprintf(bmtc.database, sizeof(bmtc.database), "/geometry/shifts/solenoid:%d:%s%s", bmtc.runNo, digiVariation.c_str(), timestamp.c_str());
	data.clear(); calib->GetCalib(data,bmtc.database);
	bmtc.targetZPos = data[0][3]*cm;
	
	return bmtc;
}

bool BMT_HitProcess::acceptTrack(int sector, int layer, int track, double efficiency)
{
	auto entry = acceptedTrackTile.try_emplace(make_tuple(sector, layer, track), false);
	if (entry.second) entry.first->second = G4UniformRand() < efficiency;
	return entry.first->second;
}

map<string, double>  BMT_HitProcess :: integrateDgt(MHit* aHit,  [[ maybe_unused ]] int hitn)
{
	map<string, double>  dgtz;
	vector<identifier> identity = aHit->GetId();
	rejectHitConditions = false;
	writeHit = true;

	if(aHit->isBackgroundHit == 1) {
		
		// background hit has all the energy in the first step.
		double totEdep = aHit->GetEdep()[0];
		
		int sector = identity[0].id;
		int layer  = identity[1].id;
		int strip  = identity[2].id;
		
		dgtz["sector"]    = sector;
		dgtz["layer"]     = layer;
		dgtz["component"] = strip;  // strip number
		dgtz["ADC_order"] = 0;
		dgtz["ADC_ADC"]   = int(1e6*totEdep/bmtc.w_i);
		dgtz["ADC_time"]  = bmtc.Twindow*G4UniformRand();;
		dgtz["ADC_ped"]   = 0;
		
		return dgtz;
	}
	
	// BMT ID:
	// layer, type, sector, strip
	
	int layer  = identity[0].id;
	int sector = identity[2].id;
	int strip  = identity[3].id;
	double energy = 0;
	int pid = aHit->GetPID();
	const double efficiency = applyInefficiencies ? bmtc.tileEfficiency.at(layer-1).at(sector-1) : 1;
	if (efficiency == 0) {
		writeHit = false;
		return dgtz;
	}

	const auto deposits = aHit->GetEdep();
	if (efficiency == 1) {
		for (double deposit : deposits) energy += deposit;
	} else {
		// Tracks can also share a strip within the electronics time window.
		const auto tracks = aHit->GetTIds();
		const auto pids = aHit->GetPIDs();
		bool accepted = false;
		for (size_t i = 0; i < deposits.size(); ++i) {
			if (acceptTrack(sector, layer, tracks[i], efficiency)) {
				if (!accepted) pid = pids[i];
				accepted = true;
				energy += deposits[i];
			}
		}
		if (!accepted) {
			writeHit = false;
			return dgtz;
		}
	}

	if(verbosity>4) {
		trueInfos tInfos(aHit);
		cout <<  log_msg << " layer: " << layer << "  sector: " << sector << "  Strip: " << strip
		<< " x=" << tInfos.x << " y=" << tInfos.y << " z=" << tInfos.z << endl;
	}
	
	
	
	dgtz["sector"]    = sector;
	dgtz["layer"]     = layer;
	dgtz["component"] = strip;  // strip number
	dgtz["ADC_order"] = 0;
	dgtz["ADC_ADC"]   = int(1e6*energy/bmtc.w_i);
	
	// for geantinos, assigning ADC = 1
	// notice for geant4 < 10.7, the pid of 0 conflicts with the optical photon
	if (pid == 0) {
		dgtz["ADC_ADC"]   = 1.0;
	}
	
	dgtz["ADC_time"]  = bmtc.Tmean+bmtc.Tsigma*G4RandGauss::shoot(0., 1.0);
	dgtz["ADC_ped"]   = 0;
	
	
	if (strip==-1) {
		dgtz["ADC_ADC"]   = 0;
	}
	
	// define conditions to reject hit
	if(rejectHitConditions) {
		writeHit = false;
	}
	
	return dgtz;
}



vector<identifier>  BMT_HitProcess :: processID(vector<identifier> id, G4Step* aStep, detector Detector)
{
	vector<identifier> yid = id;
	class bmt_strip bmts;
	
	int layer  = yid[0].id;
	int sector = yid[2].id;
	G4ThreeVector   xyz  = aStep->GetPostStepPoint()->GetPosition();  ///< Global Coordinates of interaction
	G4ThreeVector  lxyz  = aStep->GetPreStepPoint()->GetTouchableHandle()->GetHistory()->GetTopTransform().TransformPoint(xyz); ///< Local Coordinates of interaction
	double z0 = bmtc.ZMIN[layer-1]+Detector.dimensions[2];
	lxyz.setZ(lxyz.z()+z0);
	// if the scale is not set, then use fieldmanager to get the value
	// if fieldmanager is not found, the field is zero
	/*	if(bmtc.fieldScale == -1)
	 {*/
	const double point[4] = {xyz.x(), xyz.y(), xyz.z(), 10};
	double fieldValue[3] = {0, 0, 0};
	double phi_p=atan2(xyz.y(),xyz.x());
	
	G4FieldManager *fmanager = aStep->GetPostStepPoint()->GetPhysicalVolume()->GetLogicalVolume()->GetFieldManager();
	
	G4ThreeVector dm_Z(-sin(phi_p),cos(phi_p),0); //Unit vector indicating the direction of the measurement
	G4ThreeVector dm_C(0,0,1); //Unit vector indicating the direction of measurement
	
	// if no field manager, the field is zero
	if(fmanager) {
		fmanager->GetDetectorField()->GetFieldValue(point, fieldValue);
		G4ThreeVector BField(fieldValue[0],fieldValue[1],fieldValue[2]);
		G4ThreeVector qEField(cos(phi_p),sin(phi_p),0); //Product qE
		G4ThreeVector Fdir=qEField.cross(BField); //Direction of lorentz drift
		bmtc.ThetaL=bmtc.Lor_Angle.GetAngle(bmtc.HV_DRIFT[layer-1][sector-1]/bmtc.hDrift*10,BField.perp(qEField)/gauss/1000.)*degree;
		bmtc.Theta_Ls_Z=Fdir.angle(dm_Z);
		bmtc.Theta_Ls_C=dm_C.angle(Fdir);
		
		if(bmtc.runNo == 0){
			cout << " > BMT: Field found with value " << fieldValue[2]/gauss << " gauss. Setting Lorentz angle accordingly." << endl;
			bmtc.ThetaL=bmtc.Lor_Angle.GetAngle(bmtc.HV_DRIFT[layer-1][sector-1]/bmtc.hDrift*10,BField.perp(qEField)/gauss/1000.)*degree;
			bmtc.Theta_Ls_Z=Fdir.angle(dm_Z);
			bmtc.Theta_Ls_C=dm_C.angle(Fdir);
		}
	} else {
		bmtc.ThetaL=0;
		bmtc.Theta_Ls_Z=0;
		bmtc.Theta_Ls_C=0;
		if(bmtc.runNo == 0)
			cout << " > BMT: No field found. Lorentz angle set to zero." << endl;
	}
	
	double depe = aStep->GetTotalEnergyDeposit();
	if(bmtc.HV_DRIFT[layer-1][sector-1] == 0) depe = 0;
	
	// resetting depe for geantinos
	if (aStep->GetTrack()->GetDefinition() == G4ChargedGeantino::ChargedGeantinoDefinition() ){
		int np=G4Poisson( (aStep->GetStepLength()/cm) *1e4); // Warning... StepLength must be in cm... because it is 10 e- per cm for MIP
		int nsec=0;
		for (int n=0;n<np;n++) nsec+=G4Poisson(2); // For each primary ionization, there are 2 secondary ionization on average.
		depe=(np+nsec)*bmtc.w_i/1e6; // So that we recover np+nsec in bmt_strip.cc line 28
	}
	
	//cout << "resolMM " << layer << " " << xyz.x() << " " << xyz.y() << " " << xyz.z() << " " << depe << " " << aStep->GetTrack()->GetTrackID() << endl;
	
	// pairs [strip ID / fraction of energy ]
	vector<double> multi_hit = bmts.FindStrip(layer, sector, lxyz, depe, bmtc); //return strip=-1 and signal -1 if depe<ionization
	
	int n_multi_hits = multi_hit.size()/2;
	
	
	// sector = identity[0].id;
	// layer  = identity[1].id;
	// strip  = identity[2].id;
	
	// multi_hit[0] = id
	// multi_hit[1] = sharing
	
	// setting strip id to the one returned by the first entry in FindStrip
	yid[3].id = (int) multi_hit[0];
	
	// setting geantinoDepe
	yid[0].geantinoDepe = depe;
	
	yid[0].id_sharing = multi_hit[1];
	yid[1].id_sharing = multi_hit[1];
	yid[2].id_sharing = multi_hit[1];
	yid[3].id_sharing = multi_hit[1];
	if (multi_hit[1]!=-1) yid[3].id_sharing = multi_hit[1]/(1.0*(int) (1e6*depe/bmtc.w_i));
	
	// adding the additional identifiers
	for(int h=1; h<n_multi_hits; h++) {
		for(int j=0; j<3; j++) {
			identifier this_id;
			this_id.name       = yid[j].name;
			this_id.rule       = yid[j].rule;
			this_id.id         = yid[j].id;
			this_id.time       = yid[j].time;
			this_id.TimeWindow = yid[j].TimeWindow;
			this_id.TrackId    = yid[j].TrackId;
			this_id.id_sharing = multi_hit[2*h+1]; //Number of electron collected by the strip for this step
			yid.push_back(this_id);
		}
		// last id is strip
		identifier this_id;
		this_id.name       = yid[3].name;
		this_id.rule       = yid[3].rule;
		this_id.id         = (int) multi_hit[2*h];
		this_id.time       = yid[3].time;
		this_id.TimeWindow = yid[3].TimeWindow;
		this_id.TrackId    = yid[3].TrackId;
		this_id.id_sharing = multi_hit[2*h+1]/(1.0*(int) (1e6*depe/bmtc.w_i));//Fraction of depe: Mcoll/Nel
		yid.push_back(this_id);
	}
	
	
	return yid;
}


map< string, vector <int> >  BMT_HitProcess :: multiDgt( [[ maybe_unused ]] MHit* aHit,  [[ maybe_unused ]] int hitn)
{
	map< string, vector <int> > MH;
	
	return MH;
}

// - electronicNoise: returns a vector of hits generated / by electronics.
vector<MHit*> BMT_HitProcess :: electronicNoise()
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

// - charge: returns charge/time digitized information / step
map< int, vector <double> > BMT_HitProcess :: chargeTime( [[ maybe_unused ]] MHit* aHit,  [[ maybe_unused ]] int hitn)
{
	map< int, vector <double> >  CT;
	
	return CT;
}

// - voltage: returns a voltage value for a given time. The inputs are:
// charge value (coming from chargeAtElectronics)
// time (coming from timeAtElectronics)
double BMT_HitProcess :: voltage( [[ maybe_unused ]] double charge,  [[ maybe_unused ]] double time,  [[ maybe_unused ]] double forTime)
{
	return 0.0;
}


void BMT_HitProcess::initForTracking(int runno, const goptions& options)
{
	if (bmtc.runNo == runno) return;
	cout << " > Initializing bmt digitization for run number " << runno << endl;
	bmtc = initializeBMTConstants(runno, options.optMap.at("DIGITIZATION_VARIATION").args,
	                              options.optMap.at("DIGITIZATION_TIMESTAMP").args,
	                              options.optMap.at("DETECTOR_INEFFICIENCY").arg);
}

bmtConstants BMT_HitProcess::bmtc{};
