// this file should be reorganized to split the asciiField and clas12BinField factories

// gemc headers
#include "gemcUtils.h"
#include "asciiField.h"
#include "clas12BinField.h"

// 1D-dipole field
// Dependent on 2 cartesian coordinates (longitudinal, transverse)
// uniform in the other coordinate
// The values can be loaded from the map in any order
// as long as their speed is ordered.
// The values are indexed as B1_2D[longi][transverse]


// from fieldFactory:  load field map
void asciiField::loadFieldMap_Dipole(gMappedField *map, double verbosity) {
	setlocale(LC_NUMERIC, "en_US");

	int np_1 = map->getCoordinateWithSpeed(0).np;
	int np_2 = map->getCoordinateWithSpeed(1).np;
	double min1 = map->getCoordinateWithSpeed(0).min;
	double min2 = map->getCoordinateWithSpeed(1).min;
	double max1 = map->getCoordinateWithSpeed(0).max;
	double max2 = map->getCoordinateWithSpeed(1).max;
	double cell1 = (max1 - min1) / (np_1 - 1);
	double cell2 = (max2 - min2) / (np_2 - 1);

	// Allocate memory. [LONGI][TRANSVERSE]
	// as initialized in the map
	map->B1_2D = new float *[map->np[0]];
	for (unsigned int i = 0; i < map->np[0]; ++i)
		map->B1_2D[i] = new float[map->np[1]];


	double unit1 = get_number("1*" + map->getCoordinateWithSpeed(0).unit);
	double unit2 = get_number("1*" + map->getCoordinateWithSpeed(1).unit);

	double scale = map->scaleFactor * get_number("1*" + map->unit);

	double d1, d2, b;

	// progress bar
	int barWidth = 50;

	// using fscanf instead of c++ to read file, this is a lot faster
	char ctmp[100];
	string tmp;
	FILE *fp = fopen(map->identifier.c_str(), "r");

	// Loop until "</mfield>" is read or an error/EOF occurs
	while (true) { // Use a loop that breaks internally for cleaner logic
		int items_read = fscanf(fp, "%s", ctmp);

		if (items_read == 1) {
			// Successfully read one string
			tmp = std::string(ctmp);
			if (tmp == "</mfield>") {
				// Found the desired end tag, exit the loop normally
				break;
			}
			// Optional: Process the string 'tmp' here if needed within the loop
			// std::cout << "Read: " << tmp << std::endl;

		} else {
			// fscanf did not return 1. This means error, EOF, or matching failure (0).
			if (feof(fp)) {
				// Reached End Of File before finding "</mfield>"
				fprintf(stderr, "Warning: Reached EOF before finding </mfield> tag.\n");
			} else if (ferror(fp)) {
				// A read error occurred
				perror("Error reading file"); // Prints the system error message
			} else {
				// fscanf returned 0 - unexpected for %s unless input format is strange
				fprintf(stderr, "Warning: fscanf failed to match input (returned 0).\n");
			}
			// In any error/EOF case, we should stop processing.
			tmp = ""; // Clear tmp to indicate failure or incomplete state if needed after loop
			break; // Exit the loop
		}
	}

	// now reading map
	// values as read from map
	for (int i1 = 0; i1 < np_1; i1++) {
		for (int i2 = 0; i2 < np_2; i2++) {
			int items_read = fscanf(fp, "%lg %lg %lg", &d1, &d2, &b);
			if (items_read == 3) {

				d1 *= unit1;
				d2 *= unit2;

				b *= scale;

				if (verbosity > 4 && verbosity != 99)
					cout << "  Loading Map: coordinates (" << d1 << ", " << d2 << ")   value: " << b << endl;


				// checking map consistency for first coordinate
				if ((min1 + i1 * cell1 - d1) / d1 > 0.001) {
					cout << "   !! Error:  coordinate index wrong. Map first point should be " << min1 + i1 * cell1
						 << " but it's  " << d1 << " instead. Cell size: " << cell1 << "  min: " << min1 << " max : "
						 << max1 << "  index: " << i1 << endl;
				}
				// checking map consistency for second coordinate
				if ((min2 + i2 * cell2 - d2) / d2 > 0.001) {
					cout << "   !! Error:  coordinate index wrong. Map second point should be " << min2 + i2 * cell2
						 << " but it's  " << d2 << " instead. Cell size: " << cell2 << "  min: " << min2 << " max : "
						 << max2 << "  index: " << i2 << endl;
				}

				// calculating index
				unsigned t1 = (unsigned) floor((d1 - min1 + cell1 / 2) / (cell1));
				unsigned t2 = (unsigned) floor((d2 - min2 + cell2 / 2) / (cell2));

				// The values are indexed as B1_2D[longi][transverse]
				if (map->getCoordinateWithSpeed(0).name == "longitudinal"
					&& map->getCoordinateWithSpeed(1).name == "transverse") {
					map->B1_2D[t1][t2] = b;
				} else if (map->getCoordinateWithSpeed(0).name == "transverse"
						   && map->getCoordinateWithSpeed(1).name == "longitudinal") {

					t1 = (unsigned) floor((d2 - min2 + cell2 / 2) / (cell2));
					t2 = (unsigned) floor((d1 - min1 + cell1 / 2) / (cell1));
					map->B1_2D[t2][t1] = b;
				}
			} else {
				if (feof(fp)) {
					cout << " Warning: Reached end-of-file while trying to read data." << endl;
				} else if (ferror(fp)) {
					cout << " Error: An error occurred while reading the file." << endl;
				} else {
					cout << "  !! Error:  reading field map, not enough values in line " << i1 << " " << i2 << endl;
				}
			}
		}

		cout << "    [";
		double progress = (double) i1 / (double) np_1;
		int pos = progress * barWidth;
		for (int i = 0; i < barWidth; ++i) {
			if (i < pos) cout << "=";
			else if (i == pos) cout << ">";
			else cout << " ";
		}
		cout << "] " << int(progress * 100.0) << " %\r";
		cout.flush();
	}
	fclose(fp);

	cout << endl;
}

