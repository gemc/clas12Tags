//============================================================
// This script prints volumes for FTOF detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.clasrec.utils.*;
import org.jlab.detector.geant4.v2.*;
import org.jlab.detector.units.SystemOfUnits.Length;
import org.jlab.detector.base.DetectorType;
import org.jlab.detector.base.GeometryFactory;

import GeoArgParse
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);

// Why run #19?
//ConstantProvider cp = GeometryFactory.getConstants(DetectorType.FTOF, 19, "default");

ConstantProvider cp = GeometryFactory.getConstants(DetectorType.FTOF, runNumber, variation);

FTOFGeant4Factory factory = new FTOFGeant4Factory(cp);

def outFile = new File("ftof__volumes_"+variation+".txt");
outFile.newWriter().withWriter { w ->
	w<<factory;
}

def axisName = ["x", "y", "z"];
def parFile = new File("ftof__parameters_"+variation+".txt");
def writer=parFile.newWriter();


for(panels in factory.getMother().getChildren()) {
  if(panels.getName().contains("s1")) {
	writer<<sprintf("%s | %d | %s | %s | %s | %s | %s | %s | %s\n",
		"ftof.panel"+panels.getName().split("_")[1].substring(1)+".ncounters",	//ncounters
		panels.getChildren().findAll{it.isSensitive()}.size(),									//parameter value
		"na",														//units
		"number of counters in panel",								//description
		factory.getProperty("author"),								//author names
		factory.getProperty("email"),								//emails
		factory.getProperty("something"),							//document name
		factory.getProperty("something"),							//var name in document
		factory.getProperty("something"),							//document author
		factory.getProperty("date")									//date
	);
  }
}


//loop over panel volumes
for(panels in factory.getMother().getChildren()){
	for(int idim = 0; idim < panels.getDimensions().size(); idim++){
		writer<<sprintf("%s | %.3f | %s | %s | %s | %s | %s | %s | %s | %s\n",
			panels.getName()+".dimension"+idim,			//dimension0, 1, 2, 3 etc.
			panels.getDimensions().get(idim).value,		//parameter value
			panels.getDimensions().get(idim).unit,		//units
			"dimension " + idim,						//description of parameter (dimension)
			factory.getProperty("author"),				//author names
			factory.getProperty("email"),				//emails
			factory.getProperty("something"),			//document name
			factory.getProperty("something"),			//var name in document
			factory.getProperty("something"),			//document author
			factory.getProperty("date")					//date
		);
	}

	//loop over axes for position X, Y, Z print
	double[] pos = [panels.getLocalPosition().x, panels.getLocalPosition().y, panels.getLocalPosition().z];
	for(int iaxis=0; iaxis<3; iaxis++){
		writer<<sprintf("%s | %.3f | %s | %s | %s | %s | %s | %s | %s | %s\n",
			panels.getName()+".position"+axisName[iaxis],	//name of volume+position+axisname
			pos[iaxis],										//parameter value
			Length.unit(),									//units
			"position along " + axisName[iaxis] + " axis",	//description of parameter (position)
			factory.getProperty("author"),					//author names
			factory.getProperty("email"),					//emails
			factory.getProperty("something"),				//document name
			factory.getProperty("something"),				//var name in document
			factory.getProperty("something"),				//document author
			factory.getProperty("date")						//date
		);
	}


	//print rotation for each axis
	for(int iaxis=0; iaxis<3; iaxis++){
		axisLabel = panels.getLocalRotationOrder().charAt(iaxis);	//axis label taken from sequence

		writer<<sprintf("%s | %.3f | %s | %s | %s | %s | %s | %s | %s | %s\n",
			panels.getName()+".rotation"+axisLabel,			//name of volume+rotation+axisname
			panels.getLocalRotation()[iaxis],				//parameter value
			"rad",									 		//units
			"rotation along " + axisLabel + " axis",		//description of parameter (rotation)
			factory.getProperty("author"),					//author names
			factory.getProperty("email"),					//emails
			factory.getProperty("something"),				//document name
			factory.getProperty("something"),				//var name in document
			factory.getProperty("something"),				//document author
			factory.getProperty("date")						//date
		);
	}
}

writer.close();
