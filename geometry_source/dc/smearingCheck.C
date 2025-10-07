{

	TFile f("out.root");
	
	
	TCanvas *dcc = new TCanvas("a", "a", 900, 1200);

	dcc->Divide(1,3);

	
	TH2F *r1 = new TH2F("r1", "r1", 100, 0, 10, 100, -4, 4);
	TH2F *r2 = new TH2F("r2", "r2", 100, 0, 16, 100, -4, 4);
	TH2F *r3 = new TH2F("r3", "r3", 100, 0, 22, 100, -4, 4);
	
	
	dcc->cd(1);
	dc->Draw("(sdoca-doca):doca>>r1", "superlayer<3 && sdoca-doca < 20", "colz");
	dcc->cd(2);
	dc->Draw("(sdoca-doca):doca>>r2", "superlayer>2 && superlayer<5 && sdoca-doca < 20", "colz");
	dcc->cd(3);
	dc->Draw("(sdoca-doca):doca>>r3", "superlayer>4 && sdoca-doca < 20", "colz");
	
	
}