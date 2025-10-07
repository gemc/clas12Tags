//============================================================
// This script prints volumes for PCAL detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.clasrec.utils.*;
import org.jlab.detector.geant4.v2.*;
import org.jlab.detector.base.DetectorType;
import org.jlab.detector.base.GeometryFactory;

import GeoArgParse;
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);

ConstantProvider cp = GeometryFactory.getConstants(DetectorType.ECAL,runNumber,variation);

ECGeant4Factory factory = new ECGeant4Factory(cp);

def outFile = new File("ec__volumes_"+variation+".txt");
outFile.newWriter().withWriter { w ->
	w<<factory;
}

