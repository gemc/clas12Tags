
//============================================================
// This script prints volumes for SVT detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.clasrec.utils.*;
import org.jlab.detector.geant4.v2.*;
import org.jlab.detector.geant4.v2.SVT.*;
import org.jlab.detector.calib.utils.DatabaseConstantProvider;

import GeoArgParse
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);

//println "classpath dump:"
//this.class.classLoader.rootLoader.URLs.each{ println it }
//System.exit(0);

SVTConstants.VERBOSE = true;
ConstantProvider cp = new DatabaseConstantProvider(runNumber, variation);

SVTConstants.connect(cp);

SVTVolumeFactory factory = new SVTVolumeFactory( cp, false ); // ideal geometry
//SVTConstants.loadAlignmentShifts("shifts_test.dat"); // load alignment shifts from file
//factory.setApplyAlignmentShifts( true ); // shifted geometry

//factory.VERBOSE = true;
factory.BUILDSENSORS = true; // include physical sensors (aka cards)
factory.HALFBOXES = true; // geant4 wants half dimensions for boxes (but not tube radii)
factory.makeVolumes();

def outFile = new File("bst__volumes_"+variation+".txt");
outFile.newWriter().withWriter{ w -> w << factory; } // groovy does some magic to call factory.toString()

factory.putParameters();

def axisName = ["x", "y", "z"];
def parFile = new File("bst__parameters_"+variation+".txt");
def writer=parFile.newWriter();

for( Map.Entry< String, String > entry : factory.getParameters().entrySet() )
{
  String key, value, unit;

  key = entry.getKey();
  value = entry.getValue();
  unit = "na";

  def notna = true;
  
  switch( key[0] )
  {
  case "n":
  case "b":
    notna = false;
  }

  if( notna )
  {
    switch( key )
    {
    //case "sector0":
    //case "phiStart":
      //unit = factory.getProperty("unit_angle");
      //break;
    default:
      unit = factory.getProperty("unit_length");
    }
  }
  
  writer << sprintf("%s | %s | %s | %s | %s | %s\n",
        key,
        value,
        unit,
        factory.getProperty("author"),
        factory.getProperty("email"),
        factory.getProperty("date")
        );
}

writer.close();
