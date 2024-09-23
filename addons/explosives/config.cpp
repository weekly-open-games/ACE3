#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {"ACE_ModuleMine_SLAMBottomMine", "ACE_ModuleExplosive_IEDUrbanBig_Range", "ACE_ModuleExplosive_IEDLandBig_Range", "ACE_ModuleExplosive_IEDUrbanSmall_Range", "ACE_ModuleExplosive_IEDLandSmall_Range"};
        weapons[] = {"ACE_Clacker", "ACE_DefusalKit", "ACE_M26_Clacker", "ACE_DeadManSwitch", "ACE_Cellphone"};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_interaction"};
        author = ECSTRING(common,ACETeam);
        authors[] = {"Garth 'L-H' de Wet", "mharis001"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "ACE_Settings.hpp"
#include "CfgEventHandlers.hpp"
#include "Cfg3DEN.hpp"
#include "CfgAmmo.hpp"
#include "CfgMagazines.hpp"
#include "CfgWeapons.hpp"
#include "CfgVehicles.hpp"
#include "CfgCloudlets.hpp"

#include "ACE_Triggers.hpp"
#include "ACE_Arsenal_Stats.hpp"

// UI stuff
class RscText;
class RscEdit;
class RscPicture;
class RscButton;
class ctrlXSliderH;

#include "ExplosivesUI.hpp"
#include "TimerDialog.hpp"
#include "GUI_VirtualAmmo.hpp"

class CfgActions {
    class None;
    class ActivateMine: None {
        show = 0;
    };
    class Deactivate: None {
        show = 0;
    };
    class DeactivateMine: None {
        show = 0;
    };
    class UseContainerMagazine: None {
        show = 0;
    };
};

class CfgMineTriggers {
    class RangeTrigger;
    class ACE_MagneticTrigger: RangeTrigger {
        mineMagnetic = 1;
        mineTriggerRange = 1;
    };
};
