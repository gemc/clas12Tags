// gstring
#include "gstring.h"

// c++
#include <sstream>

//! returns a vector of strings from a stringstream, space is delimeter
vector<string> gstring::getStringVectorFromString(string input)
{
	vector<string> pvalues;
	stringstream plist(input);
	while(!plist.eof()) {
		string tmp;
		plist >> tmp;
		string toPut = trimSpacesFromString(tmp);
		if(toPut != "")
			pvalues.push_back(toPut);
	}

	return pvalues;
}


//! Trims Both leading and trailing spaces
string gstring::trimSpacesFromString(string in)
{
	string out;

	size_t leapos = in.find_first_not_of(" \t"); // Find the first character position after excluding leading blank spaces
	size_t endpos = in.find_last_not_of(" \t");  // Find the first character position from reverse af

	// if all spaces or empty return an empty string
	if(( leapos == string::npos) || ( endpos == string::npos))
		out = "";
	else
		out = in.substr( leapos, endpos-leapos+1 );

	return out;
}

//! returns a vector of strings from a stringstream, x (one char) is delimiter
vector<string> gstring::getStringVectorFromStringWithDelimiter(string input, string x)
{
	vector<string> pvalues;

	string tmp = "";
	for(unsigned int i=0; i<input.size(); i++) {

		if(input[i] != x[0]) {
			tmp += input[i];
		} else {
			if(tmp != "") {
				pvalues.push_back(trimSpacesFromString(tmp));
			}
			tmp = "";
		}

		// end of line
		if(i==input.size() - 1 && tmp != "") {
			pvalues.push_back(trimSpacesFromString(tmp));
		}
	}

	return pvalues;
}


//! Replace all occurences of specific chars in string with a string
string gstring::replaceCharInStringWithChars(string input, string toReplace, string replacement)
{

	string output = "";

	for(unsigned int k=0; k<input.size(); k++) {

		int replace = 0;

		for(unsigned int j=0; j<toReplace.size(); j++) {
			// found common char, replacing it with replacement
			if(input[k] == toReplace[j]) {
				output.append(replacement);
				replace = 1;
			}
		}
		if(!replace) output += input[k];
	}

	return output;
}

#include <iostream>
using namespace std;

string gstring::fillDigits(string word, string c, int ndigits)
{
	string filled;

	int toFill = ndigits - (int) word.size();

	for(int d=0; d<toFill; d++) {
		filled += c;
	}

	filled += word;

	return filled;
}


string gstring::assignAttribute(QDomElement e, string attribute, string defaultValue)
{
	if(e.attributeNode(attribute.c_str()).isAttr())
		return trimSpacesFromString(e.attributeNode(attribute.c_str()).value().toStdString());

	// otherwise
	return defaultValue;
}
int gstring::assignAttribute(QDomElement e, string attribute, int defaultValue)
{
	if(e.attributeNode(attribute.c_str()).isAttr())
		return getG4Number(trimSpacesFromString(e.attributeNode(attribute.c_str()).value().toStdString()));

	return defaultValue;
}
double gstring::assignAttribute(QDomElement e, string attribute, double defaultValue)
{
	if(e.attributeNode(attribute.c_str()).isAttr())
		return getG4Number(trimSpacesFromString(e.attributeNode(attribute.c_str()).value().toStdString()));

	return defaultValue;
}

// CLHEP units
#include "CLHEP/Units/PhysicalConstants.h"
using namespace CLHEP;


/// \fn double getG4Number(string v, bool warnIfNotUnit)
/// \brief Return value of the input string, which may or may not
/// contain units (warning given if requested)
/// \param v input string. Ex: 10.2*cm
/// \return value with correct G4 unit.
double gstring::getG4Number(string v, bool warnIfNotUnit)
{
	string value = trimSpacesFromString(v);

	// no * found
	if(value.find("*") == string::npos) {
		// no * found, this should be a number
		// No unit is still ok if the number is 0

		if(value.length()>0 && warnIfNotUnit && stod(value) != 0) {
			cout << " ! Warning: value " << v << " does not contain units." << endl;
		}
		return stod(value);

	} else {
		string rootValue = value.substr(0, value.find("*"));
		string units     = value.substr(value.find("*") + 1);

		double answer = stod(rootValue);

			 if( units == "m")         answer *= m;
		else if( units == "inches")    answer *= 2.54*cm;
		else if( units == "inch")      answer *= 2.54*cm;
		else if( units == "cm")        answer *= cm;
		else if( units == "mm")        answer *= mm;
		else if( units == "um")        answer *= 1E-6*m;
		else if( units == "fm")        answer *= 1E-15*m;
		else if( units == "deg")       answer *= deg;
		else if( units == "degrees")   answer *= deg;
		else if( units == "arcmin")    answer = answer/60.0*deg;
		else if( units == "rad")       answer *= rad;
		else if( units == "mrad")      answer *= mrad;
		else if( units == "eV")        answer *= eV;
		else if( units == "MeV")       answer *= MeV;
		else if( units == "KeV")       answer *= 0.001*MeV;
		else if( units == "GeV")       answer *= GeV;
		else if( units == "T")         answer *= tesla;
		else if( units == "T/m")       answer *= tesla/m;
		else if( units == "Tesla")     answer *= tesla;
		else if( units == "gauss")     answer *= gauss;
		else if( units == "kilogauss") answer *= gauss*1000;
		else if( units == "ns")        answer *= ns;
		else if( units == "na")        answer *= 1;
		else if( units == "counts")    answer *= 1;
		else cout << ">" << units << "<: unit not recognized for string <" << v << ">" << endl;
		return answer;
	}

	return 0;
}


G4ThreeVector gstring::vectorFromStringVector(vector<string> sv)
{
	if(sv.size() == 3) {
		double uno = getG4Number(sv[0]);
		double due = getG4Number(sv[1]);
		double tre = getG4Number(sv[2]);

		return G4ThreeVector(uno, due, tre);
	}

	return G4ThreeVector(0,0,0);
}

vector<double> gstring::getG4NumbersFromStringVector(vector<string> vstring, bool warnIfNotUnit)
{
	vector<double> output;

	for(auto &s: vstring) {
		output.push_back(getG4Number(s, warnIfNotUnit));
	}

	return output;
}

vector<double>  gstring::getG4NumbersFromString(string vstring, bool warnIfNotUnit) {
	return getG4NumbersFromStringVector(getStringVectorFromString(vstring), warnIfNotUnit);
}


// get path from filename with path
string gstring::getPathFromFilename(string file)
{
	// PRAGMA TODO:
	// can use the c++17 filename path
	// for now using string manipulation but should account for WINDOWS machines as well
	
	auto lastSlash = file.find_last_of('/');
	
	return file.substr(0, lastSlash);
}



// get filename from filename with path
string gstring::getFilenameFromFilenameWithPath(string file)
{
	// PRAGMA TODO:
	// can use the c++17 filename path
	// for now using string manipulation but should account for WINDOWS machines as well
	
	auto lastSlash = file.find_last_of('/');
	
	return file.substr(lastSlash + 1, file.length());
}








