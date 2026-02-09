// frequencySyncSignal
#include "frequencySyncSignal.h"

// gstring
#include "gstring.h"
using namespace gstring;

// c++
#include <random>
#include <iostream>
#include <algorithm> // for sort for gcc


// building first RF from the start time
oneRFOutput::oneRFOutput(int seed, double timeWindow, double startTime, double radioPeriod, double offset, int rfBunchGap)
{
	rfoffset = offset;

	// generating random number between -timeWindow and timeWindow
	random_device randomDevice;
    mt19937 generator(randomDevice());

    if(seed != -1) {
        generator.seed(seed);
    }

	// prepares continuous uniform distribution between -timeWindow/radioPeriod and timeWindow/radioPeriod
	uniform_real_distribution<> randomDistribution(-timeWindow/radioPeriod, timeWindow/radioPeriod);

    // very first RF time
	// use random engine to generate a random number between -timeWindow/radioPeriod and timeWindow/radioPeriod
	double firstRF = startTime + offset + radioPeriod*(int)randomDistribution(generator);

	// making sure the first RF is within the timewindow
	while(firstRF<0 || firstRF>timeWindow) {
		firstRF = startTime + offset + radioPeriod*(int)randomDistribution(generator);
	}

	// now filling the full signal
	fillRFValues(firstRF, timeWindow, rfBunchGap*radioPeriod);
}

// building RF from existing RFs
oneRFOutput::oneRFOutput(double oneRFValue, double rfsDistance, double timeWindow, double offset, double intervalBetweenBunches) {

	rfoffset = offset;
	// going backward in time by the distance
	double firstRF = oneRFValue - rfsDistance + offset;

	// if that doesn't work, going forward
	if(firstRF < 0 || firstRF > timeWindow) { firstRF = oneRFValue + rfsDistance  + offset; }

	// if that didn't work either, the distance between RFs is too big
	if(firstRF < 0 || firstRF > timeWindow) {
		cout << "  !! error: RF value is outside the timewindow." << endl;
	} else {
		fillRFValues(firstRF, timeWindow, intervalBetweenBunches);
	}
}

void oneRFOutput::fillRFValues(double firstRF, double timeWindow, double intervalBetweenBunches)
{
	double putRF = firstRF;

	// adding earlier RFs
	while(putRF>0) {
		rfValue.push_back(putRF);
		putRF -= intervalBetweenBunches;
	}

	// adding later RFs
	putRF = firstRF + intervalBetweenBunches;
	while(putRF<timeWindow) {
		rfValue.push_back(putRF);
		putRF += intervalBetweenBunches;
	}

	// sorting vector
	sort(rfValue.begin(), rfValue.end());

	// adding the id
	for(unsigned n = 0; n<rfValue.size(); n++) {
		rfID.push_back(n+1);
	}
}

//! overloading "<<" to print this class
ostream &operator<<(ostream &stream, oneRFOutput s)
{
	for(unsigned j=0; j< s.rfID.size(); j++) {
		stream << "       - RFID: "   << s.rfID[j]  << "   RF offset: " << s.rfoffset << "   RF Value: " << s.rfValue[j] << endl;
	}

	return stream;
}

//! overloading "<<" to print this class
ostream &operator<<(ostream &stream, FrequencySyncSignal s)
{
    stream << " > RF Signal " ;
    stream << "   - Seed: "   << s.seed;
	stream << "   - Time Window: "   << s.timeWindow;
	stream << ", event Start Time: "   << s.startTime << endl;
	stream << "   - Radio Frequency: "   << s.radioFrequency << " GHz: Period is " << s.radioPeriod << "ns" << endl;
	stream << "   - Distance between RF bunches "   << s.rfBunchGap*s.radioPeriod << " ns" << endl;

	for(unsigned i=0; i<s.rfBunchDistance.size(); i++) {
		stream << "   - Additional RF signal n. " << i+2 << " is " <<  s.rfBunchDistance[i]*s.radioPeriod << " ns away." << endl;
	}

	for(unsigned i=0; i<s.output.size(); i++) {
		stream << "    > RF Output n. " << i+1 << ":" << endl;
		stream << s.output[i] ;
	}

	return stream;
}


FrequencySyncSignal::FrequencySyncSignal(string setup)
{
	unsigned long minNumberOfArguments = 6;

	// setup is a string with at least minNumberOfArguments entries.
	// any entry after that will add an additional RFOutput
	vector<string> parsedSetup = getStringVectorFromString(setup);
	if(parsedSetup.size() < minNumberOfArguments) {
		cout << " !! Error: FrequencySyncSignal initializer incomplete: >" << setup << "< has not enough parameters, at least "
		<<  minNumberOfArguments << " needed. Exiting" << endl;
		exit(1);
	}

    seed             = stoi(parsedSetup[0]);
	timeWindow       = stod(parsedSetup[1]);
	startTime        = stod(parsedSetup[2]);
	radioFrequency   = stod(parsedSetup[3]); // clock
	radioPeriod      = 1.0/radioFrequency;   // GHz > ns
	rfBunchGap       = stoi(parsedSetup[4]); // prescale
	double rfoffset1 = stod(parsedSetup[5]); // first RF offset


	// do nothing if timewindow is 0
	if(timeWindow == 0) {
		cout << " ! Warning: timewindow is set to 0. No RF output." << endl;
		return;
	}

	// first RF: use seed
	output.push_back(oneRFOutput(seed, timeWindow, startTime, radioPeriod, rfoffset1, rfBunchGap));

	// other signals
	// pair of delays between RF signals and RF offsets
	if(parsedSetup.size() > minNumberOfArguments) {

		// total number of RF signals * 2
		unsigned long remainingNRF = parsedSetup.size() - minNumberOfArguments;

		// if remainingNRF is not a multiple of 2, return
		if (remainingNRF%2 != 0) {
			return;
		}

		// getting first RF values, subtract original offset
		double oneValue = output[0].getValues().front() - rfoffset1;

		// adding oneRFOutput for each addtional RF signal
		for(unsigned i=0; i<remainingNRF/2; i++) {
            int j = minNumberOfArguments + 2*i;
			rfBunchDistance.push_back(stoi(parsedSetup[j]));
			double thisRfOffset = stod(parsedSetup[j+1]);

			output.push_back(oneRFOutput(oneValue, rfBunchDistance[i]*radioPeriod, timeWindow, thisRfOffset, radioPeriod*rfBunchGap));
		}
	}

}
