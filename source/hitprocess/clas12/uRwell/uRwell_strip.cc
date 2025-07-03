// gemc headers
#include "uRwell_strip.h"
#include "Randomize.hh"
#include "G4Poisson.hh"
#include <iostream>
#include <cmath>
#include <set>
#define _USE_MATH_DEFINES

vector<uRwell_strip_found> uRwell_strip::FindStrip(G4ThreeVector xyz , double Edep, uRwellConstants uRwellc, double time, bool isProto)
{
	
	vector<uRwell_strip_found> strip_found;
	vector<uRwell_strip_found> strip_found_temp;
	uRwell_strip_found ClosestStrip;
	double time_strip =0; // gauss(time_gemc + time_dz + time_redout, sigma_dt);
	
	// int N_strip = Number_of_strip(uRwellc);
	
	int N_el = 1e6*Edep/uRwellc.w_i;
	
	if (N_el ==0){
		ClosestStrip.numberID = -15000;
		ClosestStrip.weight = 1;
		ClosestStrip.time = -1;
		strip_found.push_back(ClosestStrip);
		return strip_found;
	}
	
	N_el = G4Poisson(N_el*uRwellc.gain);
	
	// strip reference frame
	
	double x_real = xyz.x()*cos(uRwellc.get_stereo_angle()) + xyz.y()*sin(uRwellc.get_stereo_angle());
	double y_real = xyz.y()*cos(uRwellc.get_stereo_angle()) - xyz.x()*sin(uRwellc.get_stereo_angle());
	double z_real = xyz.z();
	
	
	double time_dz = fabs(-uRwellc.Zhalf/cm + z_real/cm)/uRwellc.v_drift ;
	
	int ClosestStrip_ID = round((y_real)/uRwellc.get_strip_pitch());
	
	double weight=Weight_td(ClosestStrip_ID, x_real, y_real, z_real, uRwellc, isProto);
    
	double strip_length_toReadout =cal_length(strip_endpoint1, xyz);
	double time_toReadout = strip_length_toReadout/uRwellc.v_eff_readout;
	
    if(uRwellc.v_eff_readout ==0) time_toReadout=0;
	time_strip = time + time_dz + time_toReadout + G4RandGauss::shoot(0., uRwellc.sigma_time);
	
	ClosestStrip.numberID = ClosestStrip_ID;
	ClosestStrip.weight = weight;
	ClosestStrip.time = time_strip;
	strip_found_temp.push_back(ClosestStrip);
	
	//To look around closest strip
	uRwell_strip_found NextStrip;
	
	int strip_num=0;
	double weight_next=1;
	double weight_previous=1;
	int clus =1;
	
 //   cout <<"ClosestStrip_ID "<<ClosestStrip_ID<<endl;
	while(weight_next>=0. || weight_previous>=0.){
        
		//Look at the next strip
		strip_num = ClosestStrip_ID + clus;
     //   cout <<"next ID "<<strip_num<<endl;
		weight_next = Weight_td(strip_num, x_real, y_real, z_real, uRwellc, isProto);
		if(weight_next!=-1){
			NextStrip.numberID = strip_num;
			NextStrip.weight = weight_next;
			strip_length_toReadout =cal_length(strip_endpoint1, xyz);
			time_toReadout = strip_length_toReadout/uRwellc.v_eff_readout;
			if(uRwellc.v_eff_readout ==0) time_toReadout=0;
			NextStrip.time = time + time_dz + time_toReadout + G4RandGauss::shoot(0., uRwellc.sigma_time);
			strip_found_temp.push_back(NextStrip);
		}
		
		//Look at the previous strip
		strip_num = ClosestStrip_ID - clus;
    //    cout <<"previous ID "<<strip_num<<endl;
	    weight_previous = Weight_td(strip_num, x_real, y_real, z_real, uRwellc, isProto);
		if(weight_previous!=-1){
			NextStrip.numberID = strip_num;
			NextStrip.weight = weight_previous;
			strip_length_toReadout =cal_length(strip_endpoint1, xyz);
			time_toReadout = strip_length_toReadout/uRwellc.v_eff_readout;
			if(uRwellc.v_eff_readout ==0) time_toReadout=0;
			NextStrip.time = time + time_dz + time_toReadout + G4RandGauss::shoot(0., uRwellc.sigma_time);
			strip_found_temp.push_back(NextStrip);
		}
		clus++;
		
	}
	
	
	/* New strip ID numeration: 1.... Number_of_strips. Number of involved strips is the size of the vector strip_found_temp  */
    /*
	auto max = std::max_element( strip_found_temp.begin(), strip_found_temp.end(),
										 []( const uRwell_strip_found &a, const uRwell_strip_found &b )
										 {
		return a.numberID < b.numberID;
	} );
	
	auto min = std::min_element( strip_found_temp.begin(), strip_found_temp.end(),
										 []( const uRwell_strip_found &a, const uRwell_strip_found &b )
										 {
		return a.numberID < b.numberID;
	} );
	
	auto avg = round((max->numberID + min->numberID)/2);
	//	auto number_of_strip = Number_of_strip(uRwellc);
	
	for (unsigned int i=0; i<strip_found_temp.size();i++){
		cout <<"b: "<<strip_found_temp.at(i).numberID<<endl;
		strip_found_temp.at(i).numberID = strip_found_temp.at(i).numberID - avg + strip_found_temp.size()/2 ;
		cout <<"a: "<<strip_found_temp.at(i).numberID<<endl;

	}
	*/
    
    // 1. Collect all unique IDs
    std::set<int> unique_ids;
    for (const auto& strip : strip_found_temp)
        unique_ids.insert(strip.numberID);

    // 2. Build oldID → newID map
    std::map<int, int> old_to_new;
    int base = *unique_ids.begin(); // Smallest ID becomes 1
    for (int id : unique_ids) {
        old_to_new[id] = id - base + 1;
    }

    // 3. Print oldID → newID mapping
    /*
    std::cout << "Old ID → New ID mapping:\n";
    for (const auto& [oldID, newID] : old_to_new) {
        std::cout << "  " << oldID << " → " << newID << '\n';
    }
*/
    // 4. Apply new numbering
    for (auto& strip : strip_found_temp) {
        strip.numberID = old_to_new[strip.numberID];
    }
    
    
	double Nel_left=N_el;
	double renorm=0;
	double weight_this_strip;
	int Nel_this_strip=0;
	
	for (unsigned int i=0;i<strip_found_temp.size();i++){
		if (Nel_left==0||renorm==1){
			strip_found_temp.at(i).weight=0;
		}
		if (renorm!=1&&Nel_left!=0){
			weight_this_strip=strip_found_temp.at(i).weight/(1-renorm);
			Nel_this_strip=GetBinomial(Nel_left,weight_this_strip);
			renorm+=strip_found_temp.at(i).weight;
			strip_found_temp.at(i).weight=Nel_this_strip;
			Nel_left-=Nel_this_strip;
		}
	}
	
	for (unsigned int i=0;i<strip_found_temp.size();i++){
		if(strip_found_temp.at(i).weight>0) strip_found.push_back(strip_found_temp[i]);
	}
	
	if (strip_found.size() ==0){
		ClosestStrip.numberID = -15000;
		ClosestStrip.weight = 1;
		ClosestStrip.time = -1;
		strip_found.push_back(ClosestStrip);
		
	}
	

	return strip_found;
	
}


