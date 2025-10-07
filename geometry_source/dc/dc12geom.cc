// c++
#include <fstream>
#include <cmath>
#include <memory>
using namespace std;

#include "dc12geom.h"


// ccdb
#include <CCDB/Calibration.h>
#include <CCDB/Model/Assignment.h>
#include <CCDB/CalibrationGenerator.h>
using namespace ccdb;


// if no option is given to this program, CCDB will be used
// if "original" is given, then the parameters are read from the
// original geometry.parm file

int main(int nargv, char **argv)
{
	string conf = "ccdb";
	
	if(nargv == 2)
	{
		conf = argv[1];
	}
	
	// any other than original is ccdb
	if(conf != "original")
	{
		read_param_ccdb();
	}
	// otherwise read the essential parameters from geometry.parm file
	else
		read_param("geometry.parm");
	
	
	// use this section to create files with trapezoid parameters
	for(int ireg = 0; ireg < nreg; ireg++) get_thickness(ireg);

	//LOOP OVER SUPERLAYERS
	for(int isup = 0; isup < nslayers; isup++)
	{
		calc_cosines_etc(isup);
		//LOOP OVER LAYERS
		for(int ilayer = 0; ilayer < nlayers; ilayer++)
		{
			//LOOP OVER WIRES
			for(int iwir = 0; iwir < nwires; iwir++)
			{
				calc_wire_info(iwir,ilayer,isup);
			}
			calc_g4layer_parameters(ilayer,isup);
		}
	}
	
	def_some_numbers();
	
	for(int isup = 0; isup < nslayers; isup++)
	{
		calc_g4mother_positions(isup);
		calc_g4layer_positions(isup);
	}
	
	string layersOut = "layers-geom-" + conf + ".dat";
	string motherOut = "mother-geom-" + conf + ".dat";
	
	write_output_g4layers(layersOut.c_str());
	write_output_g4mother(motherOut.c_str());
	
	return 0;
}


// calculates the angle (in degrees) between the 3d vectors (x1-x2) and (x1-x3)
// Returns    :: angle (deg)
// Parameters :: 3d vectors: x1,x2,x3
double anglepoint(double x1[],double x2[],double x3[])
{
	double angle, cosine, x1x2norm = 0.,x1x3norm = 0.,dot =0.;
	
	// first calculate norms of vectors
	for (int i = 0; i < ndim; i++)
	{
		x1x2norm += (x1[i]-x2[i])*(x1[i]-x2[i]);
		x1x3norm += (x1[i]-x3[i])*(x1[i]-x3[i]);
	}
	x1x2norm     =   sqrt(x1x2norm);
	x1x3norm     =   sqrt(x1x3norm);
	
	// now do dot product
	for (int i = 0; i < ndim; i++) dot += (x1[i]-x2[i])*(x1[i]-x3[i]);
	
	cosine = dot/x1x2norm/x1x3norm;
	// now calculate angle in degrees
	angle  = acos(cosine)*r2d;
	angle  = angle*(x2[1]-x3[1])/abs(x2[1]-x3[1]);
	
	return angle;
}


// calculates distance between parallel wires
// Returns    :: the distance between wires (wir2wir (cm)) and the intersection on wire2 (x3)
// Parameters :: a point from each wire (x1,x2), their dir. cosine (cwire), ref.parameter (*par)
int wiretowire(double x1[], double x2[], double cwire[], double *par)
{
	double x3[ndim]; //point on wire 2 closest to x1 (pt. on wire 1)
	double wir2wir=0.,delta = 0.;
	for (int i = 0; i<ndim; i++) delta   += cwire[i]*(x1[i]-x2[i]);
	for (int i = 0; i<ndim; i++) x3[i]    = x2[i]+cwire[i]*delta;
	for (int i = 0; i<ndim; i++) wir2wir += (x3[i]-x1[i])*(x3[i]-x1[i]);
	
	*par     = sqrt(wir2wir);
	*(par+1) = x3[0];
	*(par+2) = x3[1];
	*(par+3) = x3[2];
	
	return 1;
}



