/*-------------------------------------------------------------
 * This Processing code is licensed under the Creative Commons Attribution 3.0 Unported License.
 * https://creativecommons.org/licenses/by/3.0/
 * You must give appropriate credit, provide a link to the license, and indicate if changes were made.
 
 * Written by Sarah Spencer 2017, http://heartofpluto.co/ 
 * This is based on the short version of a Visual Basic program written by
 * H.Meinhardt and made publicly available here: 
 * http://www.eb.tuebingen.mpg.de/research/emeriti/hans-meinhardt/shell-program.html

 * see also: Meinhardt,H. and Klingler,M. (1987) J. theor. Biol 126, 63-69
 * see also: H.Meinhardt: "Algorithmic beauty of sea shells"
 * (Springer Verlag) (c) H.Meinhardt, Tübingen
 
 * This program simulates the color patterns on tropical sea shells, 
 * here 'Oliva porphyria'.
 * An autocatalytic activator a(i) leads to a burst-like activation
 * that is regulated back by the action of an inhibitor b(i). The life
 * time of the inhibitor is regulated via a hormone c, that is
 * homogeneously distributed along the growing edge. Whenever the number
 * of activated cells become too small, active cells remain activated
 * until backwards waves are triggered.
 */

int imax = 1200; // i = 1...kx < imax = cells at the growing edge
float[] ax = new float[imax];
float[] bx = new float[imax];
float[] zx = new float[imax];

int KT = 480;    // Number of displays
                 // KT * KP = number of iterations in total
int KP = 12;     // number of iterations between the displays ( = lines on the screen)
int kx = 640;    // number of cells
int dx = 1;      // width of a cell in pixel;   with kp=6 ; kx=315 and dx=2 =>
                 // simulation in a smaller field
float DA = .015; // Diffusion of the activator
float RA = .1;   // Decay rate of the inhibitor
float BA = .1;   // Basic production of the activator
float SA = .25;  // Saturation of the autocatalysis
float DB = 0;    // Diffusion of the inhibitor
float RB = .014; // Decay rate of the inhibitor
float SB = .1;   // Michaelis-Menten constant of the inhibition
float RC = .1;   // Decay rate of the hormone

float C, DAC, DBC, DBCC, RBB;
int seed = 41401;

void setup() {
   noLoop(); 
   noStroke();
   noSmooth();  
   size(kx,KT);
   randomSeed(seed);

   stroke(0);
   fill(0);
   textSize(18);
}

void draw() {
   background(255);

  // ----------- Initial condition  --------------------------
  for(int i = 1; i < kx; i++) {
     ax[i] = 0;    // Activator, general initial concentration
     bx[i] = .1;   // Inhibitor, general initial concentration
     zx[i] = RA * (.96 + (.08 * random(1))); // Fluctuation of the autocatalysis
  }
  
  C = .1; // Hormone-concentration, homogeneous in all cells
  
  int i = 10;
  for(int j = 1; j < 30; j++) { // initially active cells
     ax[i] = 1;
     i = i + int(random(0, 100));
     if(i > kx)
       break;
  }
  
  DAC = 1 - RA - 2 * DA; // These constant factors are used again and again
  DBC = 1 - RB - 2 * DB; // therefore, they are calculated only once
  DBCC = DBC;            // at the begin of the calculation
  
  int x0 = 0, y1 = 20;       //Initial position of the first line
  float A1, B1, AF, BF, AQ, BSA;
  
  for(int itot = 0; itot < KT; itot++) {
    for(int iprint = 1; iprint < KP; iprint++) { //Begin of the iteration
      // -----  --- Boundary impermeable
      A1 = ax[1]; //    a1 is the concentration  of the actual cell. since this
      B1 = bx[1]; //    concentration is identical, no diffusion through the border.
      ax[kx + 1] = ax[kx]; // Concentration in a virtual right cell
      bx[kx + 1] = bx[kx];
      BSA = 0;             // This will carry the sum of all activations of all cells
  
      // ---------- Reactions  ------
      for(i = 1; i < kx; i++) { // i = actual cell, kx = right cell
        AF = ax[i]; //local activator concentration
        BF = bx[i]; //local inhibitor concentration
        AQ = zx[i] * AF * AF / (1 + SA * AF * AF);  //Saturating autocatalysis
  
        // Calculation of the new activator and inhibitor concentration in cell i:
        ax[i] = AF * DAC + DA * (A1 + ax[i + 1]) + AQ / (SB + BF);
  
        // 1/BF => Action of the inhibitor; SB = Michaelis-Menten constant
        bx[i] = BF * DBCC + DB * (B1 + bx[i + 1]) + AQ; //new inhibitor conc.
        BSA = BSA + RC * AF; //Hormone production -> Sum of activations
        A1 = AF; //    actual concentration will be concentration in left cell
        B1 = BF; //    in the concentration change of the next cell
      }
  
      C = C * (1 - RC) + BSA / kx; // New hormone concentration , 1/kx=normalization
      RBB = RB / C;                 // on total number of cells
      //RBB => Effective life time of the inhibitor
      DBCC = 1 - 2 * DB - RBB;      // Change in a cell by diffusion
                                   // and decay. Must be recalculated since
                                   // lifetime of the inhibitor changes
    }
  
    // ----------------Plot -------------
    y1 = y1 + 1; //Next plot, one line below
  
    for(int ix = 1; ix < kx; ix++) {   //Pigment is drawn when a is higher than a threshold
      if(ax[ix] > .2) {
        line(x0 + dx * (ix - 1), y1, x0 + dx * ix, y1);
      }
    }
  }

  text("Seed = "+seed, 5, 18); 
}

void mousePressed() {
  seed = int(random(0,100000));
  randomSeed(seed);
  redraw();
}
