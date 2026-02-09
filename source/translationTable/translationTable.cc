/// \file translationTable.cc
/// \author \n Maurizio Ungaro
/// \author mail: ungaro@jlab.org\n\n\n

// translationTable framework
#include "translationTable.h"

// c++
#include <iostream>

string TranslationTable::hardwareKey(vector<int> c)
{
	string hardwareKey = "";
	for(const auto &v : c)
		hardwareKey += to_string(v) + "-" ;

	return hardwareKey;
}


Hardware TranslationTable::getHardware(vector<int> c)
{
	string hk = hardwareKey(c);

	auto search = tt.find(hk);

	if(search != tt.end())
		return search->second;
	else {
		cout << " !! Error: item <" << hk << "> not found in translation table " << name  << endl;

		return Hardware();
	}
}

void TranslationTable::addHardwareItem(vector<int> c, Hardware h)
{
	string hk = hardwareKey(c);

	auto search = tt.find(hk);

	if(search == tt.end())
		tt[hk] = h;
	else {
		cout << " !! Error: item <" << search->first << "> already in " << name << endl;
		cout << hk << endl;
	}
}

void TranslationTable::printTable()
{
	for(auto &thisItem: tt) {
		cout << "<" << thisItem.first << "> " << thisItem.second << endl;
	}
}


//! overloading "<<" to print this class
ostream &operator<<(ostream &stream, Hardware h)
{
	stream << " Crate: "   << h.crate;
	stream << " Slot: "    << h.slot;
	stream << " Channel: " << h.channel;
	
	return stream;
}