//Returns    :: length from wire point to intersection (wirelen), and intersection point (xintersection)
//Parameters :: point on the wire (xwire), wire direction (cwire), point on the plate (xplates),
//Parameters (cont) ::plate normal (cplate), ref. parameter (*par)
int lineplaneint(double xwire[],double cwire[],double xplates[],double cplate[],double *par)
{
	double wirelen,xintersection[ndim];
	double num[ndim],denom[ndim]; // temp variables
											// solve 4 eqns (3 line eqs., 1 plane eq.) for 4 quantities:
											// the 3 intersection points and the line length
	for (int i = 0; i<ndim; i++)
	{
		num[i]   = cplate[i]*(xwire[i]-xplates[i]);
		denom[i] = cwire[i]*cplate[i];
	}
	
	wirelen  = -(num[0]+num[1]+num[2])/(denom[0]+denom[1]+denom[2]); //wire length from mid-point to plane
	for (int i = 0; i<ndim; i++)  xintersection[i]= xwire[i]+wirelen*cwire[i];
	
	*par     = wirelen;
	*(par+1) = xintersection[0];
	*(par+2) = xintersection[1];
	*(par+3) = xintersection[2];
	return 1;
}

void read_param(string filename)
{
	string  line;
	ifstream infile;
	int i;
	string s;
	double a1,a2,a3,a4,a5,a6,a7,b1,b2,b3;
	
	infile.open(filename.c_str());
	if (infile)
	{
		cout << " Reading core pars from file " << filename << endl;
		while (!infile.eof())
		{
			getline(infile,line);
			if(line.compare(0,1,"#")==0)
			{
				istringstream iss;
				iss.str(line);
				iss >>s>>i>>a1>>a2>>a3>>a4>>a5>>a6>>a7;
				rlyr[i-1]    = a1;
				thopen[i-1]  = a2;
				thtilt[i-1]  = a3;
				thster[i-1]  = a4;
				thmin[i-1]   = a5;
				d[i-1]       = a6;
				xe[i-1]      = a7;
			}
			
			if(line.compare(0,1,"!")==0)
			{
				istringstream iss;
				iss.str(line);
				iss >>s>>i>>b1>>b2>>b3;
				frontgap[i-1] = b1;
				midgap[i-1]   = b2;
				backgap[i-1]  = b3;
			}
		}
		infile.close();
	}
	else
		cout << " Error: File " << filename << "  cannot not opened " << endl;



	for(int i=0; i<6; i++)
		cout<< " sl: " << i
		<< " rlyr: "   << rlyr[i]
		<< " thopen: " << thopen[i]
		<< " thtilt: " << thtilt[i]
		<< " thster: " << thster[i]
		<< " thmin: "  << thmin[i]
		<< " d: "      << d[i]
		<< " xe: "     << xe[i] << endl ;
	cout << endl;

	for(int i=0; i<3; i++)
		cout<< " reg: " << i
		<< " frontgap: "   << frontgap[i]
		<< " midgap: " << midgap[i]
		<< " backgap: " << backgap[i]  << endl;
	cout << endl;


	
	
	
}

void read_param_ccdb()
{
	cout << " Reading core pars from CCDB..." << endl;
	string connection = "mysql://clas12reader@clasdb.jlab.org/clas12";
	auto_ptr<Calibration> calib(CalibrationGenerator::CreateCalibration(connection));

    
    // reading region parameters
    auto_ptr<Assignment> dcCoreRPars(calib->GetAssignment("/geometry/dc/region"));
	
	
	for(size_t rowI = 0; rowI < dcCoreRPars->GetRowsCount(); rowI++)
	{

		// dist2tgt in ccdb region
		// setting 0, 2, 4. The next SL in the same region will be setup by code
		double rlyrT = dcCoreRPars->GetValueDouble(rowI, 2);
		rlyr[rowI*2]   = rlyrT;
		rlyr[rowI*2+1] = 0;

		// thopen in ccdb region
		double thopenT     = dcCoreRPars->GetValueDouble(rowI, 6);
		thopen[rowI*2]     = thopenT;
		thopen[rowI*2 + 1] = thopenT;
		
		// thtilt in ccdb region
		double thtiltT     = dcCoreRPars->GetValueDouble(rowI, 7);
		thtilt[rowI*2]     = thtiltT;
		thtilt[rowI*2 + 1] = thtiltT;

		// xdist in ccdb region
		double xeT     = dcCoreRPars->GetValueDouble(rowI, 8);
		xe[rowI*2]     = xeT;
		xe[rowI*2 + 1] = xeT;

		// frontgap in ccdb region
		double frontgapT = dcCoreRPars->GetValueDouble(rowI, 3);
		frontgap[rowI]   = frontgapT;

		// midgap in ccdb region
		double midgapT = dcCoreRPars->GetValueDouble(rowI, 4);
		midgap[rowI]   = midgapT;

		// backgap in ccdb region
		double backgapT  = dcCoreRPars->GetValueDouble(rowI, 5);
		backgap[rowI]    = backgapT;

	}

	
	// reading superlayer parameters
	auto_ptr<Assignment> dcCoreSLPars(calib->GetAssignment("/geometry/dc/superlayer"));
	for(size_t rowI = 0; rowI < dcCoreSLPars->GetRowsCount(); rowI++)
	{
		// thster in ccdb superlayers
		double thsterT = dcCoreSLPars->GetValueDouble(rowI, 4);
		thster[rowI]   = thsterT;
		
		// thster in ccdb superlayers
		double thminT = dcCoreSLPars->GetValueDouble(rowI, 5);
		thmin[rowI]   = thminT;
		
		// wpdist in ccdb superlayers
		double dT   = dcCoreSLPars->GetValueDouble(rowI, 6);
		d[rowI] = dT;
	}

	
	for(int i=0; i<6; i++)
		cout<< " sl: " << i
		<< " rlyr: "   << rlyr[i]
		<< " thopen: " << thopen[i]
		<< " thtilt: " << thtilt[i]
		<< " thster: " << thster[i]
		<< " thmin: "  << thmin[i]
		<< " d: "      << d[i]
		<< " xe: "     << xe[i] << endl ;
	cout << endl;
	
	for(int i=0; i<3; i++)
		cout<< " reg: " << i
		<< " frontgap: "   << frontgap[i]
		<< " midgap: " << midgap[i]
		<< " backgap: " << backgap[i]  << endl;
	cout << endl;
	

}








