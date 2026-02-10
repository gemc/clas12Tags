//============================================================
// This script prints volumes for URWT detector
//============================================================
import org.jlab.geom.base.*
import org.jlab.clasrec.utils.*
import org.jlab.detector.geant4.v2.*
import org.jlab.detector.geant4.v2.MPGD.URWT.*
import org.jlab.detector.base.*
import org.jlab.detector.calib.utils.DatabaseConstantProvider

import GeoArgParse

def variation = GeoArgParse.getVariation(args)
def runNumber = GeoArgParse.getRunNumber(args)


URWTGeant4Factory factory = new URWTGeant4Factory(runNumber,variation)

def outFile = new File("urwt__volumes_${variation}.txt")
outFile.newWriter().withWriter { w ->
    w << factory
}
