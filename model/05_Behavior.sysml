package '05_Behavior' {
    private import ScalarValues::*;

    // Reusable test steps: the vocabulary of every integration test
    action def SetCpVoltage    { in voltage_V : Real; }        // drive CP line
    action def SetPwmDutyCycle { in duty_pct : Real; }         // EVSE PWM
    action def SetPpResistance { in resistance_Ohm : Real; }   // cable coding
    action def Wait            { in time_ms : Real; }
    action def CheckS2         { in expectedClosed : Boolean; } // observe s2Switch.s2In
}