void get_thickness(int ireg)
{
	int isup1             = 2*ireg;
	int isup2             = isup1+1;
	rlyr[isup2]           = rlyr[isup1]+totnlyr*d[isup1]+midgap[ireg];
	layerthickness[isup1] = avethick*d[isup1];
	layerthickness[isup2] = avethick*d[isup2];
	regthickness[ireg]    = frontgap[ireg]+midgap[ireg]+ backgap[ireg]+totnlyr*d[isup1]+totnlyr*d[isup2];
}


//calculate some commonly used expressions
void calc_cosines_etc(int isup)
{
	ctilt         = cos(thtilt[isup]*d2r);
	stilt         = sin(thtilt[isup]*d2r);
	cster         = cos(thster[isup]*d2r);
	sster         = sin(thster[isup]*d2r);
	dw            = d[isup]*4.*cos(30.*d2r);  //characteristic distance between sense wires
	dw2           = dw/cster;                 // distance between the wire 'mid-points' which are the intersections of the wires with the chamber mid-plane

	// calculate wire direction cosines
	cwire[0]      = cwirex(isup);
	cwire[1]      = cwirey(isup);
	cwire[2]      = cwirez(isup);

	// calculate direction cosines of wire planes
	cplane[0]     =  stilt;
	cplane[1]     =  0.;
	cplane[2]     =  ctilt;
	
	// calculate direction cosines of right-hand endplate
	crhplate[0]   = sin(thopen[isup]/2.*d2r);
	crhplate[1]   = cos(thopen[isup]/2.*d2r);
	crhplate[2]   = 0.;
	
	// calculate direction cosines of rleft-hand endplate
	clhplate[0]   = sin(thopen[isup]/2.*d2r);
	clhplate[1]   =-cos(thopen[isup]/2.*d2r);
	clhplate[2]   = 0.;
	
	// input a common point on the right-hand and left-hand endplate
	//- we have chosen a point at y,z =0; i.e. the x-distance from the
	//beamline to the intersection line of the two endplates
	xplates[0]    = xe[isup];
	xplates[1]    = 0.;
	xplates[2]    = 0.;
	
	/*     now, calculate the midpoint posn. of the first guard wire in
	 the first guard layer, using the angle, thmin, as defined for
	 the "ifirstwir" guard wire in that superlayer
	 where "mid-point" is the intersection of the first wire w/ the mid-plane
	 
	 What is the FIRST WIRE?
	 X0mid is the position of the first "marked" or "fiducial" wire;
	 the one whose "mid-point" is at a polar angle of THMIN;
	 in the first layer which is a GUARD WIRE LAYER.
	 ifirstwir(sup) is the integer marker of which wire this is
	 */
	
	r         = rlyr[isup];
	dist1mid  = r/cos((thtilt[isup]-thmin[isup])*d2r);
	x0mid     = dist1mid*sin(thmin[isup]*d2r)-(ifirstwir[isup]-1)*dw2*ctilt;
	y0mid     = 0.;
	z0mid     = dist1mid*cos(thmin[isup]*d2r)+(ifirstwir[isup]-1)*dw2*ctilt;
	// calculate the thickness of a geant4 "layer"; where a geant4 layer is 3 layer thicknesses
	lyrthick  = layerthickness[isup];
}