double uRwell_strip::Weight_td(int strip, double x, double y, double z, uRwellConstants uRwellc, bool isProto){
	double wght;
	if(Build_strip(strip, uRwellc)){
	 wght=( erf((strip_y+uRwellc.get_strip_width(strip, isProto)/2.-y)/uRwellc.sigma_td/sqrt(2))-erf((strip_y-uRwellc.get_strip_width(strip, isProto)/2.-y)/uRwellc.sigma_td/sqrt(2)))*
			 (erf((strip_x+strip_length/2.-x)/uRwellc.sigma_td/sqrt(2))-erf((strip_x-strip_length/2.-x)/uRwellc.sigma_td/sqrt(2)))/2./2.;
	 if (wght<0) wght=-wght;
	}else{
		wght =-1;
	}
	return wght;
}


// Check if point P lies on segment AB
bool uRwell_strip::is_on_segment(const G4ThreeVector& P, const G4ThreeVector& A, const G4ThreeVector& B) {
    double minX = std::min(A.x(), B.x()), maxX = std::max(A.x(), B.x());
    double minY = std::min(A.y(), B.y()), maxY = std::max(A.y(), B.y());
    return (P.x() >= minX - 1e-9 && P.x() <= maxX + 1e-9 &&
            P.y() >= minY - 1e-9 && P.y() <= maxY + 1e-9);
}

