package '04_Interfaces' {
    private import ScalarValues::*;

    // ---- Port definitions (written from the sender's view; receivers use ~) ----
    port def CpSignalPort {
        out attribute cpVoltage_V : Real;      // +12 / +9 / +6 V -> states A / B / C
        out attribute dutyCycle_pct : Real;    // PWM duty -> max current (SYS-002)
    }
    port def PpSignalPort {
        out attribute ppResistance_Ohm : Real; // cable coding (SYS-003)
    }
    port def S2CommandPort {
        out attribute closeS2 : Boolean;       // request state C (SYS-004)
    }
    port def CurrentSetpointPort {
        out attribute currentSetpoint_A : Real; // setpoint to power stage (SYS-006)
    }

    // ---- Interface definitions ----
    interface def CpInterface {
        end supplier : CpSignalPort;
        end consumer : ~CpSignalPort;
    }
    interface def PpInterface {
        end supplier : PpSignalPort;
        end consumer : ~PpSignalPort;
    }
    interface def S2Interface {
        end supplier : S2CommandPort;
        end consumer : ~S2CommandPort;
    }
    interface def SetpointInterface {
        end supplier : CurrentSetpointPort;
        end consumer : ~CurrentSetpointPort;
    }
}
