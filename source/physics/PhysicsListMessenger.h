#ifndef PHYSICS_LIST_MESSENGER_H
#define PHYSICS_LIST_MESSENGER_H 1

// geant4 headers
#include "G4UImessenger.hh"
#include "G4UIcmdWithADoubleAndUnit.hh"
#include "G4UIcmdWithAString.hh"
#include "G4UIcmdWithoutParameter.hh"
#include "PhysicsList.h"

class PhysicsListMessenger: public G4UImessenger
{
	public:
		
		PhysicsListMessenger();
		virtual ~PhysicsListMessenger();
		
		void SetNewValue(G4UIcommand*, G4String);
		
	private:

		G4UIcmdWithADoubleAndUnit* fGammaCutCmd;
		G4UIcmdWithADoubleAndUnit* fElectCutCmd;
		G4UIcmdWithADoubleAndUnit* fPosCutCmd;
		G4UIcmdWithADoubleAndUnit* fCutCmd;
		G4UIcmdWithADoubleAndUnit* fAllCutCmd;
		G4UIcmdWithAString*        fPListCmd;
		G4UIcmdWithoutParameter*   fListCmd;
};

#endif