// Find the intersection between a line y = m*x + c and the segment AB
bool uRwell_strip::intersect_segment_with_line(const G4ThreeVector& A, const G4ThreeVector& B, double m, double c, G4ThreeVector& intersection) {
    double x1 = A.x(), y1 = A.y();
    double x2 = B.x(), y2 = B.y();

    double dx = x2 - x1;
    double dy = y2 - y1;

    // Handle vertical segment
    if (std::abs(dx) < 1e-9) {
        double x = x1;
        double y = m * x + c;
        intersection = {x, y, A.z()};
        return is_on_segment(intersection, A, B);
    }

    // Check if the line and the segment are parallel
    double denom = dy - m * dx;
    if (std::abs(denom) < 1e-9) return false;

    // Solve for parameter s along the segment
    double s = (m * x1 + c - y1) / denom;
    if (s < 0.0 || s > 1.0) return false; // intersection not within segment

    // Compute intersection point
    double x = x1 + s * dx;
    double y = y1 + s * dy;
    intersection = {x, y, A.z()};
    return true;
}






bool uRwell_strip::Build_strip(int strip, uRwellConstants uRwellc ){
	
	//strip straight line -> y = mx +c;
	double m = tan(uRwellc.get_stereo_angle());
	double c = strip*uRwellc.get_strip_pitch()/cos(uRwellc.get_stereo_angle());

   // Trapezoid coordinates
	G4ThreeVector A = {-uRwellc.Xhalf_base, -uRwellc.Yhalf, uRwellc.Zhalf};
	G4ThreeVector B =  {uRwellc.Xhalf_base, -uRwellc.Yhalf, uRwellc.Zhalf};
	G4ThreeVector C = {-uRwellc.Xhalf_Largebase, uRwellc.Yhalf, uRwellc.Zhalf};
	G4ThreeVector D =  {uRwellc.Xhalf_Largebase, uRwellc.Yhalf, uRwellc.Zhalf};
	


	// C-------------D //
	//  -------------  //
	//   -----------   //
	//    A-------B   //
	// Intersection points between strip straight line and Trapezoid straight lines
	
	G4ThreeVector AB_strip = intersectionPoint(m,c,A,B);
	G4ThreeVector BD_strip = intersectionPoint(m,c,B,D);
	G4ThreeVector CD_strip = intersectionPoint(m,c,C,D);
	G4ThreeVector AC_strip = intersectionPoint(m,c,A,C);
	
	vector< G4ThreeVector> strip_points ; // intersection point between strip and the trapezoid sides;
	
	// geometrical characteristic
	double length_strip=0;
	G4ThreeVector first_point;
	G4ThreeVector second_point;
	
    
    std::vector<G4ThreeVector> intersections;
    G4ThreeVector verts[4] = {A, B, D, C}; // side: AB, BD, DC, CA
    
    for (int i = 0; i < 4; ++i) {
        G4ThreeVector P1 = verts[i];
        G4ThreeVector P2 = verts[(i + 1) % 4];
        G4ThreeVector inter;

        if (intersect_segment_with_line(P1, P2, m, c, inter)) {
            intersections.push_back(inter);
        }
    }

    // Output
/*
    std::cout << "Found " << intersections.size() << " Inteserction Points:\n";
    for (size_t i = 0; i < intersections.size(); ++i) {
        std::cout << "Point " << i+1 << ": ("
                  << intersections[i].x() << ", "
                  << intersections[i].y() << ")\n";
    }
  */
    
    if(intersections.size()!=2) {
        return false;
    }else{
        first_point =intersections[0];
        second_point =intersections[1];
    }
    
	
	length_strip = cal_length(first_point, second_point);
	
	strip_length = length_strip;
	strip_endpoint1 = first_point;
	strip_endpoint2 = second_point;


	G4ThreeVector strip_endpoint1_stripFrame = change_of_coordinates(strip_endpoint1, uRwellc );
	G4ThreeVector strip_endpoint2_stripFrame = change_of_coordinates(strip_endpoint2, uRwellc );
	
	strip_y = strip_endpoint1_stripFrame.y();
	strip_x = (strip_endpoint1_stripFrame.x() + strip_endpoint2_stripFrame.x())/2;
	
    /*
	cout << "strip: "<<strip<<"  "<<uRwellc.get_strip_kind()<< endl;
	cout << strip_endpoint1.x()<< " "<< strip_endpoint1.y()<<" "<<endl;
	cout << strip_endpoint2.x()<< " "<< strip_endpoint2.y()<<" "<<endl;
	cout <<"done"<<endl;
*/

 
	return true;
}







