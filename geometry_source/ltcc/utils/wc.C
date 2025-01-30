// TODO
#if 0
{
	
	ifstream f("../parameters/wcEff.txt");
	
	TH1F *effi  = new TH1F("effi",  "effi",  100, 0.0, 1.0);
	
	TH1F *effi1R = new TH1F("effi1R", "effi1R", 6, -0.1, 1.1);
	TH1F *effi2R = new TH1F("effi2R", "effi2R", 6, -0.1, 1.1);
	TH1F *effi3R = new TH1F("effi3R", "effi3R", 6, -0.1, 1.1);
	
	
	for(int i=0; i<216; i++)
	{
		double e;
		f >> e;
		
		if(i!=11       && i!=12       && 
			i!=11 + 18  && i!=12 + 18  && 
			i!=11 + 36  && i!=12 + 36  && 
			i!=11 + 54  && i!=12 + 54  && 
			i!=11 + 72  && i!=12 + 72  && 
			i!=11 + 90  && i!=12 + 90  && 
			i!=11 + 108 && i!=12 + 108 && 
			i!=11 + 126 && i!=12 + 126 && 
			i!=11 + 144 && i!=12 + 144 && 
			i!=11 + 162 && i!=12 + 162 && 
			i!=11 + 180 && i!=12 + 180 && 
			i!=11 + 196 && i!=12 + 196 )
		
		effi->Fill(e);
	}

	
	double threshold = 0.7;
	
	double bad   = effi->Integral(0, 50);
	double soso  = effi->Integral(51, threshold*100);
	double good  = effi->Integral(threshold*100+1, 100);
	double total = effi->Integral(0, 100);
	
	double maxH = effi->GetMaximum()/100;
	
	effi1R->SetBinContent(1, maxH*bad);
	effi1R->SetBinContent(2, maxH*bad);
	effi1R->SetBinContent(3, maxH*bad);
	effi2R->SetBinContent(4, maxH*soso);
	effi3R->SetBinContent(5, maxH*good);
	effi3R->SetBinContent(6, maxH*good);
	
	effi1R->SetFillColorAlpha(kRed,   0.3);
	effi2R->SetFillColorAlpha(kBlue,   0.3);
	effi3R->SetFillColorAlpha(kGreen,  0.3);

	
	effi->Draw();
	effi1R->Draw("same");
	effi2R->Draw("same");
	effi3R->Draw("same");
	effi->Draw("same");
	
	
	TLatex lab;
	lab.SetTextFont(102);
	lab.SetNDC();

	lab.SetTextColor(kRed-3);
	lab.DrawLatex(.15,.8, Form("bad:  %3.0f", bad)) ;
	lab.SetTextColor(kBlue-3);
	lab.DrawLatex(.15,.7, Form("soso: %3.0f", soso)) ;
	lab.SetTextColor(kGreen-3);
	lab.DrawLatex(.15,.6, Form("good: %3.0f", good)) ;

	
	
}
#endif
