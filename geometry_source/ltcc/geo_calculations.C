#include <fstream>
 // This script is to calculate the positions of the LTCC geometries in segment, sector or in detector.

 // PMTs, PMT light stoppers, shields, cylindrical mirrors were placed in the LTCC sectors. The Winston Cones were drawn in AutoCAD and imported in GEMC. They were placed directly into the detector. Corresponding positions and rotations of WCs in the detector were calculating by using their positions and rotations in the sector.

 // The difference between GEMC and AutoCAD origins was estimated.

 // To place the cones in front of PMTs, the distance vector between the center of masses of PMTs and WCs (in case pmts are in front of WCs) was rotated by the given rotations of pmts then the rotated distance vector components were subtracted from the components of pmt positions.

 // The same method were repeated to find the positions of cylindrical mirrors that should be in front of the cones by using the distance vector between the center of masses of cyl mirrors and WCs.

 // The sector's frame is the rotated segment's frame around x.

 // The detector's frame is the rotated sector's frame around z and also there is a translation in z direction.

 void geo_calculations() {

 ofstream geo_calculations;
 geo_calculations.open ("geo_calculations.tsv");

 geo_calculations<<"pmtX"<<"\t"<<"pmtY"<<"\t"<<"pmtZ"<<"\t"<<"WC_R_X"<<"\t"<<"WC_R_Y"<<"\t"<<"WC_R_Z" <<"\t"<<"WC_L_X"<<"\t"<<"WC_L_Y"<<"\t"<<"WC_L_Z"<<"\t"<<"shield_R_X"<<"\t"<<"shield_R_Y"<<"\t"<<"shield_R_Z" <<"\t"<<"shield_L_X"<<"\t"<<"shield_L_Y"<<"\t"<<"shield_L_Z"<<"\t"<<"mirror_R_X"<<"\t"<<"mirror_R_Y"<<"\t"<<"mirror_R_Z" <<"\t"<<"mirror_L_X"<<"\t"<<"mirror_L_Y"<<"\t"<<"mirror_L_Z"<<endl;

 const Int_t i = 18;

 //All angles are in degrees, they will be converted to radian in trigonometric calculations

 Double_t xp[i] = {17.36, 25.42, 33.54, 41.61, 49.6, 57.51, 65.34, 72.76, 80.32, 87.93, 95.28, 103.2, 113.55, 122.17, 130.72, 139.1, 147.66, 155.46};

 Double_t yp[i] = {461.71, 458.69, 456.66, 454.56, 452.46, 450.29, 447.55, 445.13, 444.06, 442.32, 442.97, 441.12, 446.19, 443.75, 441.72, 440.17, 438.5, 436.86};

 Double_t phi[i] = {7.72, 9.44, 11.17, 12.93, 14.69, 16.47, 18.29, 20.15, 22.03, 24, 26.04, 28.18, 30.48, 32.94, 35.44, 37.97, 40.51, 43.11};

 Double_t psi[i] = {30.8, 30.37, 30.08, 29.77, 29.43, 29.08, 28.69, 28.34, 27.96, 27.52, 27.19, 26.63, 25.99, 25.26, 24.47, 23.63, 22.68, 21.74};

 Double_t th[i] = {-30.8, -30.37, -30.08, -29.77, -29.43, -29.08, -28.69, -28.34, -27.96, -27.52, -27.19, -26.63, -24, -24, -27.26, -26.26, -26.68, -26.74};

 Double_t x0[i] = {17.36, 25.42, 33.54, 41.61, 49.6, 57.51, 65.34, 72.76, 80.32, 87.93, 95.28, 103.2, 113.55, 122.17, 130.72, 139.1, 147.66, 155.46};

 Double_t y0[i] = {461.71, 458.69, 456.66, 454.56, 452.46, 450.29, 447.55, 445.13, 444.06, 442.32, 442.97, 441.12, 446.19, 443.75, 441.72, 440.17, 438.5, 436.86};

 Double_t segTh[i] = {82.28, 80.56, 78.83, 77.07, 75.31, 73.53, 71.71, 69.85, 67.97, 66, 63.96, 61.82, 59.52, 57.06, 54.56, 52.03, 49.49, 46.89};

 // the amount that shields were shifted by to avoid the overlaps

 Double_t l_sh[i] = {8.59, 8.59, 8.59, 8.59, 8.59, 8.59, 8.59, 8.59, 8.59, 8.59, 8, 8, 10.94, 10.94, 10.94, 10.94, 10.94, 10.94};

 // the distance between WC and cylindrical mirror center of masses

 Double_t l_wm[i] = {21.4, 21.4, 21.4, 21.4, 21.4, 21.4, 21.4, 21.4,  21.4, 21.4, 21.4, 25.50, 25.50, 29.9, 29.9, 29.9, 29.9, 29.9};

 Double_t cyl_tilt_r[i] = {-85, -85, -85, -85, -85, -85, -85, -85, -85, -85, -85, -85, -85, -100,  -100,  -100,  -100,  -100};

 Double_t phi_R;

 Double_t psi_R;

 Double_t th_R;

 Double_t phi_L;

 Double_t psi_L;

 Double_t th_L;

 Double_t eqlR1;

 Double_t eqlR2;

 Double_t eqlR3;

 Double_t eqlL1;

 Double_t eqlL2;

 Double_t eqlL3;

 Double_t d2r = TMath::Pi()/180.0;

 Double_t l = 10.295; // the distance between pmt and WC center of masses

 Double_t lCyl = 12.295;

 TVector3 orDif_R;
 TVector3 orDif_L;
	
        for(Int_t s=1; s<=6; s++)	
	{
		for(Int_t n=1; n<=i; n++)

		{  

			//Calculation of rotation angles of WCs in detector			

 			Double_t rotphi = 90.0 - (s-1.0)*60.0; // in degrees

 			eqlR1 =(TMath::Cos(rotphi*d2r) * TMath::Cos(th[n-1]*d2r) * TMath::Sin(psi[n-1]*d2r) + TMath::Sin(rotphi*d2r) *     (TMath::Cos(psi[n-1]*d2r) * TMath::Cos(phi[n-1]*d2r) + TMath::Sin(phi[n-1]*d2r) * TMath::Sin(th[n-1]*d2r) * TMath::Sin(psi[n-1]*d2r))) / (TMath::Cos(rotphi*d2r) * TMath::Cos(psi[n-1]*d2r) * TMath::Cos(th[n-1]*d2r) + TMath::Sin(rotphi*d2r) * (TMath::Sin(-psi[n-1]*d2r) * TMath::Cos(phi[n-1]*d2r) + TMath::Sin(phi[n-1]*d2r) * TMath::Sin(th[n-1]*d2r) * TMath::Cos(psi[n-1]*d2r))) ;

 			psi_R = TMath::Pi() + (TMath::ATan(eqlR1));  // in radian

			eqlR2 =  (TMath::Sin(rotphi*d2r) * TMath::Sin(th[n-1]*d2r) + TMath::Cos(rotphi*d2r) * TMath::Sin(phi[n-1]*d2r) * TMath::Cos(th[n-1]*d2r)) / (TMath::Cos(phi[n-1]*d2r) * TMath::Cos(th[n-1]*d2r));

 			phi_R = (TMath::ATan(eqlR2)); // in radian

 			eqlR3 = TMath::Cos(rotphi*d2r) * TMath::Sin(th[n-1]*d2r) - TMath::Sin(rotphi*d2r) * TMath::Cos(th[n-1]*d2r) * TMath::Sin(phi[n-1]*d2r);
 			th_R = (TMath::ASin(eqlR3)); // in radian

			eqlL1 =(TMath::Cos(rotphi*d2r) * TMath::Cos(-th[n-1]*d2r) * TMath::Sin(-psi[n-1]*d2r) + TMath::Sin(rotphi*d2r) *     (TMath::Cos(-psi[n-1]*d2r) * TMath::Cos(phi[n-1]*d2r) + TMath::Sin(phi[n-1]*d2r) * TMath::Sin(-th[n-1]*d2r) * TMath::Sin(-psi[n-1]*d2r))) / (TMath::Cos(rotphi*d2r) * TMath::Cos(-psi[n-1]*d2r) * TMath::Cos(-th[n-1]*d2r) + TMath::Sin(rotphi*d2r) * (TMath::Sin(psi[n-1]*d2r) * TMath::Cos(phi[n-1]*d2r) + TMath::Sin(phi[n-1]*d2r) * TMath::Sin(-th[n-1]*d2r) * TMath::Cos(-psi[n-1]*d2r))) ;

 			psi_L =(TMath::ATan(eqlL1));  // in radian

			eqlL2 =  (TMath::Sin(rotphi*d2r) * TMath::Sin(-th[n-1]*d2r) + TMath::Cos(rotphi*d2r) * TMath::Sin(phi[n-1]*d2r) * TMath::Cos(-th[n-1]*d2r)) / (TMath::Cos(phi[n-1]*d2r) * TMath::Cos(-th[n-1]*d2r));

 			phi_L = (TMath::ATan(eqlL2)); // in radian

 			eqlL3 = TMath::Cos(rotphi*d2r) * TMath::Sin(-th[n-1]*d2r) - TMath::Sin(rotphi*d2r) * TMath::Cos(-th[n-1]*d2r) * TMath::Sin(phi[n-1]*d2r);
 			th_L= (TMath::ASin(eqlL3)); // in radian
     
			   
			
			
			//Calculation of position of WCs in detector

			TVector3 d_pwR(0, 0, l); //the distance between pmt and WC center of masses
			d_pwR.RotateZ(-psi[n-1]*d2r);
                        d_pwR.RotateY(-th[n-1]*d2r); // apply (90*deg, -th*deg, 0*deg) rotation xyz order (z first, x last)
			d_pwR.RotateX(-TMath::Pi()/2);

			TVector3 d_pwL(0, 0, l); //the distance between pmt and WC center of masses
			d_pwL.RotateZ(psi[n-1]*d2r);
                        d_pwL.RotateY(th[n-1]*d2r); // apply (90*deg, -th*deg, 0*deg) rotation xyz order (z first, x last)
			d_pwL.RotateX(-TMath::Pi()/2);

			TVector3 d_rr(d_pwR.X(), d_pwR.Y(), d_pwR.Z()); //rotated distance l

			TVector3 d_rl(d_pwL.X(), d_pwL.Y(), d_pwL.Z());

			TVector3 rp(xp[n-1], yp[n-1], 0); // the position of pmts in the segment
			rp.RotateX(segTh[n-1]*d2r);
			TVector3 pmt_sec(rp.X(), rp.Y(), rp.Z());
			

			TVector3 rf_r(x0[n-1]-d_rr.X(), y0[n-1]-d_rr.Y(), 0-d_rr.Z()); // the position of WC in the segment

			TVector3 rf_l(-x0[n-1]-d_rl.X(), y0[n-1]-d_rl.Y(), 0-d_rl.Z());

			//Winston Cones have been drawn in AutoCAD and imported to GEMC. CAD imported files use detector's frame (origin, 				rotation etc.) so the position of WC needs to be calculated in detector's frame. This can be done by rotating the position vector of WC in segment first around X and Z by segTh*deg, -rotphi*deg respectively. 170 cm translation in z direction will be added at the final step
			rf_r.RotateX(segTh[n-1]*d2r);
			rf_l.RotateX(segTh[n-1]*d2r);

			TVector3 WC_pos_secR(rf_r.X(), rf_r.Y(), rf_r.Z()); //the position of WC in sector
			TVector3 WC_pos_secL(rf_l.X(), rf_l.Y(), rf_l.Z()); //the position of WC in sector


			rf_r.RotateZ(-rotphi*d2r);
			rf_l.RotateZ(-rotphi*d2r);

			TVector3 WC_pos_detR(rf_r.X(), rf_r.Y(), rf_r.Z()); //the position of WC in detector
			TVector3 WC_pos_detL(rf_l.X(), rf_l.Y(), rf_l.Z()); //the position of WC in detector
			
			// Since CAD and GEMC have different origins, the difference between the origins estimated and after rotating the distance by calculated angles phi_n, th_n and psi_n rotated distance was added to the position of WC in detector. The result gives us the position of CAD imported WC.

			

			if(n < 11) {

			orDif_R.SetXYZ(-6.3, -6.3, -8.5);
			orDif_L.SetXYZ(-6.3, -6.3, -8.5);

  			}

			if(n == 11 && n == 12) {

			orDif_R.SetXYZ(-6.7, -6.7, -13.0);
			orDif_L.SetXYZ(-6.7, -6.7, -13.0);

			}

			else {

			orDif_R.SetXYZ(-7.7, -7.7, -17.0);
			orDif_L.SetXYZ(-7.7, -7.7, -17.0);

			}

                        orDif_R.RotateZ(-psi_L);
			orDif_R.RotateY(-th_L);
			orDif_R.RotateX(-phi_L);
                        
			Double_t xf_r = WC_pos_detR.X() + orDif_R.X();
			Double_t yf_r = WC_pos_detR.Y() + orDif_R.Y();
			Double_t zf_r = WC_pos_detR.Z() + orDif_R.Z() + 170 ;

			Double_t xf_l = WC_pos_detL.X() + orDif_L.X();
			Double_t yf_l = WC_pos_detL.Y() + orDif_L.Y();
			Double_t zf_l = WC_pos_detL.Z() + orDif_L.Z() + 170 ;

			

			

			// Calculation of position of shields in sector

                        TVector3 d_sh_R(0, 0, l_sh[n-1]); //the distance between pmt and WC center of masses
			d_sh_R.RotateZ(0);
                        d_sh_R.RotateY(-th[n-1]*d2r); // rotation xyz order (z first, x last)
			d_sh_R.RotateX(-TMath::Pi()/2);

			TVector3 d_sh_L(0, 0, l_sh[n-1]); //the distance between pmt and WC center of masses
			d_sh_L.RotateZ(0);
                        d_sh_L.RotateY(th[n-1]*d2r); // rotation xyz order (z first, x last)
			d_sh_L.RotateX(-TMath::Pi()/2);

			TVector3 shiftR(d_sh_R.X(), d_sh_R.Y(), d_sh_R.Z()); //rotated distance 

			TVector3 shiftL(d_sh_L.X(), d_sh_L.Y(), d_sh_L.Z());

			TVector3 sh_segR(x0[n-1]-shiftR.X(), y0[n-1]-shiftR.Y(), 0-shiftR.Z()); // the position of shields in the segment

			TVector3 sh_segL(-x0[n-1]-shiftL.X(), y0[n-1]-shiftL.Y(), 0-shiftL.Z());

			
			sh_segR.RotateX(segTh[n-1]*d2r);
			sh_segL.RotateX(segTh[n-1]*d2r);

			TVector3 sh_pos_secR(sh_segR.X(), sh_segR.Y(), sh_segR.Z()); //the position of shields in sector
			TVector3 sh_pos_secL(sh_segL.X(), sh_segL.Y(), sh_segL.Z()); //the position of shields in sector
			

			// Calculation of position of cylindrical mirrors in sector

			TVector3 d_wm_R(0, 0, l_wm[n-1]); //the distance between WC and cyl mirror center of masses
			d_wm_R.RotateZ(0*d2r);
                        d_wm_R.RotateY(th[n-1]*d2r); // apply (90*deg, -th*deg, 0*deg) rotation xyz order (z first, x last)
			d_wm_R.RotateX(-TMath::Pi()/2);

			TVector3 d_wm_L(0, 0, l_wm[n-1]); //the distance between WC and cyl mirror center of masses
			d_wm_L.RotateZ(0*d2r);
                        d_wm_L.RotateY(-th[n-1]*d2r); // apply (90*deg, -th*deg, 0*deg) rotation xyz order (z first, x last)
			d_wm_L.RotateX(-TMath::Pi()/2);

			TVector3 mirR(d_wm_R.X(), d_wm_R.Y(), d_wm_R.Z()); //rotated distance 

			TVector3 mirL(d_wm_L.X(), d_wm_L.Y(), d_wm_L.Z());

			TVector3 mir_segR(x0[n-1]-mirR.X(), y0[n-1]-mirR.Y(),0-mirR.Z()); // the position of cyl mirrors in the segment

			TVector3 mir_segL(-x0[n-1]-mirL.X(), y0[n-1]-mirL.Y(), 0-mirL.Z());

			
			
			mir_segR.RotateX(segTh[n-1]*d2r);
			mir_segL.RotateX(segTh[n-1]*d2r);

			TVector3 mir_pos_secR(mir_segR.X(), mir_segR.Y(), mir_segR.Z()); //the position of shields in sector
			TVector3 mir_pos_secL(mir_segL.X(), mir_segL.Y(), mir_segL.Z()); //the position of shields in sector

			geo_calculations<<pmt_sec.X()<<"\t"<<pmt_sec.Y()<<"\t"<<pmt_sec.Z()<<"\t"<<WC_pos_detR.X()<<"\t"<<WC_pos_detR.Y()<<"\t"<<WC_pos_detR.Z()<<"\t"<<WC_pos_detL.X()<<"\t"<<WC_pos_detL.Y()<<"\t"<<WC_pos_detL.Z()<<"\t"<<sh_pos_secR.X()<<"\t"<<sh_pos_secR.Y()<<"\t"<<sh_pos_secR.Z()<<"\t"<<sh_pos_secL.X()<<"\t"<<sh_pos_secL.Y()<<"\t"<<sh_pos_secR.Z()<<"\t"<<mir_pos_secR.X()<<"\t"<<  mir_pos_secR.Y()<<"\t"<<  mir_pos_secR.Z()<<"\t"<<mir_pos_secL.X()<<"\t"<<  mir_pos_secL.Y()<<"\t"<<  mir_pos_secL.Z()<<endl;

			

                 }

        }

 }
