package '06_Verification' {
    package IntegrationTests {
        private import VerificationCases::*;
        private import '03_Structure'::*;
        private import '05_Behavior'::*;
        verification def IT_01_VehicleDetection {
            doc /* SYS-001 over cpLink: CP 12 V -> 9 V gives state B, S2 stays open */
            subject obc : OnBoardCharger;
            objective {
                verify '01_Requirements'::obcSystemSpecification.cpDetection;
            }
            action noVehicle : SetCpVoltage { in :>> voltage_V = 12.0; }
            then action plugIn : SetCpVoltage { in :>> voltage_V = 9.0; }
            then action settle : Wait { in :>> time_ms = 100.0; }
            then action check : CheckS2 { in :>> expectedClosed = false; }
            return verdict : VerdictKind = PassIf(obc.s2Switch.s2In.closeS2 == false);
        }
        verification def IT_02_S2CloseValidCable {
            doc /* SYS-004 over cpLink, ppLink, s2Link: PWM + valid cable closes S2 (guard TRUE) */
            subject obc : OnBoardCharger;
            objective {
                verify '01_Requirements'::obcSystemSpecification.s2Control;
            }
            action plugIn : SetCpVoltage { in :>> voltage_V = 9.0; }
            then action cable : SetPpResistance { in :>> resistance_Ohm = 680.0; }
            then action pwm : SetPwmDutyCycle { in :>> duty_pct = 50.0; }
            then action settle : Wait { in :>> time_ms = 100.0; }
            then action check : CheckS2 { in :>> expectedClosed = true; }
            return verdict : VerdictKind = PassIf(obc.s2Switch.s2In.closeS2 == true);
        }
        verification def IT_03_S2BlockedNoCable {
            doc /* SYS-004 negative test: PWM without valid cable keeps S2 open (guard FALSE) */
            subject obc : OnBoardCharger;
            objective {
                verify '01_Requirements'::obcSystemSpecification.s2Control;
            }
            action plugIn : SetCpVoltage { in :>> voltage_V = 9.0; }
            then action noCable : SetPpResistance { in :>> resistance_Ohm = 100000.0; }
            then action pwm : SetPwmDutyCycle { in :>> duty_pct = 50.0; }
            then action settle : Wait { in :>> time_ms = 500.0; }
            then action check : CheckS2 { in :>> expectedClosed = false; }
            return verdict : VerdictKind = PassIf(obc.s2Switch.s2In.closeS2 == false);
        }
        verification def IT_04_FaultShutdown {
            doc /* SYS-005 fault injection: CP lost while charging opens S2 within 100 ms (state F) */
            subject obc : OnBoardCharger;
            objective {
                verify '01_Requirements'::obcSystemSpecification.faultShutdown;
            }
            action plugIn : SetCpVoltage { in :>> voltage_V = 9.0; }
            then action cable : SetPpResistance { in :>> resistance_Ohm = 680.0; }
            then action pwm : SetPwmDutyCycle { in :>> duty_pct = 50.0; }
            then action charging : Wait { in :>> time_ms = 100.0; }
            then action cpLost : SetCpVoltage { in :>> voltage_V = 0.0; }
            then action reaction : Wait { in :>> time_ms = 100.0; }
            then action check : CheckS2 { in :>> expectedClosed = false; }
            return verdict : VerdictKind = PassIf(obc.s2Switch.s2In.closeS2 == false);
        }
        verification def IT_05_CurrentLimitMin {
            doc /* SYS-006: setpoint = min(CP limit 30 A, cable limit 20 A) -> cable limit wins */
            subject obc : OnBoardCharger;
            objective {
                verify '01_Requirements'::obcSystemSpecification.currentLimit;
            }
            action plugIn : SetCpVoltage { in :>> voltage_V = 9.0; }
            then action cable : SetPpResistance { in :>> resistance_Ohm = 680.0; }
            then action pwm : SetPwmDutyCycle { in :>> duty_pct = 50.0; }
            then action settle : Wait { in :>> time_ms = 200.0; }
            return verdict : VerdictKind = PassIf(obc.powerStage.setpointIn.currentSetpoint_A <= 20.0);
        }
        verification def IT_06_CableCapacity13A {
            doc /* SYS-003 over ppLink: 1.5 kOhm cable = 13 A limits setpoint even with 30 A PWM */
            subject obc : OnBoardCharger;
            objective {
                verify '01_Requirements'::obcSystemSpecification.cableCapacity;
            }
            action plugIn : SetCpVoltage { in :>> voltage_V = 9.0; }
            then action cable : SetPpResistance { in :>> resistance_Ohm = 1500.0; }
            then action pwm : SetPwmDutyCycle { in :>> duty_pct = 50.0; }
            then action settle : Wait { in :>> time_ms = 200.0; }
            return verdict : VerdictKind = PassIf(obc.powerStage.setpointIn.currentSetpoint_A <= 13.0);
        }
        verification def IT_07_MaxCurrentFromPwm {
            doc /* SYS-002 over cpLink: 25 % duty = 15 A limits setpoint with 63 A cable (100 Ohm) */
            subject obc : OnBoardCharger;
            objective {
                verify '01_Requirements'::obcSystemSpecification.maxCurrent;
            }
            action plugIn : SetCpVoltage { in :>> voltage_V = 9.0; }
            then action cable : SetPpResistance { in :>> resistance_Ohm = 100.0; }
            then action pwm : SetPwmDutyCycle { in :>> duty_pct = 25.0; }
            then action settle : Wait { in :>> time_ms = 200.0; }
            return verdict : VerdictKind = PassIf(obc.powerStage.setpointIn.currentSetpoint_A <= 15.0);
        }
    }
}
