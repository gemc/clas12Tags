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


namespace {
// The serial GEMC run manager prepares these immutable tile settings before transport.
map<int, BmtTileConditions> preparedTiles;

string ccdbConnection()
{
	const char* connection = getenv("CCDB_CONNECTION");
	return connection ? connection : "mysql://clas12reader@clasdb.jlab.org/clas12";
}

string requestSuffix(int runno, const goptions& options)
{
	string suffix = ":" + to_string(runno) + ":" + options.optMap.at("DIGITIZATION_VARIATION").args;
	const string& time = options.optMap.at("DIGITIZATION_TIMESTAMP").args;
	if (time != "no") suffix += ":" + time;
	return suffix;
}

BmtTileConditions::Table readTileTable(const Assignment& assignment, const string& request, bool probability)
{
	BmtTileConditions::Table table{};
	bool seen[BmtTileConditions::NLAYERS][BmtTileConditions::NSECTORS]{};
	const auto rows = assignment.GetData();
	for (size_t i = 0; i < rows.size(); ++i) {
		ostringstream line;
		for (const auto& field : rows[i]) line << field << ' ';
		const string location = request + " row " + to_string(i + 1) + " [" + line.str() + "]";
		istringstream fields(line.str());
		int sector, layer, component;
		double value;
		if (rows[i].size() != 4 || !(fields >> sector >> layer >> component >> value) || !(fields >> ws).eof()
		    || sector < 1 || sector > BmtTileConditions::NSECTORS || layer < 1 || layer > BmtTileConditions::NLAYERS
		    || component != 0 || !std::isfinite(value) || (probability && (value < 0 || value > 1)))
			throw runtime_error("Invalid BMT tile in " + location);
		if (seen[layer-1][sector-1]) throw runtime_error("Duplicate BMT tile in " + location);
		seen[layer-1][sector-1] = true;
		table[layer-1][sector-1] = value;
	}
	for (int l = 0; l < BmtTileConditions::NLAYERS; ++l)
		for (int s = 0; s < BmtTileConditions::NSECTORS; ++s)
			if (!seen[l][s]) throw runtime_error("Missing sector " + to_string(s+1) + " layer " + to_string(l+1) + " in " + request);
	return table;
}

BmtTileConditions loadTiles(Calibration& calib, const string& suffix, const goptions& options)
{
	BmtTileConditions tiles;
	const bool enabled = options.optMap.at("DETECTOR_INEFFICIENCY").arg;
	const string base = "/calibration/mvt/";
	const string drift = base + "bmt_voltage" + suffix;
	unique_ptr<Assignment> driftHV(calib.GetAssignment(drift));
	if (driftHV) {
		tiles.driftVoltage = readTileTable(*driftHV, drift, false);
	} else if (enabled) {
		throw runtime_error("Missing BMT drift-voltage assignment " + drift);
	} else {
		cerr << " > BMT: no assignment for " << drift << ", using zero drift voltage on all tiles" << endl;
	}
	if (!enabled) {
		// Existing MC uses the nominal strip voltage, even for runs with a measured assignment.
		for (auto& layer : tiles.stripVoltage) layer.fill(520);
		return tiles;
	}

	const string strip = base + "bmt_strip_voltage" + suffix;
	unique_ptr<Assignment> stripHV(calib.GetAssignment(strip));
	if (!stripHV) throw runtime_error("Missing BMT strip-voltage assignment " + strip);
	tiles.stripVoltage = readTileTable(*stripHV, strip, false);

	const string request = base + "bmt_tile_efficiency" + suffix;
	unique_ptr<Assignment> assignment(calib.GetAssignment(request));
	if (assignment) {
		tiles.efficiency = readTileTable(*assignment, request, true);
		tiles.efficiencySource = request + " assignment " + to_string(assignment->GetId());
	} else {
		if (!options.optMap.at("BMT_ALLOW_MISSING_EFFICIENCY").arg)
			throw runtime_error("Missing BMT efficiency assignment " + request);
		tiles.efficiencySource = request + " MISSING: explicit unity fallback on powered tiles";
		for (auto& layer : tiles.efficiency) layer.fill(1);
	}
	for (int l = 0; l < BmtTileConditions::NLAYERS; ++l) {
		for (int s = 0; s < BmtTileConditions::NSECTORS; ++s) {
			if (tiles.driftVoltage[l][s] != 0 && tiles.stripVoltage[l][s] != 0) continue;
			if (assignment && tiles.efficiency[l][s] > 0)
				throw runtime_error("BMT sector " + to_string(s+1) + " layer " + to_string(l+1)
				    + " has zero drift or strip voltage but efficiency " + to_string(tiles.efficiency[l][s]) + " in " + request);
			tiles.efficiency[l][s] = 0;
		}
	}
	return tiles;
}
}