void calc_midpoints(int ilayer, int isup)
{
	//first, calculate the distance to the layer in question from the first layer
	r     = (ilayer)*avethick*d[isup];
	// now, calculate the midpoint posn. of the 1st wire in the layer where "mid-point" 
	// is the intersection of the first wire w/ the mid-plane
	x1mid = x0mid+stilt*r;
	y1mid = 0.;
	z1mid = z0mid+ctilt*r;
	// now, put in the "brick-wall" stagger: layer-to-layer
	// changed on 1/26/16: M. Mestayer. Fixed staggering. The first layer of sense wires (ilayer=1) 
	// is staggered outward from the beamline relative to the first guard wire (ilayer=0)
	if(ilayer==1||ilayer==3||ilayer==5||ilayer==7)
	{
		x1mid=x1mid+0.5*dw2*ctilt;
		y1mid=0.;
		z1mid=z1mid-0.5*dw2*stilt;
	}
	
}


void calc_wire_info(int iwir, int ilayer, int isup)
{
	double param[4];
	double wirelenr,wirelenl;
	
	//xmid is the wire "mid-point"
	//xmid[0][iwir] = x1mid+(iwir)*dw2*ctilt;
	//xmid[1][iwir] = 0.;
	//xmid[2][iwir] = z1mid-(iwir)*dw2*stilt;
	
	xmid[0][iwir] = wiremidx(iwir,ilayer,isup);
	xmid[1][iwir] = wiremidy(iwir,ilayer,isup);
	xmid[2][iwir] = wiremidz(iwir,ilayer,isup);
	angmid[iwir]  = atan(xmid[0][iwir]/xmid[2][iwir])*r2d;//polar angle to the wire mid-point (deg)
	
	//find the intersection of line with a plane and the distance to the plane; first load 3-vectors:
	for (int i = 0; i<ndim; i++)  xmidwire[i]=xmid[i][iwir];
	
	//call intersection finder (for right and left plates)
	lineplaneint(xmidwire,cwire,xplates,crhplate,&param[0]);
	wirelenr        = param[0];
	xrightwire[0]   = param[1];
	xrightwire[1]   = param[2];
	xrightwire[2]   = param[3];
	
	lineplaneint(xmidwire,cwire,xplates,clhplate,&param[0]);
	wirelenl       = param[0];
	xleftwire[0]   = param[1];
	xleftwire[1]   = param[2];
	xleftwire[2]   = param[3];
	
	for (int i = 0; i<ndim; i++){
		xright[i][isup][ilayer][iwir] = xrightwire[i];
		xleft[i][isup][ilayer][iwir]  = xleftwire[i];
		//x,y,z of the wire center (not it's "mid-point")
		xcenter[i][iwir] = (xleft[i][isup][ilayer][iwir]+xright[i][isup][ilayer][iwir])/2.;
	}
	//total wirelength of each wire
	wirelength[iwir]   = abs(wirelenl)+abs(wirelenr);
	
	
}

