### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    P20-P25.agc
## Purpose:     A section of Luminary revision 116.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 12.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 494-616
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-01-22 MAS  Created from Luminary 99.
##              2017-01-28 RSB  WTIH -> WITH.
##              2017-03-09 HG   Transcribed
##              2017-03-14 HG   Fix operator CALL  --> VLOAD
##                              Fix statement CA BIT1  --> CS BIT5
##                              Fix operand   ENDRRD29 --> ENDR29RD
##		2017-03-13 RSB	Proofed comment text via 3-way diff vs
##				Luminary 99 and 131.

## Page 494
# RENDEZVOUS NAVIGATION PROGRAM 20
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY  P. VOLANTE
# FUNCTIONAL DESCRIPTION

#   THE PURPOSE OF THIS PROGRAM IS TO CONTROL THE RENDEZVOUS RADAR FROM
# STARTUP THROUGH ACQUISITION AND LOCKON TO THE CSM AND TO UPDATE EITHER
# THE LM OR CSM STATE VECTOR (AS SPECIFIED BY THE ASTRONAUT BY DSKY ENTRY)
# ON THE BASIS OF THE RR TRACKING DATA.
# CALLING SEQUENCE -

# ASTRONAUT REQUEST THROUGH DSKY V37E20E
# SUBROUTINES CALLED
#   R02BOTH (IMU STATUS CHECK)               FLAGUP
#   GOFLASH (PINBALL-DISPLAY)                FLAGDOWN
#   R23LEM  (MANUAL ACQUISITION)             BANKCALL
#   LS201   (LOS DETERMINATION)              TASKOVER
#   LS202   (RANGE LIMIT TEST)
#   R61LEM  (PREFERRED TRACKING ATTITUDE)
#   R21LEM  (RR DESIGNATE)                   ENDOFJOB
#   R22LEM  (DATA READ)                      GOPERF1
#   R31LEM  (RENDEZVOUS PARAMETER DISPLAY)
#   PRIOLARM (PRIORITY DISPLAY)
# NORMAL EXIT MODES-
#   P20 MAY BE TERMINATED IN TWO WAYS-ASTRONAUT SELECTION OF IDLING
# PROGRAM (P00) BY KEYING V37E00E OR BY KEYING IN V56E
# ALARM OR ABORT EXIT MODES-
#   RANGE GREATER THAN 400 NM DISPLAY
# OUTPUT
#   TRKMKCNT = NO OF RENDEZVOUS TRACKING MARKS TAKEN (COUNTER)
# ERASABLE INITIALIZATION REQUIRED
# FLAGS SET + RESET
#   SRCHOPT,RNDVZFLG,ACMODFLG,VEHUPFLG,UPDATFLG,TRACKFLG,
# DEBRIS
#   CENTRALS-A,Q,L
                SBANK=          LOWSUPER                        # FOR LOW 2CADR'S.

                BANK            33
                SETLOC          P20S
                BANK

                EBANK=          LOSCOUNT
                COUNT*          $$/P20
PROG22          =               PROG20
PROG20          TC              2PHSCHNG
                OCT             4
                OCT             05022
                OCT             26000                           # PRIORITY 26
                TC              LUNSFCHK                        # CHECK IF ON LUNAR SURFACE

## Page 495
                TC              ORBCHGO                         # YES
                TC              PROG20A         -2              # NO - CONTINUE WITH P20
ORBCHGO         TC              UPFLAG                          # SET VEHUPFLG - CSM STATE
                ADRES           VEHUPFLG                        # VECTOR TO BE UPDATED
                CAF             ONE                             # SET R2 FOR OPTION CSM WILL NOT
                TS              OPTION2                         # CHANGE PRESENT ORBIT
                CAF             OCT00012
                TC              BANKCALL                        # DISPLAY ASSUMED CSM ORBIT OPTION
                CADR            GOPERF4
                TC              GOTOPOOH                        # TERMINATE
                TC              ORBCHG1                         # PROCEED VALUE OF ASSUMED OPTION OK
                TC              -5                              # R2 LOADED THRU DSKY
ORBCHG1         CS              ONE
                AD              OPTION2
                EXTEND
                BZF             PROG20A
                CAF             V06N33*
                TC              BANKCALL                        # FLASH VERB-NOUN TO REQUEST ESTIMATED
                CADR            GOFLASH                         # TIME OF LAUNCH
                TC              GOTOPOOH                        # TERMINATE
                TC              ORBCHG2                         # PROCEED VALUES OK
                TC              -5                              # TIME LOADED THRU DSKY
ORBCHG2         TC              INTPRET
                GOTO
                                ORBCHG3
                BANK            32
                SETLOC          P20S4
                BANK
                COUNT*          $$/P20

ORBCHG3         CALL
                                INTSTALL
                DLOAD
                                TIG
                STORE           LNCHTM
                STORE           TDEC1                           # ESTIMATED LAUNCH TIME
                CLEAR           CLEAR
                                VINTFLAG                        # LM INTEGRATION
                                INTYPFLG                        # PRECISION - ENCKE
                CLEAR           CLEAR
                                DIM0FLAG                        # NO W-MATRIX
                                D6OR9FLG
                CALL
                                INTEGRV                         # PLANETARY INERTIAL ORIENTATION
                CALL
                                GRP2PC
                VLOAD
                                RATT1
                STODL           RSUBL                           # SAVE LM POSITION
                                TAT

## Page 496
                STCALL          TDEC1
                                INTSTALL
                SET             CLEAR
                                VINTFLAG                        # CSM INTEGRATION
                                INTYPFLG
                CLEAR           BOFF
                                DIM0FLAG
                                RENDWFLG                        # W MATRIX VALID
                                NOWMATX                         # NO
                SET             SET                             # YES - SET FOR W MATRIX
                                DIM0FLAG
                                D6OR9FLG
NOWMATX         CALL
                                INTEGRV                         # CSM INTEGRATION
                CALL
                                GRP2PC
                VLOAD
                                VATT1
                STOVL           VSUBC                           # SAVE CSM VELOCITY
                                RATT1
                STORE           RSUBC                           # SAVE CSM POSITION
                VXV             UNIT                            # COMPUTE NORMAL TO CSM ORBITAL PLANE
                                VSUBC                           # NSUB1=UNIT(R(CM) CROSS V(CM)
                STOVL           20D                             # SAVE NSUB1
                                RSUBL                           # COMPUTE ESTIMATED ORBITAL
                VXV             UNIT                            # PLANE CHANGE
                                20D                             # UCSM = UNIT(R(LM) CROSS NSUB1)
                STOVL           UCSM
                                RSUBC                           # COMPUTE ANGLE BETWEEN UCSM
                UNIT            DOT                             # AND RSUBC
                                UCSM                            # COS A = UCSM DOT UNIT (R(CM))
                SL1
                STORE           CSTH                            # SAVE DOE TIME-THETA SUBROUTINE
                DSQ             BDSU                            # COMPUTE SINE A
                                ONEB-2
                SQRT
                STOVL           SNTH                            # SAVE FOR TIME-THETA SUBROUTINE
                                RSUBC                           # POSITION OF CSM AT EST. LAUNCH
                STOVL           RVEC                            # TIME FOR TIME-THETA   B-27
                                VSUBC                           # VELOCITY OF CSM AT EST. LAUNCH
                VCOMP
                STORE           VVEC                            # TIME FOR TIME THETA   B-5
                CLEAR           CALL
                                RVSW
                                TIMETHET
                VCOMP
                STORE           NEWVEL                          # TERMINAL VELOCITY OF CSM
                DLOAD
                                T
                STOVL           TRANSTM                         # TRANSFER TIME

## Page 497
                                NEWVEL
                ABVAL
                STOVL           20D
                                0D
                STORE           NEWPOS                          # TERMINAL POSITION OF CSM
                VXV             UNIT                            # COMPUTE NORMAL TO CSM ORBITAL PLANE
                                RSUBL                           # NSUB2 = UNIT(NEWPOS CROSS R(LM))
                VXV             UNIT                            # ROTATE TERMINAL VEL INTO DESIRED
                                NEWPOS                          # ORBITAL PLANE
                VXSC            VSL1                            # VSUBC = ABVAL(NEWVEL) $ UNIT( NSUB2
                                20D
                STCALL          NCSMVEL                         # NEW CSM VELOCITY
                                GRP2PC
                CALL
                                INTSTALL
                DLOAD           BDSU
                                TRANSTM                         # LAUNCH TIME - TRANSFER TIME
                                LNCHTM
                STOVL           TET
                                NEWPOS
                STORE           RCV
                STOVL           RRECT
                                NCSMVEL
                STCALL          VRECT
                                MINIRECT
                AXT,2           CALL
                                2
                                ATOPCSM
                CALL
                                INTWAKE0
                EXIT
                TC              BANKCALL
                CADR            PROG20A
                BANK            24
                SETLOC          P20S
                BANK
                COUNT*          $$/P20

                TC              DOWNFLAG                        # RESET VEHUPFLG- LM STATE VECTOR
                ADRES           VEHUPFLG                        # TO BE UPDATED
PROG20A         TC              BANKCALL
                CADR            R02BOTH
                TC              UPFLAG
                ADRES           UPDATFLG                        # SET UPDATE FLAG
                TC              UPFLAG
                ADRES           TRACKFLG                        # SET TRACK FLAG
                TC              UPFLAG
                ADRES           RNDVZFLG                        # SET RENDEZVOUS FLAG
                TC              DOWNFLAG
                ADRES           SRCHOPTN                        # INSURE SEARCH OPTION OFF

## Page 498
                TC              DOWNFLAG                        # ALSO MANUAL ACQUISITION FLAG RESET
                ADRES           ACMODFLG
                TC              DOWNFLAG                        # TURN OFF R04FLAG TO ENSURE GETTING
                ADRES           R04FLAG                         # ALARM 521 IF CANT READ RADAR
                TC              DOWNFLAG                        # ENSURE R25 GIMBAL MONITOR IS ENABLED
                ADRES           NORRMON                         # (RESET NORRMON FLAG)
                TC              DOWNFLAG                        # RESET LOS BEING COMPUTED FLAG
                ADRES           LOSCMFLG
                TC              CLRADMOD
P20LEM1         TC              PHASCHNG
                OCT             04022
                CAF             ZERO                            # ZERO MARK COUNTER
                TS              MARKCTR
                TC              INTPRET                         # LOS DETERMINATION ROUTINE
                RTB
                                LOADTIME
                STCALL          TDEC1
                                LPS20.1
                CALL
                                LPS20.2                         # TEST RANGE R/UTINE
                EXIT
                INDEX           MPAC
                TC              +1
                TC              P20LEMA                         # NORMAL RETURN WITHIN 400 N M
526ALARM        CAF             ALRM526                         # ERROR EXIT - RANGE > 400 N. MI.
                TC              BANKCALL
                CADR            PRIOLARM
                TC              GOTOV56                         # TERMINATE EXITS P20 VIA V56 CODING
                TC              -4                              # PROC (ILLEGAL
                TC              P20LEM1                         # ENTER RECYCLE
                TC              ENDOFJOB


P20LEMA         TC              PHASCHNG
                OCT             04022
                TC              LUNSFCHK                        # CHECK LUNAR SURFACE FLAG (P22 FLAG)
                TC              P20LEMB
                TC              BANKCALL
                CADR            R61LEM                          # PREFERRED TRACKING ATTITUDE ROUTINE
P20LEMB         TC              PHASCHNG
                OCT             05022                           # RESTART AT PRIORITY 10 TO ALLOW V37
                OCT             10000                           # REQUESTED PROGRAM TO RUN FIRST
                CAF             PRIO26                          # RESTORE PRIORITY 26
                TC              PRIOCHNG
                CA              FLAGWRD1                        # IS THE TRACK FLAG SET
                MASK            TRACKBIT
                EXTEND
                BZF             P20LEMWT                        #  BRANCH - NO - WAIT FOR IT TO BE SET
P20LEMB7        CAF             BIT2                            # IS RR AUTO MODE DISCRETE PRESENT
                EXTEND

## Page 499
                RAND            CHAN33
                EXTEND
                BZF             P20LEMB3                        # YES - DO AUTOMATIC ACQUISITION (R21)


P20LEMB5        CS              OCT24                           # RADAR NOT IN AUTO CHECK IF
                AD              MODREG                          # MAJOR MODE IS 20
                EXTEND
                BZF             P20LEMB6                        # BRANCH - YES-OK TO DO PLEASE PERFORM


                AD              NEG2                            # ALSO CHECK FOR P22
                EXTEND
                BZF             P20LEMB6                        # BRANCH - YES OK TO DO PLEASE PERFORM
                CAF             ALRM514                         # TRACK FLAG SET-FLASH PRIORITY ALARM 514-
                TC              BANKCALL                        # RADAR GOES OUT OF AUTO MODE WHILE IN USE
                CADR            PRIOLARM
                TC              GOTOV56                         # TERMINATE EXITS VIA V56
                TC              P20LEMB                         # PROCEED AND ENTER BOTH GO BACK
                TC              P20LEMB                         # TO CHECK AUTO MODE AGAIN
                TC              ENDOFJOB
P20LEMB6        CAF             OCT201                          # REQUEST RR AUTO MODE SELECTION
                TC              BANKCALL
                CADR            GOPERF1
                TC              GOTOV56                         # TERMINATE EXITS P20 VIA V56 CODING
                TC              P20LEMB                         # PROCEED CHECKS AUTO MODE DISCRETE AGAIN
                TC              LUNSFCHK                        # ENTER INDICATES MANUAL ACQUISITION (R23)
                TC              P20LEMB2                        # YES - R23 NOT ALLOWED-TURN ON OPR ERROR
                TC              R23LEM                          # NO - DO MANUAL ACQUISITION


P20LEMB1        TC              UPFLAG                          # RETURN FROM R23 - LOCKON ACHIEVED
                ADRES           ACMODFLG                        # SET MANUAL FLAG AND GO BACK TO CHECK
                TC              P20LEMB                         # RR AUTO MODE


P20LEMB2        TC              FALTON                          # TURNS ON OPERATOR ERROR LIGHT ON DSKY
                TC              P20LEMB                         # AND GOES BACK TO CHECK AUTO MODE


P20LEMB3        CS              RADMODES                        # ARE RR CDUS BEING ZEROED
                MASK            RCDU0BIT
                EXTEND
                BZF             P20LEMB4                        # BRANCH - YES - WAIT
                CAF             BIT13-14                        # IS SEARCH OR MANUAL ACQUISITION FLAG SET
                MASK            FLAGWRD2
                EXTEND
                BZF             P20LEMC3                        # ZERO MEANS AUTOMATIC RR ACQUISTION
                TC              DOWNFLAG                        # RESET TO AUTO MODE
                ADRES           SRCHOPTN

## Page 500
                TC              DOWNFLAG
                ADRES           ACMODFLG
                TC              P20LEMWT                        # WAIT 2.5 SECONDS THEN GO TO RR DATA READ


P20LEMB4        CAF             250DEC
                TC              BANKCALL                        # WAIT 2.5 SECONDS WHILE RR CDUS ARE BEING
                CADR            DELAYJOB                        # ZEROED-THEN GO BACK AND CHECK AGAIN
                TC              P20LEMB3


P20LEMC3        TC              INTPRET
                RTB
                                LOADTIME
                STCALL          TDEC1
                                UPPSV
P20LEMC4        EXIT
P20LEMC         TC              PHASCHNG
                OCT             04022
                CAE             FLAGWRD0                        # IS THE RENDEZVOUS FLAG SET
                MASK            RNDVZBIT
                EXTEND
                BZF             ENDOFJOB                        # NO - EXIT P20
                CAE             FLAGWRD1                        # IS TRACK FLAG SET  (BIT 5 FLAGWORD 1)
                MASK            TRACKBIT
                EXTEND
                BZF             P20LEMD                         # BRANCH-TRACK FLAG NOT ON-WAIT 15 SECONDS
P20LEMF         TC              R21LEM


P20LEMWT        CAF             250DEC
                TC              TWIDDLE                         # USE INSTEAD OF WAITLIST SINCE SAME BANK
                ADRES           P20LEMC1                        # WAIT 2.5 SECONDS
                CAE             FLAGWRD1                        # IS TRACK FLAG SET
                MASK            TRACKBIT
                EXTEND
                BZF             ENDOFJOB                        # NO-EXIT WITHOUT DOING 2.7 PHASE CHANGE
P20LMWT1        TC              PHASCHNG
                OCT             40072
                TC              ENDOFJOB


P20LEMC1        CAE             FLAGWRD0                        # IS RENDEZVOUS FLAG SET
                MASK            RNDVZBIT
                EXTEND
                BZF             TASKOVER                        # NO - EXIT P20/R22
                CAE             FLAGWRD1                        # IS TRACK FLAG SET
                MASK            TRACKBIT
                EXTEND
                BZF             P20LEMC2                        # NO-DONT SCHEDULE R22 JOB

## Page 501
                CAF             PRIO26                          # YES-SCHEDULE R22 JOB (RR DATA READ)
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           R22LEM42

                TC              TASKOVER


P20LEMC2        TC              FIXDELAY                        # TRACK FLAG NOT SET ,WAIT 15 SECONDS
                DEC             1500                            # AND CHECK AGAIN

                TC              P20LEMC1

P20LEMD         CAF             1500DEC
                TC              TWIDDLE                         # WAITLIST FOR 15 SECONDS
                ADRES           P20LEMD1
                TC              ENDOFJOB


P20LEMD1        CAE             FLAGWRD1                        # IS TRACK FLAG SET
                MASK            TRACKBIT
                CCS             A
                TCF             P20LEMD2                        # YES-SCHEDULE DESIGNATE JOB
                TC              FIXDELAY                        # NO-WAIT 15 SECONDS
                DEC             1500
                TC              P20LEMD1


P20LEMD2        CAF             PRIO26                          # SCHEDULE JOB TO DO R21
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           P20LEMC3                        # START AT PERM. MEMORY INTEGRATION

                TC              TASKOVER


250DEC          DEC             250
ALRM526         OCT             00526
OCT201          OCT             00201
ALRM514         OCT             514
MAXTRIES        DEC             60
OCT00012        EQUALS          BINCON
ONEB-2          EQUALS          DP1/4TH
V06N33*         VN              0633
UPPSV           STQ             CALL                            # UPDATES PERMANENT STATE VECTORS
                                LS21X                           #  TO PRESENT TIME
                                INTSTALL
                CALL
                                SETIFLGS
                BOF             SET                             # IF W-MATRIX INVALID,DONT INTEGRATE IT

## Page 502
                                RENDWFLG
                                UPPSV1
                                DIM0FLAG                        # SET DIMOFLAG TO INTEGRATE W-MATRIX
                BON             SET
                                SURFFLAG                        # IF ON LUNAR SURFACE W IS 6X6
                                UPPSV5
                                D6OR9FLG                        # OTHERWISE 9X9
UPPSV5          BOF
                                VEHUPFLG
                                UPPSV3
UPPSV1          SET
                                VINTFLAG
                CALL
                                INTEGRV
                CALL                                            # GROUP 2 PHASE CHANGE
                                GRP2PC                          # TO PROTECT INTEGRATION
                CALL
                                INTSTALL
                DLOAD           CLEAR                           # GET TETCSM TO STORE IN TDEC FOR LM INT.
                                TETCSM
                                VINTFLAG
UPPSV4          CALL                                            # INTEGRATE OTHER VEHICLE
                                SETIFLGS                        #  WITHOUT W-MATRIX
                STCALL          TDEC1
                                INTEGRV
                BOFF            VLOAD
                                SURFFLAG
                                P20LEMC4
                                RCVLEM
                VSR2
                STOVL           LMPOS
                                VCVLEM
                VSR2
                STORE           LMVEL
                GOTO
                                LS21X


UPPSV3          CLEAR           CALL
                                VINTFLAG
                                INTEGRV
                CALL
                                GRP2PC
                CALL
                                INTSTALL
                SET             DLOAD
                                VINTFLAG
                                TETLEM                          # GET TETLEM TO STORE IN TDEC FOR CSM INT.
                GOTO
                                UPPSV4

## Page 503
                EBANK=          LOSCOUNT
                COUNT*          $$/P22

## Page 504
# PROGRAM DESCRIPTION
# PREFERRED TRACKING ATTITUDE PROGRAM P25
# MOD NO - 3
# BY  P. VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   THE PURPOSE OF THIS PROGRAM IS TO COMPUTE THE PREFERRED TRACKING
# ATTITUDE OF THE LM TO CONTINUOUSLY POINT THE LM TRACKING BEACON AT THE
# CSM AND TO PERFORM THE MANEUVER TO THE PREFERRED TRACKING ATTITUDE AND
# CONTINUOUSLY MAINTAIN THIS ATTITUDE WITHIN PRESCRIBED LIMITS
# CALLING SEQUENCE -
#   ASTRONAUT REQUEST THROUGH DSKY V37E25E
# SUBROUTINES CALLED -
#   BANKCALL                      FLAGUP
#   R02BOTH  (IMU STATUS CHECK)   ENDOFJOB
#   R61LEM   (PREF TRK ATT ROUT)  WAITLIST
#   TASKOVER                      FINDVAC
# NORMAL EXIT MODES  -
#   P25 MAY BE TERMINATED IN TWO WAYS-ASTRONAUT SELECTION OF IDLING
# PROGRAM(P00) BY KEYING V37E00E OR BY KEYING IN V56E
# ALARM OR ABORT EXIT MODES -
#   NONE
# OUTPUT
# ERASABLE INITIALIZATION REQUIRED
# FLAGS SET + RESET
#   TRACKFLG,P25FLAG
# DEBRIS
#   NONE
                EBANK=          LOSCOUNT
                COUNT*          $$/P25
PROG25          TC              2PHSCHNG
                OCT             4                               # MAKE GROUP 4 INACTIVE (VERB 37)
                OCT             05022
                OCT             26000                           # PRIORITY 26

                TC              BANKCALL
                CADR            R02BOTH                         # IMU STATUS CHECK
                TC              UPFLAG
                ADRES           TRACKFLG                        # SET TRACK FLAG
                TC              UPFLAG
                ADRES           P25FLAG                         # SET P25FLAG
                TC              DOWNFLAG
                ADRES           RNDVZFLG
P25LEM1         TC              PHASCHNG
                OCT             04022
                CAF             P25FLBIT
                MASK            STATE                           # IS P25FLAG SET
                EXTEND
                BZF             ENDOFJOB
                CAF             TRACKBIT                        # IS TRACKFLAG SET?

## Page 505
                MASK            STATE           +1
                EXTEND
                BZF             P25LMWT1                        # NO-SKIP PHASE CHANGE AND WAIT 1 MINUTE
                CAF             SEVEN                           # CALL R65 - FINE PREFERRED
                TS              R65CNTR
                TC              BANKCALL                        # TRACKING ATTITUDE ROUTINE
                CADR            R65LEM
                TC              P25LEM1                         # THEN GO CHECK FLAGS
P25LMWT1        CAF             60SCNDS
                TC              TWIDDLE                         # WAIT ONE MINUTE THEN CHECK AGAIN
                ADRES           P25LEM2
                TC              ENDOFJOB
P25LEM2         CAF             PRIO14
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           P25LEM1
                TC              TASKOVER
60SCNDS         DEC             6000

## Page 506
# DATA READ ROUTINE 22 (LEM)
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY P VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   TO PROCESS AUTOMATIC RR MARK DATA TO UPDATE THE STATE VECTOR OF EITHER
# LM OR CSM AS DEFINED IN THE RENDEZVOUS NAVIGATION PROGRAM (P20)
# CALLING SEQUENCE -
#          TC     BANKCALL
#          CADR   R22LEM
# SUBROUTINES CALLED -
#   LSR22.1           GOFLASH        WAITLIST
#   LSR22.2           PRIOLARM       BANKCALL
#   LSR22.3           R61LEM
# NORMAL EXIT MODES-
#   R22 WILL CONTINUE TO RECYCLE,UPDATING STATE VECTORS WITH RADAR DATA
# UNTIL P20 CEASES TO OPERATE (RENDEZVOUS FLAG SET TO ZERO) AT WHICH TIME
# R22 WILL TERMINATE SELF.
# ALARM OR ABORT EXIT MODES-
#   PRIORITY ALARM
# PRIORITY ALARM 525 LOS NOT WITHIN 3 DEGREE LIMIT
# OUTPUT
#   SEE OUTPUT FROM LSR22.3
# ERASABLE INITIALIZATION REQUIRED
#   SEE LSR22.1,LSR22.2,LSR22.3
# FLAGS SET + RESET
#   NOANGFLG
# DEBRIS
#   SEE LSR22.1,LSR22.2,LSR22.3
                EBANK=          LRS22.1X
                COUNT*          $$/R22
R22LEM          TC              PHASCHNG
                OCT             04022
                CAF             RNDVZBIT                        # IS RENDESVOUS FLAG SET?
                MASK            STATE
                EXTEND
                BZF             ENDOFJOB                        # NO-EXIT R22 AND P20
                CAF             TRACKBIT                        # IS TRACKFLAG SET?
                MASK            STATE           +1
                EXTEND
                BZF             R22WAIT                         # NO WAIT
R22LEM12        CAF             BIT14                           # IS RR AUTO TRACK ENABLE DISCRETE STILL
                EXTEND                                          # ON (A MONITOR REPOSITION BY R25 CLEARSIT
                RAND            CHAN12
                EXTEND
                BZF             P20LEMA                         # NO - RETURN TO P20
                CAF             BIT2                            # YES
                EXTEND                                          # IS RR AUTO MODE DISCRETE PRESENT
                RAND            CHAN33

## Page 507
                EXTEND
                BZF             +2                              # YES CONTINUE
                TC              P20LEMB5                        # NO - SET IT
                CS              RADMODES                        # ARE RR CDUS BEING ZEROED
                MASK            RCDU0BIT
                EXTEND
                BZF             R22LEM42                        # CDUS BEING ZEROED
                TC              PHASCHNG                        # IF A RESTART OCCURS,AN EXTRA RADAR
                OCT             00152                           # READING IS TAKEN,SO BAD DATA ISN'T USED
                TC              BANKCALL                        # YES READ DATA + CALCULATE LOS
                CADR            LRS22.1                         # DATA READ SUBROUTINE
                INDEX           MPAC
                TC              +1
                TC              R22LEM2                         # NORMAL RETURN (GOOD DATA)
                TC              P20LEMC                         # COULD NOT READ RADAR-TRY TO REDESIGNATE
                CAF             ALRM525                         # RR LOS NOT WITHIN 3 DEGREES (ALARM)
                TC              BANKCALL
                CADR            PRIOLARM
                TC              GOTOV56                         # TERMINATE EXITS P20 VIA V56 CODING
                TC              R22LEM1                         # PROC (DISPLAY DELTA THETA)
                TC              -5                              # ENTER(ILLEGAL OPTION)
                TC              ENDOFJOB


R22LEM1         TC              PHASCHNG
                OCT             04022
                CAF             V06N05                          # DISPLAY DELTA THETA
                TC              BANKCALL
                CADR            PRIODSP
                TC              GOTOV56                         # TERMINATE EXITS P20 VIA V56 CODING
                TC              R22LEM2                         # PROC (OK CONTINUE)
                TC              P20LEMC                         # ENTER(RECYCLE)
