//============================================================
// This script prints volumes for RECOIL TOF detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.clasrec.utils.*;
import org.jlab.detector.geant4.v2.recoil_tof.*;
import org.jlab.detector.base.*;

import GeoArgParse
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);


ConstantProvider cp = GeometryFactory.getConstants(DetectorType.FTOF,runNumber,"default");
//cp.show();

RecoilTOFGeant4Factory factory = new RecoilTOFGeant4Factory(cp);

def outFile = new File("recoil_tof__volumes_"+variation+".txt");

outFile.newWriter().withWriter { w ->
	w<<factory;
}