// from mappedField:  GetFieldValue
void gMappedField::GetFieldValue_Dipole(const double x[3], double *Bfield, int FIRST_ONLY) const {
	double LC = 0;        // longitudinal
	double TC = 0;        // transverse

	if (symmetry == "dipole-z") {
		TC = fabs(x[0]);
		LC = x[1];
	} else if (symmetry == "dipole-x") {
		TC = fabs(x[1]);
		LC = x[2];
	} else if (symmetry == "dipole-y") {
		TC = fabs(x[0]);
		LC = x[2];
	}

	// map indexes, bottom of the cell
	unsigned int IL = floor((LC - startMap[0]) / cellSize[0]);
	unsigned int IT = floor((TC - startMap[1]) / cellSize[1]);

	// outside map, returning no field
	if (LC < startMap[0] || TC < startMap[1]) {
		// cout << "  Field is outside limits LC: "  << LC << " TC: " << TC << " startMap0: " << startMap[0] << " startMap1: " << startMap[1] << endl;
		return;
	}

	// outside map, returning no field
	if (IL >= np[0] - 1 || IT >= np[1] - 1) {
		// cout << "  Field is outside limits IL: "  << IL << "  IT:" << IT << "  np[0] - 1: " << np[0] - 1 << " np[1] - 1: " << np[1] - 1 << endl;
		return;
	}

	// no interpolation
	if (interpolation == "none") {
		// checking if the point is closer to the top of the cell
		if (fabs(startMap[0] + IL * cellSize[0] - LC) > fabs(startMap[0] + (IL + 1) * cellSize[0] - LC)) IL++;
		if (fabs(startMap[1] + IT * cellSize[1] - TC) > fabs(startMap[1] + (IT + 1) * cellSize[1] - TC)) IT++;

		if (symmetry == "dipole-x") Bfield[0] = B1_2D[IL][IT];
		else if (symmetry == "dipole-y") Bfield[1] = B1_2D[IL][IT];
		else if (symmetry == "dipole-z") Bfield[2] = B1_2D[IL][IT];
	} else if (interpolation == "linear") {
		// relative positions within cell
		double xlr = (LC - (startMap[0] + IL * cellSize[0])) / cellSize[0];
		double xtr = (TC - (startMap[1] + IT * cellSize[1])) / cellSize[1];

		// linear interpolation
		double b10 = B1_2D[IL][IT] * (1.0 - xtr) + B1_2D[IL][IT + 1] * xtr;
		double b11 = B1_2D[IL + 1][IT] * (1.0 - xtr) + B1_2D[IL + 1][IT + 1] * xtr;
		double b1 = b10 * (1.0 - xlr) + b11 * xlr;

		if (symmetry == "dipole-x") Bfield[0] = b1;
		else if (symmetry == "dipole-y") Bfield[1] = b1;
		else if (symmetry == "dipole-z") Bfield[2] = b1;
	} else {
		cout << "  !! Unkown field interpolation method >" << interpolation << "<" << endl;
		return;
	}


	// field rotation based on ROTATE_FIELDMAP
	RotateField(Bfield);

	// we don't worry about computer speed
	// if verbosity is set this high
	// so we can output units as well
	if (verbosity > 3 && FIRST_ONLY != 99) {
		cout << "  > Track position in magnetic field map, with displacement and rotations (x,y,z)/cm: "
			 << "(" << x[0] / cm << ", "
			 << x[1] / cm << ", "
			 << x[2] / cm << ") cm,  " << endl;
		cout << "    Dipole: ";
		cout << "loc. pos. = (" << x[0] / cm << ", " << x[1] / cm << ", " << x[2] / cm << ") cm,  ";
		cout << "IT=" << IT << "   ";
		cout << "IL=" << IL << ",  ";
		cout << "B = (" << Bfield[0] / gauss << ",  " << Bfield[1] / gauss << ",  " << Bfield[2] / gauss << ") gauss "
			 << endl;

	}
}
