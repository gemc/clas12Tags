//============================================================
// This script prints volumes for FTOF detector
//============================================================
import org.jlab.geom.base.*;
import org.jlab.clasrec.utils.*;
import org.jlab.geom.detector.alert.AHDC.*;
import org.jlab.detector.units.SystemOfUnits.Length;
import org.jlab.detector.base.DetectorType;
import org.jlab.detector.base.GeometryFactory;
import org.jlab.detector.calib.utils.DatabaseConstantProvider;
import org.jlab.geom.prim.Point3D;

import GeoArgParse
def variation = GeoArgParse.getVariation(args);
def runNumber = GeoArgParse.getRunNumber(args);

// not really used at the moment
DatabaseConstantProvider cp = new DatabaseConstantProvider(runNumber, variation);
//provider.loadTable("/geometry/cnd/cndgeom");
//ConstantProvider cp = GeometryFactory.getConstants(DetectorType.FTOF, runNumber, variation);

AlertDCFactory factory = new AlertDCFactory();
Detector ahdc = factory.createDetectorCLAS(cp);

def parFile = new File("alert__parameters_"+variation+".txt");
def writer1=parFile.newWriter();

def outFile = new File("alert__volumes_"+variation+".txt");
def writer2=outFile.newWriter();

// dump the geometry in GEMC format
// currently includes only DC cells
// may want to add mother volumes
int nsectors = ahdc.getNumSectors();

for(int isec=1; isec<=nsectors; isec++) 
{
	int nsuperlayers = ahdc.getSector(isec).getNumSuperlayers();
	for(int isl=1; isl<=nsuperlayers; isl++) 
	{
		int nlayers = ahdc.getSector(isec).getSuperlayer(isl).getNumLayers();
		for(int ilay=1; ilay<=nlayers; ilay++) 
		{
			int ncomponents = ahdc.getSector(isec).getSuperlayer(isl).getLayer(ilay).getNumComponents();
			//if(isec==0 && isl==0 && ilay==0) writer1 << "ahdc.layer.ncomponents | " << ncomponents << "\n"; 
			if(ncomponents!=0) 
			{
				writer1 << "ahdc.superlayer"<< isl << ".layer"<< ilay <<".ncomponents | " << ncomponents << "| na | number of counters in panel | sergeyeva | sergeyeva@ipno.in2p3.fr | none | none | 05 June 2020 \n";

				for(int icomp=1; icomp<=ncomponents; icomp++) 
				{
					Component comp = ahdc.getSector(isec).getSuperlayer(isl).getLayer(ilay).getComponent(icomp);
					writer2<< gemc_ahdc_string(isl, ilay, comp);
				}
			}
		}
	} 	
}



writer1.close();
writer2.close();

