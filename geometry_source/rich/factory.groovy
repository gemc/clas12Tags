//============================================================
// This script prints volumes for RICH detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.detector.geant4.v2.RICHGeant4Factory;
import java.nio.file.Files;

RICHGeant4Factory factory = new RICHGeant4Factory();

def variation = args[0];
int nmodules = (args[1]).toInteger();

def name = sprintf("rich__volumes_%s.txt", [variation]);
System.out.print("\n\n > Making volumes and copying stls, variation: ");
System.out.println(variation);

def outFile = new File(name);
outFile.newWriter().withWriter { w ->
        		w<<factory;
			}				       

def dirName = sprintf("cad_%s",[variation]);
new File(dirName).mkdir();

factory.getAllVolumes().forEach{ volume ->
	if(volume.getType()=="Stl"){
		if(volume.getName() == "RICH_s4"){
			//System.out.println("Skipping download of mother volume stl file (temporary)");
			for (int i = 0; i < nmodules; i++) {
				volume.getPrimitive().copyToStlFile(sprintf("%s/%s.stl", [dirName, "AaRICH"+"_m"+(i+1).toString()]));
			}
		}
		else{
			for (int i = 0; i < nmodules; i++) {
				volume.getPrimitive().copyToStlFile(sprintf("%s/%s.stl", [dirName, volume.getName()+"_m"+(i+1).toString()]));
			}
		}
	}
}
