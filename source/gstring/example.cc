/// \file example.cc

// example on a couple of string utilities

// gstring
#include "gstring.h"
using namespace gstring;

// c++
#include <iostream>


int main(int argc, char* argv[])
{
	if(argc != 2) {
		cerr << FATALERRORL << " Error: run example with exactly one argument" << endl;
	} else {

		string test = argv[1];
		vector<string> testResult = getStringVectorFromString(test);

		for(auto &s : testResult)
			cout << s << endl;
	}
	
	return 1;
}

