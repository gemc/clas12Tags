//============================================================
// This script prints volumes for URWELL detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.clasrec.utils.*;
import org.jlab.detector.geant4.v2.URWELL.*;
import org.jlab.detector.base.*;

import GeoArgParse
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);
def NRegion = GeoArgParse.getNumberOfRegion(args);
boolean isProto = false;

if(variation == "proto") isProto = true;

ConstantProvider cp = GeometryFactory.getConstants(DetectorType.DC,runNumber,"default");
//cp.show();


URWellGeant4Factory factory = new URWellGeant4Factory(cp, isProto, NRegion);

def outFile = new File("uRwell__volumes_"+variation+".txt");
outFile.newWriter().withWriter { w ->
	w<<factory;
}