G4ThreeVector uRwell_strip::change_of_coordinates( G4ThreeVector A, uRwellConstants uRwellc){
	
	G4ThreeVector XYZ;
	XYZ.setX(A.x()*cos(M_PI*uRwellc.get_stereo_angle()/180) + A.y()*sin(M_PI*uRwellc.get_stereo_angle()/180));
    XYZ.setY(A.y()*cos(M_PI*uRwellc.get_stereo_angle()/180) - A.x()*sin(M_PI*uRwellc.get_stereo_angle()/180));
	XYZ.setZ(A.z());
	
	return XYZ;
}

G4ThreeVector uRwell_strip::intersectionPoint(double m, double c, G4ThreeVector A, G4ThreeVector B){
	
	G4ThreeVector XY;
	double mT = (B.y()-A.y())/(B.x()-A.x());
	double cT = -mT*A.x()+A.y();
	
	XY.setX((cT-c)/(m-mT));
	XY.setY( m*XY.x() +c);
	XY.setZ(A.z());
	


	return XY;
	
}

bool uRwell_strip::pointOnsegment(G4ThreeVector X, G4ThreeVector A, G4ThreeVector B){
	
	
	if((X.x()>= fmin(A.x(), B.x())) && (X.x()<=fmax(A.x(), B.x()))&&(X.y()>=fmin(A.y(), B.y())) && (X.y()<=fmax(A.y(), B.y()))){
		
		return true;
	}else{
		return false;
	}
}

double uRwell_strip::cal_length(G4ThreeVector A, G4ThreeVector B){
	double length=0;
	length = sqrt(pow((A.x()-B.x()),2) + pow((A.y()-B.y()),2)) ;
	return length;
}

double uRwell_strip::GetBinomial(double n, double p){
	double answer;
	answer=CLHEP::RandBinomial::shoot(n,p);
	//Very bad method when n=0 or p close to 0 or 1... return easily -1 in these case.
	//So need to help in the limit condition
	if (answer==-1){
		answer=n;
		if (p==0) answer=0;
	}
	return answer;
}

int uRwell_strip::Number_of_strip(uRwellConstants uRwellc){
	
	int N;
	// C-------------D //
	//  -------------  //
	//   -----------   //
	//    A-------B   //
	
	/*** number of strip in AB***/
	
	int n_AB = abs(2*uRwellc.Xhalf_base/(uRwellc.get_strip_pitch()/sin(uRwellc.get_stereo_angle())));

	/** number of strip in CA **/
    
	double AC = sqrt((pow((uRwellc.Xhalf_base-uRwellc.Xhalf_Largebase),2) + pow((uRwellc.Yhalf+uRwellc.Yhalf),2)));
    double theta = acos(2*uRwellc.Yhalf/(AC));
	int n_AC = AC/(uRwellc.get_strip_pitch()/cos(theta-abs(uRwellc.get_stereo_angle())));

	N = n_AB + n_AC+1;

    return N;
}


int uRwell_strip::strip_id(int i, uRwellConstants uRwell ){
	int ID = 0;
	
	ID = Number_of_strip(uRwell)/2+i;
	
	return ID;
	
}