R22LEM2         TC              PHASCHNG
                OCT             04022
                TC              LUNSFCHK                        # CHECK IF ON LUNAR SURFACE (P22FLAG SET)
                TC              R22LEM3                         # YES-BYPASS FLAG CHECKS AND LRS22.2
                CA              FLAGWRD1                        # IS TRACK FLAG SET
                MASK            TRACKBIT
                EXTEND
                BZF             R22WAIT                         # NO - WAIT
                TC              BANKCALL                        # YES
                CADR            LRS22.2                         # CHECKS RR BORESIGHT WITHIN 30 DEG OF +Z
                INDEX           MPAC
                TC              +1
                TC              R22LEM3                         # NORMAL RETURN (LOS WITHIN 30 OF Z-AXIS)
                TC              BANKCALL
                CADR            R61LEM
                TC              R22WAIT                         # NOT WITHIN 30 DEG OF Z-AXIS
R22LEM3         CS              FLAGWRD1                        # SHOULD WE BYPASS STATE VECTOR UPDATE
                MASK            NOUPFBIT                        # (IS NO UPDATE FLAG SET?)

## Page 508
                EXTEND
                BZF             R22LEM42                        # BRANCH-YES
                CA              FLAGWRD1                        # IS UPDATE FLAG SET
                MASK            UPDATBIT
                EXTEND
                BZF             R22LEM42                        # UPDATE FLAG NOT SET
                CAF             PRIO26                          # INSURE HIGH PRIO IN RESTART
                TS              PHSPRDT2

                TC              INTPRET
                GOTO
                                LSR22.3
R22LEM93        EXIT                                            # NORMAL EXIT FROM LSR22.3
                TC              PHASCHNG                        # PHASE CHANGE TO PROTECT AGAINST
                OCT             04022                           # CONFLICT WITH GRP2PC ERASEABLE
                TCF             R22LEM44
R22LEM96        EXIT
                CAF             ZERO                            # SET N49FLAG = ZERO TO INDICATE
                TS              N49FLAG                         # V06 N49 DISPLAY HASNT BEEN ANSWERED
                TC              PHASCHNG
                OCT             04022                           # TO PROTECT DISPLAY
                CAF             PRIO27                          # PROTECT DISPLAY
                TC              NOVAC
                EBANK=          N49FLAG
                2CADR           N49DSP
                TC              INTPRET
                SLOAD
                                N49FLAG
                BZE             BMN                             # LOOP TO CHECK IF FLAG
                                -3                              # SETTING CHANGED-BRANCH - NO
                                R22LEM7                         # PROCEED
                GOTO                                            # DISPLAY ANSWERED BY RECYCLE-INCORPORATE
                                LGRET                           #       NEXT MEASUREMENT
V34TON49        CS              TWO
                TS              N49FLAG
                TC              ENDOFJOB
R22LEM7         EXIT
                CA              N49FLAG                         # WAS ANSWER TO DISPLAY PRO OR TERM
                AD              TWO
                EXTEND
                BZF             R22LEM                          # BRANCH - TERM - TAKE ANOTHER RR READING
                TC              INTPRET
                CALL
                                GRP2PC                          # PHASE CHANGE AND
                GOTO                                            # GO TO INCORPORATE DATA.
                                ASTOK
R22LEM44        INCR            MARKCTR                         # INCREMENT COUNT OF MARKS INCORPORATED.
                TC              LUNSFCHK                        # ARE WE ON LUNAR SURFACE
                TC              R22LEM46                        # YES - WAIT 2 SECONDS

## Page 509
                CA              FIVE                            # NOT ON LUNAR SURFACE
                TC              R22LEM45                        # R65COUNTER = 5
R22LEM42        TC              LUNSFCHK                        # CHECK IF ON LUNAR SURFACE (P22FLAG SET)
                TC              R22LEM46                        # YES - WAIT 2 SECONDS
                CA              TWO                             # NO-SET R65COUNTER = 2
R22LEM45        TS              R65CNTR
                TC              BANKCALL
                CADR            R65LEM                          # FINE PREFERRED TRACKING ATTITUDE
                TC              R22LEM
R22WAIT         CAF             1500DEC
                TC              P20LEMWT        +1


R22LEM46        TC              BANKCALL                        # WAIT 2 SECONDS AND TAKE ANOTHER MARK
                CADR            2SECDELY
                TC              R22LEM

N49DSP          CAF             V06N49NB
                TC              BANKCALL                        # EXCESSIVE STATE VECTOR UPDATE - FLASH
                CADR            PRIODSP                         # VERB 06 NOUN 49 R1=DELTA R, R2=DELTA V
                TC              V34TON49                        # TERMINATE - SET N49FLAG = -2
                CS              ONE                             # PROCEED - N49FLAG = -1
                TS              N49FLAG                         # RECYCLE - N49FLAG = + VALUE
                TC              ENDOFJOB
R22RSTRT        TC              PHASCHNG                        # IF A RESTART OCCURS WHILE READING RADAR
                OCT             00152                           # COME HERE TO TAKE A RANGE-RATE READING
                TC              BANKCALL                        # WHICH ISNT USED TO PREVENT TAKING A BAD
                CADR            RRRDOT                          # READING AND TRYING TO INCORPORATE THE
                TC              BANKCALL                        # BAD DATA
                CADR            RADSTALL                        # WAIT FOR READ COMPLETE
                TC              P20LEMC                         # COULD NOT READ RADAR-TRY TO REDESIGNATE
                TC              R22LEM                          # READ SUCCESSFUL-CONTINUE AT R22


ALRM525         OCT             00525
V06N05          VN              00605
V06N49NB        VN              00649
1500DEC         DEC             1500
# LUNSFCHK-CLOSED SUBROUTINE TO CHECK IF ON LUNAR SURFACE (P22FLAG)
#          RETURNS TO CALLER +1 IF P22FLAG SET
#                  TO CALLER +2 IF P22FLAG NOT SET


                COUNT*          $$/P22
LUNSFCHK        CS              FLAGWRD8                        # CHECK IF ON LUNAR SURFACE
                MASK            SURFFBIT                        # IS SURFFLAG SET?
                CCS             A                               # BRANCH - P22FLAG SET
                INCR            Q                               # NOT SET
                TC              Q                               # RETURN

## Page 510
# RR DESIGNATE ROUTINE (R21LEM)
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY P VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   TO POINT THE RENDEZVOUS RADAR AT THE CSM UNTIL AUTOMATIC ACQUISITION
# OF THE CSM IS ACCOMPLISHED BY THE RADAR. ROUTINE IS CALLED BY P20.
# CALLING SEQUENCE -
#          TC     BANKCALL
#          CADR   R21LEM
# SUBROUTINES CALLED -
#   FINDVAC        FLAGUP           ENDOFJOB        PRIOLARM
#   NOVAC          INTPRET          LPS20.1         PHASCHNG
#   WAITLIST       JOBSLEEP         JOBWAKE         FLAGDOWN
#   TASKOVER       BANKCALL         RADSTALL        RRDESSM
# NORMAL EXIT MODES
#   WHEN LOCK-ON IS ACHIEVED,BRANCH WILL BE TO P20 WHERE R22 (DATA READ
# WILL BE SELECTED OR A NEED FOR A MANEUVER(BRANCH TO P20LEMA)
# ALARM OR ABORT EXIT MODES-
#   PRIORITY ALARM 503 WHEN LOCK-ON HASN:T BEEN ACHIEVED AFTER 30SECS -
# THIS REQUIRES ASTRONAUT INTERFACE- SELECTION OF SEARCH OPTION OF
# ACQUISITION
# OUTPUT
#   SEE LPS20.1,RRDESSM
# ERASABLE INITIALIZATION REQUIRED
#   RRTARGET,RADMODES ARE USED BY LPS20.1 AND RRDESSM
# FLAGS SET + RESET
#   LOSCMFLG      LOKONSW
# DEBRIS
#   SEE LPS20.1,RRDESSM
                EBANK=          LOSCOUNT
                COUNT*          $$/R21
R21LEM          CS              BIT14                           # REMOVE RR SELF TRACK ENABLE
                EXTEND
                WAND            CHAN12
                TC              LUNSFCHK
                TC              R21LEM5
                CAF             ZERO                            #      COMMAND ANTENNA TO MODE CENTER
                TS              TANG                            # IF NOT ON SURFACE-MODE 1-(T=0,S=0)
                TS              TANG            +1
                TC              R21LEM6
R21LEM5         CAF             BIT12
                MASK            RADMODES
                CCS             A
                TC              R21LEM10
                CAF             BIT15
                TS              TANG
                CS              HALF
                TS              TANG            +1

## Page 511
R21LEM6         TC              DOWNFLAG
                ADRES           LOKONSW
                TC              BANKCALL
                CADR            RRDESNB
                TC              +1
                TC              BANKCALL
                CADR            RADSTALL
                TC              R21-503                         # BAD RETURN FROM DESIGNATE -ISSUE ALARM
R21LEM10        TC              UPFLAG
                ADRES           LOSCMFLG                        # EVERY FOURTH PASS THRU DODES
                CAF             MAXTRIES                        # ALLOW 60 PASSES (APPROX 45 SECONDS)
                TS              DESCOUNT                        # TO DESIGNATE AND LOCK ON
R21LEM2         CAF             THREE
                TS              LOSCOUNT
R21LEM1         TC              INTPRET
                RTB             DAD
                                LOADTIME
                                HALFSEC                         # EXTRAPOLATE TO PRESENT TIME + .5 SEC.
                STCALL          TDEC1                           # LOS DETERMINATION ROUTINE
                                LPS20.1
                EXIT
R21LEM3         TC              UPFLAG                          # SET LOKONSW TO RADAR-ON DESIRED
                ADRES           LOKONSW
                TC              DOWNFLAG
                ADRES           NORRMON
                TC              INTPRET
                CALL                                            # INPUT (RRTARGET UPDATED BY LPS20.1)
                                RRDESSM                         # DESIGNATE ROUTINE
                EXIT
                TC              R21LEM4                         # LOS NOT IN MODE 2 COVERAGE
                                                                # ON LUNAR SURFACE
                TC              P20LEMA                         # VEHICLE MANEUVER REQUIRED.
                TC              BANKCALL                        # NO VEHICLE MANEUVER REQUIRED
                CADR            RADSTALL                        # WAIT FOR DESIGNATE COMPLETE - LOCKON OR
                TC              +2                              # BADEND-LOCKON NOT ACHIEVED IN 60 TRIES
                TC              R21END                          # EXIT ROUTINE RETURN TO P20 (LOCK-ON)
R21-503         CAF             ALRM503                         # ISSUE ALARM 503
                TC              BANKCALL
                CADR            PRIOLARM
                TC              GOTOV56                         # TERMINATE EXITS P20 VIA V56 CODING
                TC              R21SRCH                         # PROC
                TC              P20LEMC3
                TC              ENDOFJOB
R21END          TC              DOWNFLAG
                ADRES           LOSCMFLG                        # RESET LOSCMFLG
                TC              LUNSFCHK                        # ARE WE ON LUNAR SURFACE
                TC              P20LEMWT                        # YES - BYPASS V 50 N 72 DISPLAY
                TC              R21DISP                         # PUT UP VERIFY MAIN LOBE LOCKON DISPLAY
R21SRCH         TC              PHASCHNG
                OCT             04022

## Page 512
                TC              R24LEM                          # SEARCH ROUTINE
ALRM503         OCT             00503
ALRM527         OCT             527


R21LEM4         CAF             MAXTRIES                        # SET UP COUNTER FOR
                TS              REPOSCNT                        # 60 PASSES (APPROX 600 SECS.)
                TC              UPFLAG
                ADRES           FSPASFLG                        # SET FIRST PASS FLAG
                TC              DOWNFLAG                        # RESET LOS BEING
                ADRES           LOSCMFLG                        # COMPUTED FLAG
                TC              INTPRET
R21LEM12        RTB             DAD
                                LOADTIME
                                TENSEC                          # TIME T = T + 10 SECS.
                STORE           REPOSTM                         # SAVE FOR LONGCALL AND UPPSV
                STCALL          TDEC1
                                LPS20.1                         # COMPUTE LOS AT TIME T
                CALL
                                RRDESSM
                EXIT
                TC              R21LEM13                        # LOS NOT IN MODE 2 COVERAGE
                TC              ENDOFJOB                        # VEHICLE MANEUVER REQUIRED
                TC              KILLTASK
                CADR            BEGDES
                TC              INTPRET
                BOF             CLRGO
                                FSPASFLG                        # FIRST PASS THRU REPOSITION
                                R21LEMB                         # NO-GO TO CONTINUOUS DESIGNATE
                                FSPASFLG                        # YES-RESET FIRST PASS FLAG
                                R21LEM50
R21LEM13        CCS             REPOSCNT                        # HAVE WE TRIED 60 TIMES?
                TC              R21LEM7                         # NO-ADD 10 SECS. RECOMPUTE LOS
                TC              R21LEM11                        # YES-PUT OUT ALARM 530
R21LEM7         TS              REPOSCNT
                TC              INTPRET
R21LEM50        DLOAD           GOTO
                                REPOSTM
                                R21LEM12        +2
R21LEMB         DLOAD
                                REPOSTM
                STCALL          TDEC1
                                UPPSV
                EXIT
                TC              UPFLAG                          # SET RADMODES BIT 15 FOR
                ADRES           CDESFLAG                        # CONTINUOUS DESIGNATION
                TC              DOWNFLAG
                ADRES           LOKONSW
                TC              UPFLAG
                ADRES           NORRMON

## Page 513
                TC              BANKCALL
                CADR            RRDESNB
                TC              +1
                TC              INTPRET
                RTB             BDSU
                                LOADTIME                        # COMPUTE DELTA TIME
                                REPOSTM                         # FOR LONGCALL
                STORE           DELTATM
                EXIT
                EXTEND
                DCA             DELTATM
                TC              LONGCALL
                EBANK=          LOSCOUNT
                2CADR           R21LEM9
                TC              ENDOFJOB
R21LEM9         TC              KILLTASK
                CADR            STDESIG
                TC              CLRADMOD
                CAF             PRIO26
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           R21LEM10
                TC              TASKOVER
R21LEM11        CAF             ALRM530                         # ALARM 530-LOS NOT IN COVERAGE
                TC              BANKCALL                        # AFTER TRYING TO DESIGNATE FOR
                CADR            PRIOLARM                        # 600 SECS.
                TC              GOTOV56
                TC              GOTOV56
                TC              GOTOV56
                TC              ENDOFJOB
ALRM530         OCT             00530
TENSEC          2DEC            1000            B-28
HALFSEC         2DEC            50
R21DISP         TC              PHASCHNG
                OCT             04022
                CAF             V06N72PV                        # FLASH V 50 N 72 - PLEASE PERFORM RR
                TC              BANKCALL                        # MAIN LOBE LOCKON VERIFICATION
                CADR            GOPERF2R
                TC              GOTOV56                         # TERMINATE EXITS VIA V 56
                TC              P20LEMWT                        # PROCEED CONTINUES TO R22
                TC              -5                              # ENTER ILLEGAL
                CAF             BIT7
                TC              LINUS                           # SET BITS TO MAKE THIS A PRIORITY DISPLAY
                TC              ENDOFJOB

## Page 514
V06N72PV        VN              00672

## Page 515
# MANUAL ACQUISITION ROUTINE R23LEM
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY P VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   TO ACQUIRE THE CSM BY MANUAL OPERATION OF THE RENDEZVOUS RADAR
# CALLING SEQUENCE -
#          TC     R23LEM
# SUBROUTINES CALLED
#   BANKCALL        R61LEM
#   SETMINDB        GOPERF1
# NORMAL EXIT MODES -
#   IN RESPONSE TO THE GOPERF1 ,SELECTION OF ENTER WILL RECYCLE R23
#                              ,SELECTION OF PROC  WILL CONTINUE R23
#                              ,SELECTION OF TERM  WILL TERMINATE R23 +P20
# ALARM OR ABORT EXIT MODES -
#   SEE NORMAL EXIT MODES ABOVE
# OUTPUT
#   N.A.
# ERASABLE INITIALIZATION REQUIRED-
#   ACMODFLG MUST BE SET TO 1 (MANUAL MODE)
                EBANK=          GENRET
                COUNT*          $$/R23
R23LEM          TC              UPFLAG                          # SET NO ANGLE MONITOR FLAG
                ADRES           NORRMON
                INHINT
                TC              IBNKCALL                        # SELECT MINIMUM DEADBAND
                CADR            SETMINDB
                RELINT
R23LEM1         CAF             BIT14                           # ENABLE TRACKER
                EXTEND
                WOR             CHAN12
                CAF             OCT205
                TC              BANKCALL
                CADR            GOPERF1
                TC              R23LEM2                         # TERMINATE
                TC              R23LEM11                        # PROCEDE
                TC              R23LEM3                         # ENTER- DO ANOTHER MANUVER
R23LEM11        INHINT
                TC              RRLIMCHK                        # YES - CHECK IF ANTENNA IS WITHIN LIMITS
                ADRES           CDUT
                TC              OUTOFLIM                        # NOT WITHIN LIMITS
                TC              IBNKCALL                        # RESTORE DEADBAND TO
                CADR            RESTORDB                        # ASTRONAUT SELECTED VALUE
                RELINT
                TC              DOWNFLAG                        # CLEAR NO ANGLE MONITOR FLAG
                ADRES           NORRMON
                TC              P20LEMB1                        # RADAR IS LOCKED ON CONTINUE IN P20
OUTOFLIM        RELINT

## Page 516
                CAF             OCT501PV
                TC              BANKCALL                        # ISSUE ALARM - RR ANTENNA NOT WITHIN
                CADR            PRIOLARM                        # LIMITS
                TC              R23LEM2                         # TERMINATE - EXIT R23 TO R00 (GO TO POOH)
                TC              OUTOFLIM        +1              # PROCEED ILLEGAL
                TC              R23LEM3                         # RECYCLE- DO ANOTHER MANUVER
                TC              ENDOFJOB
R23LEM2         TC              DOWNFLAG                        # CLEAR NO ANGLE MONITOR FLAG
                ADRES           NORRMON
                TC              GOTOV56                         # AND EXIT VIA V56
R23LEM3         TC              BANKCALL
                CADR            R61LEM
                TC              R23LEM1


OCT501PV        OCT             501
OCT205          OCT             205

## Page 517
# SEARCH ROUTINE R24LEM
# PROGRAM DESCRIPTION
# MOD NO - 2
# BY  P. VOLANTE
# FUNCTIONAL DESCRIPTION
#
#   TO ACQUIRE THE CSM BY A SEARCH PATTERN WHEN THE RENDEZVOUS RADAR HAS
# FAILED TO ACQUIRE THE CSM IN THE AUTOMATIC TRACKING MODE AND TO ALLOW
# THE ASTRONAUT TO CONFIRM THAT REACQUISITION HAS NOT BEEN BY SIDELOBE.
# CALLING SEQUENCE
#          CAF    PRIONN
#          TC     FINDVAC
#          EBANK= DATAGOOD
#          2CADR  R24LEM
# SUBROUTINES CALLED
#   FLAGUP        FLAGDOWN      BANKCALL
#   R61LEM        GOFLASHR      FINDVAC
#   ENDOFJOB      NOVAC         LSR24.1
# NORMAL EXIT MODES-
#   ASTRONAUT RESPONSE TO DISPLAY OF OMEGA AND DATAGOOD.HE CAN EITHER
# REJECT BY TERMINATING (SEARCH OPTION AND RESELECTING P20) OR ACCEPT BY
# PROCEEDING (EXIT ROUTINE AND RETURN TO AUTO MODE IN P20)
# ALARM OR ABORT EXIT MODES-
#   SEE NORMAL EXIT MODES ABOVE
# OUTPUT -
#   SEE OUTPUT FROM LSR24.1 + R61LEM
# ERASABLE INITIALIZATION REQUIRED
#   SEE INPUT FOR LSR24.1
# FLAGS SET + RESET
#   SRCHOPT,ACMODFLG
                EBANK=          DATAGOOD
                COUNT*          $$/R24
R24LEM          TC              UPFLAG
                ADRES           SRCHOPTN                        # SET SRCHOPT FLAG
                TC              DOWNFLAG                        # RESET LOS BEING COMPUTED FLAG TO MAKE
                ADRES           LOSCMFLG                        # SURE DODES DOESN'T GO TO R21
R24LEM1         CAF             ZERO
                TS              DATAGOOD                        # ZERO OUT DATA INDICATOR
                TS              OMEGAD                          # ZERO OMEGA DISPLAY REGS
                TS              OMEGAD          +1              # ZERO OMEGA DISPLAY REGS
R24LEM2         TC              PHASCHNG
                OCT             04022
                CAF             V16N80
                TC              BANKCALL
                CADR            PRIODSPR
                TC              GOTOV56
                TC              R24END                          # PROCEED EXIT R24 TO P20LEM1


                TC              R24LEM3                         # RECYCLE - CALL R61 TO MANEUVER S/C

## Page 518
                TC              BANKCALL
                CADR            LRS24.1
R24END          TC              KILLTASK
                CADR            CALLDGCH
                TC              CLRADMOD                        # CLEAR BITS 10 & 15 OF RADMODES.
                TCF             P20LEM1                         # AND GO TO 400 MI. RANGE CHECK IN P20.

                BLOCK           3
                SETLOC          FFTAG6
                BANK
                COUNT*          $$/R24

CLRADMOD        CS              BIT10+15
                INHINT
                MASK            RADMODES
                TS              RADMODES
                CS              BIT2                            # DISABLE RR ERROR COUNTERS
                EXTEND
                WAND            CHAN12                          # USER WILL RELINT

                TC              Q


BIT10+15        OCT             41000
                BANK            24
                SETLOC          P20S
                BANK
                COUNT*          $$/R24

R24LEM3         TC              PHASCHNG
                OCT             04022
                TC              KILLTASK
                CADR            CALLDGCH                        # KILL WAITLIST FOR NEXT POINT IN PATTERN
                TC              CLRADMOD                        # CLEAR BITS 10 + 15 OF RADMODES
                CAF             .5SEC
                TC              BANKCALL                        # WAIT FOR DESIGNATE LOOP TO DIE
                CADR            DELAYJOB
                TC              LUNSFCHK                        # CHECK IF ON LUNAR SURFACE
                TC              R24LEM4                         # YES-DONT DO ATTITUDE MANEUVER
                TC              BANKCALL                        # CALL R61 TO DO PREFERRED TRACKING
                CADR            R61LEM                          # ATTITUDE MANEUVER
R24LEM4         CAF             ZERO                            # ZERO OUT RADCADR (WHICH WAS SET BY
                TS              RADCADR                         # ENDRADAR WHEN DESIGNATE STOPPED) SO THAT
                                                                # RRDESSM WILL RETURN TO CALLER
                TC              R24LEM2                         # AND GO BACK TO PUT UP V16 N80 DISPLAY


V16N80          VN              01680

## Page 519
# PREFERRED TRACKING ATTITUDE ROUTINE R61LEM
# PROGRAM DESCRIPTION
# MOD NO : 3                      DATE: 4-11-67
# MOD BY : P VOLANTE  SDC


# FUNCTIONAL DESCRIPTION-
#   TO COMPUTE THE PREFERRED TRACKING ATTITUDE OF THE LM TO ENABLE RR
# TRACKING OF THE CSM AND TO PERFORM THE MANEUVER TO THE PREFERRED
# ATTITUDE.
# CALLING SEQUENCE-
#          TC     BANKCALL
#          CADR   R61LEM
# SUBROUTINES CALLED
#     LPS20.1       VECPOINT
#     KALCMAN3


# NORMAL EXIT MODES-
#   NORMAL RETURN IS TO CALLER + 1
# ALARM OR ABORT EXIT MODES-
#   TERMINATE P20 + R61 BY BRANCHING TO P20END IF BOTH TRACKFLAG +
# RENDEZVOUS FLAG ARE NOT SET.
# OUTPUT -
#   SEE OUTPUT FOR LPS20.1 + ATTITUDE MANEUVER ROUTINE (R60)
# ERASABLE INITIALIZATION REQUIRED
#   GENRET USED TO SAVE Q FOR RETURN
# FLAGS SET + RESET
#   3AXISFLG
# DEBRIS
#   SEE SUBROUTINES
                SETLOC          R61
                BANK
                EBANK=          LOSCOUNT
                COUNT*          $$/R61
R61LEM          TC              MAKECADR
                TS              GENRET
                TC              UPFLAG                          # SET R61 FLAG
                ADRES           R61FLAG
                TC              R61C+L02
R65LEM          TC              MAKECADR
                TS              GENRET
                TC              DOWNFLAG                        # RESET R61 FLAG
                ADRES           R61FLAG
R61C+L01        CAF             BIT4                            # BYPASS RADAR READING IF DATA
                EXTEND                                          # GOOD NOT PRESENT
                RAND            CHAN33
                CCS             A
                TCF             R61C+L02                        # NO DATA GOOD
                TC              UPFLAG

## Page 520
                ADRES           R04FLAG                         # PREVENT 521 ALM
                TC              BANKCALL                        # READ RR RANGE AND RDOT
                CADR            RRRDOT                          #  EVERY R65 PASS (3 TIMES
                TC              BANKCALL                        #  BEFORE FIRST MARK, ONCE
                CADR            RADSTALL                        #  DURING ANY MARK PROCESSING.
                NOOP
                TC              BANKCALL
                CADR            RRRANGE
                TC              BANKCALL
                CADR            RADSTALL
                NOOP
                TC              DOWNFLAG
                ADRES           R04FLAG
R61C+L02        CAF             TRACKBIT                        # TRACKFLAG
                MASK            STATE           +1
                EXTEND
                BZF             R65WAIT                         # NOT SET
R61C+L03        TC              INTPRET
                VLOAD
                                HIUNITZ
                STORE           SCAXIS                          # TRACK AXIS UNIT VECTOR
R61LEM1         RTB             DAD
                                LOADTIME                        # EXTRAPOLATE FORWARD TO CENTER
                                3SECONDS                        # SIX SECOND PERIOD.
                STCALL          TDEC1
                                LPS20.1                         # LOS DETERMINATION + VEH ATTITUDE
                VLOAD
                                RRTARGET
                STORE           POINTVSM
                RTB             CALL                            #    GET DESIRED CDU'S FOR VECPNT1
                                READCDUD
                                VECPNT1                         # COMPUTES FINAL ANGLES FROM PRESENT CDUDS
                STORE           CPHI                            # STORE FINAL ANGLES - CPHI,CTHETA,CPSI
                EXIT
                TC              PHASCHNG
                OCT             04022
                CAF             TRACKBIT                        #  IS TRACK FLAG SET
                MASK            FLAGWRD1
                EXTEND
                BZF             R65WAIT
                TC              BANKCALL
                CADR            G+N,AUTO                        # CHECK FOR AUTO MODE
                CCS             A
                TC              R61C+L04                        # NOT IN AUTO
                TC              INTPRET
                VLOAD           CALL
                                RRTARGET
                                CDU*SMNB
                DLOAD           DSU                             # GET PHI - ARCCOS OF Z-COMPONENT OF LOS
                                MPAC            +5

## Page 521
                                COS15DEG
R61LEM2         BMN             EXIT                            # BRANCH - PHI > 15 DEGREES
                                R61C+L05                        # PHI GRE 10DEG
                EBANK=          CDUXD
                CAF             EBANK6
                TS              EBANK
                INHINT
                EXTEND
                DCA             CPHI
                DXCH            CDUXD
                CA              CPSI
                TS              CDUZD
                RELINT
                EBANK=          LOSCOUNT
                CAF             EBANK7
                TS              EBANK
                TC              R61C+L06
