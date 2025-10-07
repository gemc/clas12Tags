#include <TGraph.h>

const int NM = 12;

double mom[NM]   = { 2.00,  3.70,  5.30,  7.00,  8.70, 10.30, 12.00, 13.70, 15.30, 17.00, 18.70, 20.30};
double lele[NM]  = { 0.90,  0.90,  0.90,  0.90,  0.90,  0.90,  0.90,  0.90,  0.90,  0.90,  0.90,  0.90};
double lpim[NM]  = { 0.00,  0.41,  0.67,  0.76,  0.81,  0.83,  0.85,  0.86,  0.87,  0.87,  0.87,  0.87};
double lkaon[NM] = { 0.00,  0.00,  0.00,  0.00,  0.00,  0.13,  0.33,  0.45,  0.54,  0.61,  0.66,  0.70};

double hele[NM]  = { 0.92,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92};
double hpim[NM]  = { 0.00,  0.00,  0.10,  0.75,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92,  0.92};
double hkaon[NM] = { 0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.00,  0.10,  0.75,  0.92};


double ltccPionsRejection[NM];
double ltccKaonRejection[NM];
double ltccProtonRejection[NM];

double htccPionsRejection[NM];
double htccKaonRejection[NM];
double htccProtonRejection[NM];

double ccPionsRejection[NM];
double ccKaonRejection[NM];
double ccProtonRejection[NM];