void calc_g4layer_parameters(int ilayer,int isup){
	/*
	 c calculate the parameters for each layer's trapezoid  ----
	 c One layer of sense wires lies in a trapezoidal volume
	 c The trapezoidal volume has two trapezoidal faces and
	 c four rectangular faces.  The front and back trapezoidal
	 c faces are in planes which are parallel to the sense wire
	 c plane and equidistant from it.  The distance between
	 c the trapezoidal planes is the thickness in z.
	 c "x" is in the wire direction and "y" is perpendicular
	 c to the wire direction, but in the wire plane.
	 c To summarize "z_trap" is parallel to a 25 deg. ray from
	 c the target, "x_trap" is parallel to the wires.
	 c The y_trap extent of the trapezoid goes from guard wire
	 c to guard wire; 113 wire-gaps in total (2 guard wires, 112
	 c sense wires).  The smaller "x_trap" side is the length of
	 c the short guard wire, and the larger is the length of the
	 c long guard wire.
	 */
	double param[4];
	double xpoint1[ndim],xpoint2[ndim],xpoint3[ndim],wir2wir;
	//calculate the short and long "x" lengths
	delx1lyr[isup][ilayer] = wirelength[0]/2.;
	delx2lyr[isup][ilayer] = wirelength[nwires-1]/2.;
	//calculate the "y" length of the layer trapezoid
	for (int i = 0; i<ndim; i++){
		xpoint1[i]           = xcenter[i][0];
		xpoint2[i]           = xcenter[i][nwires-1];
	}
	//plane is a test result; it should equal 0 if x,y,z in a plane
	double plane=0.;
	for (int i = 0; i<ndim; i++) plane=plane+cplane[i]*(xcenter[i][0]-xcenter[i][nwires-1]);
	
	//calculate the separation between parallel wires       ---------
	//inputs: a point from each wire, their dir. cosine
	//output: the distance between wires and the intersection on wire2
	wiretowire(xpoint1,xpoint2, cwire, &param[0]);
	wir2wir    = param[0];
	xpoint3[0] = param[1];
	xpoint3[1] = param[2];
	xpoint3[2] = param[3];
	
	wirespan[isup][ilayer]  = wir2wir;
	delylyr[isup][ilayer]   = wir2wir/2.;
	
	// calculate the angle between the perp. line (x1-x3) and the line joining the centers, (x1-x2)
	lyrangle[isup][ilayer]  = anglepoint(xpoint1,xpoint2,xpoint3);
	
	// now calculate the "middle" of the layer trapezoid
	for (int i = 0; i<ndim; i++) xlyr[i][isup][ilayer] =(xcenter[i][0]+xcenter[i][nwires-1])/2.;
 
}

void calc_g4mother_positions(int isup)
{
	for (int ireg = 0; ireg < nreg; ireg++)
	{
		dely[ireg]     = (xx2[ireg]-xx1[ireg])/cos(thtilt[isup]*d2r)/2.;
		center_m[0][ireg] =(xx1[ireg]+xx2[ireg])/2.;
		center_m[1][ireg] = 0;
		center_m[2][ireg] =(xz1[ireg]+xz2[ireg])/2.;
		
		//expand the mother volume (optional)
		delx1[ireg]       = expand*delx1[ireg];
		delx2[ireg]       = expand*delx2[ireg];
		dely[ireg]        = expand*dely[ireg];
		regthickness[ireg]= expand*regthickness[ireg];
	}
}


void def_some_numbers()
{
	delx1[0] = xleft[1][0][0][0];
	delx1[1] = xleft[1][2][0][0];
	delx1[2] = xleft[1][4][0][0];
	delx2[0] = xleft[1][1][7][nwires-1];
	delx2[1] = xleft[1][3][7][nwires-1];
	delx2[2] = xleft[1][5][7][nwires-1];
	
	xx1[0]   = xleft[0][0][0][0];
	xx1[1]   = xleft[0][2][0][0];
	xx1[2]   = xleft[0][4][0][0];
	xx2[0]   = xleft[0][1][7][nwires-1];
	xx2[1]   = xleft[0][3][7][nwires-1];
	xx2[2]   = xleft[0][5][7][nwires-1];
	
	xz1[0]   = xleft[2][0][0][0];
	xz1[1]   = xleft[2][2][0][0];
	xz1[2]   = xleft[2][4][0][0];
	xz2[0]   = xleft[2][1][7][nwires-1];
	xz2[1]   = xleft[2][3][7][nwires-1];
	xz2[2]   = xleft[2][5][7][nwires-1];
	
	
}


void calc_g4layer_positions(int isup)
{
	int ireg = -1;
	double ctilt;
	double dx,dy,dz;
	
	ctilt  = cos(thtilt[isup]*d2r);
	stilt  = sin(thtilt[isup]*d2r);
 
	if(isup==0 || isup ==1) ireg = 0;
	if(isup==2 || isup ==3) ireg = 1;
	if(isup==4 || isup ==5) ireg = 2;
	
	for (int ilayer = 0; ilayer < nlayers; ilayer++)
	{
		// calculate distance in sector coord. system
		
		dx      = xlyr[0][isup][ilayer]-center_m[0][ireg];
		dy      = xlyr[1][isup][ilayer]-center_m[1][ireg];
		dz      = xlyr[2][isup][ilayer]-center_m[2][ireg];
		
		
		// now rotate to the mother coordinate system and interchange "x" and "y"
		delxlyr[0][isup][ilayer] = dy;
		delxlyr[1][isup][ilayer] = ctilt*dx-stilt*dz;
		delxlyr[2][isup][ilayer] = ctilt*dz+stilt*dx;
	}
}


