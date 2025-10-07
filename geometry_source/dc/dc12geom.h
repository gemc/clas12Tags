// these numbers now come from the database
// the variable names changed:
// See geometry.parm for the original table


// rlyr = dist2tgt in region
// thopen = thopen in region
// thtilt = thtilt in region
// thster = thster in superlayers
// thmin = thmin in superlayers
// d =  wpdist in superlayer
// xe = xdist in region


// frontgap = frontgap in region
// midgap = midgap in region
// backgap = backgap in region


// to check the parameters from ccdb:
// setenv CCDB_CONNECTION mysql://clas12reader@clasdb.jlab.org/clas12
// ccdb -i
// cat /geometry/dc/region
// cat /geometry/dc/superlayer

double cwirex(int isup);
double cwirey(int isup);
double cwirez(int isup);
double wiremidx(int iwir, int ilayer, int isup);
double wiremidy(int iwir, int ilayer, int isup);
double wiremidz(int iwir, int ilayer, int isup);

double anglepoint(double x1[],double x2[],double x3[]);
int wiretowire(double x1[],double x2[],double cwire[], double *par);
int lineplaneint(double xwire[],double cwire[],double xplates[],double cplate[],double *par);
void read_param(string filename);
void read_param_ccdb();
void get_thickness (int ireg);
void calc_cosines_etc (int isup);
void calc_midpoints (int ilayer, int isup);
void calc_wire_info (int iwir, int ilayer, int isup);
void calc_g4layer_parameters(int ilayer, int isup);
void calc_g4mother_positions(int isup);
void calc_g4layer_positions(int isup);
void def_some_numbers();
void write_output_g4layers(string filename);
void write_output_g4mother(string filename);
void getWirePositions(int isup,int ilayer,double xc[],double yc[],double zc[],double xcos[],double ycos[],double zcos[]);

double pi          = 3.141592654;
double d2r         = pi/180.0; // degrees to radians
double r2d         = 1.0/d2r;  // radians to degrees
double expand      = 1.0000;   // expand mother volume


const int nlayers   = 8; //number of layers in a superlayer
const int nslayers  = 6;   // number of superlayers
const int ndim      = 3;   // number of spatial dimensions: x,y,z
const int nreg      = 3;   // number of DC regions
const int nwires    = 114; // total number of wires in each layer
const int totnlyr   = 21;  // total number of layers in a superlayer - 1 
const int avethick  = 3;   // average thickness of hexagonal layer in units of d (an essential parameter)


double rlyr[nslayers];    //distance from the target to the first guard wire plane in each superlayer
double thopen[nslayers];  //opening angle between endplate planes in each superlayer
double thtilt[nslayers];  //tilt angle (relative to z) of the six superlayers
double thster[nslayers];  //stereo angle of the wires in the six superlayers,angle of rotation about the normal to the wire plane 
double thmin[nslayers];   //polar angle to the first guard wire's "mid-point" where the wire mid-point is the intersection of the wire with the chamber mid-plane
double d[nslayers];       //distance between wire planes
double xe[nslayers];      //distance between the line of intersection of the two endplate planes and the target position
double frontgap[nreg];     //distance between the upstream gas bag and the first guard wire layer
double midgap[nreg];       //the distance between the last guard wire layer of one superlayer and the first guard wire layer of the next superlayer - for each region
double backgap[nreg];       //distance between the last guard wire layer of a region and the downstream gas bag - for each region
               
int ifirst        = 1; 
int ifirstwir[nslayers] = {1,1,1,1,1,1}; //guard wire "marked" in a superlayer, corresponding to thmin 

double r, rfront[nreg],rback[nreg],regthickness[nreg];
double layerthickness[nslayers];
double cplane[ndim],cwire[ndim];                          //direction cosines of wire plane normals and wire directions
double crhplate[ndim],clhplate[ndim];                     //dir. cosines of normals to rh and lh endplates
double xplates[ndim];
double dw,dw2,ctilt,stilt,cster,sster;
double dist1mid,x0mid,y0mid,z0mid,x1mid,y1mid,z1mid,lyrthick;
double wirelength[nwires],xmid[ndim][nwires],angmid[nwires];
double xrightwire[ndim],xleftwire[ndim],xmidwire[ndim];
double xcenter[ndim][nwires],xleft[ndim][nslayers][nlayers][nwires],xright[ndim][nslayers][nlayers][nwires];
double delx1lyr[nslayers][nlayers],delx2lyr[nslayers][nlayers],delylyr[nslayers][nlayers];
double wirespan[nslayers][nlayers],lyrangle[nslayers][nlayers];
double xlyr[ndim][nslayers][nlayers];
double xx1[nreg],xx2[nreg],xz1[nreg],xz2[nreg];
double delx1[nreg],delx2[nreg],dely[nreg],center_m[ndim][nreg]; // mother G4 volumes dim
double delxlyr[ndim][nslayers][nlayers];
