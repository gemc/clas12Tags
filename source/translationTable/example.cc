/// \file example.cc

// example on how to use the translationTable library
// this will load tables from Jefferson Lab CLAS12 CCDB database

// translationTable 
#include "translationTable.h"

// CCDB Warning
// copying the static library to the build directory will produce compilation errors.
// not doing so will build the example, but to run it, it will require the ccdb dynamic library.
// interesting huh?? Why is that.

#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>
using namespace ccdb;



//! example of main declaring GOptions
int main(int argc, char* argv[])
{
	bool verbosity = false;

	if(argc > 1) {
		string arg1 = argv[1];
		if(arg1 == "v")
			verbosity = true;
	}

	TranslationTable TT("ec");

	// loads translation table from CLAS12 Database:
	// Translation table for EC (ECAL+PCAL).
	// Crate sector assignments: ECAL/FADC=1,7,13,19,25,31 ECAL/TDC=2,8,14,20,26,32
	// PCAL/FADC=3,9,15,21,27,33 PCAL/TDC=4,10,16,22,28,34.
	// ORDER: 0=FADC 2=TDC.

	string connection =  "mysql://clas12reader@clasdb.jlab.org/clas12";
	string database   = "/daq/tt/ec:1";

	vector<vector<double> > data;
	auto_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(connection));

	data.clear(); calib->GetCalib(data, database);
	cout << " Data loaded from CCDB with " << data.size() << " columns." << endl;

	// filling translation table
	for(unsigned row = 0; row < data.size(); row++)
	{
		int crate   = data[row][0];
		int slot    = data[row][1];
		int channel = data[row][2];

		int sector = data[row][3];
		int layer  = data[row][4];
		int pmt    = data[row][5];
		int order  = data[row][6];

		if(verbosity) {
			cout << " crate: " << crate << "  slot: " << slot << "  channel: " << channel ;
			cout << " sector: " << sector << "  layer: " << layer << "  pmt: " << pmt << "  order: " << order << endl;
		}

		// order is important as we could have duplicate entries w/o it
		TT.addHardwareItem({sector, layer, pmt, order}, Hardware(crate, slot, channel));
	}
	cout << " Data loaded in translation table. " << endl;


	// now inquiring TT for sector, layer, component, order  =  1, 4, 1-36, 0
	for(int i=1; i<36; i++)
		cout << " hardware for pmt: " << i << ": " << TT.getHardware({1, 4, i, 0}) << endl;

	return 1;
}

