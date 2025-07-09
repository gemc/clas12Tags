// gemc headers
#include "outputFactory.h"
#include "gemcOptions.h"
#include "string_utilities.h"

#include "hipo_output.h"
#include "txt_output.h"
#include "txt_simple_output.h"

// mlibrary
#include "gstring.h"
using namespace gstring;

// C++ headers
#include <fstream>
using namespace std;

#define EVIO_BUFFER 30000000

outputFactory* getOutputFactory(map<string, outputFactoryInMap>* outputFactoryMap, string outputType) {
	if (outputFactoryMap->find(outputType) == outputFactoryMap->end()) {
		cout << endl << endl << "  >>> WARNING: Output type <" << outputType << "> NOT FOUND IN  Output Map." << endl;
		return nullptr;
	}

	return (*outputFactoryMap)[outputType]();
}

outputContainer::outputContainer(goptions Opts) {
	gemcOpt       = Opts;
	string hd_msg = gemcOpt.optMap["LOG_MSG"].args + " Output File: >> ";

	string optf = gemcOpt.optMap["OUTPUT"].args;
	outType.assign(optf, 0, optf.find(","));
	outFile.assign(optf, optf.find(",") + 1, optf.size());
	outFile.erase(remove(outFile.begin(), outFile.end(), ' '), outFile.end());

	if (outType != "no") cout << hd_msg << " Opening output file \"" << trimSpacesFromString(outFile) << "\"." << endl;
	if (outType == "txt" || outType == "txt_simple") txtoutput = new ofstream(trimSpacesFromString(outFile).c_str());
	{
	}

	if (outType == "hipo") { initializeHipo(false); }
}

void outputFactory::prepareEvent([[maybe_unused]] outputContainer* output, [[maybe_unused]] map<string, double>* configuration) {
}


outputContainer::~outputContainer() {
	string hd_msg = gemcOpt.optMap["LOG_MSG"].args + " Output File: >> ";

	if (outType != "no" && outType != "hipo") cout << " Closing " << outFile << "." << endl;
	if (outType == "txt" || outType == "txt_simple") txtoutput->close();
	{
	}
	if (outType == "hipo") {
		cout << hd_msg << " Closing Hipo file \"" << trimSpacesFromString(outFile) << "\"." << endl;
		if (hipoWriter && fileOpened && eventsWritten) { hipoWriter->close(); }
		if (hipoWriter) {
			delete hipoWriter;
			hipoWriter = nullptr;
		}
		if (hipoSchema) {
			delete hipoSchema;
			hipoSchema = nullptr;
		}
	}
}


map<string, outputFactoryInMap> registerOutputFactories() {
	map<string, outputFactoryInMap> outputMap;

	outputMap["txt"]        = &txt_output::createOutput;
	outputMap["txt_simple"] = &txt_simple_output::createOutput;

	outputMap["hipo"] = &hipo_output::createOutput;

	return outputMap;
}

int generatedParticle::getVariableFromStringI(string what) {
	if (what == "pid") return PID;
	else if (what == "multiplicity") return multiplicity;

	return 0;
}

double generatedParticle::getVariableFromStringD(string what) {
	if (what == "px") return momentum.x();
	else if (what == "py") return momentum.y();
	else if (what == "pz") return momentum.z();
	else if (what == "vx") return vertex.x();
	else if (what == "vy") return vertex.y();
	else if (what == "vz") return vertex.z();
	else if (what == "time") return time;

	return 0;
}

int ancestorInfo::getVariableFromStringI(string what) {
	if (what == "pid") return pid;
	else if (what == "tid") return tid;
	else if (what == "mtid") return mtid;

	return 0;
}

double ancestorInfo::getVariableFromStringD(string what) {
	if (what == "trackE") return trackE;
	else if (what == "px") return p.x();
	else if (what == "py") return p.y();
	else if (what == "pz") return p.z();
	else if (what == "vx") return vtx.x();
	else if (what == "vy") return vtx.y();
	else if (what == "vz") return vtx.z();

	return 0;
}