R61C+L05        EXIT
                INHINT
                TC              IBNKCALL
                FCADR           ZATTEROR
                TC              IBNKCALL
                FCADR           SETMINDB                        # REDUCE ATTITUDE ERROR
                TC              DOWNFLAG
                ADRES           3AXISFLG
                TC              UPFLAG
                ADRES           PDSPFLAG                        # SET PRIORITY DISPLAY FLAG
                TC              BANKCALL
                CADR            R60LEM
                INHINT
                TC              IBNKCALL
                FCADR           RESTORDB
                TC              PHASCHNG
                OCT             04022
                TC              DOWNFLAG
                ADRES           PDSPFLAG                        # RESET PRIORITY DISPLAY FLAG
R61C+L06        CA              FLAGWRD1
                MASK            R61FLBIT
                CCS             A
                TC              R61C+L4
                CCS             R65CNTR
                TC              +2
                TC              R61C+L4                         # R65CNTR = 0 - EXIT ROUTINE
                TS              R65CNTR
                CAF             06SEC
                TC              TWIDDLE
                ADRES           R61C+L2
                TC              ENDOFJOB
R61C+L2         CAF             PRIO26
                TC              FINDVAC

## Page 522
                EBANK=          LOSCOUNT
                2CADR           R61C+L01
                TC              TASKOVER
R61C+L04        TC              BANKCALL                        # TO CONVERT ANGLES TO FDAI
                CADR            BALLANGS
                TC              R61C+L06
R61C+L4         CAE             GENRET
                TCF             BANKJUMP                        # EXIT R61
R61C+L1         CAF             BIT7+9PV                        # IS RENDEZVOUS OR P25FLAG SET
                MASK            STATE
                EXTEND
                BZF             ENDOFJOB                        # NO-EXIT ROUTINE AND PROGRAM.
                TC              R61C+L06                        # YES EXIT ROUTINE
R65WAIT         TC              POSTJUMP
                CADR            P20LEMWT


BIT7+9PV        OCT             00500
COS15DEG        2DEC            0.96593         B-1
06SEC           DEC             600
PHI             EQUALS          20D
READCDUD        INHINT                                          # READS DESIRED CDU'S AND STORES IN
                CAF             EBANK6                          # MPAC TP EXITS WITH MODE SET TO TP
                XCH             EBANK
                TS              RUPTREG1
                EBANK=          CDUXD
                CA              CDUXD
                TS              MPAC
                EXTEND
                DCA             CDUYD
                DXCH            MPAC            +1
                CA              RUPTREG1
                TS              EBANK
                RELINT
                TCF             TMODE
                BLOCK           02
                SETLOC          RADARFF
                BANK

                EBANK=          LOSCOUNT
                COUNT*          $$/RRSUB

## Page 523
# THE FOLLOWING SUBROUTINE RETURNS TO CALLER + 2 IF THE ABSOLUTE VALUE OF VALUE OF C(A) IS GREATER THAN THE
# NEGATIVE OF THE NUMBER AT CALLER +1. OTHERWISE IT RETURNS TO CALLER +3. MAY BE CALLED IN RUPT OR UNDER EXEC.

MAGSUB          EXTEND
                BZMF            +2
                TCF             +2
                COM

                INDEX           Q
                AD              0
                EXTEND
                BZMF            Q+2                             # ABS(A) <= CONST  GO TO L+3
                TCF             Q+1                             # ABS(A) >  CONST  GO TO L+2

## Page 524
# PROGRAM NAME_  RRLIMCHK                                                  ARE IN THE LIMITS OF THE CURRENT MODE.

# FUNCTIONAL DESCRIPTION_
# RRLIMCHK CHECKS RR DESIRED GIMBAL ANGLES TO SEE IF THEY ARE WITHIN
# THE LIMITS OF THE CURRENT MODE. INITIALLY THE DESIRED TRUNNION AND
# SHAFT ANGLES ARE STORED IN ITEMP1 AND ITEMP2. THE CURRENT RR
# ANTENNAE MODE (RADMODES BIT 12) IS CHECKED WHICH IS = 0 FOR
# MODE 1 AND =1 FOR MODE 2.
# MODE 1 - THE TRUNNION ANGLE IS CHECKED AT MAGSUB TO SEE IF IT IS
# BETWEEN -55 AND +55 DEGREES. IF NOT, RETURN TO L +2. IF WITHIN LIMITS,
# THE SHAFT ANGLE IS CHECKED TO SEE IF IT IS BETWEEN -70 AND +59 DEGREES.
# IF NOT, RETURN TO L +2. IF IN LIMITS, RETURN TO L +3.
# MODE 2 - THE SHAFT ANGLE IS CHECKED AT MAGSUB TO SEE IF IT IS
# BETWEEN -139 AND -25 DEGREES. IF NOT, RETURN TO L +2. IF WITHIN
# LIMITS, THE TRUNNION ANGLE IS CHECKED TO SEE IF IT IS BETWEEN +125
# AND -125 (+235) DEGREES. IF NOT, RETURN TO L +2. IF IN LIMITS, RETURN
# TO L +3.

