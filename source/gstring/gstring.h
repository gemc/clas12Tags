#ifndef GSTRING_H
#define GSTRING_H 1

#ifndef FATALERRORL
	#define	FATALERRORL " ☣︎"
	#define	GWARNING    " ⚠︎"
#endif

// c++
#include <vector>
#include <string>
using namespace std;

// qt
#include <QtXml>

// geant4
#include "G4ThreeVector.hh"

namespace gstring
{
	//! a vector of strings from a stringstream, space is delimiter
	vector<string> getStringVectorFromString(string);

 	//! returns a vector of strings from a stringstream, second string is delimiter
	vector<string> getStringVectorFromStringWithDelimiter(string, string);

	//! Removes leading and trailing spaces
	string trimSpacesFromString(string);

	//! Replace all occurences of a char in string with a string
	string replaceCharInStringWithChars(string input, string toReplace, string replacement);

	// adds zeros to fill totDigits
	string fillDigits(string word, string c, int ndigits);


	// returns values (with defaults) from a QDomElement
	string assignAttribute(QDomElement e, string attribute, string defaultValue);
	int    assignAttribute(QDomElement e, string attribute, int defaultValue);
	double assignAttribute(QDomElement e, string attribute, double defaultValue);

	// returns a string from a QVariant
	inline string qVariantToStdString(QVariant input) {
		return input.toString().toStdString();
	}

	// getting a number from a string that contains units
	double getG4Number(string input, bool warnIfNotUnit = false);
	vector<double> getG4NumbersFromStringVector(vector<string> vstring, bool warnIfNotUnit = false);
	vector<double> getG4NumbersFromString(string vstring, bool warnIfNotUnit = false);

	G4ThreeVector vectorFromStringVector(vector<string> sv);
	
	
	// get path from filename with path
	string getPathFromFilename(string file);
	
	// get filename from filename with path
	string getFilenameFromFilenameWithPath(string file);
}





#endif
