//============================================================
// This script prints volumes for PCAL detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.detector.geant4.v2.*;
import org.jlab.detector.base.DetectorType;
import org.jlab.detector.base.GeometryFactory;

import GeoArgParse
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);

ConstantProvider cp = GeometryFactory.getConstants(DetectorType.CTOF,runNumber,variation)

CTOFGeant4Factory factory = new CTOFGeant4Factory(cp);

def outFile = new File("ctof__volumes_"+variation+".txt");
outFile.newWriter().withWriter { w ->
	w<<factory;
}

def dirName = args[args.length-1];
new File(dirName).mkdir();

factory.getComponents().forEach{ volume ->
	if(volume.getType()=="Stl"){
		volume.getPrimitive().toCSG().toStlFile(sprintf("%s/%s.stl", [dirName, volume.getName()]));
	}
}

new File(dirName+'_upstream').mkdir();

import eu.mihosoft.vrl.v3d.Vector3d;
import org.jlab.detector.units.SystemOfUnits.Length;
import org.jlab.detector.geant4.v2.CTOFGeant4Factory.CTOFpaddle
import java.io.InputStream

String caddbpath  = "/geometry/ctof/cad/"
double globalOffset = cp.getDouble("/geometry/target/position", 0)
double cadRadius  = cp.getDouble(caddbpath+"radius", 0)
double cadThick   = cp.getDouble(caddbpath+"thickness", 0)
double cadAngle   = cp.getDouble(caddbpath+"angle", 0)
double cadOffset  = cp.getDouble(caddbpath+"offset", 0)

(0..100).collect{
   InputStream strm = CTOFGeant4Factory.class.getClassLoader().getResourceAsStream(sprintf('ctof/cad/lgu%02d.stl',it))
   if(strm!=null) {
     def component = new CTOFpaddle(factory, cp, String.format("lgu%02d", it), strm, it)
     component.scale(Length.mm / Length.cm)

     component.rotate("zyx", Math.toRadians(90+cadAngle), Math.toRadians(180), 0)

     Vector3d idealCenter = new Vector3d(cadRadius+cadThick/2.0,0, 0)
     idealCenter.rotateZ(Math.toRadians(cadAngle*(it-0.5)));

     Vector3d currentCenter = component.center
     Vector3d shift = currentCenter.clone().sub(idealCenter)
     component.translate(shift.x, shift.y, shift.z+cadOffset+globalOffset)
     component.getPrimitive().toCSG().toStlFile(sprintf("%s_upstream/%s.stl", [dirName, component.getName()]))
   }
}


