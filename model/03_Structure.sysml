package '03_Structure' {
    private import '04_Interfaces'::*;

    // ---- System: On-Board Charger and its internal wiring ----
    part def OnBoardCharger {
        attribute ratedPower_kW : ScalarValues::Real;
        attribute maxInputCurrent_A : ScalarValues::Real;
        part controller : ChargingController;
        part cpCircuit : ControlPilotCircuit;
        part ppCircuit : ProximityPilotCircuit;
        part s2Switch : S2Switch;
        part powerStage : PowerStage;
        interface connect cpCircuit.cpOut to controller.cpIn;
        interface connect ppCircuit.ppOut to controller.ppIn;
        interface connect controller.s2Out to s2Switch.s2In;
        interface setpointLink : SetpointInterface connect controller.setpointOut to powerStage.setpointIn;
    }

    // ---- Charging controller with the IEC 61851 state machine ----
    part def ChargingController {
        attribute cpDutyCycle_pct : ScalarValues::Real;
        attribute currentLimit_A : ScalarValues::Real;
        port cpIn : ~CpSignalPort;
        port ppIn : ~PpSignalPort;
        port s2Out : S2CommandPort;
        port setpointOut : CurrentSetpointPort;
        exhibit state chargingSM {
            entry;
            then stateA;
            state stateA;
            state stateB {
                entry action assign s2Out.closeS2 := false;
            }
            state stateC;
            state stateF {
                entry action assign s2Out.closeS2 := false;
            }
            transition A_to_B first stateA accept when cpIn.cpVoltage_V < 10.5 then stateB;
            transition B_to_C first stateB accept when cpIn.dutyCycle_pct > 0.0
                if ppIn.ppResistance_Ohm < 2000.0
                do action assign s2Out.closeS2 := true then stateC;
            transition C_to_B first stateC accept when cpIn.dutyCycle_pct == 0.0 then stateB;
            transition B_to_A first stateB accept when cpIn.cpVoltage_V > 10.5 then stateA;
            transition C_to_F first stateC accept when cpIn.cpVoltage_V < 1.0 then stateF;
            transition B_to_F first stateB accept when cpIn.cpVoltage_V < 1.0 then stateF;
            transition F_to_A first stateF accept when cpIn.cpVoltage_V > 10.5 then stateA;
        }
    }

    part def ControlPilotCircuit {
        attribute cpVoltage_V : ScalarValues::Real;
        port cpOut : CpSignalPort;
    }
    part def ProximityPilotCircuit {
        attribute ppResistance_Ohm : ScalarValues::Real;
        port ppOut : PpSignalPort;
    }
    part def S2Switch {
        attribute isClosed : ScalarValues::Boolean;
        port s2In : ~S2CommandPort;
    }
    part def PowerStage {
        port setpointIn : ~CurrentSetpointPort;
    }

    // ---- Product variants ----
    part obc11kW : OnBoardCharger {
        attribute :>> ratedPower_kW = 11.0;
        attribute :>> maxInputCurrent_A = 16.0;
    }
    part obc22kW : OnBoardCharger {
        attribute :>> ratedPower_kW = 22.0;
        attribute :>> maxInputCurrent_A = 32.0;
    }

    // ---- Requirement allocation (satisfy) ----
    satisfy '01_Requirements'::obcSystemSpecification by obc11kW;
    satisfy '01_Requirements'::obcSystemSpecification by obc22kW;
    satisfy '01_Requirements'::obcSystemSpecification.cpDetection by obc11kW.cpCircuit;
    satisfy '01_Requirements'::obcSystemSpecification.maxCurrent by obc11kW.controller;
    satisfy '01_Requirements'::obcSystemSpecification.cableCapacity by obc11kW.ppCircuit;
    satisfy '01_Requirements'::obcSystemSpecification.s2Control by obc11kW.s2Switch;
    satisfy '01_Requirements'::obcSystemSpecification.faultShutdown by obc11kW.controller;
    satisfy '01_Requirements'::obcSystemSpecification.currentLimit by obc11kW.controller;
}