vector<string> BMT_HitProcess::prepareRuns(const vector<int>& runs, const goptions& options, bool writesDigitizedHits)
{
	preparedTiles.clear();
	if (!options.optMap.at("DETECTOR_INEFFICIENCY").arg) return {};
	if (writesDigitizedHits && options.optMap.at("SKIPREJECTEDHITS").arg)
		cerr << " > BMT warning: SKIPREJECTEDHITS=1 drops fully rejected hits from MC::True; "
		        "use SKIPREJECTEDHITS=0 for pre-readout truth." << endl;
	unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(ccdbConnection()));
	if (!calib) throw runtime_error("Could not open the BMT calibration database");
	vector<string> sources;
	for (int run : runs) {
		auto tiles = loadTiles(*calib, requestSuffix(run, options), options);
		sources.push_back(tiles.efficiencySource);
		preparedTiles.emplace(run, std::move(tiles));
	}
	return sources;
}

static bmtConstants initializeBMTConstants(int runno, const goptions& options)
{
	bmtConstants bmtc{};
	bmtc.runNo = runno;
	bmtc.connection = ccdbConnection();
	const string& digiVariation = options.optMap.at("DIGITIZATION_VARIATION").args;
	const string& snapshot = options.optMap.at("DIGITIZATION_TIMESTAMP").args;
	const string timestamp = snapshot == "no" ? "" : ":" + snapshot;
	vector<vector<double>> data;
	unique_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(bmtc.connection));
	if (!calib) throw runtime_error("Could not open the BMT calibration database");
	const auto prepared = preparedTiles.find(runno);
	bmtc.tiles = prepared != preparedTiles.end() ? prepared->second : loadTiles(*calib, requestSuffix(runno, options), options);

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

	// Imported background already contains the detector response.
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
	const double efficiency = applyInefficiencies ? bmtc.tiles.efficiency.at(layer-1).at(sector-1) : 1;
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
		bmtc.ThetaL=bmtc.Lor_Angle.GetAngle(bmtc.tiles.driftVoltage[layer-1][sector-1]/bmtc.hDrift*10,BField.perp(qEField)/gauss/1000.)*degree;
		bmtc.Theta_Ls_Z=Fdir.angle(dm_Z);
		bmtc.Theta_Ls_C=dm_C.angle(Fdir);
		
		if(bmtc.runNo == 0){
			cout << " > BMT: Field found with value " << fieldValue[2]/gauss << " gauss. Setting Lorentz angle accordingly." << endl;
			bmtc.ThetaL=bmtc.Lor_Angle.GetAngle(bmtc.tiles.driftVoltage[layer-1][sector-1]/bmtc.hDrift*10,BField.perp(qEField)/gauss/1000.)*degree;
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
	if(bmtc.tiles.driftVoltage[layer-1][sector-1] == 0) depe = 0;
	
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
	bmtc = initializeBMTConstants(runno, options);
}

bmtConstants BMT_HitProcess::bmtc{};
