program sncEVG

/*
States:
ON - switched on and working ok
OFF - switched off
WARNING - minor problem
ERROR - major problem
FAULT - PV connection problem
INIT - initialization of the PV-s ongoing
*/

#define EVT_14HZ 14
#define EVT_HBEAT 122
#define EVT_CLK 88.052

// GENERAL
// =======
// Overrun protection 1s
int DLY_PROT=1;

// 14HZ Generator
// ==============
// SETPOINTS
int TEVT0_SP = EVT_14HZ; assign TEVT0_SP to "{IOC}-{DEV}:TrigEvt0-EvtCode-SP";
int MXC0_SP = 6289464; assign MXC0_SP to "{IOC}-{DEV}:Mxc0-Prescaler-SP";
string TEVT0_SRC_SP = "Mxc0"; assign TEVT0_SRC_SP to "{IOC}-{DEV}:TrigEvt0-TrigSrc-Sel";
// READBACKS
int TEVT0; assign TEVT0 to "{IOC}-{DEV}:TrigEvt0-EvtCode-RB"; monitor TEVT0;
int MXC0; assign MXC0 to "{IOC}-{DEV}:Mxc0-Prescaler-RB"; monitor MXC0;
string TEVT0_SRC; assign TEVT0_SRC to "{IOC}-{DEV}:TrigEvt0-TrigSrc-Sel"; monitor TEVT0_SRC;

// HEARTBEAT CONFIGURATION
// =======================
// SETPOINTS
int TEVT7_SP = EVT_HBEAT; assign TEVT7_SP to "{IOC}-{DEV}:TrigEvt7-EvtCode-SP";
int MXC7_SP = 88052500; assign MXC7_SP to "{IOC}-{DEV}:Mxc7-Prescaler-SP";
string TEVT7_SRC_SP = "Mxc7"; assign TEVT7_SRC_SP to "{IOC}-{DEV}:TrigEvt7-TrigSrc-Sel";
// READBACKS
int TEVT7; assign TEVT7 to "{IOC}-{DEV}:TrigEvt7-EvtCode-RB"; monitor TEVT7;
int MXC7; assign MXC7 to "{IOC}-{DEV}:Mxc7-Prescaler-RB"; monitor MXC7;
string TEVT7_SRC; assign TEVT7_SRC to "{IOC}-{DEV}:TrigEvt7-TrigSrc-Sel"; monitor TEVT7_SRC;

// EVENT CLOCK TEST
// ================
string ssLink_str = "EVENT_CLOCK_";
// PLL test
int PLL = 0; assign PLL to "{IOC}-{DEV}:EvtClk-Pll-Sts"; monitor PLL;
// Master Enable test
string Master_En_SP="Ena Master"; assign Master_En_SP to "{IOC}-{DEV}:Enable-Sel";
string Master_En; assign Master_En to "{IOC}-{DEV}:Enable-Sel"; monitor Master_En;

// RF TEST
// =======
string ssRF_str = "RADIO_FREQUENCY_";
//MTCA-EVG:EvtClk-RFDiv-SP
//MTCA-EVG:EvtClk-RFFreq-SP
//MTCA-EVG:EvtClk-Frequency-RB
//MTCA-EVG:EvtClk-FracSynFreq-SP
//MTCA-EVG:EvtClk-Source-Sel
float RF_CLK_SP = EVT_CLK; assign RF_CLK_SP to "{IOC}-{DEV}:EvtClk-RFFreq-SP";
float RF_CLK_RB; assign RF_CLK_RB to "{IOC}-{DEV}:EvtClk-RFFreq-RB"; monitor RF_CLK_RB;


// ================

ss RADIO_FREQUENCY {
    state INIT {
      when () {
        printf(ssRF_str);
        printf("INIT\n");
        pvPut(RF_CLK_SP);
        //printf("EVT_CLK=%d\n",EVT_CLK_int);
      } state ON
    }

    state ON {
      when (delay(DLY_PROT) //&&
            //  floor(RF_CLK_RB) - floor(RF_CLK_SP);
            ) {
        printf(ssRF_str);
        printf("ON\n");
        floor(RF_CLK_RB);
      } state ERROR
    }
    state ERROR {
       when (
             //          nint(RF_CLK_RB) != nint(RF_CLK_SP)
             ) {
         printf(ssRF_str);
         printf("ERROR\n");
	} state ON
    }

}



// EVENT CLOCK TEST
// ================
ss EVENT_CLOCK {
    state INIT {
      when () {
        printf(ssLink_str);
        printf("INIT\n");
        pvPut(Master_En_SP);
      } state ON
    }

    state ON {
      when (delay(DLY_PROT) &&
            PLL == 1 &&
            strcmp(Master_En, Master_En_SP) == 0) {
        printf(ssLink_str);
        printf("ON\n");
      } state ERROR
    }
    state ERROR {
       when (PLL != 1 ||
             strcmp(Master_En, Master_En_SP) != 0) {
         printf(ssLink_str);
         printf("ERROR\n");
	} state ON
    }

}



// 14HZ Generator
// ==============
ss GEN_14HZ {
    state INIT {
      when () {
        printf("GEN_14HZ_");
        printf("INIT\n");
        pvPut(MXC0_SP);
        pvPut(TEVT0_SP);
        pvPut(TEVT0_SRC_SP);
      } state ON
    }

    state ON {
        when (delay(DLY_PROT) &&
              MXC0 == MXC0_SP &&
              TEVT0 == TEVT0_SP &&
              strcmp(TEVT0_SRC, TEVT0_SRC_SP) == 0) {
          printf("GEN_14HZ_");
          printf("ON\n");
	} state ERROR
    }
    state ERROR {
        when (MXC0 != MXC0_SP ||
              TEVT0 != TEVT0_SP ||
              strcmp(TEVT0_SRC, TEVT0_SRC_SP) != 0) {
          printf("GEN_14HZ_");
          printf("ERROR\n");
	} state ON
    }
}


//HEARTBEAT SECTION
//=================
ss HBEAT {
    state INIT {
      when () {
        printf("HBEAT_");
        printf("INIT\n");
        pvPut(MXC7_SP);
        pvPut(TEVT7_SP);
        pvPut(TEVT7_SRC_SP);
      } state ON
    }

    state ON {
        when (delay(DLY_PROT) &&
              MXC7 == MXC7_SP &&
              TEVT7 == TEVT7_SP &&
              strcmp(TEVT7_SRC, TEVT7_SRC_SP) == 0) {
          printf("HBEAT_");
          printf("ON\n");
        } state ERROR
    }
    state ERROR {
        when (MXC7 != MXC7_SP ||
              TEVT7 != TEVT7_SP ||
              strcmp(TEVT7_SRC, TEVT7_SRC_SP) != 0) {
          printf("HBEAT_");
          printf("ERROR\n");
	} state ON
    }
}
