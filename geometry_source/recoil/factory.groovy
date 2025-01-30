//============================================================
// This script prints volumes for RECOIL detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.clasrec.utils.*;
import org.jlab.detector.geant4.v2.RECOIL.*;
import org.jlab.detector.base.*;

import GeoArgParse
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);
def NRegion = GeoArgParse.getNumberOfRegion(args);

ConstantProvider cp = GeometryFactory.getConstants(DetectorType.DC,runNumber,"default");
//cp.show();

RecoilGeant4Factory factory = new RecoilGeant4Factory(cp, NRegion);

def outFile = new File("recoil__volumes_"+variation+".txt");

outFile.newWriter().withWriter { w ->
	w<<factory;
}

