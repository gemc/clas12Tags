//============================================================
// This script prints volumes for FTOF detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.clasrec.utils.*;
import org.jlab.detector.geant4.v2.*;
import org.jlab.detector.geant4.v2.DCGeant4Factory.MinistaggerStatus;
import org.jlab.detector.geant4.v2.DCGeant4Factory.FeedthroughsStatus;
import org.jlab.detector.base.*;

import GeoArgParse
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);

ConstantProvider cp = GeometryFactory.getConstants(DetectorType.DC,runNumber,variation);
//cp.show();

DCGeant4Factory factory = new DCGeant4Factory(cp, MinistaggerStatus.NOTONREFWIRE, FeedthroughsStatus.OFF, false, null);

def outFile = new File("dc__volumes_"+variation+".txt");
outFile.newWriter().withWriter { w ->
	w<<factory;
}

