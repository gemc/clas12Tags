#include "show_segment.h"

// ATTENTION
// for some reason this crashes when called a second time.
// need to call one by one. Sucks
//

// TODO need to figure out where all these objects are defined..

void show_segment(int s)
{
#if 0
	TLatex lab;
	lab.SetTextColor(kBlue+3);
	lab.SetTextFont(42);
	lab.SetNDC(1);
	lab.SetTextSize(0.05);

	CE->cd(1);
	gPad->SetTheta(90);
	gPad->SetPhi(-0.0001);
	
	ell[s]->Draw();
	hyp[s]->Draw("same");


	EFP[0][s]->Draw();
	EFP[1][s]->Draw();	
	el_cent[s]->Draw();

	HFP[0][s]->Draw();
	HFP[1][s]->Draw();
	
	xcenter->Draw();
	ycenter->Draw();
	lab.DrawLatex(0.13, 0.915,  Form("Ellipse, Hyperbola functions for Segment %d ", s+1 ));
	
	
	lab.SetTextColor(kRed);
	lab.SetTextSize(0.028);
	lab.DrawLatex(0.82, 0.65,  "#bullet  Ellipse Foci");
	lab.DrawLatex(0.82, 0.58,  "#diamond  Ellipse Center");
	lab.SetTextColor(kGreen-3);
	lab.DrawLatex(0.82, 0.50,  "#bullet  Hyperbola Foci");
	
	
	
	// ZOOMED IN
	
	lab.SetTextSize(0.05);
	lab.SetTextColor(kBlue+3);
	lab.SetTextSize(0.05);

	CE->cd(2);
	gPad->SetTheta(90);
	gPad->SetPhi(0.0001);
	
	elz[s]->Draw();
	hyz[s]->Draw("same");
	
	EFP[0][s]->Draw();
	EFP[1][s]->Draw();
	HFP[0][s]->Draw();
	HFP[1][s]->Draw();
	x12[s]->Draw();
	
	
	double minyf = 500;
	
	if(minyf>el_foci[3][s]) minyf = el_foci[3][s];
	if(minyf>hp_foci[3][s]) minyf = hp_foci[3][s];

	
	ycenter2->SetPoint(0, 0, minyf-31, 0);
	ycenter2->Draw();

	ellipse_vert1->SetPoint(0, x12y12[0][s], x12y12[1][s], 0);
	ellipse_vert1->SetPoint(1, x12y12[0][s], 521, 0);
	ellipse_vert1->Draw();
	
	el_start[s]->Draw();
	
	ellipse_vert2->SetPoint(0, 0, el_y_sol[s], 0);
	ellipse_vert2->SetPoint(1, 0, 521, 0);
	ellipse_vert2->Draw();
	
	lab.DrawLatex(0.36, 0.915,  Form("Mirror Segment  %d ", s+1 ));
	
	lab.SetTextColor(kRed);
	lab.SetTextSize(0.028);
	lab.DrawLatex(0.82, 0.65,  "#bullet  Ellipse Foci");
	lab.SetTextColor(kBlack);
	lab.DrawLatex(0.82, 0.58,  "#nabla Ellipse Limits");
	lab.SetTextColor(kGreen-3);
	lab.DrawLatex(0.82, 0.50,  "#bullet  Hyperbola Foci");
	lab.SetTextColor(kBlack);
	lab.DrawLatex(0.82, 0.42,  "#times  Hyperbola Limits");

	hp_start[s]->Draw();

	x21[s]->Draw();


	CE->Print(Form("segment_%d.gif", s+1));
#endif	
}




















