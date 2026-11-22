package '01_Requirements' {
    requirement def <'SYS-001'> ControlPilotStateDetection {
        doc 
        /* The OBC shall detect the control pilot states A, B, C, E and F
         * according to IEC 61851-1 and report a state change within 100 ms. */
    }
    requirement def <'SYS-002'> MaxCurrentFromDutyCycle {
        doc 
        /* The OBC shall determine the maximum allowed AC input current
         * from the control pilot PWM duty cycle according to IEC 61851-1. */
    }
    requirement def <'SYS-003'> CableCapacityFromProximityPilot {
        doc 
        /* The OBC shall determine the cable current capacity from the
         * proximity pilot resistance: 1.5 kOhm = 13 A, 680 Ohm = 20 A,
         * 220 Ohm = 32 A, 100 Ohm = 63 A. */
    }
    requirement def <'SYS-004'> S2SwitchControl {
        doc 
        /* The OBC shall close switch S2 only when it is ready to draw
         * power, requesting the transition from state B to state C. */
    }
    requirement def <'SYS-005'> ChargingShutdownOnFault {
        doc 
        /* The OBC shall stop drawing power and open S2 within 100 ms
         * when the control pilot reports state E or F, or the CP signal is lost. */
    }
    requirement def <'SYS-006'> ChargingCurrentLimit {
        doc 
        /* The OBC shall limit its AC input current to the lower of
         * the maximum current signalled by the control pilot duty cycle (SYS-002)
         * and the cable current capacity determined from the proximity pilot (SYS-003). */
    }
    requirement obcSystemSpecification {
        requirement cpDetection : ControlPilotStateDetection;
        requirement maxCurrent : MaxCurrentFromDutyCycle;
        requirement cableCapacity : CableCapacityFromProximityPilot;
        requirement s2Control : S2SwitchControl;
        requirement faultShutdown : ChargingShutdownOnFault;
        requirement currentLimit : ChargingCurrentLimit;
    }
}