// need to be updated with correct format for generic trapezoid
public String gemc_ahdc_string(int superlayer, int layer, Component comp) {
        StringBuilder str = new StringBuilder();
	/*
	for (int ip = 0; ip < comp.getNumVolumePoints(); ip++) {
	    Point3D p = comp.getVolumePoint(ip);
            str.append(String.format("%14.6f*cm | %14.6f*cm | %14.6f*cm ||", p.x(), p.y(), p.z())); 
        }
	*/
	// reading top face vertices of AHDC cell and storing their x,y coordinates
	Point3D p0 = comp.getVolumePoint(0);
	double top_x_0 = p0.x();
	double top_y_0 = p0.y();
	Point3D p1 = comp.getVolumePoint(1);
	double top_x_1 = p1.x();
	double top_y_1 = p1.y();
	Point3D p2 = comp.getVolumePoint(2);
	double top_x_2 = p2.x();
	double top_y_2 = p2.y();
	Point3D p3 = comp.getVolumePoint(3);
	double top_x_3 = p3.x();
	double top_y_3 = p3.y();
	Point3D p4 = comp.getVolumePoint(4);
	double top_x_4 = p4.x();
	double top_y_4 = p4.y();
	Point3D p5 = comp.getVolumePoint(5);
	double top_x_5 = p5.x();
	double top_y_5 = p5.y();
	// reading bottom face vertices of AHDC cell and storing their x,y coordinates
	Point3D p6 = comp.getVolumePoint(6);
	double bottom_x_6 = p6.x();
	double bottom_y_6 = p6.y();
	Point3D p7 = comp.getVolumePoint(7);
	double bottom_x_7 = p7.x();
	double bottom_y_7 = p7.y();
	Point3D p8 = comp.getVolumePoint(8);
	double bottom_x_8 = p8.x();
	double bottom_y_8 = p8.y();
	Point3D p9 = comp.getVolumePoint(9);
	double bottom_x_9 = p9.x();
	double bottom_y_9 = p9.y();
	Point3D p10 = comp.getVolumePoint(10);
	double bottom_x_10 = p10.x();
	double bottom_y_10 = p10.y();
	Point3D p11 = comp.getVolumePoint(11);
	double bottom_x_11 = p11.x();
	double bottom_y_11 = p11.y();



	// calculating the angle between wires in each superlayer, alphaW_layer
	double numWires;
	if (superlayer == 0) 
        {
            numWires = 47.0; //47
        }
        
        else if (superlayer == 1) 
        {
            numWires = 56.0; //56
        }
        else if (superlayer == 2)
        {
            numWires = 72.0; //72
        }
        else if (superlayer == 3)
        {
            numWires = 87.0;
        }
        else
        {
            numWires = 99.0;
        }
	
	double alphaW_layer = Math.toRadians(360.0/numWires);
	
	int nsubcells = 2;
	for (int isubcell=1; isubcell <= nsubcells; isubcell++)
	{
		// component name should be added as attribute of the ALERTDCWire class, mother volume should be checked
        	str.append(String.format("superlayer%d_layer%d_ahdccell%d_subcell%d | root", superlayer, layer, (comp.getComponentId()), isubcell));
		
		/*
		// Placing each sub-cell by use of the middle point of the AHDC cell signal wire
		// the center has to be re-calculated for each trapezoide sub-cell
		// use top_x, top_y, bottom_x, bottom_y coordinates
		// now it is the middle point on the signal wire of the whole AHDC cell
        	//str.append(String.format("| %8.4f*mm %8.4f*mm %8.4f*mm | ",
                //comp.getLine().midpoint().x(), comp.getLine().midpoint().y(), comp.getLine().midpoint().z()));
		double midpoint_x = comp.getLine().midpoint().x();
		double midpoint_y = comp.getLine().midpoint().y();
		double midpoint_z = comp.getLine().midpoint().z();
		*/
		
		// Just giving the origin point of coordinate system in which the trapezoides vertices are defined
		//str.append(String.format("| %8.4f*mm %8.4f*mm %8.4f*mm | ", 0.0, 0.0, 150.0));
		str.append(String.format("| %8.4f*mm %8.4f*mm %8.4f*mm | ", 0.0, 0.0, 127.7)); // in mm

		// these should be the rotation angles 	
        	double[] rotate = [0, 0, 0];
        	for (int irot = 0; irot < rotate.length; irot++)
		{
           		str.append(String.format(" %8.4f*deg ", Math.toDegrees(rotate[rotate.length - irot - 1])));
       		}

		// geant4 volume type
		String type = "G4GenericTrap"
        	str.append(String.format("| %8s |", type));
		// to add the half-length in Z axis, coatjava class dimensions are in mm!		
		str.append(String.format(" %8.4f*mm ", (comp.getLine().end().z()-comp.getLine().origin().z())/2));
		// need to be corrected according to geant4 volume definition 
		if (isubcell==1)
		{
			str.append(String.format("%14.6f*mm %14.6f*mm ", top_x_0, top_y_0));
			str.append(String.format("%14.6f*mm %14.6f*mm ", top_x_1, top_y_1));
			str.append(String.format("%14.6f*mm %14.6f*mm ", top_x_2, top_y_2));
			str.append(String.format("%14.6f*mm %14.6f*mm ", top_x_3, top_y_3));
		
			str.append(String.format("%14.6f*mm %14.6f*mm ", bottom_x_6, bottom_y_6));
			str.append(String.format("%14.6f*mm %14.6f*mm ", bottom_x_7, bottom_y_7));
			str.append(String.format("%14.6f*mm %14.6f*mm ", bottom_x_8, bottom_y_8));
			str.append(String.format("%14.6f*mm %14.6f*mm ", bottom_x_9, bottom_y_9));
		}
		else
		{
			str.append(String.format("%14.6f*mm %14.6f*mm ", top_x_3, top_y_3));
			str.append(String.format("%14.6f*mm %14.6f*mm ", top_x_4, top_y_4));
			str.append(String.format("%14.6f*mm %14.6f*mm ", top_x_5, top_y_5));
			str.append(String.format("%14.6f*mm %14.6f*mm ", top_x_0, top_y_0));
			
			str.append(String.format("%14.6f*mm %14.6f*mm ", bottom_x_9, bottom_y_9));
			str.append(String.format("%14.6f*mm %14.6f*mm ", bottom_x_10, bottom_y_10));
			str.append(String.format("%14.6f*mm %14.6f*mm ", bottom_x_11, bottom_y_11));
			str.append(String.format("%14.6f*mm %14.6f*mm ", bottom_x_6, bottom_y_6));
		}
		// currently only writing the component id but should save all necessary identifiers according to detector definition
        	str.append(" | ");
        	str.append(String.format(" %d %d %d", superlayer, layer, (comp.getComponentId())));

		str.append("\n");
	}
        
        return str.toString();
}