void ltccHtcc() {

    // style:
    // remove stats box
    gStyle->SetOptStat(0);

    // increase bottom distance of histogram from axis
    gStyle->SetPadBottomMargin(0.15);
    gStyle->SetPadLeftMargin(0.15);

    // print momentum and efficiency
    cout << "Momentum" << "\t L Electron"   << "\t L Pion" << "\t\t L Kaon"
                       << "\t\t H Electron" << "\t H Pion" << "\t\t  H Kaon" << endl;
    for (int i=0; i<NM; i++) {
        cout << mom[i] << "\t\t "
        << lele[i] << "\t\t " << lpim[i] << "\t\t " << lkaon[i] << "\t\t "
        << hele[i] << "\t\t " << hpim[i] << "\t\t " << hkaon[i] << endl;
    }

    // created 2D histograms
    TH2F *hltcc = new TH2F("hltcc", "LTCC", 13, 0., 21, 9, 0.5, 9.5);
    // set max to 1
    hltcc->SetMaximum(1.0);
    // set title
    hltcc->SetTitle("LTCC / HTCC efficiencies");

    // fill 2D histograms bins
    for (int i=0; i<NM; i++) {
        hltcc->Fill(mom[i], 8, lele[i]);
        hltcc->Fill(mom[i], 7, lpim[i]);
        hltcc->Fill(mom[i], 6, lkaon[i]);
        hltcc->Fill(mom[i], 4, hele[i]);
        hltcc->Fill(mom[i], 3, hpim[i]);
        hltcc->Fill(mom[i], 2, hkaon[i]);
    }

    // draw 2D histograms
    hltcc->Draw("colz");

	// label x axis as momentum
    hltcc->GetXaxis()->SetTitle("Momentum (GeV/c)");
    // increase label size
    hltcc->GetXaxis()->SetTitleSize(0.06);
    // increase label offset
    hltcc->GetYaxis()->SetLabelSize(0.06);

    // label y axis as particle type
    hltcc->GetYaxis()->SetTitleSize(0.18);
    hltcc->GetYaxis()->SetBinLabel(8, "Electron");
    hltcc->GetYaxis()->SetBinLabel(7, "Pion");
    hltcc->GetYaxis()->SetBinLabel(6, "Kaon");
    hltcc->GetYaxis()->SetBinLabel(4, "Electron");
    hltcc->GetYaxis()->SetBinLabel(3, "Pion");
    hltcc->GetYaxis()->SetBinLabel(2, "Kaon");

    // new canvas
    gStyle->SetPadBottomMargin(0.15);
    gStyle->SetPadLeftMargin(0.3);


    // created 2D histograms
    TH2F *rejections = new TH2F("rejections", "rejections", 13, 0., 21, 9, 0.5, 9.5);
    // set max to 1
    rejections->SetMaximum(1.0);
    rejections->SetMinimum(0.0);
    // set title
    rejections->SetTitle("LTCC / HTCC Efficiency * Rejection Factors");


    // created 2D histograms
    TH2F *arejections = new TH2F("arejections", "rejections", 13, 0., 21, 5, 0.5, 5.5);
    // set max to 1
    arejections->SetMaximum(1.0);
    arejections->SetMinimum(0.0);
    // set title
    arejections->SetTitle("LTCC + HTCC Efficiency * Rejection Factors");


    // fill 2D histograms bins
    for (int i=0; i<NM; i++) {
        ltccPionsRejection[i]  = 0;
        ltccKaonRejection[i]   = 0;
        ltccProtonRejection[i] = 0;
        htccPionsRejection[i]  = 0;
        htccKaonRejection[i]   = 0;
        htccProtonRejection[i] = 0;
        ccPionsRejection[i]    = 0;
        ccKaonRejection[i]     = 0;
        ccProtonRejection[i]   = 0;


        if (lpim[i] == 0 && lele[i] > 0) {
            ltccPionsRejection[i] =  lele[i] ;
        }

        if (lkaon[i] == 0 && lpim[i] > 0) {
            ltccKaonRejection[i] =  lpim[i] ;
        }
        if (lkaon[i] > 0 ) {
            ltccProtonRejection[i] = lkaon[i];
        }

        if (hpim[i] == 0 && hele[i] > 0) {
            htccPionsRejection[i] =  hele[i] ;
        }
        if (hkaon[i] == 0 && hpim[i] > 0) {
            htccKaonRejection[i] =  hpim[i] ;
        }
        if (hkaon[i] > 0) {
            htccProtonRejection[i] =  hkaon[i] ;
        }

        ccPionsRejection[i] = 1 - ( 1 - ltccPionsRejection[i]  ) * ( 1 - htccPionsRejection[i]  );
        ccKaonRejection[i]  = 1 - ( 1 - ltccKaonRejection[i]   ) * ( 1 - htccKaonRejection[i]   );
        ccProtonRejection[i]= 1 - ( 1 - ltccProtonRejection[i] ) * ( 1 - htccProtonRejection[i] );


        rejections->Fill(mom[i], 8, ltccPionsRejection[i]);
        rejections->Fill(mom[i], 7, ltccKaonRejection[i]);
        rejections->Fill(mom[i], 6, ltccProtonRejection[i]);

        rejections->Fill(mom[i], 4, htccPionsRejection[i]);
        rejections->Fill(mom[i], 3, htccKaonRejection[i]);
        rejections->Fill(mom[i], 2, htccProtonRejection[i]);

        arejections->Fill(mom[i], 4, ccPionsRejection[i]);
        arejections->Fill(mom[i], 3, ccKaonRejection[i]);
        arejections->Fill(mom[i], 2, ccProtonRejection[i]);


    }

    TCanvas *c2 = new TCanvas("c2", "c2", 800, 600);
    // draw 2D histograms
    rejections->Draw("colz");

    // label x axis as momentum
    rejections->GetXaxis()->SetTitle("Momentum (GeV/c)");
    // increase label size
    rejections->GetXaxis()->SetTitleSize(0.06);
    // increase label offset
    rejections->GetYaxis()->SetLabelSize(0.06);

    // label y axis as particle type
    rejections->GetYaxis()->SetTitleSize(0.18);
    rejections->GetYaxis()->SetBinLabel(8, "Pure Electrons");
    rejections->GetYaxis()->SetBinLabel(7, "Pure Pions");
    rejections->GetYaxis()->SetBinLabel(6, "Pure Kaons");
    rejections->GetYaxis()->SetBinLabel(4, "Pure Electrons");
    rejections->GetYaxis()->SetBinLabel(3, "Pure Pions");
    rejections->GetYaxis()->SetBinLabel(2, "Pure Kaons");

    TCanvas *c3 = new TCanvas("c3", "c3", 800, 600);

    // draw 2D histograms
    arejections->Draw("colz");

    // label x axis as momentum
    arejections->GetXaxis()->SetTitle("Momentum (GeV/c)");
    // increase label size
    arejections->GetXaxis()->SetTitleSize(0.06);
    // increase label offset
    arejections->GetYaxis()->SetLabelSize(0.06);

    // label y axis as particle type
    arejections->GetYaxis()->SetTitleSize(0.18);
    arejections->GetYaxis()->SetBinLabel(4, "Pure Electrons");
    arejections->GetYaxis()->SetBinLabel(3, "Pure Pions");
    arejections->GetYaxis()->SetBinLabel(2, "Pure Kaons");

}
