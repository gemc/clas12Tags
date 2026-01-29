//============================================================
// This script prints volumes for URWT detector
//============================================================
import org.jlab.geom.base.*
import org.jlab.clasrec.utils.*
import org.jlab.detector.geant4.v2.*
import org.jlab.detector.geant4.v2.MUVT.*
import org.jlab.detector.base.*
import org.jlab.detector.calib.utils.DatabaseConstantProvider

import GeoArgParse

def variation = GeoArgParse.getVariation(args)
def runNumber = GeoArgParse.getRunNumber(args)
// Provider CCDB
DatabaseConstantProvider cp = new DatabaseConstantProvider(runNumber, variation)


MUVTConstants.connect(cp)


// Crea la factory Geant4
MUVTGeant4Factory factory = new MUVTGeant4Factory(cp,variation)

// Scrive il file volumi (minuscolo, come cerca il Perl)
def outFile = new File("muvt__volumes_${variation}.txt")
outFile.newWriter().withWriter { w ->
    w << factory
}
