// Qt headers
#include <QtSql>

// gemc headers
#include "sensitiveID.h"
#include "gemcUtils.h"

// CLHEP units
#include "CLHEP/Units/PhysicalConstants.h"

using namespace CLHEP;


sensitiveID::sensitiveID(string SDName, goptions gemcOpt, string factory, string variation, string sys, int run) : name(SDName), system(sys) {

	double verbosity = gemcOpt.optMap["HIT_VERBOSITY"].arg;
	int fastmcMode = gemcOpt.optMap["FASTMCMODE"].arg;  // fast mc = 2 will increase prodThreshold and maxStep to 5m
	double runno_arg = gemcOpt.optMap["RUNNO"].arg;

	thisFactory = factory + " " + variation;

	if (SDName == "flux" || SDName == "mirror") {
		description = "generic flux/mirror detector";
		identifiers.push_back("id");
		signalThreshold = 0;
		timeWindow = 0;
		prodThreshold = 1 * mm;  // standard 1 mm production threshold
		maxStep = 1 * mm;
		return;
	}

	if (SDName == "counter") {
		description = "generic counter detector";
		identifiers.push_back("id");
		signalThreshold = 0;
		timeWindow = -1;
		prodThreshold = 1 * mm;  // standard 1 mm production threshold
		maxStep = 1 * mm;
		return;
	}

	// TEXT sensitivity infos. For now, CAD and GDML are loaded with TEXT
	if (factory == "TEXT" || factory == "CAD" || factory == "GDML") {
		string fname = system + "__hit_" + variation + ".txt";
		if (factory == "CAD")
			fname = system + "__hit_cad.txt";
		if (factory == "GDML")
			fname = system + "__hit_cad.txt";

		if (verbosity > 1) cout << " > Loading TEXT Hit definitions for sensitive system <" << SDName << ">..." << endl;

		ifstream IN(fname.c_str());
		if (!IN) {
			// if file is not found, maybe it's in the GEMC_DATA_DIR directory
			if (getenv("GEMC_DATA_DIR") != nullptr) {
				string maybeHere = (string) getenv("GEMC_DATA_DIR") + "/" + fname;

				IN.open(maybeHere.c_str());
				if (!IN && verbosity > 2) {
					cout << "  !!! Error: Failed to open hit file " << fname << " for sensitive detector: >"
						 << SDName << "<. Maybe the filename doesn't exist?" << endl;
				}
			}
			if (!IN && verbosity > 2) {
				cout << "  !!! Error: Failed to open hit file " << fname << " for sensitive detector: >"
					 << SDName << "<. Maybe the filename doesn't exist?" << endl;
			}
		}

		if (IN) {
			while (!IN.eof()) {
				string dbline;
				getline(IN, dbline);

				if (!dbline.size())
					continue;

				gtable gt(getStringVectorFromStringWithDelimiter(dbline, "|"));

				if (gt.data.size())
					if (gt.data[0] == SDName) {
						// Reading variables
						// 0 is system name, by construction is SD

						// 1: description
						description = gt.data[1];

						// 2: Identifiers
						vector <string> ids = getStringVectorFromString(gt.data[2]);
						for (unsigned i = 0; i < ids.size(); i++)
							identifiers.push_back(ids[i]);

						// 3: Minimum Energy Cut for processing the hit
						signalThreshold = get_number(gt.data[3], 1);

						// 4: Time Window
						timeWindow = get_number(gt.data[4], 1);

						// 5: Production Threshold in the detector
						prodThreshold = get_number(gt.data[5], 1);
						if (fastmcMode > 0) prodThreshold = 5000;

						// 6: Maximum Acceptable Step in the detector
						maxStep = get_number(gt.data[6], 1);
						if (fastmcMode > 0) maxStep = 5000;

						// 7: rise time of the PMT signal
						riseTime = get_number(gt.data[7], 1);

						// 8: fall time of the PMT signal
						fallTime = get_number(gt.data[8], 1);

						// 9: from MeV to mV constant
						mvToMeV = get_number(gt.data[9]);

						// 10: pedestal
						pedestal = get_number(gt.data[10]);

						// 11: time from PMT face to signal
						delay = get_number(gt.data[11]);

					}
			}
			IN.close();
		}
			// default values if file is not present
		else {
			// 1: description
			description = "unknown";
			identifiers.push_back("unknown");
			signalThreshold = 1;
			timeWindow = 100;
			prodThreshold = 1;
			maxStep = 10;
			riseTime = 10;
			fallTime = 20;
			mvToMeV = 100;
			pedestal = 100;
			delay = 100;

			if (fastmcMode > 0) {
				prodThreshold = 5000;
				maxStep = 5000;
			}
		}

		return;
	}



	// SQLITE sensitivity infos
	if (factory == "SQLITE") {
		// connection to the DB
		QSqlDatabase db = openGdb(gemcOpt);
		if (verbosity > 1) cout << " > Loading SQLITE Hit definitions for sensitive system <" << SDName << ">..." << endl;

		if (runno_arg != -1) run = runno_arg; // if RUNNO is set (different from -1), use it
		int run_number = get_sql_run_number(db, system, variation, run, "hits");

		string dbexecute =
				"select name, description, identifiers, signalThreshold, timeWindow, prodThreshold, maxStep, riseTime, fallTime, mvToMeV, pedestal, delay from hits";
		dbexecute += " where variation ='" + variation + "'";
		dbexecute += " and run = " + stringify(run_number);
		dbexecute += " and system = '" + system + "'";
		dbexecute += " and name = '" + SDName + "'";

		QSqlQuery q;
		if (!q.exec(dbexecute.c_str())) {
			cout << " !!! Failed to execute SQLITE query " << dbexecute << ". This is a fatal error. Exiting." << endl;
			qDebug() << q.lastError();
			exit(1);
		}
		// Warning if nothing is found
		if (q.size() == 0 && verbosity) {
			cout << "  ** WARNING: sensitive detector \"" << SDName << "\" not found in factory " << factory
				 << " for variation " << variation << endl << endl;
		}

		// loading hit definitions from DB
		while (q.next()) {
			// Reading variables
			// 0 is system name
			name = qv_tostring(q.value(0));

			// 1: description
			description = qv_tostring(q.value(1));

			// 2: Identifiers
			vector <string> ids = getStringVectorFromString(qv_tostring(q.value(2)));
			for (unsigned i = 0; i < ids.size(); i++)
				identifiers.push_back(ids[i]);

			// 3: Minimum Energy Cut for processing the hit
			signalThreshold = get_number(qv_tostring(q.value(3)));

			// 4: Time Window
			timeWindow = get_number(qv_tostring(q.value(4)));

			// 5: Production Threshold in the detector
			prodThreshold = get_number(qv_tostring(q.value(5)));

			// 6: Maximum Acceptable Step in the detector
			maxStep = get_number(qv_tostring(q.value(6)));

			// 7: rise time of the PMT signal
			riseTime = get_number(qv_tostring(q.value(7)));

			// 8: fall time of the PMT signal
			fallTime = get_number(qv_tostring(q.value(8)));

			// 9: from MeV to mV constant
			mvToMeV = get_number(qv_tostring(q.value(9)));

			// 10: pedestal
			pedestal = get_number(qv_tostring(q.value(10)));

			// 11: time from PMT face to signal
			delay = get_number(qv_tostring(q.value(11)));

		}

		return;
	}

}


ostream &operator<<(ostream &stream, sensitiveID SD) {
	cout << "  > Sensitive detector " << SD.name << ": " << endl << endl;
	for (unsigned int i = 0; i < SD.identifiers.size(); i++) {
		cout << "    - identifier element:  " << SD.identifiers[i] << endl;
	}
	cout << endl << "  >  Signal Threshold:        " << SD.signalThreshold / MeV << " MeV." << endl;
	cout << "  >  Production Threshold:    " << SD.prodThreshold / mm << " mm." << endl;
	cout << "  >  Time Window for:         " << SD.timeWindow / ns << " ns." << endl;
	cout << "  >  Maximum Acceptable Step: " << SD.maxStep / mm << " mm." << endl;
	cout << "  >  Signal Rise Time:        " << SD.riseTime / ns << " ns." << endl;
	cout << "  >  Signal Fall Time:        " << SD.fallTime / ns << " ns." << endl;
	cout << "  >  Signal MeV to mV:        " << SD.mvToMeV << "  mV/MeV" << endl;
	cout << "  >  Signal Pedestal:         " << SD.pedestal << " mV" << endl;
	cout << "  >  Signal Delay             " << SD.delay / ns << " ns." << endl;
	cout << endl;

	return stream;
}
