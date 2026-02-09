// example on how to use the goptions framework library
// This example will create two three options, two of them
// with their own category: time and process.

// options
#include "goptions.h"


// this function defines the options map
map<string, GOption> defineOptions()
{
	map<string, GOption> optionsMap;

	optionsMap["geometry"]      = GOption("Window Geometry", "1400x1200");
	optionsMap["timeWindow"]    = GOption("Defines the Time Window", 100, "time");
	optionsMap["interpolation"] = GOption("Interpolation algorithm", "linear", "process");
	optionsMap["interpolation"].addHelp("Possible choices are:\n");
	optionsMap["interpolation"].addHelp(string(GOPTIONITEM) + "linear\n");
	optionsMap["interpolation"].addHelp(string(GOPTIONITEM) + "none (no interpolation)\n");

	return optionsMap;
}


// example of main loading the options map and printing one values and one option
int main(int argc, char* argv[])
{
	
	GOptions *gopts = new GOptions(argc, argv, defineOptions(), 1);

	cout << " example: The option interpolation is set at: " << gopts->getString("interpolation") << endl;
	cout << " example: Interpolation Option: " << gopts->getOption("interpolation") << endl << endl;

	return 1;
}