void write_output_g4layers(string filename)
{
	ofstream outfile;
	outfile.open(filename.c_str());
	if (outfile.is_open())
	{
		for (int isup = 0; isup < nslayers; isup++)
		{
			for (int ilayer = 0; ilayer < nlayers; ilayer++)
			{
				outfile<<isup+1<<"  "<<ilayer+1<<"  "<<
				delxlyr[0][isup][ilayer]<<"  "<<delxlyr[1][isup][ilayer]<<"  "<<delxlyr[2][isup][ilayer]<<"  "<<
				delx1lyr[isup][ilayer]  <<"  "<<delx2lyr[isup][ilayer]  <<"  "<<delylyr[isup][ilayer]<<"  "<<
				lyrangle[isup][ilayer]  <<"  "<<layerthickness[isup]/2  <<"  "<<thster[isup]<<endl;
			}
		}
		outfile.close();
	}
	else cout << "Unable to open file";
}


void write_output_g4mother(string filename)
{
	ofstream outfile;
	outfile.open(filename.c_str());
	if (outfile.is_open())
	{
		for (int ireg = 0; ireg < nreg; ireg++)
		{
			outfile<<ireg+1<<"  "<<delx1[ireg]<<"  "<<delx2[ireg]     <<"  "<<dely[ireg]<<"  "<<
			regthickness[ireg]/2     <<"  "<<center_m[1][ireg]<<"  "<<center_m[0][ireg]<<"  "<<center_m[2][ireg]<<endl;
		}
		outfile.close();
	}
	else cout << "Unable to open file";
}


double cwirex(int isup)
{
	//calculate wire direction cosine-x
	double cwire;
	cwire = -sin(thster[isup]*d2r)*cos(thtilt[isup]*d2r);
	return cwire;
}


double cwirey(int isup)
{
	//calculate wire direction cosine-y
	double cwire;
	cwire = cos(thster[isup]*d2r);
	return cwire;
}


double cwirez(int isup)
{
	//calculate wire direction cosine-z
	double cwire;
	cwire = sin(thster[isup]*d2r)*sin(thtilt[isup]*d2r);
	return cwire;
}


double wiremidx(int iwir, int ilayer, int isup)
{
	//wire "mid-point" in x
	double xmid;
	calc_cosines_etc(isup);
	r          = (ilayer)*avethick*d[isup];
	x1mid      = x0mid+stilt*r;
	
	//now, put in the "brick-wall" stagger: layer-to-layer
	// Changed on 1/26/16: M. Mestayer. 
	// See comment above on staggering.
	if(ilayer==1||ilayer==3||ilayer==5||ilayer==7)
	{
		x1mid=x1mid+0.5*dw2*ctilt;
	}
	
	xmid = x1mid+(iwir)*dw2*ctilt;
	return xmid;
	//cout<<x0mid<<"  "<<stilt<<"  "<<r"  "<<dw2<<"  "<<ctilt<<endl;
}


double wiremidy(int iwir, int ilayer, int isup)
{
	// wire "mid-point" in y
	return 0.;
}


double wiremidz(int iwir, int ilayer, int isup)
{
	//wire "mid-point" in z
	double zmid;
	calc_cosines_etc(isup);
	r          = (ilayer)*avethick*d[isup];
	z1mid      = z0mid+ctilt*r;
	
	// now, put in the "brick-wall" stagger: layer-to-layer
	// Changed on 1/26/16: M. Mestayer.
	// See comment above on staggering.
	if(ilayer==1||ilayer==3||ilayer==5||ilayer==7)
	{
		z1mid=z1mid-0.5*dw2*stilt;
	}
 
	zmid = z1mid-(iwir)*dw2*stilt;
	return zmid;
}


void getWirePositions(int isup,int ilayer,double xc[],double yc[],double zc[],double xcos[],double ycos[],double zcos[])
{
	for (int iwir = 0; iwir < nwires; iwir++)
	{
		//LOOP OVER WIRES
		xc[iwir]    = wiremidx(iwir,ilayer,isup);
		yc[iwir]    = wiremidy(iwir,ilayer,isup);
		zc[iwir]    = wiremidz(iwir,ilayer,isup);
		xcos[iwir]  = cwirex(isup);
		ycos[iwir]  = cwirey(isup);
		zcos[iwir]  = cwirez(isup);
	}
}






