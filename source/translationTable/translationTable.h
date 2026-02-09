/// \mainpage
/// \section Overview
/// The translation table framework provides an interface between an
/// hardware object <Crate Slot Channel> to a vector of int.\n

/// \file translationTable.h
/// \author \n Maurizio Ungaro
/// \author mail: ungaro@jlab.org\n\n\n

#ifndef GTRANSLATIONTABLE_H
#define GTRANSLATIONTABLE_H

// c++
#include <string>
#include <map>
#include <vector>
using namespace std;

struct Hardware {

	Hardware(int c, int s, int ch) : crate(c), slot(s), channel(ch) {}
	Hardware() : crate(0), slot(0), channel(0) {}

private:
	int crate;
	int slot;
	int channel;

public:
	int getCrate()   {return crate;}
	int getSlot()    {return slot;}
	int getChannel() {return channel;}

	//! overloading the << operator
	friend ostream &operator<<(ostream &stream, Hardware);

};


class TranslationTable {

public:
	TranslationTable(string n) : name(n) { ; }
	TranslationTable() = default;

private:
	map<string, Hardware> tt;
	string name;
	string hardwareKey(vector<int>);

public:
	Hardware getHardware(vector<int>);
	void addHardwareItem(vector<int> i, Hardware h);
	string getName() {return name;}
	void printTable();

};


#endif