# CALLING SEQUENCE:
# L  TC  RRLIMCHK (WITH INTERRUPT INHIBITED)
# L +1  ADRES  T,S  (DESIRED TRUNNION ANGLE ADDRESS)

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES, MODEA, MODEB (OR DESIRED TRUNNION AND SHAFT
# ANGLES ELSEWHERE IN CONSECUTIVE LOCATIONS - UNSWITCHED ERASABLE OR
# CURRENT EBANK).

# SUBROUTINES CALLED_  MAGSUB

# JOBS OR TASKS INITIATED_  NONE

# ALARMS_  NONE

# EXIT_  L + 2 (EITHER OR BOTH ANGLES NOT WITHIN LIMITS OF CURRENT MODE)
# L + 3 (BOTH ANGLES WITHIN LIMITS OF CURRENT MODE)

RRLIMCHK        EXTEND
                INDEX           Q
                INDEX           0
                DCA             0
                INCR            Q
                DXCH            ITEMP1
                LXCH            Q                               # L(CALLER +2) TO L.

                CAF             ANTENBIT                        # SEE WHICH MODE RR IS IN.
                MASK            RADMODES
                CCS             A
                TCF             MODE2CHK

                CA              ITEMP1                          # MODE 1 IS DEFINED AS

## Page 525
                TC              MAGSUB                          #     1. ABS(T) L 55 DEGS.
                DEC             -.30555                         #     2. ABS(S + 5.5 DEGS) L 64.5 DEGS
                TC              L                               #         (SHAFT LIMITS AT +59, -70 DEGS)

                CAF             5.5DEGS
                AD              ITEMP2                          # S
                TC              MAGSUB
                DEC             -.35833                         # 64.5 DEGS
                TC              L
                TC              RRLIMOK                         # IN LIMITS.

MODE2CHK        CAF             82DEGS                          # MODE 2 IS DEFINED AS
                AD              ITEMP2                          #     1. ABS(T) G 125 DEGS.
                TC              MAGSUB                          #     2. ABS(S + 82 DEGS) L 57 DEGS
                DEC             -.31667                         #         (SHAFT LIMITS AT -25, -139 DEGS)
                TC              L

                CA              ITEMP1
                TC              MAGSUB
                DEC             -.69444                         # 125 DEGS

RRLIMOK         INDEX           L
                TC              L                               # ( = TC 1 )

5.5DEGS         DEC             .03056
82DEGS          DEC             .45556

## Page 526
# PROGRAM NAME_  SETTRKF                                                  . IF EITHER:

# FUNCTIONAL DESCRIPTION_
# SETTRKF UPDATES THE TRACKER FAIL LAMP ON THE DSKY.                      HER THE ALT OR VEL INFORMATION.
# INITIALLY THE LAMP TEST FLAG (IMODES33 BIT 1) IS CHECKED.
# IF A LAMP TEST IS IN PROGRESS, THE PROGRAM EXITS TO L +1.
# IF NO LAMP TEST THE FOLLOWING IS CHECKED SEQUENTIALLY_
# 1) RR CDU:S BEING ZEROED, RR CDU OK, AND RR NOT IN
# AUTO MODE (RADMODES BITS 13, 7, 2).
# 2) LR VEL DATA FAIL AND NO LR POS DATA (RADMODES BITS
# 8,5)
# 3) NO RR DATA (RADMODES BIT 4)
# THE ABSENCE OF ALL THREE SIMULTANEOUSLY IN (1), THE PRESENCE OF BOTH
# IN (2), AND THE PRESENCE OF (3) RESULTS IN EITHER THE TRACKER FAIL
# LAMP (DSPTAB +11D BIT 8) BEING TURNED ON OR LEFT ON. OTHERWISE,
# THE TRACKER FAIL LAMP IS TURNED OFF OR IS LEFT OFF. THEREFORE, THE
# TRACKER FAIL LAMP IS TURNED ON IF_
# A ) RR CDU FAILED WITH RR IN AUTO MODE AND RR CDU:S NOT BEING ZEROED.
# B) N SAMPLES OF LR DATA COULD NOT BE TAKEN IN 2N TRIES WITH
# EITHER THE ALT OR VEL INFORMATION
# C) N SAMPLES OF RR DATA COULD NOT BE OBTAINED FROM 2N TRIES
# WITH EITHER THE AL

# CALLING SEQUENCE:
# L  TC  SETTRKF

# ERASABLE INITIALIZATION REQUIRED: IMODES33, RADMODES, DSPTAB +11D
# SUBROUTINES CALLED_  NONE

# JOBS OR TASKS INITIATED_  NONE

# ALARMS_  TRACKER FAIL LAMP

# EXIT_  L +1 (ALWAYS)                                                          ED.

SETTRKF         CAF             BIT1                            # NO ACTION IF DURING LAMP TEST.
                MASK            IMODES33
                CCS             A
                TC              Q

RRTRKF          CA              BIT8
                TS              L

                CAF             13,7,2                          # SEE IF CDU FAILED.
                MASK            RADMODES
                EXTEND
                BZF             TRKFLON                         # CONDITION 3 ABOVE.

RRCHECK         CAF             RRDATABT                        # SEE IF RR DATA FAILED.
                MASK            RADMODES

## Page 527
                CCS             A
TRKFLON         CA              L
                AD              DSPTAB          +11D            # HALF ADD DESIRED AND PRESENT STATES.
                MASK            L
                EXTEND
                BZF             TCQ                             # NO CHANGE.

FLIP            CA              DSPTAB          +11D            # CANT USE LXCH DSPTAB +11D (RESTART PROB)
                EXTEND
                RXOR            LCHAN
                MASK            POSMAX
                AD              BIT15
                TS              DSPTAB          +11D
                TC              Q

13,7,2          OCT             10102
ENDRMODF        EQUALS

## Page 528
# PROGRAM NAME_  RRTURNON

# FUNCTIONAL DESCRIPTION_

# RRTURNON IS THE TURN-ON SEQUENCE WHICH, ALONG WITH
# RRZEROSB, ZEROS THE CDU:S AND DETERMINES THE RR MODE.
# INITIALLY, CONTROL IS TRANSFERRED TO RRZEROSB FOR THE
# ACTUAL TURN-ON SEQUENCE. UPON RETURN THE PROGRAM
# WAITS 1 SECOND BEFORE REMOVING THE TURN-ON FLAG
# (RADMODES BIT1) SO THE REPOSITION ROUTINE WON:T
# INITIATE PROGRAM ALARM 00501. A CHECK IS THEN MADE
# TO SEE IF A PROGRAM IS USING THE RR (STATE BIT 7). IF
# SO, THE PROGRAM EXITS TO ENDRADAR SO THAT THE RR CDU
# FAIL FLAG (RADMODES BIT 7) CAN BE CHECKED BEFORE
# RETURNING TO THE WAITING PROGRAM. IF NOT, THE PROGRAM EXITS
# TO TASKOVER.

# CALLING SEQUENCE: WAITLIST TASK FROM RRAUTCHK IF THE RR POWER ON AUTO
# BIT (CHAN 33 BIT 2) CHANGES TO 0 AND NO PROGRAM WAS USING
# THE RR (STATE BIT 7).

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES, STATE

# SUBROUTINES CALLED_  RRZEROSB, FIXDELAY, TASKOVER, ENDRADAR

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE (SEE RRZEROSB)

# EXIT_   TASKOVER, ENDRADAR (WAITING PROGRAM)

                BANK            24
                SETLOC          P20S1
                BANK

                EBANK=          LOSCOUNT
                COUNT*          $$/RSUB
RRTURNON        TC              RRZEROSB
                TC              FIXDELAY                        # WAIT 1 SEC BEFORE REMOVING TURN ON FLAG
                DEC             100                             # SO A MONITOR REPOSITION WONT ALARM.
                CS              TURNONBT
                MASK            RADMODES
                TS              RADMODES
                TCF             TASKOVER

## Page 529
# PROGRAM NAME_  RRZEROSB

# FUNCTIONAL DESCRIPTION_
# RRZEROSB IS A CLOSED SUBROUTINE TO ZERO THE RR CDU:S,
# DETERMINE THE RR MODE, AND TURNS ON THE TRACKER FAIL
# LAMP IF REQUIRED. INITIALLY THE RR CDU ZERO BIT (CHAN 12
# BIT 1) IS SET. FOLLOWING A 20 MILLISECOND WAIT, THE LGC
# RR CDU COUNTERS (OPTY, OPTX) ARE SET = 0 AFTER
# WHICH THE RR CDU ZERO DISCRETE (CHAN 12 BIT 1) IS
# REMOVED. A 4 SECOND WAIT IS SET TO ALL THE RR CDU:S
# TO REPEAT THE ACTUAL TRUNNION AND SHAFT ANGLES. THE
# RR CDU ZERO FLAG (RADMODES BIT 13) IS REMOVED. THE
# CONTENTS OF OPTY IS THEN CHECKED TO SEE IF THE TRUNNION
# ANGLE IS LESS THAN 90 DEGREES. IF NOT, BIT 12 OF
# RADMODES IS SET = 1 TO INDICATE RR ANTENNA MODE 2.
# IF LESS THAN 90 DEGREES, BIT 12 OF RADMODES IS SET = 0 TO
# INDICATE RR ANTENNA MODE 1. SETTRKF IS THEN CALLED TO
# SEE IF THE TRACKER FAIL LAMP SHOULD BE TURNED ON.

# CALLING SEQUENCE: L  TC  RRZEROSB (FROM RRTURNON AND RRZERO)
# ERASABLE INITIALIZATION REQUIRED:
# RADMODES (BIT 13 SET), DSPTAB +11D

# SUBROUTINES CALLED_  FIXDELAY, MAGSUB, SETTRKF

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  TRACKER FAIL

# EXIT_  L +1 (ALWAYS)

RRZEROSB        EXTEND
                QXCH            RRRET
                CAF             BIT1                            # BIT 13 OF RADMODES MUST BE SET BEFORE
                EXTEND                                          # COMING HERE.
                WOR             CHAN12                          # TURN ON ZERO RR CDU
                TC              FIXDELAY
                DEC             2

                CAF             ZERO
                TS              CDUT
                TS              CDUS
                CS              ONE                             # REMOVE ZEROING BIT.
                EXTEND
                WAND            CHAN12
                TC              FIXDELAY
                DEC             1000                            # RESET FAIL INHIBIT IN 10 SECS - D.281

                CS              RCDU0BIT                        # REMOVE ZEROING IN PROCESS BIT.

## Page 530
                MASK            RADMODES
                TS              RADMODES

                CA              CDUT
                TC              MAGSUB
                DEC             -.5
                TCF             +3                              # IF MODE 2.

                CAF             ZERO
                TCF             +2
                CAF             ANTENBIT
                XCH             RADMODES
                MASK            -BIT12
                ADS             RADMODES

                TC              SETTRKF                         # TRACKER LAMP MIGHT GO ON NOW.

                TC              RRRET                           # DONE.

-BIT12          EQUALS          -1/8                            # IN SPROOT

## Page 531
# PROGRAM NAME_  DORREPOS
# FUNCTIONAL DESCRIPTION_
# DORREPOS IS A SEQUENCE OF TASKS TO DRIVE THE RENDEZVOUS RADAR
# TO A SAFE POSITION. INITIALLY SETRRECR IS CALLED WHERE THE RR
# ERROR COUNTERS (CHAN 12 BIT 2) ARE ENABLED AND LASTYCMD
# AND LASTXCMD SET = 0 TO INDICATE THE DIFFERENCE BETWEEN THE
# DESIRED STATE AND PRESENT STATE OF THE COMMANDS. THE RR
# TURN-ON FLAG (RADMODES BIT 1) IS CHECKED AND IF NOT PRESENT,
# PROGRAM ALARM 00501 IS REQUESTED BEFORE CONTINUING. IN EITHER
# CASE, FOLLOWING A 20 MILLISECOND WAIT THE PROGRAM CHECKS THE CURRENT
# RR ANTENNA MODE (RADMODES BIT 12). RRTONLY IS THEN CALLED
# TO DRIVE THE TRUNNION ANGLE TO 0 DEGREES IF IN MODE 1 AND TO 180
# DEGREES IF IN MODE 2. UPON RETURN, THE CURRENT RR ANTENNA
# MODE (RADMODES BIT 12) IS AGAIN CHECKED. RRSONLY IS THEN
# CALLED TO DRIVE THE SHAFT ANGLE TO 0 DEGREES IF IN MODE 1 AND TO
# -90 DEGREES IF IN MODE 2. IF DURING RRTONLY OR RRSONLY A
# REMODE HAS BEEN REQUESTED (RADMODES BIT 14), AND ALWAYS
# FOLLOWING COMPLETION OF RRSONLY, CONTROL IS TRANSFERRED TO
# REPOSRPT. HERE THE REPOSITION FLAG (RADMODES BIT 11) IS
# REMOVED. A CHECK IS THEN MADE ON THE DESIGNATE FLAG (RADMODES
# BIT 10). IF PRESENT, CONTROL IS TRANSFERRED TO BEGDES. IF NOT PRESENT
# INDICATING NO FURTHER ANTENNA CONTROL REQUIRED, THE RR ERROR
# COUNTER BIT (CHAN 12 BIT 2) IS REMOVED AND THE ROUTINE EXITS TO
# TASKOVER.

# CALLING SEQUENCE:
# WAITLIST CALL FROM RRGIMON IF TRUNNION AND SHAFT CDU ANGLES
# NOT WITHIN LIMITS OF CURRENT MODE.

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES

# SUBROUTINES CALLED_
# RRTONLY, RRSONLY, BEGDES (EXIT)

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS-  NONE

# EXIT_  TASKOVER, BEGDES

DORREPOS        TC              SETRRECR                        # SET UP RR CDU ERROR COUNTERS.

# ALARM 501 DELETED IN DANCE 279 PER PCR 97.

                TC              FIXDELAY
                DEC             2

                CAF             ANTENBIT                        # MANEUVER TRUNNION ANGLE TO NOMINAL POS.

## Page 532
                MASK            RADMODES
                CCS             A
                CAF             BIT15                           # 0 FOR MODE 1 AND 180 FOR MODE 2.
                TC              RRTONLY

                CAF             ANTENBIT                        # NOW PUT SHAFT IN RIGHT POSITION
                MASK            RADMODES
                CCS             A
                CS              HALF                            # -90 FOR MODE 2.
                TC              RRSONLY

REPOSRPT        CS              REPOSBIT                        # RETURNS HERE FROM RR1AXIS IF REMODE
                                                                # REQUESTED DURING REPOSITION.
                MASK            RADMODES                        # REMOVE REPOSITION BIT.
                TS              RADMODES
                MASK            DESIGBIT                        # SEE IF SOMEONE IS WAITING TO DESIGNATE.
                CCS             A
                TCF             BEGDES
                CS              BIT2                            # IF NO FURTHER ANTENNA CONTROL REQUIRED,
                EXTEND                                          # REMOVE ERROR COUNTER ENABLE.
                WAND            CHAN12
                TCF             TASKOVER

SETRRECR        CAF             BIT2                            # SET UP RR ERROR COUNTERS.
                EXTEND
                RAND            CHAN12
                CCS             A                               # DO NOT CLEAR LAST COMMAND IF
                TC              Q                               # ERROR COUNTERS ARE ENABLED.

                TS              LASTYCMD
                TS              LASTXCMD
                CAF             BIT2
                EXTEND
                WOR             CHAN12                          # ENABLE RR CDU ERROR COUNTERS.
                TC              Q

## Page 533
# PROGRAM NAME_  REMODE                                                 IVES SHAFT TO -45, AND FINALLY DRIVES

# FUNCTIONAL DESCRIPTION_                                               S DONE WITH SINGLE AXIS ROTATIONS (SEE
# REMODE IS THE GENERAL REMODING SUBROUTINE. IT DRIVES THE
# TRUNNION ANGLE TO 0 DEGREES IF THE CURRENT MODE IS MODE 1,
# 180 DEGREES FOR MODE 2, THEN DRIVES THE SHAFT ANGLE TO -45
# DEGREES, AND FINALLY DRIVES THE TRUNNION ANGLE TO -130 DEGREES,
# TO PLACE THE RR IN MODE 2, -50 DEGREES FOR MODE 1, BEFORE
# INITIATING 2-AXIS CONTROL. ALL REMODING IS DONE WITH SINGLE
# AXIS ROTATIONS (RR1AXIS). INITIALLY THE RR ANTENNA MODE FLAG
# (RADMODES BIT 12) IS CHECKED. CONTROL IS THEN TRANSFERRED TO
# RRTONLY TO DRIVE THR TRUNNION ANGLE TO 0 DEGREES IF IN MODE 1
# OR 180 DEGREES IF IN MODE 2. RRSONLY IS THEN CALLED TO DRIVE
# THE SHAFT ANGLE TO -45 DEGREES. THE RR ANTENNA MODE FLAG
# (RADMODES BIT 12) IS CHECKED AGAIN. CONTROL IS AGAIN
# TRANSFERRED TO RRTONLY TO DRIVE THE TRUNNION ANGLE TO -130
# DEGREES TO PLACE THE RR IN MODE 2 IF CURRENTLY IN MODE 1 OR TO
# -50 DEGREES IF IN MODE 2 TO PLACE THE RR IN MODE 1. RMODINV
# IS THEN CALLED TO SET RADMODES BIT 12 TO INDICATE THE NEW
# RR ANTENNA MODE. THE REMODE FLAG (RADMODES BIT 14)
# IS REMOVED TO INDICATE THAT REMODING IS COMPLETE. THE PROGRAM
# THEN EXITS TO STDESIG TO BEGIN 2-AXIS CONTROL.

# CALLING SEQUENCE:
# FROM BEGDES WHEN REMODE FLAG (RADMODES BIT 14) IS SET.
# THIS FLAG MAY BE SET IN RRDESSM AND RRDESNB IF RRLIMCHK
# DETERMINES THAT THE DESIRED ANGLES ARE WITHIN THE LIMITS OF THE
# OTHER MODE.

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES

# SUBROUTINES CALLED_
# RRTONLY, RRSONLY, RMODINV (ACTUALLY PART OF)

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  STDESIG

REMODE          CAF             ANTENBIT                        # DRIVE TRUNNION TO 0 (180)
                MASK            RADMODES                        # (ERROR COUNTER ALREADY ENABLED)
                CCS             A
                CAF             BIT15
                TC              RRTONLY

                CAF             -45DEGSR
                TC              RRSONLY

## Page 534
                CS              RADMODES
                MASK            ANTENBIT
                CCS             A
                CAF             -80DEGSR                        # GO TO T = -130 (-50).
                AD              -50DEGSR
                TC              RRTONLY

                CS              RADMODES
                MASK            ANTENBIT
                CCS             A
                CAF             BIT15                           # GO TO T = -180 (+0).
                TC              RRTONLY

                CS              RADMODES                        # GO TO S = -90 (+0).
                MASK            ANTENBIT
                CCS             A
                CS              HALF
                TC              RRSONLY

                TC              RMODINV

                CS              REMODBIT                        # END OF REMODE.
                MASK            RADMODES
                TS              RADMODES

                CAF             DESIGBIT                        # WAS REMODE CALLED DURING DESIGNATE?
                MASK            RADMODES                        # (BIT10 RADMODES = 1)
                EXTEND
                BZF             RGOODEND                        # NO-RETURN TO CALLER WAITING IN RADSTALL
                TC              STDESIG                         # YES - RETURN TO DESIGNATE
-45DEGSR        =               13,14,15
-50DEGSR        DEC             -.27778
-80DEGSR        DEC             -.44444

RMODINV         LXCH            RADMODES                        # INVERT THE MODE STATUS.
                CAF             ANTENBIT
                EXTEND
                RXOR            LCHAN
                TS              RADMODES
                TC              Q

## Page 535
# PROGRAM NAMES_  RRTONLY, RRSONLY

# FUNCTIONAL DESCRIPTION_
# RRTONLY AND RRSONLY ARE SUBROUTINES FOR DOING SINGLE AXIS
# RR MANEUVERS FOR REMODE AND REPOSITION. IT DRIVES TO
# WITHIN 1 DEGREE. INITIALLY, AT RR1AX2, THE REMODE AND REPOSITION
# FLAGS (RADMODES BITS 14, 11) ARE CHECKED. IF BOTH EXIST,
# THE PROGRAM EXITS TO REPOSRPT (SEE DORREPOS). THIS INDICATES
# THAT SOMEONE POSSIBLY REQUESTED A DESIGNATE (RADMODES BIT 10)
# WHICH REQUIRES A REMODE (RADMODES BIT 14) AND THAT A
# REPOSITION IS IN PROGRESS (RADMODES BIT 11). IF NONE
# OR ONLY ONE OF THE FLAGS EXIST, REMODE OR REPOSITION, MAGSUB
# IS CALLED TO SEE IF THE APPROPRIATE ANGLE IS WITHIN 1 DEGREE. IF YES,
# CONTROL RETURNS TO THE CALLING ROUTINE. IF NOT, CONTROL IS
# TRANSFERRED TO RROUT FOR SINGLE AXIS MANEUVERS WITH THE OTHER
# ANGLE SET = 0. FOLLOWING A .5 SECOND WAIT, THE ABOVE PROCEDURE IS
# REPEATED.

# CALLING SEQUENCE: L-1 CAF *ANGLE*  (DESIRED ANGLE SCALED PI)
# L  TC  RRTONLY (TRUNNION ONLY)
# RRSONLY (SHAFT ONLY)
# RRTONLY IS CALLED BY PREPOS29;
# RRTONLY AND RRSONLY ARE CALLED BY DORREPOS AND REMODE

# ERASABLE INITIALIZATION REQUIRED:
# C(A) = DESIRED ANGLE, RADMODES

# SUBROUTINES CALLED_
# FIXDELAY, REPOSRPT, MAGSUB, RROUT

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  REPOSRPT (REMODE AND REPOSITION FLAGS PRESENT - RADMODES
# BITS 14, 11)
# L+1 (ANGLE WITHIN ONE DEGREE OR RR OUT OF AUTO MODE)

RRTONLY         TS              RDES                            # DESIRED TRUNION ANGLE.
                CAF             ZERO
                TCF             RR1AXIS

RRSONLY         TS              RDES                            # SHAFT COMMANDS ARE UNRESOLVED SINCE THIS
                CAF             ONE                             # ROUTINE ENTERED ONLY WHEN T = 0 OR 180.

RR1AXIS         TS              RRINDEX
                EXTEND
                QXCH            RRRET
                TCF             RR1AX2

## Page 536
NXTRR1AX        TC              FIXDELAY
                DEC             50                              # 2 SAMPLES PER SECOND.

RR1AX2          CS              RADMODES                        # IF SOMEONE REQUESTES AS DESIGNATE WHICH
                MASK            PRIO22                          # REQUIRES A REMODE AND A REPOSITION IS IN
                EXTEND                                          # PROGRESS, INTERRUPT IT AND START THE
                BZF             REPOSRPT                        # REMODE IMMEDIATELY.

                CA              RDES
                EXTEND
                INDEX           RRINDEX
                MSU             CDUT
                TS              ITEMP1                          # SAVE ERROR SIGNAL.
                EXTEND
                MP              RRSPGAIN                        # TRIES TO NULL .7 OF ERROR OVER NEXT .5
                TS              L
                CA              RADMODES
                MASK            AUTOMBIT
                XCH             ITEMP1                          # STORE RR-OUT-OF-AUTO-MODE BIT.
                TC              MAGSUB                          # SEE IF WITHIN ONE DEGREE.
                DEC             -.00555                         # SCALED IN HALF-REVS.

                CCS             ITEMP1                          # NO.  IF RR OUT OF AUTO MODE, EXIT.
                TC              RRRET                           # RETURN TO CALLER.

                CCS             RRINDEX                         # COMMAND FOR OTHER AXIS IS ZERO.
                TCF             +2                              # SETTING A TO 0.
                XCH             L
                DXCH            TRUNNCMD
                TC              RROUT

                TCF             NXTRR1AX                        # COME BACK IN .5 SECONDS.

RRSPGAIN        DEC             .59062                          # NULL .7 ERROR IN .5 SEC.

## Page 537
# PROGRAM NAME_  RROUT                                                          RROR COUNTER SCALING. RROUT LIMITS THEM

# FUNCTIONAL DESCRIPTION_
# RROUT RECEIVES RR GYRO COMMANDS IN TANG, TANG +1 IN RR
# ERROR COUNTER SCALING. RROUT THEN LIMITS THEM AND
# GENERATES COMMANDS TO THE CDU TO ADJUST THE ERROR COUNTERS
# TO THE DESIRED VALUES. INITIALLY MAGSUB CHECKS THE MAGNITUDE OF
# THE COMMAND (SHAFT ON 1ST PASS) TO SEE IF IT IS GREATER THAN
# 384 PULSES. IF NOT, CONTROL IS TRANSFERRED TO RROUTLIM TO
# LIMIT THE COMMAND TO +384 OR -384 PULSES. THE DIFFERENCE IS
# THEN CALCULATED BETWEEN THE DESIRED STATE AND THE PRESENT STATE OF
# THE ERROR COUNTER AS RECORDED IN LASTYCMD AND LASTXCMD.
# THE RESULT IS STORED IN OPTXCMD (1ST PASS) AND OPTYCMD (2ND
# PASS). FOLLOWING THE SECOND PASS, FOR THE TRUNNION COMMAND, THE
# OCDUT AND OCDUS ERROR COUNTER DRIVE BITS (CHAN 14 BITS 12, 11)
# ARE SET. THIS PROGRAM THEN EXITS TO THE CALLING PROGRAM.

# CALLING SEQUENCE:
# L TC RROUT (WITH RUPT INHIBITED) RROUT IS CALLED BY
# RRTONLY, RRSONLY, AND DODES

# ERASABLE INITIALIZATION REQUIRED:
# TANG, TANG +1 (DESIRED COMMANDS), LASTYCMD, LASTXCMD
# (1ST PASS = 0), RR ERROR COUNTER ENAGLE SET (CHAN 12 BIT 2).

# SUBROUTINES CALLED_
# MAGSUB

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  L+1 (ALWAYS)                                                         SIRED VALUES. RUPT MUST BE INHIBITED.

RROUT           LXCH            Q                               # SAVE RETURN.
                CAF             ONE                             # LOOP TWICE.
RROUT2          TS              ITEMP2
                INDEX           A
                CA              TRUNNCMD
                TS              ITEMP1                          # SAVE SIGN OF COMMAND FOR LIMITING.

                TC              MAGSUB                          # SEE IF WITHIN LMITS.
-RRLIMIT        DEC             -384
                TCF             RROUTLIM                        # LIMIT COMMAND TO MAG OF 384.

SETRRCTR        CA              ITEMP1                          # COUNT OUT DIFFERENCE BETWEEN DESIRED
                INDEX           ITEMP2                          # STATE AND PRESENT STATE AS RECORDED IN
                XCH             LASTYCMD                        # LASTYCMD AND LASTXCMD
                COM

## Page 538
                AD              ITEMP1
                AD              NEG0                            # PREVENT +0 IN OUTCOUNTER
                INDEX           ITEMP2
                TS              CDUTCMD

                CCS             ITEMP2                          # PROCESS BOTH INPUTS.
                TCF             RROUT2

                CAF             PRIO6                           # ENABLE COUNTERS.
                EXTEND
                WOR             CHAN14                          # PUT ON CDU DRIVES S AND T
                TC              L                               # RETURN.

RROUTLIM        CCS             ITEMP1                          # LIMIT COMMAND TO ABS VAL OF 384.
                CS              -RRLIMIT
                TCF             +2
                CA              -RRLIMIT
                TS              ITEMP1
                TCF             SETRRCTR        +1

## Page 539
#          ROUTINE TO ZERO THE RR CDUS AND DETERMINE THE ANTENNA MODE.

RRZERO          CAF             BIT11+1                         # SEE IF MONITOR REPOSITION OR NOT IN AUTO
                MASK            RADMODES                        # IF SO, DONT RE-ZERO CDUS.
                CCS             A
                TCF             RADNOOP                         # (IMMEDIATE TASK TO RGOODEND).

                INHINT
                CS              RCDU0BIT                        # SET FLAG TO SHOW ZEROING IN PROGRESS.
                MASK            RADMODES
                AD              RCDU0BIT
                TS              RADMODES

                CAF             ONE
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           RRZ2
                CS              RADMODES                        # SEE IF IN AUTO MODE.
                MASK            AUTOMBIT
                CCS             A
                TCF             ROADBACK
                TC              ALARM                           # AUTO DISCRETE NOT PRESENT - TRYING
                OCT             510
ROADBACK        RELINT
                TCF             SWRETURN

RRZ2            TC              RRZEROSB                        # COMMON TO TURNON AND RRZERO.
                TCF             ENDRADAR

BIT11+1         OCT             02001

## Page 540
# PROGRAM NAME_  RRDESSM                                                        R (HALF-UNIT) IN RRTARGET. REMODES IF

# FUNCTIONAL DESCRIPTION_
# THIS INTERPRETIVE ROUTINE WILL DESIGNATE, IF DESIRED ANGLES ARE
# WITHIN THE LIMITS OF EITHER MODE, TO A LINE-OF SIGHT (LOS) VECTOR
# (HALF-UNIT) KNOWN WITH RESPECT TO THE STABLE MEMBER PRESENT
# ORIENTATION. INITIALLY THE IMU CDU:S ARE READ AND CONTROL
# TRANSFERRED TO SMNB TO TRANSFORM THE LOS VECTOR FROM STABLE
# MEMBER TO NAVIGATION BASE COORDINATES (SEE STG MEMO -699)
# RRANGLES IS THEN CALLED TO CALCULATE THE RR GIMBAL ANGLES,
# TRUNNION AND SHAFT, FOR BOTH THE PRESENT AND ALTERNATE MODE.
# RRLIMCHK IS CALLED TO SEE IF THE ANGLES CALCULATED FOR THE
# PRESENT MODE ARE WITHIN LIMITS.  IF WITHIN LIMITS, THE RETURN
# LOCATION IS INCREMENTED, INASMUCH AS NO VEHICLE MANEUVER IS
# REQUIRED, BEFORE EXITING TO STARTDES. IF NOT WITHIN LIMITS OF THE
# CURRENT MODE, TRYSWS IS CALLED. FOLLOWING INVERTING OF THE RR
# ANTENNA MODE FLAG (RADMODES BIT 12), RRLIMCHK IS CALLED
# TO SEE IF THE ANGLES CALCULATED FOR THE ALTERNATE MODE ARE WITHIN
# LIMITS. IF YES, THE RR ANTENNA MODE FLAG IS AGAIN INVERTED,
# THE REMODE FLAG (RADMODES BIT 14) SET, AND THE RETURN LOCATION
# INCREMENTED, TO INDICATE NO VEHICLE MANEUVER IS REQUIRED, BEFORE
# EXITING TO STARTDES. IF THESE ANGLES ARE NOT WITHIN LIMITS
# OF THE ALTERNATE MODE, THE RR ANTENNA MODE FLAG (RADMODES
# BIT 12) IS INVERTED BEFORE RETURNING DIRECTLY TO THE CALLING PROGRAM
# TO INDICATE THAT A VEHICLE MANEUVER IS REQUIRED.

# CALLING SEQUENCE:
# L  STCALL  RRTARGET  (LOS HALF-UNIT VECTOR IN SM COORDINATES)
# L+1  RRDESSM
# L+2  BASIC  (VEHICLE MANEUVER REQUIRED)
# L+3  BASIC  (NO VEHICLE MANEUVER REQUIRED)

# ERASABLE INITIALIZATION REQUIRED:
# RRTARGET, RADMODES

# SUBROUTINES CALLED_
# READCDUS, SMNB, RRANGLES, RRLIMCHK, TRYSWS (ACTUALLY
# PART OF), RMODINV

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  L+2 (NEITHER SET OF ANGLES ARE WITHIN LIMITS OF RELATED MODE)
# STARTDES (DESIGNATE POSSIBLE AT PRESENT VEHICLE ATTITUDE-RETURNS
# TO L+3 FROM STARTDES)                                                    CAN BE DONE IN PRESENT VEH ATTITUDE.

RRDESSM         STQ             CLEAR
                                DESRET

## Page 541
                                RRNBSW
                CALL                                            # COMPUTES SINES AND COSINES, ORDER Y Z X
                                CDUTRIG
                VLOAD           CALL                            # LOAD VECTOR AND CALL TRANSFORMATION
                                RRTARGET
                                *SMNB*

                CALL                                            # GET RR GIMBAL ANGLES IN PRESENT AND
                                RRANGLES                        # ALTERNATE MODE.
                EXIT

                INHINT
                TC              RRLIMCHK
                ADRES           MODEA                           # CONFIGURATION FOR CURRENT MODE.
                TC              +3                              # NOT IN CURRENT MODE
OKDESSM         INCR            DESRET                          # INCREMENT SAYS NO VEHICLE MANEUVER REQ.
                TC              STARTDES                        # SHOW DESIGNATE REQUIRED
                CS              FLAGWRD8
                MASK            SURFFBIT                        # CHECK IF ON LUNAR SURFACE (SURFFLAG=P22F
                EXTEND
                BZF             NORDSTAL                        # BRANCH-YES-CANNOT DESIGNATE IN MODE 2
                TC              TRYSWS


LUNDESCH        CS              FLAGWRD8                        # OVERFLOW RETURN FROM RRANGLES
                MASK            SURFFBIT                        # CHECK IF ON LUNAR SURFACE
                EXTEND
                BZF             NORDSTAL                        # BRANCH-YES-RETURN TO CALLER - ALARM 527
                CA              STATE
                MASK            RNDVZBIT
                CCS             A                               # TEST RNDVZFLG.
                TC              NODESSM                         # NOT ON MOON-CALL FOR ATTITUDE MANEUVER
                TCF             ENDOFJOB                        # ...BUT NOT IN R29.

## Page 542
# PROGRAM NAME_  STARTDES                                                 STORED AS A HALF-UNIT VECTOR IN RRTARGET

# FUNCTIONAL DESCRIPTION_                                                 CKON IS DESIRED. BIT14 OF RADMODES IS
# STARTDES IS ENTERED WHEN WE ARE READY TO BEGIN DESIGNATION.             OR REPOSITION OPERATION. IN THIS
# BIT 14 OF RADMODES IS ALREADY SET IF A REMODE IS REQUIRED.              THE REPOSITION WILL BE INTERRUPTED.
# AT THIS TIME, THE RR ANTENNA MAY BE IN A REPOSITION                     GINS.
# OPERATION. IN THIS CASE, IF A REMODE IS REQUIRED IT MAY HAVE
# ALREADY BEGUN BUT IN ANY CASE THE REPOSITION WILL BE INTERRUPTED.
# OTHERWISE, THE REPOSITION WILL BE COMPLETED BEFORE 2-AXIS
# DESIGNATION BEGINS. INITIALLY DESCOUNT IS SET = 60 TO INDICATE
# THAT 30 SECONDS WILL BE ALLOWED FOR THE RR DATA GOOD INBIT
# (CHAN 33 BIT 4) IF LOCK-ON IS DESIRED (STATE BIT 5). BIT 10
# OF RADMODES IS SET TO SHOW THAT A DESIGNATE IS REQUIRED.
# THE REPOSITION FLAG (RADMODES BIT 11) IS CHECKED. IF SET,
# THE PROGRAM EXITS TO L+3 OF THE CALLING PROGRAM (SEE RRDESSM
# AND RRDESNB). THE PROGRAM WILL BEGIN DESIGNATING TO THE DESIRED
# ANGLES FOLLOWING THE REPOSITION OR REMODE IF ONE WAS
# REQUESTED.  IF THE REPOSITION FLAG IS NOT SET, SETRRECR IS CALLED
# WHICH SETS THE RR ERROR COUNTER ENABLE BIT (CHAN 12 BIT 2)
# AND SETS LASTYCMD AND LASTXCMD = 0 TO INDICATE THE
# DIFFERENCE BETWEEN THE PRESENT AND DESIRED STATE OF THE ERROR
# COUNTERS. A 20 MILLISECOND WAITLIST CALL IS SET FOR BEGDES
# AFTER WHICH THE PROGRAM EXITS TO L+3 OF THE CALLING PROGRAM.

# CALLING SEQUENCE:
# FROM RRDESSM AND RRDESNB WHEN ANGLES WITHIN LIMITS.

# ERASABLE INITIALIZATION REQUIRED:
# RADMODES, (SEE DODES)

# SUBROUTINES CALLED_
# SETRRECR, WAITLIST

# JOBS OR TASKS INITIATED_
# BEGDES

# ALARMS_  NONE

# EXIT_  L+3 OF CALLING PROGRAM (SEE RRDESSM)
# L+2 OF CALLING PROGRAM (SEE RRDESNB)

STARTDES        INCR            DESRET
                CS              RADMODES
                MASK            DESIGBIT
                ADS             RADMODES
                MASK            REPOSBIT                        # SEE IF REPOSITIONING IN PROGRESS.
                CCS             A
                TCF             DESRETRN                        # ECTR ALREADY SET UP.

                TC              SETRRECR                        # SET UP ERROR COUNTERS.

## Page 543
                CAF             TWO
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           BEGDES
DESRETRN        CA              RADCADR                         # FIRST PASS THRU DESIGNATE
                EXTEND
                BZF             DESRTRN                         # YES   SET EXIT
                TC              ENDOFJOB                        # NO
DESRTRN         RELINT
                INCR            DESRET
                CA              DESRET
                TCF             BANKJUMP


NORDSTAL        CAF             ZERO                            # ZERO RADCADR TO WIPE  OUT ANYONE
                TS              RADCADR                         # WAITING IN RADSTALL SINCE WE ARE NOW
                TCF             DESRTRN                         # RETURNING TO P20 AND MAY DO NEW RADSTALL

## Page 544
#          SEE IF RRDESSM CAN BE ACCOMPLISHED AFTER A REMODE.

TRYSWS          TC              RMODINV                         # (NOTE RUPT INHIBIT)
                TC              RRLIMCHK                        # TRY DIFFERENT MODE.
                ADRES           MODEB
                TCF             NODESSM                         # VEHICLE MANEUVER REQUIRED.

                TC              RMODINV                         # RESET BIT12
                CAF             REMODBIT                        # SET FLAG FOR REMODE.
                ADS             RADMODES

                TCF             OKDESSM

NODESSM         TC              RMODINV                         # RE-INVERT MODE AND RETURN
                INCR            DESRET                          # TO CALLER +2
                TCF             NORDSTAL

MAXTRYS         DEC             60

## Page 545
#          DESIGNATE TO SPECIFIC RR GIMBAL ANGLES (INDEPENDENT OF VEHICLE MOTION). ENTER WITH DESIRED ANGLES IN
# TANG AND TANG +1.

RRDESNB         TC              MAKECADR
                TS              DESRET

                TC              DOWNFLAG                        # RESET FLAG TO PREVENT DODES FROM GOING
                ADRES           LOSCMFLG                        # BACK TO R21
                CA              MAXTRYS                         # SET TIME LIMIT COUNTER
                TS              DESCOUNT                        # FOR DESIGNATE
                INHINT                                          # SEE IF CURRENT MODE OK.
                TC              RRLIMNB                         # DO SPECIAL V41 LIMIT CHECK
                ADRES           TANG
                TCF             TRYSWN                          # SEE IF IN OTHER MODE.

OKDESNB         RELINT
                EXTEND
                DCA             TANG
                DXCH            TANGNB
                TC              INTPRET

                CALL                                            # GET LOS IN NB COORDS.
                                RRNB
                STORE           RRTARGET

                SET             EXIT
                                RRNBSW

                INHINT
                TCF             STARTDES        +1
TRYSWN          TC              RMODINV                         # SEE IF OTHER MODE WILL DO.
                TC              RRLIMNB                         # DO SPECIAL V41 LIMIT CHECK
                ADRES           TANG
                TCF             NODESNB                         # NOT POSSIBLE.

                TC              RMODINV
                CAF             REMODBIT                        # CALL FOR REMODE.
                ADS             RADMODES
                TCF             OKDESNB

NODESNB         TC              RMODINV                         # REINVERT MODE BIT.
                TC              ALARM                           # BAD INPUT ANGLES.
                OCT             502
                TC              CLRADMOD
                TC              ENDOFJOB                        # AVOID 503 ALARM.

RRLIMNB         INDEX           Q                               # THIS ROUTINE IS IDENTICAL TO RRLIMCHK
                CAF             0                               # EXCEPT THAT THE MODE 1 SHAFT LOWER
                INCR            Q                               # LIMIT IS -85 INSTEAD OF -70 DEGREES
                EXTEND

## Page 546
                INDEX           A                               # READ GIMBAL ANGLES INTO ITEMP STORAGE
                DCA             0
                DXCH            ITEMP1
                LXCH            Q                               # L(CALLER +2) TO L

                CAF             ANTENBIT                        # SEE WHICH MODE RR IS IN.
                MASK            RADMODES
                CCS             A
                TCF             MODE2CHK                        # MODE 2 CAN USE RRLIMCHK CODING
                CA              ITEMP1
                TC              MAGSUB                          # MODE 1 IS DEFINED AS
                DEC             -.30555                         #   1. ABS(T) L 55 DEGS
                TC              L                               #   2  SHAFT LIMITS AT +59, -85 DEGS

                CA              ITEMP2                          # LOAD SHAFT ANGLE
                EXTEND
                BZMF            NEGSHAFT                        # IF NEGATIVE SHAFT ANGLE, ADD 20.5 DEGS
                AD              5.5DEGS
SHAFTLIM        TC              MAGSUB
                DEC             -.35833                         # 64.5 DEGREES
                TC              L                               # NOT IN LIMITS
                TC              RRLIMOK                         # IN LIMITS
NEGSHAFT        AD              20.5DEGS                        # MAKE NEGATIVE SHAFT LIMIT -85 DEGREES
                TCF             SHAFTLIM


20.5DEGS        DEC             .11389

## Page 547
# PROGRAM NAME_  BEGDES

# FUNCTIONAL DESCRIPTION_
# BEGDES CHECKS VARIOUS DESIGNATE REQUESTS AND REQUESTS THE
# ACTUAL RR DESIGNATION. INITIALLY A CHECK IS MADE TO SEE IF A
# REMODE (RADMODES BIT 14) IS REQUESTED OR IN PROGRESS. IF SO,
# CONTROL IS TRANSFERRED TO STDESIG AFTER ROUTINE REMODE IS
# EXECUTED.  IF NO REMODE, STDESIG IS IMMEDIATELY CALLED WHERE
# FIRST THE REPOSITION FLAG (RADMODES BIT 11) IS CHECKED. IF
# PRESENT, THE DESIGNATE FLAG (RADMODES BIT 10) IS REMOVED
# AFTER WHICH THE PROGRAM EXITS TO RDBADEND. IF THE REPOSITION
# FLAG IS NOT PRESENT, THE CONTINUOUS DESIGNATE FLAG (RADMODES
# BIT 15) IS CHECKED. IF PRESENT, ON EXECUTIVE CALL IS IMMEDIATELY
# MADE FOR DODES AFTER WHICH A .5 SECOND WAIT IS INITIATED BEFORE
# REPEATING AT STDESIG. IF THE RR SEARCH ROUTINE (LRS24.1) IS DESIGNATING
# TO A NEW POINT (NEWPTFLG SET) THE CURRENT DESIGNATE TASK IS TERMINATED.
# IF CONTINUOUS DESIGNATE IS NOT WANTED, THE DESIGNATE FLAG (RADMODES
# BIT 10) IS CHECKED. IF NOT PRESENT, THE PROGRAM EXITS TO ENDRADAR TO
# CHECK RR CDU FAIL BEFORE RETURNING TO THE CALLING PROGRAM. IF DESIGNATE
# IS STILL REQUIRED, DESCOUNT IS CHECKED TO SEE IF THE 30 SECONDS HAS
# EXPIRED BEFORE RECEIVING THE RR DATA GOOD (CHAN 33 BIT 4)
# SIGNAL. IF OUT OF TIME, PROGRAM ALARM 00503 IS REQUESTED, THE
# RR AUTO TRACKER ENABLE AND RR ERROR COUNTER ENABLE
# (CHAN 12 BITS 14,2) BITS REMOVED, AND THE DESIGNATE FLAG
# (RADMODES BIT 10) REMOVED BEFORE EXITING TO RDBADEND. IF
# TIME HAS NOT EXPIRED, DESCOUNT IS DECREMENTED, THE
# EXECUTIVE CALL MADE FOR DODES, AND A .5 SECOND WAIT INITIATED
# BEFORE REPEATING THIS PROCEDURE AT STDESIG.

# CALLING SEQUENCE:
# WAITLIST CALL FROM STARTDES
# TCF BEGDES FROM DORREPOS
# TC STDESIG RETURNING, FROM REMODE

# ERASABLE INITIALIZATION REQUIRED:
# DESCOUNT, RADMODES

# SUBROUTINES CALLED_
# ENDRADAR, FINDVAC

# JOBS OR TASKS INITIATED_  DODES

# ALARMS_  PROGRAM ALARM 00503 (30 SECONDS HAVE EXPIRED) WITH NO RR DATA
# GOOD (CHAN 33 BIT 4) RECEIVED WHEN LOCK-ON (STATE BIT 5) WAS REQUESTED.

# EXIT_  TASKOVER (SEARCH PATTERN DESIGNATING TO NEW POINT)
# ENDRADAR (NO DESIGNATE - RADMODES BIT 10)
# RDBADEND (REPOSITION OR 30 SECONDS EXPIRED)

BEGDES          CS              RADMODES

## Page 548
                MASK            REMODBIT
                CCS             A
                TC              STDESIG
                TC              REMODE
DESLOOP         TC              FIXDELAY                        # 2 SAMPLES PER SECOND.
                DEC             50

STDESIG         CAF             REPOSBIT
                MASK            RADMODES                        # SEE IF GIMBAL LIMIT MONITOR HAS FOUND US
                CCS             A                               # OUT OF BOUNDS. IF SO, THIS BIT SHOWS A
                TCF             BADDES                          # REPOSITION TO BE IN PROGRESS.

                CCS             RADMODES                        # SEE IF CONTINUOUS DESIGNATE WANTED.
                TCF             +3                              # IF SO, DONT CHECK BIT 10 TO SEE IF IN
                TCF             +2                              # LIMITS BUT GO RIGHT TO FINDVAC ENTRY.
                TCF             MOREDES         +1

                CS              RADMODES                        # IF NON-CONTINUOUS, SEE IF END OF
                MASK            DESIGBIT                        # PROBLEM (DATA GOOD IF LOCK-ON WANTED OR
                CCS             A                               # WITHIN LIMITS IF NOT). IF SO, EXIT AFTER
                TCF             ENDRADAR                        # CHECKING RR CDU FAIL.

STDESIG1        CCS             DESCOUNT                        # SEE IF THE TIME LIMIT HAS EXPIRED
                TCF             MOREDES

                CS              B14+B2                          # IF OUT OF TIME, REMOVE ECR ENABLE + TRKR
                EXTEND
                WAND            CHAN12
BADDES          TC              DOWNFLAG
                ADRES           DESIGFLG
                TCF             RDBADEND

MOREDES         TS              DESCOUNT
                CAF             PRIO26                          # UPDATE GYRO TORQUE COMMANDS.
                TC              FINDVAC
                EBANK=          LOSCOUNT
                2CADR           DODES
                TCF             DESLOOP

B14+B2          OCT             20002

## Page 549
# PROGRAM NAME_  DODES

# FUNCTIONAL DESCRIPTION_
# DODES CALCULATES AND REQUESTS ISSUANCE OF RR GYRO TORQUE
# COMMANDS. INITIALLY THE CURRENT RR CDU ANGLES ARE STORED AND
# THE LOS HALF-UNIT VECTOR TRANSFORMED FROM STABLE MEMBER TO
# NAVIGATION BASE COORDINATES VIA SMNB IF NECESSARY. THE
# SHAFT AND TRUNNION COMMANDS ARE THEN CALCULATED AS FOLLOWS_
# + SHAFT = LOS  . (COS(S), 0, -SIN (S)) (DOT PRODUCT)
# -TRUNNION = LOS  . (SIN (T) SIN (S), COS (T), SIN (T) COS (S) )
# THE SIGN OF THE SHAFT COMMAND IS THEN REVERSED IF IN MODE 2
# (RADMODES BIT 12) BECAUSE A RELAY IN THE RR REVERSES THE
# POLARITY OF THE COMMAND. AT RRSCALUP EACH COMMAND IS
# SCALED AND IF EITHER, OR BOTH, OF THE COMMANDS IS GREATER THAN
# .5 DEGREES, MPAC +1 IS SET POSITIVE. IF A CONTINUOUS DESIGNATE
# (RADMODES BIT 15) IS DESIRED AND THE SEARCH ROUTINE IS NOT OPERATING,
# THE RR AUTO TRACKER ENABLE BIT (CHAN 12 BIT 14) IS CLEARED AND RROUT
# CALLED TO PUT OUT THE COMMANDS PROVIDED NO REPOSITION (RADMODES BIT 11)
# IS IN PROGRESS. IF A CONTINUOUS DESIGNATE AND THE SEARCH ROUTINE IS
# OPERATING (SRCHOPT FLAG SET) THE TRACK ENABLE IS NOT CLEARED. IF NO
# CONTINUOUS DESIGNATE AND BOTH COMMANDS ARE NOT LESS THAN .5 DEGREES AS
# INDICATED BY MPAC +1, THE RR AUTO TRACKER ENABLE BIT (CHAN 12 BIT 14) IS
# CLEARED AND RROUT CALLED TO PUT OUT THE COMMANDS PROVIDED NO REPOSITION
# (RADMODES BIT 11) IS IN PROGRESS. IF BOTH COMMANDS ARE LESS THAN .5
# DEGREES AS INDICATED BY MPAC+1, THE RR AUTO TRACKER ENABLE BIT
# (CHAN 12 BIT 14) IS CLEARED AND RROUT CALLED TO PUT OUT THE
# COMMANDS PROVIDED NO REPOSITION (RADMODES BIT 11) IS IN
# PROGRESS. IF BOTH COMMANDS ARE LESS THAN .5 DEGREES, THE
# LOCK-ON FLAG (STATE BIT 5) IS CHECKED. IF NOT PRESENT, THE
# DESIGNATE FLAG (RADMODES BIT 10) IS CLEARED, THE RR ERROR
# COUNTER ENABLE BIT (CHAN 12 BIT 2) IS CLEARED, AND ENDOFJOB
# CALLED. IF LOCK-ON IS DESIRED, THE RR AUTO TRACKER (CHAN 12
# BIT 14) IS ENABLED FOLLOWED BY A CHECK OF THE RECEIPT OF THE
# RR DATA GOOD (CHAN 33 BIT 4) SIGNAL. IF RR DATA GOOD
# PRESENT, THE DESIGNATE FLAG (RADMODES BIT 10) IS CLEARED,
# THE RR ERROR COUNTER ENABLE BIT (CHAN 12 BIT 2) IS CLEARED,
# AND ENDOFJOB CALLED. IF RR DATA GOOD IS NOT PRESENT, RROUT
# IS CALLED TO PUT OUT THE COMMANDS PROVIDED NO REPOSITION
# (RADMODES BIT 11) IS IN PROGRESS AFTER WHICH THE JOB IS TERMINATED
# VIA ENDOFJOB.

# CALLING SEQUENCE:
# EXECUTIVE CALL EVERY .5 SECONDS FROM BEGDES.

# ERASABLE INITIALIZATION REQUIRED:
# RRTARGET (HALF-UNIT LOS VECTOR IN EITHER SM OR NB COORDINATES),
# LOKONSW (STATE BIT 5), RRNBSW (STATE BIT 6), RADMODES

# SUBROUTINES CALLED_
# READCDUS, SMNB, CDULOGIC, MAGSUB, RROUT

## Page 550

# JOBS OR TASKS INITIATED_
# NONE

# ALARMS_  NONE

# EXIT_  ENDOFJOB (ALWAYS)

DODES           EXTEND
                DCA             CDUT
                DXCH            TANG

                TC              INTPRET

                SETPD           VLOAD
                                0
                                RRTARGET
                BON             VXSC
                                RRNBSW
                                DONBRD                          # TARGET IN NAV-BASE COORDINATES
                                MLOSV                           # MULTIPLY UNIT LOS BY MAGNITUDE
                VSL1            PDVL
                                LOSVEL
                VXSC            VAD                             # ADD ONE SECOND RELATIVE VELOCITY TO LOS
                                MCTOMS
                UNIT            CALL
                                CDUTRIG
                CALL
                                *SMNB*

DONBRD          STODL           32D
                                TANG            +1
                RTB             PUSH                            # SHAFT COMMAND = V(32D).(COS(S), 0,
                                CDULOGIC                        #      (-SIN(S)).
                SIN             PDDL                            # SIN(S) TO 0 AND COS(S) TO 2.
                COS             PUSH
                DMP             PDDL
                                32D
                                36D
                DMP             BDSU
                                0
                STADR
                STORE           TANG            +1              # SHAFT COMMAND

                SLOAD           RTB
                                TANG
                                CDULOGIC
                PUSH            COS                             # COS(T) TO 4.
                PDDL            SIN
                PUSH            DMP                             # SIN(T) TO 6.
                                2

## Page 551
                SL1             PDDL                            # DEFINE VECTOR U =  (SIN(T)SIN(S))
                                4                               #                    (COS(T)      )
                PDDL            DMP                             #                    (SIN(T)COS(S))
                                6
                                0
                SL1             VDEF
                DOT             EXIT                            # DOT U WITH LOS TO GET TRUNNION COMMAND.
                                32D

## Page 552
#          AT THIS POINT WE HAVE A ROTATION VECTOR IN DISH AXES LYING IN THE TS PLANE. CONVERT THIS TO A
# COMMANDED RATE AND ENABLE THE TRACKER IF WE ARE WITHIN .5 DEGREES OF THE TARGET.

                CS              MPAC                            # DOT WAS NEGATIVE OF DESIRED ANGLE.
                EXTEND
                MP              RDESGAIN                        # SCALING ON INPUT ANGLE WAS 4 RADIANS.
                TS              TRUNNCMD                        # TRUNNION COMMAND FOR RROUT
                CS              RADMODES                        # A RELAY IN THE RR REVERSES POLARITY OF
                MASK            BIT12                           # THE SHAFT COMMANDS IN MODE 2 SO THAT A
                EXTEND                                          # POSITIVE TORQUE APPLIED TO THE SHAFT
                BZF             +3                              # GYRO CAUSES A POSITIVE CHANGE IN THE
                CA              TANG            +1              # SHAFT ANGLE. COMPENSATE FOR THIS SWITCH
                TCF             +2                              # BY CHANGING THE POLARITY OF OUR COMMAND.
   +3           CS              TANG            +1
                EXTEND
                MP              RDESGAIN                        # SCALING ON INPUT ANGLE WAS 4 RADIANS.
                TS              SHAFTCMD                        # SHAFT COMMAND FOR RROUT
                TC              INTPRET

                DLOAD           DMP
                                2                               # COS(S).
                                4                               # COS(T).
                SL1             PDDL                            # Z COMPONENT OF URR.
                DCOMP           PDDL                            # Y COMPONENT = -SIN(T).
                                0                               # SIN(S).
                DMP             SL1
                                4                               # COS(T).
                VDEF            BON                             # FORM URR IN NB AXES.
                                RRNBSW                          # BYPASS NBSM CONVERSION IN VERB 41.
                                +3
                CALL
                                *NBSM*                          # GET URR IN SM AXES.
                DOT             EXIT
                                RRTARGET                        # GET COSINE OF ANGLE BETWEEN RR AND LOS.

                EXTEND
                DCS             COS1/2DG
                DAS             MPAC                            # DIFFERENCE OF COSINES, SCALED B-2.
                CCS             MPAC
                CA              ZERO                            # IF COS ERROR BIGGER, ERROR IS SMALLER.
                TCF             +2
                CA              ONE
                TS              MPAC            +1              # ZERO IF RR IS POINTED OK, ONE IF NOT.

## Page 553
# SEE IF TRACKER SHOULD BE ENABLED OR DISABLED.

                CCS             RADMODES                        # IF CONTINUOUS DESIGNATE WANTED, PUT OUT
                TCF             SIGNLCHK                        # COMMANDS WITHOUT CHECKING MAGNITUDE OF
                TCF             SIGNLCHK                        # ERROR SIGNALS
                TCF             DORROUT
SIGNLCHK        CCS             MPAC            +1              # SEE IF BOTH AXES WERE WITHIN .5 DEGS.
                TCF             DGOODCHK
                CS              STATE                           # IF WITHIN LIMITS AND NO LOCK-ON WANTED,
                MASK            LOKONBIT                        # PROBLEM IS FINISHED.
                CCS             A
                TCF             RRDESDUN

                CAF             BIT14                           # ENABLE THE TRACKER.
                EXTEND
                WOR             CHAN12

DGOODCHK        CAF             BIT4                            # SEE IF DATA GOOD RECEIVED YET
                EXTEND
                RAND            CHAN33
                CCS             A
                TCF             DORROUT

RRDESDUN        CS              BIT10                           # WHEN PROBLEM DONE, REMOVE BIT 10 SO NEXT
                MASK            RADMODES                        # WAITLIST TASK WE WILL GO TO RGOODEND.
                INHINT
                TS              RADMODES

                TC              DOWNFLAG                        # RESET LOSCMFLG TO PREVENT A
                ADRES           LOSCMFLG                        # RECOMPUTATION OF LOS AFTER DATA GOOD
                CS              BIT2                            # TURN OFF ENABLE RR ERROR COUNTER
                EXTEND
                WAND            CHAN12
                TCF             ENDOFJOB                        # WITH ECTR DISABLED.

DORROUT         CA              FLAGWRD2                        # IF BOTH LOSCMFLAG AND SEARCH FLAG ARE
                MASK            BIT12,14                        # ZERO, BYPASS VELOCITY ADJUSTMENT TO LOS
                EXTEND
                BZF             NOTP20
                TC              INTPRET
                VLOAD           VXSC                            # MULTIPLY UNIT LOS BY MAGNITUDE
                                RRTARGET
                                MLOSV
                VSL1            PUSH
                VLOAD           VXSC                            # ADD .5 SEC. OF VELOCITY
                                LOSVEL                          # TO LOS VECTOR
                                MCTOMS
                VSR1            VAD
                UNIT
                STODL           RRTARGET                        # STORE VELOCITY-CORRECTED LOS (UNIT)

## Page 554
                                36D
                STORE           MLOSV                           # AND STORE MAGNITUDE
                EXIT
NOTP20          INHINT
                CS              RADMODES                        # PUT OUT COMMAND UNLESS MONITOR
                MASK            REPOSBIT                        # REPOSITION HAS TAKEN OVER.
                CCS             A
                TC              RROUT

                CA              FLAGWRD2
                MASK            LOSCMBIT                        # IF LOSCMFLG NOT SET, DON'T TEST
                EXTEND                                          # LOS COUNTER
                BZF             ENDOFJOB
                CCS             LOSCOUNT                        # TEST LOS COUNTER TO SEE IF TIME TO GET
                TC              DODESEND                        # A NEW LOS
                TC              KILLTASK                        # YES - KILL TASK WHICH SCHEDULES DODES
                CADR            DESLOOP         +2
                RELINT
                CCS             NEWJOB
                TC              CHANG1
                TC              BANKCALL
                CADR            R21LEM2


DODESEND        TS              LOSCOUNT
                TC              ENDOFJOB


RDESGAIN        DEC             .53624                          # TRIES TO NULL .5 ERROR IN .5 SEC.
BIT12,14        EQUALS          PRIO24                          # OCT 24000
COS1/2DG        2DEC            .999961923      B-2             # COSINE OF 0.5 DEGREES.
MCTOMS          2DEC            100             B-13

## Page 555
# RADAR READ INITIALIZATION

# RADAR DATA ARE READ BY A BANKCALL FOR THE APPROPRIATE LEAD-IN BELOW.

LRALT           TC              INITREAD        -1              # ONE SAMPLE PER READING.
ALLREAD         OCT             17

LRVELZ          TC              INITREAD
                OCT             16

LRVELY          TC              INITREAD
                OCT             15

LRVELX          TC              INITREAD
                OCT             14

RRRDOT          TC              INITREAD        -1
                OCT             12

RRRANGE         TC              INITREAD        -1
                OCT             11

# LRVEL IS THE ENTRY TO THE LR VELOCITY READ ROUTINE WHEN 5 SAMPLES ARE
# WANTED. ENTER WITH C(A)= 0,2,4 FOR LRVELZ,LRVELY,LRVELX RESP.

LRVEL           TS              TIMEHOLD                        # STORE VBEAM INDEX HERE MOMEMTARILY
                CAF             FIVE                            # SPECIFY FIVE SAMPLES
                INDEX           TIMEHOLD
                TCF             LRVELZ

## Page 556
 -1             CAF             ONE                             # ENTRY TO TAKE ONLY 1 SAMPLE.
INITREAD        INHINT

                TS              TIMEHOLD                        # GET DT OF MIDPOINT OF NOMINAL SAMPLING
                EXTEND                                          # INTERVAL (ASSUMES NO BAD SAMPLES WILL BE
                MP              BIT3                            # ENCOUNTERED).
                DXCH            TIMEHOLD

                CCS             A
                TS              NSAMP
                AD              ONE
# INSERT FOLLOWING INSTRUCTION TO GET 2N TRIES FOR N SAMPLES.
#               DOUBLE
                TS              SAMPLIM

                CAF             DGBITS                          # READ CURRENT VALUE OF DATA GOOD BITS.
                EXTEND
                RAND            CHAN33
                TS              OLDATAGD

                CS              ALLREAD
                EXTEND
                WAND            CHAN13                          # REMOVE ALL RADAR BITS

                INDEX           Q
                CAF             0
                TC              IBNKCALL
                CADR            RADSTART

                EXTEND
                DCA             TIME2
                DAS             TIMEHOLD                        # TIME OF NOMINAL MIDPOINT.

                CAF             ZERO
                TS              L
                DXCH            SAMPLSUM
                TCF             ROADBACK

DGBITS          OCT             230

## Page 557
# RADAR RUPT READER

# THIS ROUTINE STARTS FROM A RADARUPT. IT READS THE DATA $ LOTS MORE.

                SETLOC          RADARUPT
                BANK

                COUNT*          $$/RRUPT
RADAREAD        EXTEND                                          # MUST SAVE SBANK BECAUSE OF RUPT EXITS
                ROR             SUPERBNK                        # VIA TASKOVER (BADEND OR GOODEND.
                TS              BANKRUPT
                EXTEND
                QXCH            QRUPT

                EXTEND
                DCA             TTOGO                           # LOAD TIME TO TIG
                DXCH            TTOTIG                          # FOR R65 RADAR READING.

                CAF             SEVEN
                EXTEND
                RAND            CHAN13
                TS              DNINDEX
                EXTEND                                          # IF RADAR SELECT BITS ZERO,DO NOT STORE
                BZF             TRYCOUNT                        # DATA FOR DOWNLIST (ERASABLE PROBLEMS)
                CA              RNRAD
                INDEX           DNINDEX
                TS              DNRRANGE        -1
TRYCOUNT        CCS             SAMPLIM
                TCF             PLENTY
                TCF             NOMORE
                TC              ALARM
                OCT             520
                TC              RESUME

NOMORE          CA              FLGWRD11                        # IS LRBYPASS SET?
                MASK            LRBYBIT
                EXTEND
                BZF             BADRAD                          # NO.  R12 IS ON -- BYPASS 521 ALARM.

                CS              FLAGWRD3                        # CHECK R04FLAG.
                MASK            R04FLBIT                        # IF 1,R04 IS RUNNING. DO NOT ALARM-
                EXTEND
                BZF             BADRAD

                TC              ALARM                           # P20 WANTS THE ALARM.
                OCT             521
BADRAD          CS              ONE
                TS              SAMPLIM
                TC              RDBADEND        -2
PLENTY          TS              SAMPLIM

## Page 558
                CAF             BIT3
                EXTEND
                RAND            CHAN13                          # TO FIND OUT WHICH RADAR
                EXTEND
                BZF             RENDRAD

                TC              R77CHECK                        # R77 QUITS HERE.
VELCHK          CAF             BIN3                            # = 00003 OCT
                EXTEND
                RXOR            CHAN13                          # RESET ACTIVITY BIT
                MASK            BIN3
                EXTEND
                BZF             LRHEIGHT                        # TAKE A LR RANGE READING

                CAF             POSMAX
                MASK            RNRAD
                AD              LVELBIAS
                TS              L
                CAE             RNRAD
                DOUBLE
                MASK            BIT1
                DXCH            ITEMP3

                CAF             BIT8                            # DATA GOOD ISNT CHECKED UNTIL AFTER READ-
                TC              DGCHECK                         # ING DATA SO SOME RADAR TESTS WILL WORK
                                                                # INDEPENDENT OF DATA GOOD.

                CCS             NSAMP
                TC              NOEND
GOODRAD         CS              ONE
                TS              SAMPLIM
                CS              ITEMP1                          # WHEN ENOUGH GOOD DATA HAS BEEN GATHERED,
                MASK            RADMODES                        # RESET DATA FAIL FLAGS FOR SETTRKF.
                TS              RADMODES
                TC              RADLITES                        # LAMPS MAY GO OFF IF DATA JUST GOOD.
                TC              RGOODEND        -2

NOEND           TS              NSAMP
RESAMPLE        CCS             SAMPLIM                         # SEE IF ANY MORE TRIES SHOULD BE MADE.
                TCF             +2
                TCF             DATAFAIL                        # N SAMPLES NOT AVAILABLE.
                CAF             BIT4                            # RESET ACTIVITY BIT.
                TC              IBNKCALL
                CADR            RADSTART

                TC              RESUME


LRHEIGHT        CAF             BIT5
                TS              ITEMP1                          # (POSITION OF DATA GOOD BIT IN CHAN 33)

## Page 559

                CAF             BIT9
                TC              SCALECHK        -1

RENDRAD         CAF             REPOSBIT                        # MAKE SURE ANTENNA HAS NOT GONE OUT OF
                MASK            RADMODES                        # LIMITS.
                CCS             A
                TCF             BADRAD

                CS              RADMODES                        # BE SURE RR CDU HASNT FAILED.
                MASK            RCDUFBIT
                CCS             A
                TCF             BADRAD

                CAF             BIT4                            # SEE IF DATA HAS BEEN GOOD.
                TS              ITEMP1                          # (POSITION OF DATA GOOD BIT IN CHAN 33)

                CAF             BIT1                            # SEE IF RR RDOT.
                EXTEND
                RAND            CHAN13
                TS              Q                               # FOR LATER TESTING.
                CCS             A
                TCF             +2
                TCF             RADIN                           # NO SCALE CHECK FOR RR RDOT.
                CAF             BIT3
                TS              L

SCALECHK        EXTEND
                RAND            CHAN33                          # SCALE STATUS NOW
                XCH             L
                MASK            RADMODES                        # SCALE STATUS BEFORE
                EXTEND
                RXOR            LCHAN                           # SEE IF THEY DIFFER
                CCS             A
                TC              SCALCHNG                        # THEY DIFFER

RADIN           CAF             POSMAX
                MASK            RNRAD
                TS              ITEMP4

                CAE             RNRAD
                DOUBLE
                MASK            BIT1
                TS              ITEMP3

                CCS             Q                               # SEE IF RR RDOT.
                TCF             SCALADJ                         # NO, BUT SCALE CHANGING MAY BE NEEDED.

                EXTEND                                          # IF RR RANGE RATE, THROW OUT BIAS.
                DCS             RDOTBIAS
DASAMPL         DAS             ITEMP3

## Page 560
DGCHECK2        CA              ITEMP1                          # SEE THAT DATA HAS BEEN GOOD BEFORE AND
                TC              DGCHECK         +1              # AFTER TAKING SAMPLE.
                TC              GOODRAD

SCALCHNG        LXCH            RADMODES
                AD              BIT1
                EXTEND
                RXOR            LCHAN
                TS              RADMODES
                CAF             DGBITS                          # UPDATE LAST VALUE OF DATA GOOD BITS.
                EXTEND
                RAND            CHAN33
                TS              OLDATAGD
                TC              UPFLAG                          # SET RNGSCFLG
                ADRES           RNGSCFLG                        # FOR LRS24.1
                TCF             BADRAD

# R77 MUST IGNORE DATA FAILS SO AS NOT TO DISTURB THE ASTRONAUT.

R77CHECK        CS              FLAGWRD5
                MASK            R77FLBIT
                CCS             A
                TC              Q                               # NOT R77
                CS              BITS5,8                         # UPDATE LR DATA GOOD BITS IN RADMODES
                MASK            RADMODES
                TS              L
                CA              BITS5,8
                EXTEND
                RAND            CHAN33
                AD              L
                TS              RADMODES
                TC              RGOODEND        -2
BITS5,8         OCT             220

## Page 561
# THE FOLLOWING ROUTINE INCORPORATES RR RANGE AND LR ALT SCALE INFORMATION AND LEAVES DATA AT LO SCALE.

SCALADJ         CCS             L                               # L HAS SCALE INBIT FOR THIS RADAR.
                TCF             +2                              # ON HIGH SCALE.
                TCF             DGCHECK2

                CA              DNINDEX
                MASK            BIT3
                CCS             A
                TCF             LRSCK

                DXCH            ITEMP3
                DDOUBL
                DDOUBL
                DDOUBL
                DXCH            ITEMP3

                TCF             DGCHECK2

LRSCK           EXTEND
                DCA             ITEMP3
                DDOUBL
                DDOUBL
                TCF             DASAMPL


DGCHECK         TS              ITEMP1                          # UPDATE DATA GOOD BIT IN OLDATAGD AND
                EXTEND                                          # MAKE SURE IT WAS ON BEFORE AND AFTER THE
                RAND            CHAN33                          # SAMPLE WAS TAKEN BEFORE RETURNING. IF
                TS              L                               # NOT, GOES TO RESAMPLE TO TRY AGAIN. IF
                CS              ITEMP1                          # MAX NUMBER OF TRIES HAS BEEN REACHED,
                MASK            OLDATAGD                        # THE BIT CORRESPONDING TO THE DATA GOOD
                AD              L                               # WHICH FAILED TO APPEAR IS IN ITEMP1 AND
                XCH             OLDATAGD                        # CAN BE USED TO SET RADMODES WHICH VIA
                MASK            ITEMP1                          # SETTRKF SETS THE TRACKER FAIL LAMP.
                AD              L
                CCS             A                               # SHOULD BOTH BE ZERO.
                TC              RESAMPLE
                DXCH            ITEMP3                          # IF DATA GOOD BEFORE AND AFTER, ADD TO
                DAS             SAMPLSUM                        # ACCUMULATION.
                TC              Q

DATAFAIL        CS              ITEMP1                          # IN THE ABOVE CASE, SET RADMODES BIT
                MASK            RADMODES                        # SHOWING SOME RADAR DATA FAILED.
                AD              ITEMP1
                TS              RADMODES

                DXCH            ITEMP3                          # IF WE HAVE BEEN UNABLE TO GATHER N
                DXCH            SAMPLSUM                        # SAMPLES, USE LAST ONE ONLY.

## Page 562
                TC              RADLITES
                TCF             NOMORE

## Page 563
#          CODING TO PROTECT CHANNEL 13 WILL RADAR READ IS IN CRITICAL PERIOD


                SETLOC          C13BANK
                BANK

RADSTART        TS              Q
   +1           EXTEND
                READ            LOSCALAR                        # READ PRESENT TIME
                TS              L

                MASK            LOW5                            # ONLY THE LOW 5 BITS MATTER
                COM
                AD              BIT6                            # COMPUTE DELTA TIME TO NEXT T5 TICK
                MASK            LOW5
                TS              RADDEL

                AD              NEG2                            # IF A TICKING OF T5 IS NEAR, WAIT UNTIL
                EXTEND                                          # IT HAS TICKED.  THE MAX DELAY HERE WILL
                BZMF            RADSTART        +1              # BE 937.5 MICROSECONDS

                CA              Q
                EXTEND                                          # IT IS SAFE TO SET THE ACTIVITY BIT NOW
                WOR             CHAN13                          # BECAUSE OF THE ABOVE LOOP

                CS              L
                TS              RADTIME                         # SAVE NEGATIVE TIME OF READ
                TC              ISWRETRN


C13STAL1        TS              C13FSAV

                CA              BIT4
                EXTEND
                RAND            CHAN13
                EXTEND
                BZF             TCQSTAL                         # IF NO RADAR ACTIVITY, RETURN

C13SLOOP        NOOP                                            # *** NECESSARY TO PREVENT A TC TRAP ***
                EXTEND
                READ            LOSCALAR
                AD              RADTIME                         # COMPUTE DELTA T SINCE LAST RADAR READ
                AD              HALF
                AD              HALF                            # CORRECT FOR TIME OVERFLOW
                XCH             L

                CA              90MSCALR
                AD              RADDEL
                EXTEND
                SU              L

## Page 564
                EXTEND
                BZMF            TCQSTAL                         # FORBIDDEN  ZONE IS PAST, RETURN

                AD              -DTSCALR
                EXTEND
                BZMF            C13SLOOP                        # IN THE FORBIDDEN PERIOD, LOOP UNTIL O.K.

TCQSTAL         LXCH            Q                               # ALL IS WELL, RETURN
                CA              C13FSAV
                DTCF

90MSCALR        OCT             440                             # 90 MILLISEC IN SCALAR
-DTSCALR        OCT             77754                           # -5.9375 MS IN SCALAR

                SETLOC          FFTAG6
                BANK

C13STALL        CAF             PRIO36                          # PRIO36 = 36000 = FCADR (17,2000)
                XCH             FBANK
                TCF             C13STAL1

## Page 565

# THIS ROUTINE CHANGES THE LR POSITION, AND CHECKS THAT IT GOT THERE.

                SETLOC          P20S1
                BANK

                COUNT*          $$/RSUB
LRPOS2          INHINT

                CS              RADMODES
                MASK            LRPOSBIT                        # SHOW DESIRED LR POSITION IS 2
                ADS             RADMODES

                CAF             BIT7
                EXTEND
                RAND            CHAN33                          # SEE IF ALREADY THERE.
                EXTEND
                BZF             RADNOOP

                CAF             BIT13
                EXTEND
                WOR             CHAN12                          # COMMAND TO POSITION 2
                CAF             6SECS                           # START SCANNING FOR INBIT AFTER 7 SECS.
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           LRPOSCAN
                TC              ROADBACK

LRPOSNXT        TS              SAMPLIM
                TC              FIXDELAY                        # SCAN ONCE PER SECOND 15 TIMES MAX AFTER
                DEC             100                             # INITIAL DELAY OF 7 SECONDS.

                CAF             BIT7                            # SEE IF LR POS2 IS ON
                EXTEND
                RAND            CHAN33
                EXTEND
                BZF             LASTLRDT                        # IF THERE, WAIT FINAL SECOND FOR BOUNCE.

                CCS             SAMPLIM                         # SEE IF MAX TIME UP.
                TCF             LRPOSNXT

                CS              BIT13                           # IF TIME UP, DISABLE COMMAND AND ALARM.
                EXTEND
                WAND            CHAN12
                TCF             RDBADEND

RADNOOP         CAF             ONE                             # NO FURTHER ACTION REQUESTED.
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           RGOODEND

## Page 566
                TC              ROADBACK

LASTLRDT        CA              2SECS                           # WAIT TWO SECONDS AFTER RECEIPT OF INBIT
                TC              VARDELAY                        # TO WAIT FOR ANTENNA BOUNCE TO DIE OUT.

                CS              BIT13                           # REMOVE COMMAND
                EXTEND
                WAND            CHAN12
                TCF             RGOODEND

LRPOSCAN        CAF             FOURTEEN                        # SET UP FOR 15 SAMPLES.
                TCF             LRPOSNXT

6SECS           DEC             600

## Page 567
#          SEQUENCES TO TERMINATE RR OPERATIONS.

ENDRADAR        CAF             RCDUFBIT                        # PROLOG TO CHECK RR CDU FAIL BEFORE END.
                MASK            RADMODES
                CCS             A
                TCF             RGOODEND
                TCF             RDBADEND
 -2             CS              ZERO                            # RGOODEND WHEN NOT UNDER WAITLIST CONTROL
                TS              RUPTAGN

RGOODEND        CAF             TWO
                TC              POSTJUMP
                CADR            GOODEND

 -2             CS              ZERO                            # RDBADEND WHEN NOT UNDER WAITLIST.
                TS              RUPTAGN
RDBADEND        CAF             TWO
                TC              POSTJUMP
                CADR            BADEND

BIN3            EQUALS          THREE

## Page 568
# PROGRAM NAME_ LPS20.1 VECTOR EXTRAPOLATION AND LOS COMPUTATION
# MOD. NO.  2      BY  J.D. COYNE    SDC    DATE 12-7-66

# FUNCTIONAL DESCRIPTION_
# 1) EXTRAPOLATE THE LEM AND CSM VECTORS IN ACCORDANCE WITH THE TIME REFERED TO IN CALLER + 1.
# 2) COMPUTES THE LOS VECTOR TO THE CSM, CONVERTS IT TO STABLE MEMBER COORDINATES AND STORES IT IN RRTARGET.
# 3) COMPUTES THE MAGNITUDE OF THE LOS VECTOR AND STORES IT IN MLOSV


# CALLING SEQUENCE       CALL
#                               LPS20.1


# SUBROUTINES CALLED_

# LEMPREC,CSMPREC

# NORMAL EXIT_ RETURN TO CALLER + 2


# ERROR EXITS_ NONE


# ALARMS_ NONE

# OUTPUT_

# LOS VECTOR (HALF UNIT) IN SM COORDINATES STORED IN RRTARGET
# MAGNITUDE OF THE LOS VECTOR (METERS SCALED B-29) STORED IN MSLOV
# RRNBSW CLEARED


# INITIALIZED ERASEABLE

# TDEC1 MUST CONTAIN THE TIME FOR EXTRAPOLATION
# SEE ORBITAL INTEGRATION ROUTINE


# DEBRIS_

# MPAC DESTROYED BY THIS ROUTINE


                BANK            23
                SETLOC          P20S
                BANK

## Page 569
                COUNT*          $$/LPS20

LPS20.1         STQ             BOFF
                                LS21X
                                LOSCMFLG                        # LOSCMFLG = 0 MEANS NOT CALLED BY R21
                                LMINT                           # SO CALL LEMCONIC TO GET LM STATE
                BON                                             # IF IN R21 AND ON LUNAR SURFACE
                                SURFFLAG                        # DON'T CALL LEMCONIC
                                CSMINT
LMINT           CALL
                                LEMCONIC                        # EXTRAPOLATE LEM
                VLOAD
                                RATT
                STOVL           LMPOS                           # SAVE LM POSITION B-29
                                VATT
                STODL           LMVEL                           # SAVE LM VELOCITY B-7
                                TAT
CSMINT          STCALL          TDEC1
                                CSMCONIC                        #  EXTRAPOLATE CSM
                VLOAD           VSU                             # COMPUTE RELATIVE VELOCITY V(CSM) - V(LM)
                                VATT
                                LMVEL
                MXV             VSL1
                                REFSMMAT
                EXIT
                TC              KILLTASK                        # KILL THE TASK WHICH CALLS DODES SINCE
                CADR            DESLOOP         +2              # STORING INTO ERASEABLES DODES USES
                TC              INTPRET
                STOVL           LOSVEL
                                RATT
                VSU             BOFF
                                LMPOS
                                RNDVZFLG
                                NOTSHIFT
                BOVB
                                TCDANZIG
                VSL
                                9D
NOTSHIFT        UNIT            BOVB                            # IF OVERFLOW, RANGE MUST BE GREATER
                                526ALARM                        # THAN 400 N. M.
                MXV             VSL1
                                REFSMMAT                        # CONVERT TO STABLE MEMBER
                STODL           RRTARGET
                                36D                             # SAVE MAGNITUDE OF LOS VECTOR FOR
                STORE           MLOSV                           # VELOCITY CORRECTION IN DESIGNATE
                CLRGO
                                RRNBSW
                                LS21X

## Page 570
# PROGRAM NAME_ LPS20.2  400 NM RANGE CHECK
# MOD. NO. 2   BY J.D. COYNE   SDC    DATE 12-7-66


# FUNCTIONAL DESCRIPTION_

# COMPARES THE MAGNITUDE OF THE LOS VECTOR TO 400 NM


# CALLING SEQUENCE       CALL
#                               LPS20.2


# SUBROUTINES CALLED_ NONE


# NORMAL EXIT _ RETURN TO CALLER +1, MPAC EQ 0 (RANGE 400NM OR LESS.)


# ERROR EXITS _ RETURN TO CALLER +1, MPAC EQ 1 (RANGE GREATER THAN 400NM)


# ALARMS_ NONE


# OUTPUT_ NONE


# INITIALIZED ERASEABLE_

# PDL 36D MUST CONTAIN THE MAGNITUDE OF THE VECTOR
# DEBRIS

# MPAC DESTROYED BY THIS ROUTINE


                SETLOC          P20S1
                BANK
                COUNT*          $$/LPS20

LPS20.2         DLOAD           DSU
                                MLOSV                           # MAGNITUDE OF LOS
                                FHNM                            # OVER 400NM  _
                BPL
                                TOFAR
                SLOAD           RVQ
                                ZERO/SP
TOFAR           SLOAD           RVQ
                                ONE/SP
ONE/SP          DEC             1

## Page 571
FHNM            2DEC            740800          B-20            # 400 NAUTICAL MILES IN METERS B-20

## Page 572
# PROGRAM NAME: LRS22.1 (DATA READ SUBROUTINE 1)
# MOD. NO.: 1       BY:  P. VOLANTE  SDC           DATE:  11-15-66


# FUNCTIONAL DESCRIPTION

# 1) READS RENDEZVOUS RADAR RANGE AND RANGE-RATE,TRUNION AND SHAFT ANGLES,THREE CDU VALUES AND TIME. CONVERTS THIS
# DATA AND LEAVES IT FOR THE MEASUREMENT INCORPORATION ROUTINE (LSR22.3). CHECKS FOR THE RR DATA GOOD DISCRETE,FOR
# RR REPOSITION AND RR CDU FAIL

# 2) COMPARES RADAR LOS WITH LOS COMPUTED FROM STATE VECTORS TO SEE IF THEY ARE WITHIN THREE DEGREES


# CALLING SEQUENCE:  BANKCALL FOR LRS22.1


# SUBROUTINES CALLED:

#        RRRDOT   LPS20.1
#        RRRANGE  BANKCALL
#        RADSTALL CDULOGIC
#        RRNB     SMNB
# NORMAL EXIT: RETURN TO CALLER+1 WITH MPAC SET TO +0


# ERROR EXITS:  RETURN TO CALLER+1 WITH ERROR CODE STORED IN MPAC AS FOLLOWS:

#               00001-ERROR EXIT 1-RR DATA NO GOOD (NO RR DATA GOOD DISCRETE OR RR CDU FAIL OR RR REPOSITION)
#               00002-ERROR EXIT 2-RR LOS NOT WITHIN THREE DEGREES OF LOS COMPUTED FROM STATE VECTORS


# ALARMS:  521-COULD NOT READ RADAR DATA (RR DATA GOOD DISCRETE NOT PRESENT BEFORE AND AFTER READING THE RADAR)
#  (THIS ALARM IS ISSUED BY THE RADAREAD SUBROUTINE WHICH IS ENTERED FROM A RADARUPT)

# OUTPUT: RRLOSVEC - THE RR LINE-OF-SIGHT VECTOR (USED BY LRS22.2)-A HALF-UNIT VECTOR
#         RM- THE RR RANGE READING (TO THE CSM) DP, IN METERS SCALED B-29 (USED BY LRS22.2 AND LRS22.3)

#    ALL OF THE FOLLOWING OUTPUTS ARE USED BY LRS22.3:

#         RDOTM- THE RR RANGE-RATE READING,DP, IN METERS PER CENTISECOND, SCALED B-7
#         RRTRUN-RR TRUNION ANGLE,DP,IN REVOLUTIONS,SCALED B0
#         RRSHAFT-RR SHAFT ANGLE,DP,IN REVOLUTIONS,SCALED B0
#         AIG,AMG,AOG-THE CDU ANGLES,THREE SP WORDS
#         MKTIME-THE TIME OF THE RR READING,DP,IN CENTISECONDS


# ERASABLE INITIALIZATION REQUIRED:

#    RNRAD,THE RADAR READ COUNTER FROM WHICH IS OBTAINED:

## Page 573
#     1) RR RANGE SCALED 9.38 FT. PER BIT ON THE LOW SCALE AND 75.04 FT. PER BIT ON THE HIGH SCALE
#     2) RR RANGE RATE,SCALED .6278 FT./SEC. PER BIT

#    THE CDU ANGLES FROM CDUX,CDUY,CDUZ AND TIME1 AND TIME2


# DEBRIS:  LRS22.1X,A,L,Q,PUSHLIST

                BANK            32
                SETLOC          LRS22
                BANK
                COUNT*          $$/LRS22

LRS22.1         TC              MAKECADR
                TS              LRS22.1X
                TC              DOWNFLAG
                ADRES           RNGSCFLG
                INHINT
                CAF             BIT3
                EXTEND                                          # GET RR RANGE SCALE
                RAND            CHAN33                          # FROM CHANNEL 33 BIT 3
                TS              L
                CS              RRRSBIT
                MASK            RADMODES
                AD              L
                TS              RADMODES
                RELINT
READRDOT        TC              BANKCALL
                CADR            RRRDOT                          # READ RANGE-RATE (ONE SAMPLE)
                TC              BANKCALL
                CADR            RADSTALL                        # WAIT FOR DATA READ COMPLETION
                TCF             EREXIT1                         # COULD NOT READ RADAR-ERROR EXIT 1

                INHINT                                          # NO INTERRUPTS WHILE READING TIME AND CDU
                DXCH            TIMEHOLD                        # SET MARK TIME EQUAL TO THE MID-POINT
                DXCH            MPAC            +5              # TEMP BUFFER FOR DOWNLINK
                DXCH            SAMPLSUM                        # SAVE RANGE-RATE READING
                DXCH            RDOTMSAV
                EXTEND
                DCA             CDUY                            # SAVE ICDU ANGLES
                DXCH            MPAC            +3              # TEMP BUFFER FOR DOWNLINK
                CA              CDUX
                TS              MPAC            +2              # TEMP BUFFER FOR DOWNLINK
                EXTEND
                DCA             TIME2                           #  SAVE TIME
                DXCH            MPAC                            # SAVE TIME OF CDY READINGS IN MPAC
                EXTEND
                DCA             CDUT                            # SAVE TRUNION AND SHAFT ANGLES FOR RRNB
                DXCH            TANG

## Page 574
                RELINT
                TC              BANKCALL
                CADR            RRRANGE                         # READ RR RANGE (ONE SAMPLE)
                TC              BANKCALL
                CADR            RADSTALL                        # WAIT FOR READ COMPLETE
                TC              CHEXERR                         # CHECK FOR ERRORS DURING READ
                INHINT                                          # COPY CYCLE FOR MARK DATA ON DOWNLINK
                EXTEND
                DCA             DNRRANGE                        # RANGE,RANGE RATE (RAW DATA)
                DXCH            RANGRDOT
                DXCH            MPAC            +5
                DXCH            MKTIME                          # MARK TIME
                DXCH            MPAC            +3
                DXCH            AIG                             # CDUY, CDUZ
                EXTEND
                DCA             TANG                            # PRESERVE TANG
                DXCH            TANGNB                          # TRUNNION AND SHAFT ANGLES
                CA              MPAC            +2
                TS              AOG                             # CDUX
                TC              INTPRET
                STODL           20D                             # SAVE TIME OF CDU READINGS IN 20D
                                RDOTMSAV                        # CONVERT RDOT UNITS AND SCALING
                SL              DMPR                            # START WITH READING SCALED B-28, -.6278
                                14D                             # FT./SECOND PER BIT
                                RDOTCONV                        # END WITH METERS/CENTISECOND, B-7
                STORE           RDOTM
                SLOAD           RTB
                                TANG                            # GET TRUNION ANGLE
                                CDULOGIC                        # CONVERT TO DP ONES COMP. IN REVOLUTIONS
                STORE           RRTRUN                          # AND SAVE FOR TMI ROUTINE (LSR22.3)
                SLOAD           RTB
                                TANG            +1              # DITTO FOR SHAFT ANGLE
                                CDULOGIC
                STODL           RRSHAFT
                                SAMPLSUM
                DMP             SL2R                            # CONVERT UNITS AND SCALING OF RANGE
                                RANGCONV                        # PER BIT, END WITH METERS,SCALED -29
                STCALL          RM
                                RRNB                            # COMPUTE RADAR LOS USING RRNB
                STODL           RRBORSIT                        # AND SAVE
                                20D
                STCALL          TDEC1                           # GET STATE VECTOR LOS AT TIME OF CDU READ
                                LPS20.1
                EXIT
                CA              AIG                             # STORE IMU CDU ANGLES AT MARKTIME
                TS              CDUSPOT                         # IN CDUSPOT FOR TRG*SMNB
                CA              AMG
                TS              CDUSPOT         +2
                CA              AOG
                TS              CDUSPOT         +4

## Page 575
                TC              INTPRET
                VLOAD           CALL                            # LOAD VECTOR AND CALL TRANSFORMATION
                                RRTARGET
                                TRG*SMNB                        # ROTATE LOS AT MARKTIME FROM SM TO NB.
                DOT                                             # DOT WITH RADAR LOS TO GET ANGLE
                                RRBORSIT
                SL1             ACOS                            # BETWEEN THEM
                STORE           DSPTEM1                         # STORE FOR POSSIBLE DISPLAY
                DSU             BMN                             # IS IT LESS THAN 3 DEGREES
                                THREEDEG
                                NORMEXIT                        # YES-NORMAL EXIT

                EXIT                                            # ERROR EXIT 2
                CAF             BIT2                            # SET ERROR CODE
                TS              MPAC
                TCF             OUT22.1

NORMEXIT        EXIT                                            # NORMAL EXIT-SET MPAC EQUAL ZERO
                CAF             ZERO
                TS              MPAC
OUT22.1         CAE             LRS22.1X                        # EXIT FROM LRS22.1
                TC              BANKJUMP
CHEXERR         CAE             FLAGWRD5
                MASK            RNGSCBIT
                CCS             A                               # CHECK IF RANGE SCALE CHANGED
                TCF             READRDOT                        # YES-TAKE ANOTHER READING

EREXIT1         CA              BIT1                            # SET ERROR CODE
                TS              MPAC
                TC              OUT22.1
THREEDEG        2DEC            .008333333                      # THREE DEGREES,SCALED REVS,B0
RRLOSVEC        EQUALS          RRTARGET

## Page 576
# PROGRAM NAME - LRS22.2 (DATA READ SUBROUTINE 2)


# MOD. NO.: 1        BY: P VOLANTE  SDC           DATE   4-11-67

# FUNCTIONAL DESCRIPTION-
#    2)  CHECKS IF THE RR LOS (I.E. THE RADAR BORESIGHT VECTOR) IS WITHIN 30 DEGREES OF THE LM +Z AXIS


# CALLING SEQUENCE- BANKCALL FOR LRS22.2


# SUBROUTINES CALLED: G+N,AUTO   SETMAXDB
# NORMAL EXIT - RETURN TO CALLER WITH MPAC SET TO +0 (VIA SWRETURN)


# ERROR EXIT -  RETURN TO CALLER WITH MPAC SET TO 00001 -RADAR LOS NOT WITHIN 30 DEGREES OF LM +Z AXIS


# ALARMS - NONE                                                             IN THE AUTO MODE


# ERASABLE INITIALIZATION REQUIRED -
#      RRLOSVEC - THE RR LINE-OF-SIGHT VECTOR-A HALF UNIT VECTOR COMPUTED BY LRS22.1
#      RM - RR RANGE, METERS B-29, FROM LRS22.1
#      BIT 14 CHANNEL 31 -INDICATES AUTOPILOT IS IN AUTO MODE


# DEBRIS -  A,L,Q MPAC -PUSHLIST AND PUSHLOC ARE NOT CHANGED BY THIS ROUTINE


                SETLOC          P20S
                BANK
LRS22.2         TC              MAKECADR
                TS              LRS22.1X
                TC              INTPRET
                                                                # CHECK IF RR LOS IS WITHIN 30 DEG OF
30DEGCHK        DLOAD           ACOS                            # THE SPACECRAFT +Z AXIS
                                RRBORSIT        +4              # BY TAKING ARCCOS OF Z-COMP. OF THE RR
                                                                # LOS VECTOR,A HALF UNIT VECTOR
                                                                # IN NAV BASE AXES)
                DSU             BMN
                                30DEG
                                OKEXIT                          # NORMAL EXIT-WITHIN 30 DEG.
                EXIT                                            # ERROR EXIT-NOT WITHIN 30 DEG.
                CAF             BIT1                            # SET ERROR CODE IN MPAC
                TS              MPAC
                TCF             OUT22.2
OKEXIT          EXIT                                            # NORMAL EXIT-SET MPAC = ZERO

## Page 577
                CAF             ZERO
                TS              MPAC
OUT22.2         CAE             LRS22.1X
                TC              BANKJUMP


30DEG           2DEC            .083333333                      # THIRTY DEGREES,SCALED REVS,B0

## Page 578
# PROGRAM NAME - LSR22.3                                                  DATE - 29 MAY 1967
# MOD. NO 3                                                               LOG SECTION - P20-25
# MOD. BY - DANFORTH                                                      ASSEMBLY LEMP20S REV 10
#
# FUNCTIONAL DESCRIPTION

# THIS ROUTINE COMPUTES THE B-VECTORS AND DELTA Q FOR EACH OF THE QUANTITIES MEASURED BY THE RENDEZVOUS
# RADAR.(RANGE,RANGE RATE,SHAFT AND TRUNNION ANGLES). THE ROUTINE CALLS THE INCORP1 AND INCORP2 ROUTINES
# WHICH COMPUTE THE DEVIATIONS AND CORRECT THE STATE VECTOR.

# CALLING SEQUENCE
# THIS ROUTINE IS PART OF P20 RENDEZVOUS NAVIGATION FOR THE LM COMPUTER O NLY. THE ROUTINE IS ENTERED FROM
# R22LEM  ONLY AND RETURNS DIRECTLY TO R22LEM  FOLLOWING SUCCESSFUL INCORPORATION OF MEASURED DATA. IF THE
# COMPUTED STATE VECTOR DEVIATIONS EXCEED THE MAXIMUM PERMITTED. THE ROUTINE RETURNS TO R22LEM  TO DISPLAY
# THE DEVIATIONS. IF THE ASTRONAUT ACCEPTS THE DATA R22LEM  RETURNS TO    LSR22.3 TO INCORPORATE THE
# DEVIATIONS INTO THE STATE VECTOR. IF THE ASTRONAUT REJECTS THE DEVIATIONS, NO MORE MEASUREMENTS ARE
# PROCESSED FOR THIS MARK,I.E.,R22LEM  GETS THE NEXT MARK.

#
# SUBROUTINES CALLED
#  WLINIT     LGCUPDTE     INTEGRV     INCORP1     ARCTAN
#  GETULC     RARARANG     INCORP2     NBSM        INTSTALL
#
# OUTPUT
#  CORRECTED LM OR CSM STATE VECTOR (PERMANENT)
#  NUMBER OF MARKS INCORPORATED IN MARKCTR
#  MAGNITUDE OF POSITION DEVIATION (FOR DISPLAY) IN R22DISP METERS B-29
#  MAGNITUDE OF VELOCITY DEVIATION (FOR DISPLAY) IN R22DISP +2 M/CSEC B-7
#  UPDATED W-MATRIX
#

# ERASABLE INITIALIZATION REQUIRED
#  LM AND CSM STATE VECTORS
#  W-MATRIX
#  MARK TIME IN MKTIME
#  RADAR RANGE IN RM METERS B-29
#        RANGE RATE IN RDOTM METERS/CSES B-7
#        SHAFT ANGLE IN RRSHAFT REVS.B0
#        TRUNNION ANGLE IN RRTRUN REVS. B0
#  GIMBAL ANGLES  INNER IN AIG
#                 MIDDLE IN AMG
#                 OUTER IN AOG
#  REFSMMAT
#  RENDWFLG
#  NOANGFLG
#  VEHUPFLG

# DEBRIS
#  PUSHLIST--ALL
#  MX, MY, MZ  (VECTORS)

## Page 579
#  ULC,RXZ,SINTHETA,LGRET,RDRET,BVECTOR,W.IND,X78T


                BANK            13
                SETLOC          P20S3
                BANK

                EBANK=          LOSCOUNT
                COUNT*          $$/LSR22
LSR22.3         CALL
                                GRP2PC
                BON             SET
                                SURFFLAG                        # ARE WE ON LUNAR SURFACE
                                LSR22.4                         # YES
                                DMENFLG
                BOFF            CALL
                                VEHUPFLG
                                DOLEM
                                INTSTALL
                CLEAR           CALL                            # LM PRECISION INTEGRATION
                                VINTFLAG
                                SETIFLGS
                CALL
                                INTGRCAL
                CALL
                                GRP2PC
                CALL
                                INTSTALL
                CLEAR           BOFF
                                DIM0FLAG
                                RENDWFLG
                                NOTWCSM
                SET             SET                             # CSM WITH W-MATRIX INTEGRATION
                                DIM0FLAG
                                D6OR9FLG
NOTWCSM         SET             CLEAR
                                VINTFLAG
                                INTYPFLG
                SET             CALL
                                STATEFLG
                                INTGRCAL
                GOTO
                                MARKTEST
DOLEM           CALL
                                INTSTALL
                SET             CALL
                                VINTFLAG
                                SETIFLGS
                CALL
                                INTGRCAL

## Page 580
                CALL
                                GRP2PC
                CALL
                                INTSTALL
                CLEAR           BOFF
                                DIM0FLAG
                                RENDWFLG
                                NOTWLEM
                SET             SET                             # LM WITH W-MATRIX INTEGRATION
                                DIM0FLAG
                                D6OR9FLG
NOTWLEM         CLEAR           CLEAR
                                INTYPFLG
                                VINTFLAG
                SET             CALL
                                STATEFLG
                                INTGRCAL
MARKTEST        BON             CALL                            # HAS W-MATRIX BEEN INVALIDATED
                                RENDWFLG                        # HAS W-MATRIX BEEN INVALIDATED
                                RANGEBQ
                                WLINIT                          # YES-REINITIALIZE
RANGEBQ         BON             EXIT                            # DON'T CALL R65 IF ON SURFACE
                                SURFFLAG
                                RANGEBQ1
                CA              ZERO
                TS              R65CNTR
                TC              BANKCALL
                CADR            R65LEM
                TC              INTPRET
RANGEBQ1        AXT,2           BON                             #  CLEAR X2
                                0
                                LMOONFLG                        # IS MOON SPHERE OF INFLUENCE
                                SETX2                           # YES. STORE ZERO IN SCALSHFT REGISTER
                INCR,2
                                2
SETX2           SXA,2           CALL
                                SCALSHFT                        # 0-MOON. 2-EARTH
                                GRP2PC
                AXT,1           SXA,1                           # STORE RANGE CODE (1) FOR R3 IN NOUN 49
                                1
                                WHCHREAD
                SLOAD           SR                              # GET SINGLE PRECISION RVARMIN (B-12)
                                RVARMIN                         # SHIFT TO TRIPLE PRECISION    (B-40)
                                28D
                RTB
                                TPMODE                          # AND SAVE  IN 20D
                STORE           20D
                CALL                                            # BEGIN COMPUTING THE B-VECTORS,DELTAQ
                                GETULC                          # B-VECTORS FOR RANGE
                BON             VCOMP                           # B0, COMP. IF LM BEING CORRECTED

## Page 581
                                VEHUPFLG
                                +1
                STOVL           BVECTOR
                                ZEROVECS
                STORE           BVECTOR         +6              # B1
                STODL           BVECTOR         +12D            # B2
                                36D
                SRR*            BDSU
                                2,2                             # SHIFT FROM EARTH/MOON SPHERE TO B-29
                                RM                              # RM - (MAGNITUDE RCSM-RLM)
                SLR*
                                2,2                             # SHIFT TO EARTH/MOON SPHERE
                STODL           DELTAQ                          # EARTH B-29. MOON B-27
                                36D                             # RLC  B-29/B-27
                NORM            DSQ                             # NORMALIZE AND SQUARE
                                X1
                DMP             SR*
                                RANGEVAR                        # MULTIPLY BY RANGEVAR(B12) THEN
                                0               -2,1            # UNNORMALIZE
                SR*             SR*
                                0,1
                                0,2
                SR*             RTB
                                0,2
                                TPMODE
                STORE           VARIANCE                        # B-40
                DCOMP           TAD
                                20D                             #   B-40
                BMN             TLOAD
                                QOK
                                20D                             #   B-40
                STORE           VARIANCE
QOK             CALL
                                LGCUPDTE

                SSP             CALL
                                WHCHREAD
                DEC             2                               # STORE R-RATE CODE (2) FOR R3 IN NOUN 49
                                GRP2PC
                CALL                                            # B-VECTOR,DELTAQ FOR RANGE RATE
                                GETULC
                PDDL            SR*                             # GET RLC SCALED B-29/B-27
                                36D                             # AND SHIFT TO B-23
                                0               -4,2
                STOVL           36D                             # THEN STORE BACK IN 36D
                BON             VCOMP                           # B1, COMP. IF LM BEING CORRECTED
                                VEHUPFLG
                                +1
                VXSC
                                36D                             # B1 = RLC  (B-24/B-22)

## Page 582
                STOVL           BVECTOR         +6
                                NUVLEM
                VSR*            VAD
                                6,2                             # SHIFT FOR EARTH/MOON SPHERE
                                VCVLEM                          # EARTH B-7. MOON B-5
                PDVL            VSR*                            # VL TO PD6
                                NUVCSM
                                6,2                             # SHIFT FOR EARTH/MOON SPHERE
                VAD             VSU
                                VCVCSM
                PDVL            DOT                             # VC - VL = VLC TO PD6
                                0
                                6
                PUSH            SRR*                            # RDOT B-8/B-6 TO PD12
                                2,2                             # SHIFT FROM EARTH/MOON SPHERE TO B-8
                DSQ             DMPR                            # RDOT**2 B-16 X RATEVAR B12
                                RATEVAR
                STORE           VARIANCE
                SLOAD           SR
                                VVARMIN                         # GET SINGLE PRECISION VVARMIN (B+12)
                                16D                             # SHIFT TO DP (B -4)
                STORE           24D                             # AND SAVE IN 24D
                DSU             BMN                             # IS MIN. VARIANCE > COMPUTED VARIANCE
                                VARIANCE
                                VOK                             # BRANCH - NO
                DLOAD                                           # YES - USE MINIMUM VARIANCE
                                24D
                STORE           VARIANCE
VOK             DLOAD           SR2                             # RDOT(PD12) FROM B-8/B-6
                PDDL            SLR*                            # TO B-10/B-8
                                RDOTM                           # SHIFT TO EARTH/MOON SPHERE
                                0               -1,2            # B-7 TO B-10/B-8
                DSU
                DMPR
                                36D
                STOVL           DELTAQ                          #   B-33
                                0                               # NOW GET B0
                VXV             VXV                             # (ULC X VLC) X ULC
                BON             VCOMP                           # B0, COMP. IF LM BEING CORRECTED
                                VEHUPFLG
                                +1
                VSR*
                                0               -2,2            # SCALED B-5
                STOVL           BVECTOR
                                ZEROVECS
                STORE           20D                             # ZERO OUT 20 TO 25 IN PUSHLIST
                STOVL           BVECTOR         +12D
                                BVECTOR
                ABVAL           NORM                            # LOAD B0, GET MAGNITUDE AND NORMALIZE
                                20D                             # SHIFT COUNT IN 20D

## Page 583
                VLOAD           ABVAL
                                BVECTOR         +6D             # LOAD B1, GET MAGNITUDE AND NORMALIZE
                NORM            DLOAD
                                22D                             # SHIFT COUNT IN 22D
                                22D                             # FIND WHICH SHIFT IS SMALLER
                DSU             BMN                             # BRANCH- B0 HAS SMALLER SHIFT COUNT
                                20D
                                VOK1
                LXA,1           GOTO
                                22D                             # LOAD X2 WITH THE SMALLER SHIFT COUNT
                                VOK2
VOK1            LXA,1
                                20D
VOK2            VLOAD           VSL*                            # THEN ADJUST B0,B1,DELTAQ AND VARIANCE
                                BVECTOR                         # WITH THIS SHIFT COUNT
                                0,1
                STOVL           BVECTOR
                                BVECTOR         +6
                VSL*
                                0,1
                STODL           BVECTOR         +6
                                DELTAQ
                SL*
                                0,1
                STORE           DELTAQ
                DLOAD           SL*                             # GET RLC AND ADJUST FOR SCALE SHIFT
                                36D
                                0               -1,1
                DSQ             DMP                             # MULTIPLY RLC**2 BY VARIANCE
                                VARIANCE
                SL4             RTB                             # SHIFT TO CONFORM TO BVECTORS AND DELTAQ
                                TPMODE
                STCALL          VARIANCE                        # AND STORE TP VARIANCE
                                LGCUPDTE

                CALL
                                GRP2PC
                BON             EXIT                            # ARE ANGLES TO BE DONE
                                SURFFLAG
                                RENDEND                         # NO
                EBANK=          AIG
MXMYMZ          CAF             AIGBANK
                TS              BBANK
                CA              AIG                             # YES, COMPUTE  MX, MY, MZ
                TS              CDUSPOT
                CA              AMG
                TS              CDUSPOT         +2
                CA              AOG
                TS              CDUSPOT         +4              # GIMBL ANGLES NOW IN CDUSPOT FOR TRG*NBSM
                TC              INTPRET

## Page 584
                VLOAD           CALL
                                UNITX
                                TRG*NBSM
                VXM             VSL1
                                REFSMMAT
                STOVL           MX
                                UNITY
                CALL
                                *NBSM*
                VXM             VSL1
                                REFSMMAT
                STOVL           MY
                                UNITZ
                CALL
                                *NBSM*
                VXM             VSL1
                                REFSMMAT
SHAFTBQ         STCALL          MZ
                                RADARANG
                SSP             VLOAD                           # STORE SHAFT CODE (3) FOR R3 IN NOUN 49
                                WHCHREAD
                DEC             3
                                ULC
                DOT             SL1
                                MX
                STOVL           SINTH                           # 18D
                                ULC
                DOT             SL1
                                MZ
                STCALL          COSTH                           # 16D
                                ARCTAN
                BDSU            DMP
                                RRSHAFT
                                2PI/8
                SL3R            PUSH
                DLOAD           SL3
                                X789
                SRR*            BDSU                            # SHIFT FROM -5/-3 TO B0
                                0,2
                DMP             SRR*
                                RXZ
                                0,1                             # SHIFT TO EARTH/MOON SPHERE
                STOVL           DELTAQ                          # EARTH B-29. MOON B-27
                                ULC
                VXV             VSL1
                                MY
                UNIT
                BOFF            VCOMP                           # B0, COMP. IF CSM BEING CORRECTED
                                VEHUPFLG
                                +1

## Page 585
                STOVL           BVECTOR
                                ZEROVECS
                STORE           BVECTOR         +6
                STODL           BVECTOR         +12D
                                RXZ
                SR*             SRR*                            # SHIFT FROM EARTH/MOON SPHERE TO B-25
                                0               -2,1
                                0,2
                STORE           BVECTOR         +12D
                SLOAD
                                SHAFTVAR
                DAD             DMP
                                IMUVAR                          # RAD**2 B12
                                RXZ
                SRR*            DMP
                                0,1                             # SHIFT TO EARTH/MOON SPHERE
                                RXZ
                SR*             SR*
                                0               -2,1
                                0,2
                SR*             RTB
                                0,2
                                TPMODE                          # STORE VARIANCE TRIPLE PRECISION
                STCALL          VARIANCE                        # B-40
                                LGCUPDTE

                CALL
                                GRP2PC
TRUNBQ          CALL
                                RADARANG
                SSP             VLOAD                           # STORE TRUNNION CODE (4) FOR R3 IN N49
                                WHCHREAD
                DEC             4
                                ULC
                VXV             VSL1
                                MY
                VXV             VSL1                            # (ULC X MY) X ULC
                                ULC
                BOFF            VCOMP                           # B0, COMP. IF CSM BEING CORRECTED
                                VEHUPFLG
                                +1
                STOVL           BVECTOR
                                ZEROVECS
                STORE           BVECTOR         +6
                STODL           BVECTOR         +12D
                                RXZ
                SR*             SRR*                            # SHIFT FROM EARTH/MOON SPHERE TO B-25
                                0               -2,1
                                0,2
                STORE           BVECTOR         +14D

## Page 586
                SLOAD
                                TRUNVAR
                DAD             DMP
                                IMUVAR
                                RXZ
                SRR*            DMP
                                0,1                             # SHIFT TO EARTH/MOON SPHERE
                                RXZ
                SR*             SR*
                                0               -2,1
                                0,2
                SR*             RTB
                                0,2
                                TPMODE                          # STORE VARIANCE TRIPLE PRECISION
                STODL           VARIANCE
                                SINTHETA
                ASIN            BDSU                            # SIN  THETA IN PD6
                                RRTRUN
                DMP             SL3R
                                2PI/8
                PDDL            SL3
                                X789            +2
                SRR*            BDSU                            # SHIFT FROM -5/-3 TO B0
                                0,2
                DMP             SRR*
                                RXZ
                                0,1
                STCALL          DELTAQ                          # EARTH B-29. MOON B-27
                                LGCUPDTE
                CALL
                                GRP2PC
RENDEND         GOTO
                                R22LEM93
# FUNCTIONAL DESCRIPTION
# LSR22.4 IS THE ENTRY TO PERFORM LUNAR SURFACE NAVIGATION FOR THE LM
# COMPUTER ONLY. THIS ROUTINE COMPUTES THE B-VECTORS AND DELTA Q FOR RANGE
# AND RANGE RATE MEASURED BY THE RENDEZVOUS RADAR

# SUBROUTINES CALLED
#  INSTALL   LGCUPDTE  INCORP1   RP-TO-R
#  INTEGRV   GETULC    INCORP2

# OUTPUT
#  CORRECTED CSM STATE VECTOR (PERMANENT)
#  NUMBER OF MARKS INCORPORATED IN MARKCTR
#  MAGNITUDE OF POSITION DEVIATION (FOR DISPLAY) IN R22 DISP METERS B-29
#  MAGNITUDE OF VELOCITY DEVIATION (FOR DISPLAY) IN R22DISP +2 M/CSEC B-7
#  UPDATED W-MATRIX

## Page 587
# ERASABLE INITIALIZATION REQUIRED
#  LM AND CSM STATE VECTORS
#  W-MATRIX
#  MARK TIME IN MKTIME
#  RADAR RANGE IN RM METERS B-29
#        RANGE RATE IN RDOTM METERS/CSEC B-7
#  VEHUPFLG


LSR22.4         CALL
                                INTSTALL
                SET             CLEAR
                                STATEFLG
                                VINTFLAG                        # CALL TO GET LM POS + VEL IN REF COORD.
                CALL
                                INTGRCAL
                CALL
                                GRP2PC
                CLEAR           CALL
                                DMENFLG                         # SET MATRIX SIZE TO 6X6 FOR INCORP
                                INTSTALL
                DLOAD           BHIZ                            # IS THIS FIRST TIME THROUGH
                                MARKCTR
                                INITWMX6                        # YES, INITIALIZE 6X6 W-MATRIX
                CLEAR           SET
                                D6OR9FLG
                                DIM0FLAG
                SET             CLEAR
                                VINTFLAG
                                INTYPFLG
                CALL
                                INTGRCAL
                GOTO
                                RANGEBQ


INITWMX6        CALL
                                WLINIT                          # INITIALIZE W-MATRIX
                SET             CALL
                                VINTFLAG
                                SETIFLGS
                CALL
                                INTGRCAL
                GOTO
                                RANGEBQ

# THIS ROUTINE CLEARS RFINAL (DP) AND CALLS INTEGRV

INTGRCAL        STQ             DLOAD
                                IGRET
                                MKTIME

## Page 588
                STCALL          TDEC1
                                INTEGRV
                GOTO
                                IGRET

# THIS ROUTINE INITIALIZES THE W-MATRIX BY ZEROING ALL W THEN SETTING
# DIAGONAL ELEMENTS TO INITIAL STORED VALUES.

                EBANK=          W
WLINIT          EXIT
                CAF             WBANK
                TS              BBANK
                CAF             WSIZE
                TS              W.IND
                CAF             ZERO
                INDEX           W.IND
                TS              W
                CCS             W.IND
                TC              -5
                CAF             AIGBANK                         # RESTORE EBANK 7
                TS              BBANK
                TC              INTPRET
                BON             SLOAD                           # IF ON LUNAR SURFACE,INITIALIZE WITH
                                SURFFLAG                        # WSURFPOS AND WSURFVEL INSTEAD OF
                                WLSRFPOS                        # WRENDPOS AND WRENDVEL
                                WRENDPOS
                GOTO
                                WPOSTORE
WLSRFPOS        SLOAD
                                WSURFPOS
WPOSTORE        SR                                              # SHIFT TO B-19 SCALE
                                5
                STORE           W
                STORE           W               +8D
                STORE           W               +16D
                BON             SLOAD
                                SURFFLAG
                                WLSRFVEL
                                WRENDVEL
                GOTO
                                WVELSTOR
WLSRFVEL        SLOAD
                                WSURFVEL
WVELSTOR        STORE           W               +72D
                STORE           W               +80D
                STORE           W               +88D
                SLOAD
                                WSHAFT
                STORE           W               +144D
                SLOAD

## Page 589
                                WTRUN
                STORE           W               +152D
                SET             SSP                             # SET RENDWFLG - W-MATRIX VALID
                                RENDWFLG
                                MARKCTR                         # SET MARK COUNTER EQUAL ZERO
                                0
                RVQ

                EBANK=          W
WBANK           BBCON           WLINIT
                EBANK=          AIG
AIGBANK         BBCON           LSR22.3

# GETULC

# THIS SUBROUTINE COMPUTES THE RELATIVE POSITION VECTOR BETWEEN THE CSM
# AND THE LM, LEAVING THE UNIT VECTOR IN THE PUSHLIST AND MPAC AND THE
# MAGNITUDE IN 36D.

GETULC          SETPD           VLOAD
                                0
                                DELTALEM
                LXA,2
                                SCALSHFT                        # LOAD X2 WITH SCALE SHIFT
                VSR*            VAD
                                9D,2                            # SHIFT FOR EARTH/MOON SPHERE
                                RCVLEM
                PDVL            VSR*
                                DELTACSM
                                9D,2                            # SHIFT FOR EARTH/MOON SPHERE
                VAD             VSU
                                RCVCSM
                RTB             PUSH                            # USE NORMUNIT TO PRESERVE ACCURACY
                                NORMUNX1
                STODL           ULC
                                36D
                SL*                                             # ADJUST MAGNITUDE FROM NORMUNIT
                                0,1
                STOVL           36D                             # ULC IN PD0 AND MPAC,RLC IN 36D
                                ULC
                RVQ
# RADARANG

# THIS SUBROUTINE COMPUTES SINTHETA = -ULC DOT MY
# RXZ = (SQRT (1-SINTHETA**2))RLC
# OUTPUT
#  ULC IN ULC, PD0
#  RLC IN PD36D
#  SIN THETA IN SINTHETA AND PD6
#  RXZ NORM IN RXZ (N IN X1)

## Page 590
RADARANG        STQ             CALL
                                RDRET
                                GETULC
                VCOMP           DOT
                                MY
                SL1R            PUSH                            # SIN THETA TO PD6
                STORE           SINTHETA
                DSQ             BDSU
                                DP1/4TH                         # 1 - (SIN THETA)**2
                SQRT            DMP
                                36D
                SL1             NORM
                                X1                              # SET SHIFT COUNTER IN X1
                STORE           RXZ
                GOTO                                            # EXIT
                                RDRET
LGCUPDTE        STQ             CALL
                                LGRET
                                INCORP1
                VLOAD           ABVAL
                                DELTAX          +6
                LXA,2           SRR*
                                SCALSHFT                        # 0-MOON. 2-EARTH
                                2,2                             # SET VEL DISPLAY TO B-7
                STOVL           R22DISP         +2
                                DELTAX
                ABVAL           SRR*
                                2,2                             # SET POS DISPLAY TO B-29
                STORE           R22DISP
                SLOAD           SR
                                RMAX
                                10D
                DSU             BMN
                                R22DISP
                                R22LEM96                        # GO DISPLAY
                SLOAD           DSU
                                VMAX
                                R22DISP         +2              # VMAX MINUS VEL. DEVIATION
                BMN
                                R22LEM96                        # GO DISPLAY
ASTOK           CALL
                                INCORP2
                GOTO
                                LGRET
IMUVAR          2DEC            E-6             B12             # RAD**2
WSIZE           DEC             161
2PI/8           2DEC            3.141592653     B-2
                EBANK=          LOSCOUNT

## Page 591

# PROGRAM NAME LRS24.1   RR SEARCH ROUTINE
# MOD NO  0        BY  P VOLANTE   SDC         DATE 1-15-67


# FUNCTIONAL DESCRIPTION

# DRIVES THE RENDEZVOUS RADAR IN A HEXAGONAL SEARCH PATTERN ABOUT THE LOS TO THE CSM (COMPUTED FROM THE CSM AND LM
# STATE VECTORS) CHECKING FOR THE DATA GOOD DISCRETE AND MONITORING THE ANGLE BETWEEN THE RADAR BORESIGHT AND THE
# LM +Z AXIS. IF THIS ANGLE EXCEEDS 30 DEGREES THE PREFERRED TRACKING ATTITUDE ROUTINE IS CALLED TO PERFORM AN
# ATTITUDE MANEUVER.


# CALLING SEQUENCE - BANKCALL FOR LRS24.1


# SUBROUTINES CALLED

#       LEMCONIC      R61LEM
#       CSMCONIC      RRDESSM
#       JOBDELAY      FLAGDOWN
#       WAITLIST      FLAGUP
#       RRNB          BANKCALL


# EXIT  - TO ENDOFJOB WHEN THE SEARCH FLAG (SRCHOPT) IS NOT SET


# OUTPUT

#     DATAGOOD (SP)-FOR DISPLAY IN R1- 00000 INDICATES NO LOCKON
#                                      11111 INDICATES LOCKON ACHIEVED
#     OMEGAD   (SP)-FOR DISPLAY IN R2- ANGLE BETWEEN RR BORESIGHT VECTOR AND THE SPACECRAFT +Z AXIS

# ERASABLE INITIALIZATION REQUIRED
#    SEARCH FLAG MUST BE SET
#    LM AND CSM STATE VECTORS AND REFSMMAT MATRIX
# DEBRIS

#    RLMSRCH      UXVECT
#    VXRLM        UYVECT
#    LOSDESRD     NSRCHPNT
#    DATAGOOD     OMEGAD
#    MPAC         PUSHLIST


                COUNT*          $$/LRS24
LRS24.1         CAF             ZERO
                TS              NSRCHPNT                        # SET SEARCH PATTERN POINT COUNTER TO ZERO
CHKSRCH         CAF             BIT14                           # ISSUE AUTO TRACK ENABLE TO RADAR
                EXTEND

## Page 592
                WOR             CHAN12
                CAF             SRCHOBIT                        # CHECK IF SEARCH STILL REQUESTED
                MASK            FLAGWRD2                        # (SRCHOPT FLAG SET)
                EXTEND
                BZF             ENDOFJOB                        # NO-TERMINATE JOB


                CAF             6SECONDS                        # SCHEDULE TASK TO DRIVE RADAR TO NEXT PT.
                INHINT
                TC              WAITLIST                        # IN 6 SECONDS
                EBANK=          LOSCOUNT
                2CADR           CALLDGCH
                RELINT
                CS              RADMODES                        # IS REMODE IN PROGRESS
                MASK            REMODBIT
                EXTEND
                BZF             ENDOFJOB                        # YES- WAIT SIX SECONDS
                TC              INTPRET

                RTB             DAD                             #  COMPUTE LOS AT PRESENT TIME + 1.5 SEC.
                                LOADTIME
                                1.5SECS
LRS24.11        STCALL          TDEC1
                                LEMCONIC                        # EXTRAPOLATE LM STATE VECTOR
                VLOAD
                                RATT
                STOVL           RLMSRCH                         # SAVE LEM POSITION
                                VATT
                STODL           SAVLEMV                         # SAVE LEM VELOCITY
                                TAT
                STCALL          TDEC1                           # EXTRAPOLATE CSM STATE VECTOR
                                CSMCONIC                        # EXTRAPOLATE CSM STATE VECTOR
                VLOAD           VSU                             # LOS VECTOR = R(CSM)-R(LM)
                                RATT
                                RLMSRCH
                UNIT
                STOVL           LOSDESRD                        # STORE DESIRED LOS
                                VATT                            # COMPUTE UNIT(V(CM) CROSS R(CM))
                UNIT            VXV
                                RATT
                UNIT
                STORE           VXRCM
                VLOAD           VSU
                                VATT
                                SAVLEMV
                MXV             VSL1                            # CONVERT FROM REFERENCE TO STABLE MEMBER
                                REFSMMAT
                STORE           SAVLEMV                         # VLC = V(CSM) - V(LM)
                SLOAD           BZE                             # CHECK IF N=0

## Page 593
                                NSRCHPNT
                                DESGLOS                         # YES-DESIGNATE ALONG LOS
                DSU             BZE                             # IS N=1
                                ONEOCT                          # YES-CALCULATE X AND Y AXES OF
                                CALCXY                          # SEARCH PATTERN COORDINATE SYSTEM
                VLOAD                                           # NO-ROTATE X-Y AXES TO NEXT SEARCH POINT
                                UXVECT
                STOVL           UXVECTPR                        # SAVE ORIGINAL X AND Y VECTORS
                                UYVECT                          # UXPRIME = ORIGINAL UX
                STORE           UYVECTPR                        # UYPRIME = ORIGINAL UY
                VXSC
                                SIN60DEG                        # UX =(COS 60)UXPR +(SIN 60)UYPR
                STOVL           UXVECT
                                UXVECTPR
                VXSC            VAD
                                COS60DEG
                                UXVECT
                UNIT
                STOVL           UXVECT
                                UXVECTPR                        # UY=(-SIN60)UXPR +(COS 60)UYPR
                VXSC
                                SIN60DEG
                STOVL           UYVECT
                                UYVECTPR
                VXSC            VSU
                                COS60DEG
                                UYVECT
                UNIT
                STORE           UYVECT
OFFCALC         VXSC            VAD                             # OFFSET VECTOR = K(UY)
                                OFFSTFAC                        # LOS VECTOR + OFFSET VECTOR DEFINES
                                LOSDESRD                        # DESIRED POINT IN SEARCH PATTERN
                UNIT            MXV
                                REFSMMAT                        # CONVERT TO STABLE MEMBER COORDINATES
                VSL1
CONTDESG        STOVL           RRTARGET
                                SAVLEMV
                STORE           LOSVEL
                EXIT
                INHINT
                TC              KILLTASK                        # KILL ANY PRESENTLY WAITLISTED TASK
                CADR            DESLOOP         +2              # WHICH WOULD DESIGNATE TO THE LAST
                                                                # POINT IN THE PATTERN
CONTDES2        CS              CDESBIT
                MASK            RADMODES                        # SET BIT 15 OF RADMODES TO INDICATE
                AD              CDESBIT                         # A CONTINUOUS DESIGNATE WANTED.
                TS              RADMODES
                TC              INTPRET

                CALL

## Page 594
                                RRDESSM                         # DESIGNATE RADAR TO RRTARGET VECTOR

                EXIT
                TC              LIMALARM                        # LOS NOT IN MODE 2 COVERAGE (P22)
                TC              LIMALARM                        # VEHICLE MANEUVER REQUIRED (P20)


                                                                # COMPUTE OMEGA,ANGLE  BETWEEN RR LOS AND
                                                                # SPACECRAFT +Z AXIS
OMEGCALC        EXTEND
                DCA             CDUT
                DXCH            TANGNB
                TC              INTPRET
                CALL
                                RRNB
                DLOAD           ACOS                            # OMEGA IS ARCCOSINE OF Z-COMPONENT OF
                                36D                             # VECTOR COMPUTED BY RRNB (LEFT AT 32D)
                STORE           OMEGDISP                        # STORE FOR DISPLAY IN R2
                EXIT
                TC              ENDOFJOB

## Page 595
# CALCULATE X AND Y VECTORS FOR SEARCH PATTERN COORDINATE SYSTEM


CALCXY          VLOAD           VXV
                                VXRCM
                                LOSDESRD
                UNIT
                STOVL           UXVECT                          # UX = (VLM X RLM) X LOS
                                LOSDESRD
                VXV             UNIT
                                UXVECT
                STORE           UYVECT                          # UY = LOS X UX
                GOTO
                                OFFCALC


DESGLOS         VLOAD           MXV                             # WHEN N= 0,DESIGNATE ALONG LOS
                                LOSDESRD
                                REFSMMAT                        # CONVERT LOS FROM REFERENCE TO SM COORDS
                VSL1            GOTO
                                CONTDESG


CALLDGCH        CAE             FLAGWRD0                        # IS RENDEZVOUS FLAG SET
                MASK            RNDVZBIT
                EXTEND
                BZF             TASKOVER                        # NO-EXIT R24
                CAF             PRIO25                          # YES -SCHEDULE JOB TO DRIVE RADAR TO NEXT
                TC              FINDVAC                         # POINT IN SEARCH PATTERN
                EBANK=          RLMSRCH
                2CADR           DATGDCHK
                TC              TASKOVER


DATGDCHK        CAF             BIT4
                EXTEND                                          # CHECK IF DATA GOOD DISCRETE PRESENT
                RAND            CHAN33
                EXTEND
                BZF             STORE1S                         # YES- GO TO STORE 11111 FOR DISPLAY IN R1
                CS              SIX
                AD              NSRCHPNT                        # IS N GREATER THAN 6
                EXTEND
                BZF             LRS24.1                         # YES - RESET N = 0 AND START AROUND AGAIN
                INCR            NSRCHPNT                        # NO-SET N = N+1 AN GO TO
                TCF             CHKSRCH                         # NEXT POINT IN PATTERN


STORE1S         CAF             ALL1S                           # STORE 11111 FOR DISPLAY IN R1
                TS              DATAGOOD

## Page 596
                INHINT
                TC              KILLTASK                        # DELETE DESIGNATE TASK FROM
                CADR            DESLOOP         +2              # WAITLIST USING KILLTASK
                TC              ENDOFJOB

LIMALARM        TC              ALARM                           # ISSUE ALARM 527-LOS NOT IN MODE2
                OCT             527                             # COVERAGE IN P22 OR VEHICLE MANEUVER
                INHINT                                          # REQUIRED IN P20
                TC              KILLTASK                        # KILL WAITLIST CALL FOR NEXT
                CADR            CALLDGCH                        # POINT IN SEARCH PATTERN
                TC              ENDOFJOB


ALL1S           DEC             11111
SIN60DEG        2DEC            .86603
COS60DEG        =               DPHALF                          # (2DEC   .50)
UXVECTPR        EQUALS          12D                             # PREVIOUS
UYVECTPR        EQUALS          18D
RLMUNIT         EQUALS          12D
OFFSTFAC        2DEC            0.05678                         # TANGENT OF 3.25 DEGREES
ONEOCT          OCT             00001                           # ****  NOTE-THESE TWO CONSTANTS MUST ****
3SECONDS        2DEC            300                             # ****  BE IN THIS ORDER BECAUSE      ****
                                                                # ****  ONEOCT NEEDS A LOWER ORDER    ****
                                                                # ****  WORD OF ZEROES                ****
6SECONDS        DEC             600
1.5SECS         2DEC            150
ZERO/SP         EQUALS          HI6ZEROS
                BLOCK           02
                SETLOC          FFTAG5
                BANK
                COUNT*          $$/P20
GOTOV56         EXTEND                                          # P20 TERMINATES BY GOTOV56 INSTEAD OF
                DCA             VB56CADR                        # GOTOPOOH
                TCF             SUPDXCHZ
                EBANK=          WHOCARES
VB56CADR        2CADR           TRMTRACK

## Page 597
# PROGRAM NAME: R29  (RENDEZVOUS RADAR DESIGNATE DURING POWERED FLIGHT)
# MOD NO. 2       BY H. BLAIR-SMITH       JULY 2, 1968.


# FUNCTIONAL DESCRIPTION:

# DESIGNATES THE RENDEZVOUS RADAR TOWARD THE COMPUTED LOS TO THE CSM, WITH THE CHIEF OBJECTIVE OF OBTAINING RANGE
# AND RANGE RATE DATA AT 2-SECOND INTERVALS FOR TRANSMISSION TO THE GROUND.  WHEN THE RR IS WITHIN .5 DEGREE OF
# THE COMPUTED LOS, TRACKING IS ENABLED, AND DESIGNATION CONTINUES UNTIL THE DATA-GOOD DISCRETE IS RECEIVED.  AT
# THAT POINT, DESIGNATION CEASES AND A RADAR-READING ROUTINE TAKES OVER, PREPARING A CONSISTENT SET OF DATA FOR
# DOWN TELEMETRY.  THE SET INCLUDES RANGE, RANGE RATE, MARK TIME, TWO RR CDU ANGLES, THREE IMUCDU ANGLES, AND AN
# INDICATOR WHICH IS 1 WHEN THE SET IS CONSISTENT AND 0 OTHERWISE.  THE INDICATOR IS IN TRKMKCNT.

# CALLING SEQUENCE:  BEGUN EVERY 2 SECONDS AS AN INTEGRAL PART OF SERVICER


# SUBROUTINES CALLED:

# REMODE   RRTONLY
# UNIT     MPACVBUF
# QUICTRIG AX*SR*T
# SPSIN    SPCOS
# SETRRECR RROUT
# RRRDOT   RRRANGE


# EXIT:  TO NOR29NOW, IN SERVICER.


# OUTPUT:  (ALL FOR DOWNLINK)

# RM       RDOTM                  (RAW)
# AIG      AMG
# AOG      TRKMKCNT               TRKMKCNT = 00001 IF SET IS CONSISTENT,
# TANGNB   TANGNB +1              OTHERWISE TRKMKCNT = 00000.
# MKTIME

## Page 598

# ERASABLE INITIALIZATION REQUIRED:

# NOR29FLG READRFLG               (TO 1 AND 0 BY FRESH START)  (RESET NOR29FLG TO LET SERVICER RUN R29)
# PIPTIME  RADMODES (BIT 10)      (BIT SET TO 0 BY FRESH START)
# R(CSM)   V(CSM)
# R        V                      (PIPTIME THRU V BY AVE G IN SERVICER)


# DEBRIS:

# RADMODES (BIT 10)
# LOSSM    LOSVDT/4       (= RRTARGET & LOSVEL)
# SAVECDUT OLDESFLG       (SAVECDUT = MLOSV)
# LOSCMFLG READRFLG


# ALARMS:  NONE.


# COMPONENT JOBS AND TASKS:

# INITIALIZING, IF RR IS FOUND TO BE IN MODE 1:  JOB R29REMOJ AND TASK REMODE:  ALWAYS: TASK PREPOS29.
# DESIGNATING:  TASK BEGDES29 & JOB R29DODES.
# RADAR READING:  TASK R29READ AND JOB R29RDJOB.  ALL JOBS ARE NOVAC TYPE.


                BANK            33
                SETLOC          R29/SERV
                BANK

                COUNT*          $$/R29

NR29&RDR        EQUALS          EBANK5

## Page 599
# SERVICER COMES TO R29 FROM "R29?" IF NOR29FLG, READRFLG, RRREMODE, RRCDUZRO, RRREPOS, AND DISPLAY-INERTIAL-DATA
# ARE ALL RESET, AND THE RR IS IN LGC MODE (OFTEN CONFUSINGLY CALLED AUTO MODE).

R29             CS              RADMODES
                MASK            DESIGBIT
                EXTEND
                BZF             R29.LOS                         # BRANCH IF DESIGNATION IS ALREADY ON.

                INHINT
                ADS             RADMODES                        # SHOW THAT DESIGNATION IS NOW ON.
                CS              BIT14
                EXTEND
                WAND            CHAN12                          # REMOVE RR TRACK ENABLE DISCRETE.
                CS              LOSCMBIT
                MASK            FLAGWRD2
                TS              FLAGWRD2                        # CLEAR LOSCMFLG TO SHOW DES. LOOP IS OFF.
                CS              OLDESBIT
                MASK            STATE
                TS              STATE                           # SHOW THAT DES. LOOP IS NOT REQUESTED.
                TC              BANKCALL
                CADR            SETRRECR                        # ENABLE RR ERROR COUNTERS.
                CA              ANTENBIT
                MASK            RADMODES
                CCS             A                               # TEST RR MODE BIT.
                TCF             SETPRPOS                        # MODE 2.

                CA              PRIO21                          # MODE 1; MUST REMODE.
                TC              NOVAC
                EBANK=          LOSCOUNT
                2CADR           R29REM0J                        # NEEDS OWN JOB TO RADSTALL IN.

                CS              DESIGBIT
                MASK            RADMODES                        # CLEAR DESIGNATE FLAG IN RADMODES
                TS              RADMODES                        # BEFORE CALLING REMODE
                CA              REMODBIT
                ADS             RADMODES                        #  SHOW THAT REMODING IS ON.
                TCF             NOR29NOW                        # CONTINUE SERVICER FUNCTIONS.

SETPRPOS        CA              ONE
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           PREPOS29                        # TASK TO SET TRUNNION ANGLE TO -180 DEG.
                CA              REPOSBIT
                ADS             RADMODES                        # SHOW THAT REPOSITIONING IS ON.
                TCF             NOR29NOW

## Page 600
# FORCE RENDEZVOUS RADAR INTO MODE 2.


R29REM0J        CA              ONE
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           REMODE                          # REMODE MUST RUN AS A TASK.
                TC              BANKCALL                        # WAIT FOR END OF REMODING.
                CADR            RADSTALL

                TCF             ENDOFJOB                        # BAD EXIT CAN'T HAPPEN.
                TCF             ENDOFJOB

# TASK TO PREPOSITION THE RR TRUNNION ANGLE TO -180 DEG.

                SETLOC          R29S1
                BANK

PREPOS29        CA              NEGMAX                          # -180 DEG.
                TC              RRTONLY                         # DRIVE TRUNNION CDU.
                CS              REPOSBIT                        # SHOW THAT REPOSITIONING IS OFF.
                MASK            RADMODES
                TS              RADMODES
                TCF             TASKOVER


# COMPUTE LINE-OF-SIGHT AND LOS VELOCITY, AND PASS THEM TO THE R29DODES LOOP.


                SETLOC          R29
                BANK

R29.LOS         EXTEND
                DCS             PIPTIME
                DXCH            MPAC
                EXTEND
                DCA             TIME2
                DAS             MPAC                            # (MPAC) = T-PIPTIME, SCALED B-28.
                TS              MODE                            # SET MODE TO DOUBLE PRECISION.
                CA              MPAC            +1
                EXTEND
                MP              BIT12
                DXCH            MPAC                            # T-PIPTIME NOW SCALED B-17.
                TC              INTPRET

## Page 601
# LOSCMFLG=0 MEANS THAT THE DESIGNATION IS READY FOR NEW DATA.  SETTING LOSCMFLG MAKES IT GO AWAY SO SETUP29D CAN
# START IT UP WHEN THE DATA IS IN PLACE.


                PDVL            VSU                             # PUSH DOWN T-PIPTIME.
                                V(CSM)
                                V                               # LOSVEL = V(CSM) - V.
                PDDL            VXSC                            # SWAP LOSVEL FOR T-PIPTIME, MULTIPLY THEM
                VAD             VSU                             #  AND ADD THE RESULT TO R(CSM) - R TO GET
                                R(CSM)                          #  AN UP-TO-DATE LOS VECTOR IN SM AXES.
                                R
                BOFSET          EXIT                            # (BOFSET DOES ITS THING INHINTED.)
                                LOSCMFLG                        # IF DESIGNATE LOOP IS OFF, CHANGE LOSCM-
                                SETUP29D                        #  FLG TO ON AND GO TO SET UP NEW DATA.
                TCF             NOR29NOW                        # IF DES. LOOP IS ON, LET IT USE OLD DATA.

SETUP29D        STOVL           LOSSM                           # LINE-OF-SIGHT VECTOR, STABLE MEMBER AXES
                                0
                VXSC
                                .5SECB17
                STORE           LOSVDT/4                        # 1/2 SECOND'S WORTH OF LOS VELOCITY.
                CLEAR           EXIT
                                LOSCMFLG                        # LET R29DLOOP USE NEW DATA.

                CS              STATE
                MASK            OLDESBIT
                EXTEND
                BZF             NOR29NOW                        # BRANCH IF R29 DES. LOOP IS REQUESTED.
                INHINT
                ADS             STATE                           # OTHERWISE REQUEST IT NOW.

                CCS             PIPCTR                          # SEE IF TASK SHOULD BE OFFSET ONE SECOND.
                CS              SUPER110                        # -96D +100D = 4.
                AD              1SEC                            # 0 +100D = 100D.
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           BEGDES29                        # START BEGDES29 TASK ASAP.
                TCF             NOR29NOW                        # RELINT AND CONTINUE SERVICER FUNCTIONS.

.5SECB17        2DEC            50              B-17

## Page 602
# R29 DESIGNATE JOB AND TASK MACHINERY.  TASK RECURS EVERY .5 SEC UNTIL DESIGNATE IS CALLED OFF; IT MAY WAIT FOR A
# CENTISECOND OR TWO IF IT COMES UP WHILE SETUP29D IS SUPPLYING NEW DATA.


                BANK            24
                SETLOC          P20S
                BANK

                COUNT*          $$/R29

BEGDES29        CAF             PRIO21
                TC              NOVAC
                EBANK=          LOSVDT/4
                2CADR           R29DODES                        # START R29DODES JOB TWICE A SECOND.
R29DLOOP        CAF             .5SEC
                TC              VARDELAY

                CS              RADMODES
                MASK            DESIGBIT
                CCS             A
                TCF             TASKOVER                        # QUIT IF DESIGNATION IS CALLED OFF.

                CS              FLAGWRD2
                MASK            LOSCMBIT
                EXTEND
                BZF             +3                              # BRANCH IF SETUP29D'S SUPPLYING NEW DATA.
                ADS             FLAGWRD2                        # SET LOSCMFLG:  SHOW THAT DES. LOOP IS ON.
                TCF             BEGDES29

                CA              ONE
                TCF             R29DLOOP        +1              # WAIT A CENTISECOND FOR NEW DATA.

## Page 603
# R29DODES:  RR DESIGNATION LOOP FOR R29

# THIS ROUTINE DOES MUCH THE SAME THING AS DODES, BUT A GREAT DEAL FASTER.  IT TAKES THE NON-UNITIZED LOS VECTOR
# IN STABLE MEMBER COORDINATES (LOSSM) AND A DELTA-LOS IN SM AXES (LOSVDT/4) WHICH IS 1/2 SEC TIMES LOS VELOCITY,
# AND DEVELOPS THE SHAFT AND TRUNNION COMMANDS USING SINGLE PRECISION AS MUCH AS POSSIBLE, AND INTERPRETIVE NOT AT
# ALL.  THE UNIT(LOSSM + LOSVEL * 1 SEC) IS COMPUTED IN DP AND TRANSFORMED TO NAV BASE COORDINATES IN DOUBLE PRE-
# CISION (USING SP SINES AND COSINES OF CDU ANGLES), AND THE REST IS DONE IN SP.

# THE FUNCTIONAL DIFFERENCE IS THAT R29DODES ALWAYS CLEARS LOSCMFLG WHEN IT ENDS, AND IT STARTS UP THE R29READ
# TASK WHEN LOCK-ON IS ACHIEVED.


                BANK            32
                SETLOC          F2DPS*32
                BANK

                COUNT*          $$/R29
                EBANK=          LOSVDT/4

R29DODES        CA              ONE
                TS              TANG                            # INDICATE 1ST PASS THRU VECTOR LOOP.
                CA              FIVE

R29DVBEG        CCS             A                               # COUNT DOWN BY TWOS IN VECTOR LOOP.
                TS              Q
                CCS             TANG
                TCF             R29DPAS1                        # DO THIS ON 1ST PASS THRU LOOP.

                EXTEND                                          # (A "PASS" HERE MEANS 3 TIMES AROUND).
                INDEX           Q
                DCA             LOSVDT/4
                INDEX           Q
                DAS             LOSSM                           # ADVANCE LOS VECTOR 1/2 SECOND.

R29DPAS1        EXTEND
                INDEX           Q
                DCA             LOSSM
                INDEX           Q                               # MOVE CURRENT LOS (1ST PASS) OR LOS PRO-
                DXCH            MPAC            +1              # JECTED 1/2 SEC AHEAD (2ND PASS).
                CCS             TANG
                TCF             R29DVEND                        # BUG OUT HERE IN 1ST PASS.

                EXTEND
                INDEX           Q
                DCA             LOSVDT/4
                INDEX           Q
                DAS             MPAC            +1              # PROJECT LOS 1 SECOND AHEAD (2ND PASS).

R29DVEND        CCS             Q
                TCF             R29DVBEG                        # BRANCH TO CONTINUE VECTOR LOOP.

## Page 604
# UNITIZE AND TRANSFORM TO NAV BASE AXES THE PRESENT LOS (1ST PASS) OR THE 1-SEC PROJECTED LOS (2ND PASS).

                DXCH            MPAC            +1
                DXCH            MPAC
                CA              R29FXLOC                        # = ADRES INTB15 + -34D
                TS              FIXLOC
                TC              USPRCADR                        # WITH FIXLOC ARMED FOR LENGTH AND LENGTH
                CADR            UNIT                            # SQUARED, BORROW UNITIZING ROUTINE.
                TC              MPACVBUF                        # MOVE UNIT(LOS) TO AX*SR*T ARG AREA.

                CCS             TANG
                TCF             +2
                TCF             GOTANGLS                        # GET CDU ANGLES ONLY AFTER 1ST PASS.
                INHINT                                          # ENSURE CONSISTENT CDU READINGS.
                EXTEND
                DCA             CDUT
                DXCH            SAVECDUT                        # TRUNNION AND SHAFT ANGLES.
                CA              CDUY
                TS              CDUSPOT
                CA              CDUZ
                TS              CDUSPOT         +2
                CA              CDUX
                TS              CDUSPOT         +4              # CDU ANGLES IN FUNNY ORDER FOR AX*SR*T.
                TC              BANKCALL
                CADR            QUICTRIG                        # GET SINES AND COSINES OF CDU ANGLES.

GOTANGLS        CS              THREE
                TC              BANKCALL
                CADR            AX*SR*T                         # TRANSFORM UNIT LOS TO NB AXES (ULOSNB).

                CCS             TANG
                TCF             +2
                TCF             R29DPAS2                        # GO TO RR COMMAND COMP. AFTER 2ND PASS.

## Page 605
# COMPUTE COSINE OF THE ANGLE BETWEEN THE PRESENT LOS AND THE RR BORESIGHT VECTOR, AND SET THE SELFTRACK ENABLE IF
# THE COSINE IS APPROXIMATELY COS(.5 DEG) OR GREATER (I.E. SMALLER ANGLE).


                INHINT
                TS              TANG                            # INDICATE 2ND PASS THRU VECTOR LOOP.
                CA              SAVECDUT
                TC              SPCOS
                TS              PUSHLOC                         # PUSHLOC = COS T.
                CS              SAVECDUT
                TC              SPSIN
                TS              MODE                            # MODE = -SIN T.
                EXTEND
                MP              VBUF            +2              # FORM - SIN T ULOSNBY.
                DXCH            MPAC
                CA              SAVECDUT        +1
                TC              SPSIN
                TS              SAVECDUT                        # SAVECDUT NOW = SIN S.
                EXTEND
                MP              PUSHLOC
                EXTEND
                MP              VBUF                            # FORM SIN S COS T ULOSNBX.
                DAS             MPAC
                CA              SAVECDUT        +1
                TC              SPCOS
                TS              SAVECDUT        +1              # SAVECDUT +1 NOW = COS S .
                EXTEND
                MP              PUSHLOC
                EXTEND
                MP              VBUF            +4              # FORM COS S COS T ULOSNBZ.
                DAS             MPAC                            # COS(ERROR) = ULOSNB . (SIN S COS T,
                EXTEND                                          # - SIN T, COS S COS T).
                DCA             MPAC
TESTCOS         DAS             MPAC                            # (ULOSNB IN VBUF WAS A HALF-UNIT VECTOR).
                CCS             A                               # TEST FOR + OVERFLOW, NONE, OR MINUS.
                CA              BIT14
                NOOP
                EXTEND
                WOR             CHAN12                          # IF PLUS OVERFLOW, SET SELFTRACK ENABLE.
                RELINT
                TCF             R29DVBEG        -1              # MAKE 2ND PASS THRU VECTOR LOOP.

## Page 606
# COMPUTE SHAFT AND TRUNNION COMMANDS TO NULL HALF THE ERROR IN HALF A SECOND.


R29DPAS2        CA              SAVECDUT        +1
                EXTEND
                MP              VBUF                            # FORM COS S ULOSNB'X.
                DXCH            TANG
                CS              SAVECDUT
                EXTEND
                MP              VBUF            +4              # FORM - SIN S ULOSNB'Z.
                DAS             TANG                            #  RAW SHAFT CMD = ULOSNB' . (COS S, 0,
                CS              MODE                            # - SIN S)
                EXTEND
                MP              SAVECDUT
                EXTEND
                MP              VBUF                            # FORM SIN T SIN S ULOSNB'X.
                DXCH            MPAC
                CA              PUSHLOC
                EXTEND
                MP              VBUF            +2              # FORM COS T ULOSNB'Y.
                DAS             MPAC
                CS              MODE
                EXTEND
                MP              SAVECDUT        +1
                EXTEND
                MP              VBUF            +4              # FORM SIN T COS S ULOSNB'Z.
                DAS             MPAC                            # RAW TRUNNION CMD = ULOSNB'.
                CA              MPAC                            # (SIN S SIN T, COS T, SIN S COS T).
                EXTEND
                MP              RR29GAIN
                XCH             TRUNNCMD                        # STORE REFINED T CMD,GET RAW S CMD.
                EXTEND
                MP              RR29GAIN
                TS              SHAFTCMD                        # STORE REFINED SHAFT COMMAND FOR RROUT

## Page 607
# WHETHER OR NOT TRACKING WAS ENABLED THIS TIME, CHECK ON RR DATA-GOOD.  IF PRESENT, STOP DESIGNATING AND START
# READING DATA FROM THE RENDEZVOUS RADAR.


DGOOD?          CAF             BIT4
                EXTEND
                RAND            CHAN33                          # GET RR DATA-GOOD BIT.
                INHINT                                          # (MAINLY FOR RROUT).
                EXTEND
                BZF             R29LOKON                        # BRANCH IF DATA-GOOD IS PRESENT.

                TC              BANKCALL
                CADR            RROUT                           # DATA-GOOD IS ABSENT, SO SEND COMMANDS.
                TCF             END29DOD

R29LOKON        CS              DESIGBIT
                MASK            RADMODES
                TS              RADMODES                        # SHOW THAT DESIGNATION IS OVER.
                CS              BIT2
                EXTEND
                WAND            CHAN12                          # DISABLE RR ERROR COUNTERS.
                CA              READRBIT
                ADS             FLAGWRD3                        # SHOW THAT READING HAS BEEN REQUESTED.
                CCS             PIPCTR                          # SEE IF TASK SHOULD BE OFFSET 1 SEC.
                CS              SUPER110                        # - 96D + 100D = 4.
                AD              1SEC                            # 0 + 100D = 100D.
                TC              WAITLIST
                EBANK=          LOSCOUNT
                2CADR           R29READ                         # START READING TASK AND JOB.
END29DOD        CS              LOSCMBIT
                MASK            FLAGWRD2
                TS              FLAGWRD2                        # ALWAYS CLEAR LOSCMFLG.
                TCF             ENDOFJOB

R29FXLOC        ADRES           INTB15+         -34D
RR29GAIN        DEC             -.53624
LOSVDT/4        EQUALS          LOSVEL
LOSSM           EQUALS          RRTARGET
SAVECDUT        EQUALS          MLOSV

## Page 608
# RR READING IS SET UP BY R29DODES WHEN IT DETECTS RR LOCK-ON.


                BANK            24
                SETLOC          P20S
                BANK

                COUNT*          $$/R29

                EBANK=          LOSCOUNT

R29READ         CAF             PRIO26                          # CALLED BY WAITLIST.
                TC              NOVAC
                EBANK=          LOSCOUNT
                2CADR           R29RDJOB                        # START JOB TO READ AND DOWNLINK FOR R29.

                CA              2SECS
                TC              VARDELAY

                CA              FLAGWRD3                        # 2 SECONDS LATER, SEE IF READING IS STILL
                MASK            READRBIT                        # ALLOWED (NO TRACKER FAIL ETC.)
                CCS             A
                TCF             R29READ                         # IT'S OK; CALL IT AGAIN.
                TCF             TASKOVER                        # IT AIN'T; WAIT FOR REDESIGNATE.

R29RDJOB        CA              FLAGWRD3                        # CALLED VIA NOVAC.
                MASK            NR29FBIT
                CCS             A                               # TEST "NOR29FLG".
                TCF             ENDR29RD                        # R29 OVER,EXIT WITH RR STILL LOCKED ON
                CA              RADMODES
                MASK            AUTOMBIT
                CCS             A                               # TEST RR-NOT-IN-AUTO-MODE BIT.
                TCF             ENDRRD29                        # ASTRO TOOK RR OUT OF AUTO MODE.

                TC              BANKCALL
                CADR            RRRDOT                          # INITIATE READING OF RANGE RATE.
                TC              BANKCALL
                CADR            RADSTALL                        # GO TO SLEEP UNTIL IT'S READY.
                TCF             ENDRRD29                        # BAD READ; REDESIGNATE.

## Page 609
# R29 RADAR READING CONTINUED.


                DXCH            TIMEHOLD
                DXCH            MPAC                            # TIME OF RR READING, FOR DOWNLINK.
                INHINT                                          # BE SURE OF 5 CONSISTENT CDU ANGLES.
                EXTEND
                DCA             CDUT
                DXCH            MPAC            +2              # RRCDU ANGLES AT RR READ, FOR DOWNLINK.
                EXTEND
                DCA             CDUY
                DXCH            MPAC            +4              # MPAC'S 7 WORDS ARE BUFFER FOR COPYCYCLE.
                CA              CDUX
                TS              MPAC            +6              # IMUCDU ANGLES AT RR READ, FOR DOWNLINK.

R29RANGE        TC              BANKCALL
                CADR            RRRANGE                         # INITIATE READING OF RR RANGE.
                TC              BANKCALL
                CADR            RADSTALL                        # GO TO SLEEP UNTIL IT'S READY.
                TCF             R29RRR?                         # BAD READ OR SCALE CHANGE ... WHICH?

                INHINT
                DXCH            DNRRANGE                        # COPYCYCLE TO LAY OUT NEW R29 DOWNLINK.
                DXCH            RM
                DXCH            MPAC
                DXCH            MKTIME
                DXCH            MPAC            +2
                DXCH            TANGNB
                DXCH            MPAC            +4
                DXCH            AIG
                CA              MPAC            +6
                TS              AOG
                CA              ONE
                TS              TRKMKCNT                        # SHOW THAT DOWNLINK DATA IS CONSISTENT.
                TCF             ENDOFJOB

R29RRR?         CS              FLAGWRD5
                MASK            BIT10
                CCS             A                               # WAS IT A SCALE CHANGE (REAL OR PHONY)?
                TCF             ENDRRD29                        # NO, A BAD READ; REDESIGNATE.
                TC              DOWNFLAG
                ADRES           RNGSCFLG
                TCF             R29RANGE                        # YES; CLEAR FLAG AND READ AGAIN.

ENDRRD29        CS              BIT14                           # TROUBLE MADE US COME HERE TO LEAVE THE
                EXTEND                                          # RR-READING MODE. DISCREDIT DOWNTEL
                WAND            CHAN12
ENDR29RD        CA              ZERO
                TS              TRKMKCNT
                TC              DOWNFLAG

## Page 610
                ADRES           READRFLG
                TCF             ENDOFJOB

## Page 611
# W-MATRIX MONITOR


                BANK            31
                SETLOC          VB67
                BANK
                COUNT*          $$/EXTVB

                EBANK=          WWPOS

V67CALL         TC              INTPRET
                CALL
                                V67WW
                EXIT
                EXTEND                                          # SAVE THE PRESENT N99 VALUES FOR
                DCA             WWPOS                           # COMPARISON AFTER THE DISPLAY
                DXCH            WWBIAS          +2
                EXTEND
                DCA             WWVEL
                DXCH            WWBIAS          +4
                EXTEND
                DCA             WWBIAS
                DXCH            WWBIAS          +6
V06N99DS        CAF             V06N99
                TC              BANKCALL
                CADR            GOXDSPF
                TCF             ENDEXT
                TCF             V6N99PRO
                TCF             V06N99DS
V6N99PRO        ZL
                CA              FIVE
N99LOOP         TS              Q
                INDEX           Q
                CS              WWPOS
                INDEX           Q
                AD              WWPOS           +6
                ADS             L
                CCS             Q                               # THE SUM OF ALL DIFFERENCES MUST BE ZERO.
                TCF             N99LOOP
                LXCH            A
                EXTEND
                BZF             V06N9933
                TC              UPFLAG
                ADRES           V67FLAG

V06N9933        TC              INTPRET
                BON             EXIT
                                V67FLAG
                                +2
                TCF             ENDEXT
                DLOAD

## Page 612
                                WWPOS
                SL4             SL1
                STODL           0D
                                WWVEL
                STODL           2D
                                WWBIAS
                SL                                              # SHIFT FROM NOUN SCALING (B-5) TO
                                10D                             # INTERNAL SCALING (B+5)
                STORE           4D
                BON             LXA,1
                                SURFFLAG
                                V67SURF
                                0D
                SXA,1           LXA,1
                                WRENDPOS
                                2D
                SXA,1           GOTO
                                WRENDVEL
                                V67CLRF
V67SURF         LXA,1           SXA,1
                                0D
                                WSURFPOS
                LXA,1           SXA,1
                                2D
                                WSURFVEL
V67CLRF         LXA,1           SXA,1
                                4D
                                WTRUN
                SXA,1
                                WSHAFT
                CLEAR           EXIT
                                RENDWFLG
                TCF             ENDEXT
V67WW           STQ             BOV
                                S2
                                +1
                CLEAR           CALL
                                V67FLAG
                                INTSTALL
                SSP             DLOAD
                                S1
                DEC             6
                                ZEROVECS
                STORE           WWPOS
                STORE           WWVEL
                STORE           WWBIAS
                AXT,1
                DEC             54
NXPOSVEL        VLOAD*          VSQ
                                W               +54D,1

## Page 613
                GOTO
                                ADDPOS
V06N99          VN              0699

                SETLOC          VB67A
                BANK
                COUNT*          $$/EXTVB

ADDPOS          DAD
                                WWPOS
                STORE           WWPOS
                VLOAD*          VSQ
                                W               +108D,1
                DAD
                                WWVEL
                STORE           WWVEL
                VLOAD*          VSQ
                                W               +162D,1
                DAD
                                WWBIAS
                STORE           WWBIAS
                TIX,1           SQRT
                                NXPOSVEL
                SR                                              # SHIFT FROM INTERNAL SCALING (B+5) TO
                                10D                             # NOUN SCALING (B-5)
                STODL           WWBIAS
                                WWVEL
                SQRT
                STODL           WWVEL
                                WWPOS
                SQRT
                STORE           WWPOS
                BOV             GOTO
                                +2
                                V67XXX
                DLOAD
                                DPPOSMAX
                STORE           WWPOS
                STORE           WWVEL
                STORE           WWBIAS
V67XXX          DLOAD           DSU
                                WWPOS
                                FT99999
                BMN             DLOAD
                                +3
                                FT99999
                STORE           WWPOS
                LXA,1           SXA,1
                                S2
                                QPRET

## Page 614
                EXIT
                TC              POSTJUMP
                CADR            INTWAKE

FT99999         2DEC            30479           B-19

## Page 615
                BANK            25
                SETLOC          RADARUPT
                BANK
                COUNT*          $$/RRUPT

                EBANK=          LOSCOUNT

RADLITES        CS              BIT5
                AD              ITEMP1
                CCS             A
                CS              ONE
                TCF             VLIGHT

                TCF             RRTRKF

HLIGHT          TS              ITEMP5                          # ZERO ITEMP5 FOR H INDEX

                CA              HLITE
                TS              L

                CA              LRALTBIT
BOTHLITS        MASK            RADMODES
                CCS             A
                TCF             ONLITES

                CA              FLGWRD11
                INDEX           ITEMP5
                MASK            HFLSHBIT
                CCS             A
                TCF             RRTRKF

LITIT           EXTEND
                QXCH            ITEMP6
                TC              TRKFLON         +1

                TC              ITEMP6

ONLITES         INDEX           ITEMP5
                CS              HFLSHBIT
                MASK            FLGWRD11
                TS              FLGWRD11

                CA              L
                TCF             LITIT
VLIGHT          TS              ITEMP5
                CA              VLITE
                TS              L
                CA              BIT8
                TCF             BOTHLITS

## Page 616
HLITE           EQUALS          BIT5
VLITE           EQUALS          BIT3
