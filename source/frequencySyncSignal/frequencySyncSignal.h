#ifndef FREQUENCYSYNCSIGNAL_H
#define FREQUENCYSYNCSIGNAL_H 1

// c++
#include <string>
#include <vector>

using namespace std;

class oneRFOutput {
public:
    // first RF constructor uses a random number generator, setting seed here
    oneRFOutput(int seed, double timeWindow, double startTime, double radioPeriod, double offset, int rfBunchGap);

    // subsequent RFs signals
    oneRFOutput(double oneRFValue, double rfsTimeDistance, double timeWindow, double offset, double intervalBetweenBunches);

    vector<int> getIDs() { return rfID; }
    vector<double> getValues() { return rfValue; }

private:
    vector<int> rfID;
    vector<double> rfValue;
	double rfoffset;
    void fillRFValues(double firstRF, double timeWindow, double intervalBetweenBunches);
    friend ostream &operator<<(ostream &stream, oneRFOutput);

};

class FrequencySyncSignal {

public:
    // constructor from string.
    // This will be replaced by a goption later on
    // setup example: "250, 100, 0.5, 80, 40":
    // - 250: Time window for all RFs
    // - 100: Event start time
    // - 0.5: Beam frequency (GHz)
    // - 80:  Distance between signals in the same RF, in number of bunches (1 bunch time = 1/frequency)
    // - 40:  Distance between different RFs output, in number of bunches (1 bunch time = 1/frequency)
    FrequencySyncSignal(string setup);

private:
    // these quantities are kept here for documentation
    // to build RFoutputs they do not need to be members
    int seed;              // seed for random number generator
    double timeWindow;     // total timewindow of one event - in ns
    double startTime;      // event start time
    double radioFrequency; // radiofrequency - in GHz
    double radioPeriod;    // period - in ns. It's 1/radioFrequency
    int rfBunchGap;        // time between RF bunches within the same RF signal, in number of radioPeriod

    vector<int> rfBunchDistance; // distance (in number of radioInterval) between multiple RF signals

    // output is a vector of oneRFOutput
    // The number of Radiofrequency signals is defined by the size of rfsDistance.
    // If that's 0, then we only have the first RF.
    // Within one RF, the number of bunches is defined by the total time window and
    // the radioperiod: the timewindow is filled with bunches.
    vector <oneRFOutput> output;


public:
    vector <oneRFOutput> getOutput() { return output; }

    //! overloading the << operator
    friend ostream &operator<<(ostream &stream, FrequencySyncSignal);

};


#endif
