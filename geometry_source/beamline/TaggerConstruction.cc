

TaggerConstruction::TaggerConstruction(G4LogicalVolume* mother) 
{
 //Using:
 //OPTION 3:    Helium bag. Upstream vacuum box window.
  
  CLAS_Materials Materials; 
 
  float OPTION           = 0;
  float tag_mag_field_strength;
  int imperv_pole =0;
  int vac_shield_tag=0;
  double vac_shield_tag_thick=0.0;
  double lead_thick=0.0;
  
  G4Material *poleface_material = Materials.Iro;
  string poleface_mat_string;
  
  string what;
  ifstream iopt("options.inp");
  while(!iopt.eof())
 {
  iopt >> what;
  if(what == "OPTION")                    iopt >>  OPTION ;
  if(what == "TAGGER_MAGFIELD")           iopt >>  tag_mag_field_strength;
  if(what == "POLEFACE_MATERIAL")         iopt >> poleface_mat_string;
  if(what == "IMPERV_POLE")               iopt >> imperv_pole;
  if(what == "VAC_SHIELD_TAG")            iopt >> vac_shield_tag;
  if(what == "VAC_SHIELD_TAG_THICK")      iopt >> vac_shield_tag_thick;
  if(what == "LEAD_THICK")                iopt >> lead_thick;
 }

 iopt.close();

 cout << endl << " Configuration chosen: " << OPTION << endl ;
 cout <<         " Magnetig field: "       <<  tag_mag_field_strength << " Tesla" << endl ;
 // %%%%%%%%%%%%%%%%%
 // Rotation matrixes
 // %%%%%%%%%%%%%%%%%

 G4RotationMatrix *xRot30deg = new G4RotationMatrix();
 xRot30deg->rotateX(-30.5*deg);

 G4RotationMatrix *yRot90deg = new G4RotationMatrix();
 yRot90deg->rotateY(90*deg); 

 G4RotationMatrix *xRot26deg = new G4RotationMatrix();
 xRot26deg->rotateX(-26*deg);

 G4RotationMatrix *zRot21deg = new G4RotationMatrix();
 zRot21deg->rotateZ(21*deg);

  G4RotationMatrix *xRot20deg = new G4RotationMatrix();
 xRot20deg->rotateX(-20*deg);

 G4RotationMatrix *xRot9deg = new G4RotationMatrix();
 xRot9deg->rotateX(9.6*deg);

 G4RotationMatrix *yRot90deg2 = new G4RotationMatrix();
 yRot90deg2->rotateX(30.5*deg); 
 yRot90deg2->rotateY(90*deg); 
 


 if(poleface_mat_string == "Iro"){
   poleface_material = Materials.Iro;
 }



 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 // uniform magnetic field along X axis 
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 G4double fieldValue = tag_mag_field_strength*tesla;

 G4UniformMagField*        myField = new G4UniformMagField(G4ThreeVector(fieldValue, 0., 0.));
 G4Mag_UsualEqRhs*      myEquation = new G4Mag_UsualEqRhs(myField);        
 G4MagIntegratorStepper* myStepper = new G4ClassicalRK4(myEquation);
 G4ChordFinder*      myChordFinder = new G4ChordFinder(myField, 0.01*mm, myStepper); 
 G4FieldManager*          fieldMgr = new G4FieldManager(myField, myChordFinder); 









 // %%%%%%%%%%%%%%%%%%%%
 // Curved Tagger Magnet 
 // %%%%%%%%%%%%%%%%%%%%

 G4Tubs* tag_mag_tube_iron1 = new G4Tubs("tag_mag_tube_iron1",  600.*cm, 730.*cm, 45.*cm,  50.*deg, 37.*deg);
 
 G4Box* tag_mag_box1        =  new G4Box("tag_mag_box1",  222.*cm, 47.*cm,  50.*cm); 
 G4ThreeVector tag_mag_box1_pos(220*cm,  560.*cm,  0.*cm);

 G4Tubs* tag_mag_vac_tube   = new G4Tubs("tag_mag_vac_tube",    600.*cm, 735.*cm, 1.2*2.54*cm,  45.*deg, 50.*deg);
 G4ThreeVector tag_mag_vac_tube_pos(0*cm,  -30.*cm,  0.*cm);
 
 G4Box* tag_mag_box3        =  new G4Box("tag_mag_box3",  228.*cm, 7.*cm,  5.*cm); 
 G4ThreeVector tag_mag_box3_pos(240*cm,  695.*cm,  0.*cm);

 G4SubtractionSolid *tag_mag_iron1 = new G4SubtractionSolid("tag_mag_iron1", tag_mag_tube_iron1, tag_mag_box1, zRot21deg, tag_mag_box1_pos);
 G4SubtractionSolid *tag_mag_iron2 = new G4SubtractionSolid("tag_mag_iron2", tag_mag_iron1,      tag_mag_vac_tube,     0, tag_mag_vac_tube_pos);

 G4SubtractionSolid *tag_mag_iron3 = new G4SubtractionSolid("tag_mag_iron3", tag_mag_iron2,      tag_mag_box3,         0, tag_mag_box3_pos);

 G4ThreeVector tag_magnet_pos(0.*cm, -695.*cm, 0.*cm);
 G4LogicalVolume *tag_mag_log = new G4LogicalVolume(tag_mag_iron3, Materials.Iro, "tag_mag_log", 0, 0, 0);

 G4VisAttributes *tag_mag_att = new G4VisAttributes(G4Colour(19./255., 19./255., 237./255.));
 tag_mag_att->SetForceSolid(true);
 tag_mag_att->SetVisibility(true);
 tag_mag_log->SetVisAttributes(tag_mag_att); 
  
 CLAS_Detector tagger_magnet;              
 tagger_magnet.logVol = tag_mag_log;
 tagger_magnet.pos    = tag_magnet_pos;
 tagger_magnet.rot    = yRot90deg;
 tagger_magnet.LOG    = false;
 tagger_magnet.exist  = true;    
 Tagger.Detectors.push_back(tagger_magnet);

 


 // %%%%%%%%%%%%%%%%%%%%%
 // Tagger Magnetic field
 // %%%%%%%%%%%%%%%%%%%%%
 
 
 G4Tubs* tag_mag_field = new G4Tubs("tag_mag_field",  694.*cm, 740.*cm, 1.18*2.54*cm,  62*deg, 30*deg); 
 G4ThreeVector tag_mag_field_pos(0.*cm, -730.*cm, -20.*cm);

 //adding thin sheets of impervium on the pole faces
 G4Tubs* imperv_tub = new G4Tubs("imperv_tub",  689.*cm, 735.*cm, 0.01*2.54*cm,  50.*deg, 37.*deg);
 G4ThreeVector imperv_tub_right_pos((-1.2+0.01)*2.54*cm, -725.*cm, -20.*cm);
 G4ThreeVector imperv_tub_left_pos((1.2-0.01)*2.54*cm, -725.*cm, -20.*cm);

 G4LogicalVolume *imperv_tub_right_log = new G4LogicalVolume(imperv_tub, poleface_material, "imperv_tub_right_log", 0, 0, 0);
 G4VisAttributes *imperv_tub_right_att = new G4VisAttributes(G4Colour(255./255., 0./255., 0./255.));
 imperv_tub_right_att->SetForceSolid(true);
 imperv_tub_right_att->SetVisibility(true);
 imperv_tub_right_log->SetVisAttributes(imperv_tub_right_att);

 CLAS_Detector imperv_tub_right;   
 imperv_tub_right.logVol = imperv_tub_right_log;
 imperv_tub_right.pos    = imperv_tub_right_pos ;
 imperv_tub_right.rot    = yRot90deg;
 imperv_tub_right.LOG    = false; 
 imperv_tub_right.exist  = true; 
 //Tagger.Detectors.push_back(imperv_tub_right); 

 G4LogicalVolume *imperv_tub_left_log = new G4LogicalVolume(imperv_tub, poleface_material, "imperv_tub_left_log", 0, 0, 0);
 G4VisAttributes *imperv_tub_left_att = new G4VisAttributes(G4Colour(255./255., 0./255., 0./255.));
 imperv_tub_left_att->SetForceSolid(true);
 imperv_tub_left_att->SetVisibility(true);
 imperv_tub_left_log->SetVisAttributes(imperv_tub_left_att);

 CLAS_Detector imperv_tub_left;   
 imperv_tub_left.logVol = imperv_tub_left_log;
 imperv_tub_left.pos    = imperv_tub_left_pos ;
 imperv_tub_left.rot    = yRot90deg;
 imperv_tub_left.LOG    = false; 
 imperv_tub_left.exist  = true; 
 //Tagger.Detectors.push_back(imperv_tub_left);
 //ends here

 G4LogicalVolume *field_log = new G4LogicalVolume(tag_mag_field, Materials.Vacuum, "field_log", fieldMgr, 0, 0);
 G4VisAttributes *field_att = new G4VisAttributes(G4Colour(200./255., 19./255., 237./255.));
 field_att->SetForceSolid(true);
 field_att->SetVisibility(true);
 field_log->SetVisAttributes(field_att);

 CLAS_Detector tag_field;   
 tag_field.logVol = field_log;
 tag_field.pos    = tag_mag_field_pos ;
 tag_field.rot    = yRot90deg;
 tag_field.LOG    = false; 
 tag_field.exist  = true;
 
 if(imperv_pole ==1){
   Tagger.Detectors.push_back(imperv_tub_right);
   Tagger.Detectors.push_back(imperv_tub_left);
 }

 Tagger.Detectors.push_back(tag_field);              



 








 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 // Tagger Aluminum Box 1. Big hodoscope 
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 G4Box* tagger_alu_box     =  new G4Box("tagger_alu_box",      60.*cm,  38.*cm,  (265.0+53.34-7.62)*cm);   
 G4Box* tagger_alu_vac_box =  new G4Box("tagger_alu_vac_box",   15.0*cm,  38.*cm,  (265.5+53.34-7.62)*cm); 

 G4Box* alu_plate_sub  = new G4Box("alu_plate",  74.0*2.54*cm, 1.9*2.54*cm,  5.2*2.54*cm);   

 G4ThreeVector tagger_alu_vac_pos(0.*cm,   0.5*cm,   0*cm);
 G4ThreeVector alu_plate_sub_pos( 0.*cm,  34.5*cm, (244.8+45.72)*cm);


 G4SubtractionSolid *tagger_alu_vacbox1 = new G4SubtractionSolid("tagger_alu_vacbox1", tagger_alu_box,     tagger_alu_vac_box, 0, tagger_alu_vac_pos);
 G4SubtractionSolid *tagger_alu_vacbox  = new G4SubtractionSolid("tagger_alu_vacbox",  tagger_alu_vacbox1,      alu_plate_sub, 0, alu_plate_sub_pos);

 G4LogicalVolume *tagger_alu_log = new G4LogicalVolume(tagger_alu_vacbox, Materials.Alu, "tagger_alu_log", 0, 0, 0);
 G4VisAttributes *tagger_alu_att = new G4VisAttributes(G4Colour(196./255., 226./255., 232./255.));
 tagger_alu_att->SetForceSolid(true);
 tagger_alu_att->SetVisibility(true);
 tagger_alu_log->SetVisAttributes(tagger_alu_att);

 G4ThreeVector tagger_alu_pos(    0.*cm, (-280-26.67+1.5)*cm, (470.+46.2-2.6)*cm);  

 CLAS_Detector tag_alum_box;               
 tag_alum_box.logVol = tagger_alu_log;
 tag_alum_box.pos    = tagger_alu_pos;
 tag_alum_box.rot    = xRot30deg;
 tag_alum_box.LOG    = false;
 tag_alum_box.exist  = true;
 Tagger.Detectors.push_back(tag_alum_box);






 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 // A aluminum plate at 3/4' thick 5' wide the end of the hodoscope
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 G4Box* alu_plate  = new G4Box("alu_plate",  24.0*2.54*cm, 0.75*2.54*cm,  5.0*2.54*cm);   
 G4ThreeVector alu_plate_pos(0.*m, (-377.0-47.62-0.87)*cm, (697.0+84.1-0.5)*cm);  

 G4LogicalVolume  *alu_plate_log = new G4LogicalVolume(alu_plate, Materials.Alu, "alu_plate_log", 0, 0, 0);
 G4VisAttributes *alu_plate_att = new  G4VisAttributes(G4Colour(120./255., 220./255., 120./255.));
 alu_plate_att->SetForceSolid(true);
 alu_plate_att->SetVisibility(true);
 alu_plate_log->SetVisAttributes(alu_plate_att); 

 CLAS_Detector alum_plate;
 alum_plate.logVol = alu_plate_log;
 alum_plate.pos    = alu_plate_pos;
 alum_plate.rot    = xRot30deg;
 alum_plate.LOG    = false;
 alum_plate.exist  = true;
 Tagger.Detectors.push_back(alum_plate);





 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 // A steel plate at 1/2' thick 5' wide the end of the hodoscope on top of the aluminum plate
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 G4Box* steel_plateb  = new G4Box("steel_plateb",  24.0*2.54*cm, 0.5*2.54*cm,  5.0*2.54*cm);   
 G4ThreeVector steel_plateb_pos(0.*m, (-374.0-47.62-0.87)*cm, (698.5+84.1-0.5)*cm);

 G4LogicalVolume  *steel_plateb_log = new G4LogicalVolume(steel_plateb, Materials.Steel, "steel_plateb_log", 0, 0, 0);
 G4VisAttributes *steel_plateb_att = new  G4VisAttributes(G4Colour(120./255., 220./255., 225./255.));
 steel_plateb_att->SetForceSolid(true);
 steel_plateb_att->SetVisibility(true);
 steel_plateb_log->SetVisAttributes(steel_plateb_att); 

 CLAS_Detector ste_plate;
 ste_plate.logVol = steel_plateb_log;
 ste_plate.pos    = steel_plateb_pos;
 ste_plate.rot    = xRot30deg;
 ste_plate.LOG    = false;
 ste_plate.exist  = true;
 Tagger.Detectors.push_back(ste_plate);











 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 // Tagger Aluminum Box 2. Small Hodoscope 
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 double hodo_l =  28.26; //inches, used to be:80.0  cm
 //if(OPTION == 2 || OPTION == 3) hodo_l = 40;

 G4Trd* tagger_alu_box2     = new G4Trd("tagger_alu_box2",     60.0*cm, 60.0*cm, 38.0*cm, 22.0*cm, hodo_l*2.54*cm);   
 G4Trd* tagger_alu_vac_box2 = new G4Trd("tagger_vac_alu_box2", 59.6*cm, 59.7*cm, 37.7*cm, 21.7*cm, hodo_l*2.54*cm);   
 G4SubtractionSolid *tagger_alu_vacbox2 = new G4SubtractionSolid("tagger_alu_vacbox2", tagger_alu_box2, tagger_alu_vac_box2, 0, 0);

 G4LogicalVolume *tagger_alu_log2 = new G4LogicalVolume(tagger_alu_vacbox2, Materials.Alu, "tagger_alu_log2", 0, 0, 0);
 G4VisAttributes *tagger_alu_att2 = new G4VisAttributes(G4Colour(196./255., 226./255., 232./255.));
 tagger_alu_att2->SetForceSolid(true);
 tagger_alu_att2->SetVisibility(true);
 tagger_alu_log2->SetVisAttributes(tagger_alu_att2);

 G4ThreeVector tagger_alu_pos2(    0.*cm, (-451.0-47.62+3.5)*cm, (772+84.1-6.58)*cm);  

 CLAS_Detector tag_alum_box2;               
 tag_alum_box2.logVol = tagger_alu_log2;
 tag_alum_box2.pos    = tagger_alu_pos2;
 tag_alum_box2.rot    = xRot26deg;
 tag_alum_box2.LOG    = false;
 tag_alum_box2.exist  = true;
 Tagger.Detectors.push_back(tag_alum_box2);

 
 //############################################################
 //tagger vac box 
 //############################################################
 G4Box* tagger_vac_box1 =  new G4Box("tagger_vac_box1", 3.95*2.54*cm, 11.5*2.54*cm, 388.5*cm);
 G4Box* tagger_mag_box1 =  new G4Box("tagger_mag_box1",        50*cm,        50*cm, 1030*cm);
 G4ThreeVector tagger_vac_pos( 0.*cm, -208.25*cm, 477.*cm);
 G4ThreeVector relative_pos( 0.*cm, -695.0*cm+24.5*cm, -165.*cm);
 
 
 G4SubtractionSolid *tagger_vac_box2 = new G4SubtractionSolid("tagger_vac_box2", tagger_vac_box1, tagger_mag_box1, xRot9deg,   G4ThreeVector(0.*cm, 12.*cm, -600.*cm));
 G4SubtractionSolid *tagger_vac_box3 = new G4SubtractionSolid("tagger_vac_box3", tagger_vac_box2, tag_mag_iron2, yRot90deg2, relative_pos); 
 G4SubtractionSolid *tagger_vac_box4 = new G4SubtractionSolid("tagger_vac_box4", tagger_vac_box3, tagger_alu_box,  xRot26deg,  tagger_alu_pos); 
 G4SubtractionSolid *tagger_vac_box5 = new G4SubtractionSolid("tagger_vac_box5", tagger_vac_box4, tagger_alu_box2, xRot20deg,  tagger_alu_pos2); 
 G4SubtractionSolid *tagger_vac_box6 = new G4SubtractionSolid("tagger_vac_box6", tagger_vac_box5, tag_mag_field,   yRot90deg2, G4ThreeVector(0.*cm, -701.8*cm, -163.2*cm)); 

 //use with extended field box
 G4Tubs* tag_mag_vac_tube5   = new G4Tubs("tag_mag_vac_tube5",    600.*cm, 735.*cm, 1.18*2.54*cm,  50.*deg, 37.*deg);
 G4SubtractionSolid *tagger_vac_box7 = new G4SubtractionSolid("tagger_vac_box7", tagger_vac_box5, tag_mag_vac_tube5,   yRot90deg2,G4ThreeVector(0.*cm, -695*cm, -165.*cm) );
 
 //use with imperv sheets
 G4Tubs* tag_mag_vac_tube6   = new G4Tubs("tag_mag_vac_tube6",    600.*cm, 735.*cm, 0.01*2.54*cm,  50.*deg, 37.*deg);
 G4SubtractionSolid *tagger_vac_box8 = new G4SubtractionSolid("tagger_vac_box8", tagger_vac_box6, tag_mag_vac_tube6,   yRot90deg2,G4ThreeVector((1.2-0.01)*2.54*cm, -695*cm, -165.*cm) );
 G4SubtractionSolid *tagger_vac_box9 = new G4SubtractionSolid("tagger_vac_box9", tagger_vac_box8, tag_mag_vac_tube6,   yRot90deg2,G4ThreeVector((-1.2+0.01)*2.54*cm, -695*cm, -165.*cm) );

 //note: use box6 for nominal, box7 for extended field, box9 for iperv sheets on the line below 
 G4LogicalVolume *tagger_vac_log = new G4LogicalVolume(tagger_vac_box9, Materials.Vacuum,  "tagger_vac_log", 0, 0, 0);
 G4VisAttributes *tagger_vac_att = new G4VisAttributes(G4Colour(255./255., 210./255., 210./255.));
 tagger_vac_att->SetForceSolid(true);
 tagger_vac_att->SetVisibility(true);
 tagger_vac_log->SetVisAttributes(tagger_vac_att);

 //1/4"thick steel to cover above vacuum box
 G4Box* tagger_vacbox1   =  new G4Box("tagger_vacbox1",   4.20*2.54*cm,  11.75*2.54*cm, 388.5*cm);
 G4Box* tagger_vacbox2   =  new G4Box("tagger_vacbox2",   3.95*2.54*cm,  11.75*2.54*cm, 390.0*cm);


 G4SubtractionSolid *vacbox_shell2    = new G4SubtractionSolid("vacbox_shell2",    tagger_vacbox1,   tagger_vacbox2, 0, G4ThreeVector(0.*cm, -0.25*2.54*cm, 0.*cm));
 G4SubtractionSolid *vacbox_shell3    = new G4SubtractionSolid("vacbox_shell3",    vacbox_shell2, tagger_mag_box1, xRot9deg,   G4ThreeVector(0.*cm, 12.*cm, -600.*cm));
 G4SubtractionSolid *vacbox_shell = new G4SubtractionSolid("vacbox_shell", vacbox_shell3, tag_mag_iron1, yRot90deg2,   relative_pos);
 G4ThreeVector vacbox_pos( 0.*cm, -208.25*cm, 477.*cm);


 G4LogicalVolume *vacbox_log = new G4LogicalVolume(vacbox_shell, Materials.Steel,  "vacbox_log", 0, 0, 0);
 G4VisAttributes *vacbox_att = new G4VisAttributes(G4Colour(196./255.,226./255., 232./255.));
 vacbox_att->SetForceSolid(true);
 vacbox_att->SetVisibility(true);
 vacbox_log->SetVisAttributes(vacbox_att);

 CLAS_Detector tag_vacuum_box;               
 tag_vacuum_box.logVol = tagger_vac_log;
 tag_vacuum_box.pos    = tagger_vac_pos;
 tag_vacuum_box.rot    = xRot30deg;
 tag_vacuum_box.LOG    = false;
 tag_vacuum_box.exist  = true;
 Tagger.Detectors.push_back(tag_vacuum_box);


 CLAS_Detector tag_vacbox;               
 tag_vacbox.logVol = vacbox_log;
 tag_vacbox.pos    = vacbox_pos;
 tag_vacbox.rot    = xRot30deg;
 tag_vacbox.LOG    = false;
 tag_vacbox.exist  = true;
 Tagger.Detectors.push_back(tag_vacbox);
 
 
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%
 // Modified endplate: OPTION 3
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%

 G4Box* modendplate_box  =  new G4Box("modendplate_box",    4.25*2.54*cm,  9.525*2.54*cm,  0.3175*cm);   

 G4Box* modendplate_box2 =  new G4Box("modendplate_box2",   3.5*2.54*cm,   7.885*2.54*cm,  1.0*cm);   


 G4SubtractionSolid *modendplate1_box = new G4SubtractionSolid("modendplate1_box", modendplate_box,  modendplate_box2, 0, G4ThreeVector(0.*cm, 1.14*2.54*cm, 0.*cm));

 G4LogicalVolume *modendplate_log = new G4LogicalVolume(modendplate1_box, Materials.Steel, "modendplate_log", 0, 0, 0);
 G4VisAttributes *modendplate_att = new G4VisAttributes(G4Colour(196./255., 210./255., 200./255.));
 modendplate_att->SetForceSolid(true);
 modendplate_att->SetVisibility(true);
 modendplate_log->SetVisAttributes(modendplate_att);

 G4ThreeVector modendplate_pos( 0.*cm, (-356.63-47.62)*cm, (735.26+84.1)*cm);

 CLAS_Detector tag_modendplate_box;               
 tag_modendplate_box.logVol = modendplate_log;
 tag_modendplate_box.pos    = modendplate_pos;
 tag_modendplate_box.rot    = xRot30deg;
 tag_modendplate_box.LOG    = false;
 tag_modendplate_box.exist  = true;






    





 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 // Aluminum window upstream end of helium bag: OPTION 3
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 G4Box* Al_frame_box  =  new G4Box("Al_frame_box",  5.5*2.54*cm,  10.0*2.54*cm, 0.3775*2.54*cm);
 G4Box* Al_hole_box   =  new G4Box("Al_hole_box",   3.5*2.54*cm,  8.1*2.54*cm,    1.00*2.54*cm); 

 G4SubtractionSolid *Al_frame = new G4SubtractionSolid("Al_frame", Al_frame_box, Al_hole_box, 0, 0);  


 G4LogicalVolume *Al_frame_log = new G4LogicalVolume(Al_frame,      Materials.Alu, "Al_frame_log", 0, 0, 0);
 G4VisAttributes *Al_frame_att = new G4VisAttributes(G4Colour(0./255., 40./255., 255./255.));
 Al_frame_att->SetForceSolid(true);
 Al_frame_att->SetVisibility(true);
 Al_frame_log->SetVisAttributes(Al_frame_att);


 G4Box* Al_window_box =  new G4Box("Al_window_box", 3.5*2.54*cm,  8.05*2.54*cm,  0.01*cm);
 G4LogicalVolume *Al_window_log = new G4LogicalVolume(Al_window_box, Materials.Alu, "Al_window_log", 0, 0, 0);
 G4VisAttributes *Al_window_att = new G4VisAttributes(G4Colour(250./255., 10./255., 25./255.));
 Al_window_att->SetForceSolid(true);
 Al_window_att->SetVisibility(true);
 Al_window_log->SetVisAttributes(Al_window_att);
   

 G4ThreeVector Al_frame_pos(0.*cm, (-357.13-47.62)*cm, (736.13+84.1)*cm);
 G4ThreeVector Al_window_pos(0.*cm, (-357.13-47.62)*cm,(736.13+84.1)*cm); 


 CLAS_Detector  tag_Al_frame;
 tag_Al_frame.logVol = Al_frame_log;
 tag_Al_frame.pos    = Al_frame_pos;
 tag_Al_frame.rot    = xRot30deg;
 tag_Al_frame.LOG    = false;
 tag_Al_frame.exist  = true;

 
 CLAS_Detector  tag_Al_window;
 tag_Al_window.logVol = Al_window_log;
 tag_Al_window.pos    = Al_window_pos;
 tag_Al_window.rot    = xRot30deg;
 tag_Al_window.LOG    = false;
 tag_Al_window.exist  = true;













 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 // Helium bag (8" radius): OPTION 3
 // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 G4Tubs* heliumbag_tube   = new G4Tubs("heliumbag_tube",    0.*2.54*cm, 8.0*2.54*cm, (265.-48.5)*cm, 0.*deg, 360.*deg); 

 G4ThreeVector heliumbag_pos(0.*cm, (-487-24.25)*cm, (971.94+42)*cm);

 G4LogicalVolume *heliumbag_log = new G4LogicalVolume(heliumbag_tube, Materials.Hel, "heliumbag_log", 0, 0, 0);
 G4VisAttributes *heliumbag_att = new G4VisAttributes(G4Colour(122./255., 0./255., 0./255.));
 heliumbag_att->SetForceSolid(true);
 heliumbag_att->SetVisibility(true);
 heliumbag_log->SetVisAttributes(heliumbag_att);


 CLAS_Detector tag_heliumbag;              
 tag_heliumbag.logVol = heliumbag_log; 
 tag_heliumbag .pos    = heliumbag_pos;
 tag_heliumbag .rot    = xRot30deg;
 tag_heliumbag .LOG    = false;
 tag_heliumbag .exist  = true;

















 // %%%%%%%%%%%%%%%%%%%%%
 // Hall B level 1 floor:
 // %%%%%%%%%%%%%%%%%%%%%

 G4Box* floorL1_box =  new G4Box("floorL1_box", 400.*cm,     // x semilenght
   				                 2.0*cm,     // y semilenght
						 514.56*cm);

 G4ThreeVector floorL1_pos(0.*cm, -215*cm, 1102.68*cm);  

 G4LogicalVolume *floorL1_log = new G4LogicalVolume(floorL1_box, Materials.Iro, "floorL1_log", 0, 0, 0);
 G4VisAttributes *floorL1_att = new G4VisAttributes(G4Colour(150./255., 110./255., 200./255.));
 //G4VisAttributes *floorL1_att = new G4VisAttributes(G4Colour(255./255., 255./255., 255./255.));
 floorL1_att->SetForceSolid(true);
 floorL1_att->SetVisibility(true);
 floorL1_log->SetVisAttributes(floorL1_att);

 CLAS_Detector tag_floorL1;               
 tag_floorL1.logVol = floorL1_log;
 tag_floorL1.pos    = floorL1_pos;
 tag_floorL1.rot    = 0;
 tag_floorL1.LOG    = false;
 tag_floorL1.exist  = true;
 Tagger.Detectors.push_back(tag_floorL1);
 

//1/4"thick Lead to cover tagger Hodo
 G4Box* tag_shield_box1   =  new G4Box("tag_shield_box1",   (4.2+lead_thick)*2.54*cm,  (11.75+lead_thick)*2.54*cm, 388.5*cm);
 G4Box* tag_shield_box2   =  new G4Box("tag_shield_box2",   4.2*2.54*cm,  (11.75+lead_thick)*2.54*cm, 390.0*cm);
 G4ThreeVector offset_iron_pos( 0.*cm, 0.0*cm, 0.01*cm);

 G4SubtractionSolid *tag_shield_shell2    = new G4SubtractionSolid("tag_shield_shell2",    tag_shield_box1,   tag_shield_box2, 0, G4ThreeVector(0.*cm, -2.0*lead_thick*cm, 0.*cm));
 G4SubtractionSolid *tag_shield_shell3    = new G4SubtractionSolid("tag_shield_shell3",    tag_shield_shell2, tagger_mag_box1, xRot9deg,   G4ThreeVector(0.*cm, 12.*cm, -600.*cm));
 G4SubtractionSolid *tag_shield_shell = new G4SubtractionSolid("tag_shield_shell", tag_shield_shell3, tag_mag_iron1, yRot90deg2,   relative_pos+offset_iron_pos);
 G4ThreeVector tag_shield_pos( 0.*cm, -208.25*cm+2.54, 477.*cm);


 G4LogicalVolume *tag_shield_log = new G4LogicalVolume(tag_shield_shell, Materials.Lea,  "tag_shield_log", 0, 0, 0);
 G4VisAttributes *tag_shield_att = new G4VisAttributes(G4Colour(255./255.,10./255., 10./255.));
 tag_shield_att->SetForceSolid(true);
 tag_shield_att->SetVisibility(true);
 tag_shield_log->SetVisAttributes(tag_shield_att);

 


 CLAS_Detector tag_shield;               
 tag_shield.logVol = tag_shield_log;
 tag_shield.pos    = tag_shield_pos;
 tag_shield.rot    = xRot30deg;
 tag_shield.LOG    = false;
 tag_shield.exist  = true;
 if (vac_shield_tag ==1) Tagger.Detectors.push_back(tag_shield);






