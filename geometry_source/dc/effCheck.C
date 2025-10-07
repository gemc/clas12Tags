{

	TFile f("out.root");
	
	

	
	TH1F *allWireR1 = new TH1F("allWireR1", "allWireR1", 100, 0, 10);
	TH1F *detWireR1 = new TH1F("detWireR1", "detWireR1", 100, 0, 10);
	TH1F *effWireR1 = new TH1F("effWireR1", "effWireR1", 100, 0, 10);

	TH1F *allWireR2 = new TH1F("allWireR2", "allWireR2", 100, 0, 16);
	TH1F *detWireR2 = new TH1F("detWireR2", "detWireR2", 100, 0, 16);
	TH1F *effWireR2 = new TH1F("effWireR2", "effWireR2", 100, 0, 16);

	TH1F *allWireR3 = new TH1F("allWireR3", "allWireR3", 100, 0, 22);
	TH1F *detWireR3 = new TH1F("detWireR3", "detWireR3", 100, 0, 22);
	TH1F *effWireR3 = new TH1F("effWireR3", "effWireR3", 100, 0, 22);

	dc->Draw("doca>>allWireR1",             "superlayer<3");
	dc->Draw("doca>>detWireR1",  "wire>0 &&  superlayer<3");
	effWireR1->Divide(allWireR1, detWireR1, 1, 1);
	effWireR1->SetMaximum(1.2);
	effWireR1->SetMinimum(1);
	
	
	dc->Draw("doca>>allWireR2",            "superlayer>2 && superlayer<5 ");
	dc->Draw("doca>>detWireR2",  "wire>0 && superlayer>2 && superlayer<5 ");
	effWireR2->Divide(allWireR2, detWireR2, 1, 1);
	effWireR2->SetMaximum(1.2);
	effWireR2->SetMinimum(1);
	
	dc->Draw("doca>>allWireR3",            "superlayer>4");
	dc->Draw("doca>>detWireR3",  "wire>0 && superlayer>4");
	effWireR3->Divide(allWireR3, detWireR3, 1, 1);
	effWireR3->SetMaximum(1.2);
	effWireR3->SetMinimum(1);
	
	TCanvas *dcc = new TCanvas("a", "a", 900, 1200);
	dcc->Divide(1,3);

	dcc->cd(1);
	effWireR1->Draw("");
	
	dcc->cd(2);
	effWireR2->Draw("");
	
	dcc->cd(3);
	effWireR3->Draw("");
	
}