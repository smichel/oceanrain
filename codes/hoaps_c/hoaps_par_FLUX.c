// standard header
#include <stdlib.h>
#include <math.h>
#include <stdio.h>

// kosh header
//#include <kosh_math.h>
//#include <kosh_kerror.h>
//#include <kosh_undef.h>

// hoaps header
//#include "hoaps_par.h"

#define HOAPS_SLVP (1013.25) // standard sea level pressure
// makros
#ifndef SQR
#define SQR(x)    ( (x)*(x) )
#endif
#ifndef MAX
#define MAX(x,y)  ( (x) > (y) ) ? (x) : (y);
#endif
#ifndef MIN
#define MIN(x,y)  ( (x) < (y) ) ? (x) : (y);
#endif

// parameter
#define C_VON  (0.4)     // von Karman's "constant"
#define C_BETA (1.2)     // Given as 1.25 in Fairall et al.(1996)
#define C_FDG  (1.00)    // Fairall's LKB rr to von karman adjustment
                         //   based on results from Flux workshop August 1995
#define C_TOK  (273.16)  // Celsius to Kelvin
#define C_CPW  (4000.)   // J/kg/K specific heat water
#define C_RHOW (1022.)   // density water
#define C_CPA  (1004.67) // J/kg/K specific heat of dry air (Businger 1982)
#define C_RGAS (287.1)   // J/kg/K     gas const. dry air
#define C_GRAV (9.81)    // gravity
#define C_ZI   (600.)    // mixed layer height


// private stability functions
extern double psit_ (
    double zl         // height/L where L is the Obukhov length
);
extern double psiu_ (
    double zl         // height/L where L is the Obukhov length
);
extern int hoaps_par_FLUX_Fairall(
        double *ce,           // ptr to transfer coef latent heat flux
        double *evap,         // ptr to evaporation
        double *qe,           // ptr to latent heat flux
        double *qh,           // ptr to sensible heat flux
  const double ts,            // SST in deg_C
  const double qs,            // sea surface humidity in g/kg
  const double t,             // air temperature in deg_C
  const double q,             // air humidity in g/kg
  const double u              // wind speed in m/s
        );
/* Name
 *    hoaps_par_FLUX_Fairall
 *
 * Description
 *    compute bulk air-sea fluxes using fairall model
 *
 *   evaluate surface fluxes, surface roughness and stability of
 *   the atmospheric surface layer from bulk parameters based on
 *   liu et al. (79) JAS 36 1722-1735
 *
 *    trimmed code from seaflux.f (COARE bulk flux version 2.6a)
 */

int main(void)
{   
    double ce;
    double evap;
    double qe;
    double qh;
    int s;
    
    s = hoaps_par_FLUX_Fairall(&ce, &evap, &qe, &qh, 20, 1.2, 22, 1.4, 8);
    
    printf("ce:%e\n", ce);
    printf("evap:%e\n", evap);
    printf("qe:%e\n", qe);
    printf("qh:%e\n", qh);
    
    return 0;
}
int hoaps_par_FLUX_Fairall (  // {{{
  // arguments
        double *ce,           // ptr to transfer coef latent heat flux
        double *evap,         // ptr to evaporation
        double *qe,           // ptr to latent heat flux
        double *qh,           // ptr to sensible heat flux
  const double ts,            // SST in deg_C
  const double qs,            // sea surface humidity in g/kg
  const double t,             // air temperature in deg_C
  const double q,             // air humidity in g/kg
  const double u              // wind speed in m/s
) {
  // local parameter
  static const double zu  = 37.5;  // height of wind measurement
  static const double zt  = 37.5;  // height of air temp. and RH
  static const double zq  = 37.5;  // height of water vapor measurement

  // local variables
  static double q_;       // local air humidity in kg/kg
  static double qs_;      // local sea surface humidity in kg/kg
  static double wg;       // Gustiness factor
  static double tsr;      // temperature scaling parameter
  static double usr;      // velocity scaling parameter
  static double qsr;      // humidity scaling parameter
  static double zo;       // roughness length
  static double rr;       // Roughness Reynolds number
  static double zl;       // height/L where L is the Obukhov length
  static double l;        // Obukhov length
  static double zot;      // roughness length for temperature
  static double zoq;      // roughness length for humidity
  static double ta;       // air temperature in K
  static double rhoa;     // kg/m3  Moist air density
  static double xlv;      // J/kg  latent heat of vaporization at TS
  static double du_wg;
  static double visa;     // Kinematic viscosity of dry air
  static double ribu;
  static double zot10;
  static double s;
  static double dt;       // potential temperature diff.
  static double dq;       // difference in humidity
  static double du;       // windspeed relative to current
  static double cd, ct;   // transfere coefficients
  static double u10;      // windspeed at 10m */
  static double zetu, charn, ribcu, cc, bf, 
                l10, cd10, ch10, ct10, zo10;
  static int    nits;

  // test arguments
  //KERROR_TEST_VALUE (ce, NULL, KERROR_NULL, EXIT_FAILURE);
  //*ce = DOUBLE_UNDEF;
  //KERROR_TEST_VALUE (evap, NULL, KERROR_NULL, EXIT_FAILURE);
  //*evap = DOUBLE_UNDEF;
  //KERROR_TEST_VALUE (qe, NULL, KERROR_NULL, EXIT_FAILURE);
  //*qe = DOUBLE_UNDEF;
  //KERROR_TEST_VALUE (qh, NULL, KERROR_NULL, EXIT_FAILURE);
  //*qh = DOUBLE_UNDEF;

  // convert kg/kg
  q_  =  q * 0.001;
  qs_ = qs * 0.001;

  // get air temp in K
  ta = t + C_TOK;

  // latent heat of vaporization at TS
  xlv = (2.501 - ts*0.00237) * 1.e6;

  // moist air density
  rhoa = HOAPS_SLVP * 100. / (C_RGAS*ta*(q_*0.61 + 1.));

  // Kinematic viscosity of dry air - Andreas (1989) CRREL Rep. 89
  visa = 1.326e-5*(1 + t*0.006542 + t*t*8.301e-6 - t*t*t*4.84e-9);

  // Initial guesses
  zo = 1e-4;
  wg = .5;                    
  // assumes U is measured rel. to current
  du = u;
  // include gustiness in wind spd. difference equivalent to S in definition of fluxes
  du_wg = pow( du*du + wg*wg, 0.5);
  // potential temperature diff. Changed sign
  dt = ts - t - 0.0098*zt;
  dq = qs_ - q_;            // from Coar2_5b

  // **************** neutral coefficients ******************
  u10 = du_wg * log(10./zo)/log(zu/zo);
  usr = u10 * .035;
  zo10 = .011 * usr*usr/C_GRAV + 0.11*visa/usr;
  cd10 = pow( C_VON/log(10./zo10), 2. );
  ch10 = .00115;
  ct10 = ch10/sqrt(cd10);
  zot10 = 10/exp(C_VON/ct10);
  cd = pow( C_VON/log(zu/zo10), 2 );

  // ************* Grachev and Fairall (JAM, 1997) **********
  ct = C_VON/log(zt/zot10);      // Temperature transfer coefficient
  cc = C_VON * ct/cd;            // z/L vs Rib linear coefficient
  // Saturation or plateau Rib
  ribcu = -zu / (C_ZI*0.004*C_BETA*C_BETA*C_BETA );
  ribu = -C_GRAV * zu * (dt+0.61*ta*dq)/(ta*du_wg*du_wg);
  if (ribu < 0.)
    zetu = cc*ribu/(1+ribu/ribcu);    // Unstable G and F
  else
    zetu = cc*ribu*(1+27/9*ribu/cc ); // Stable, Chris forgets origin

  l10 = zu/zetu; // MO length
  nits = (zetu > 50.) ? 1 : 3;

  // ****** First guess stability dependent scaling params. ******
  usr = du_wg*C_VON / (log(zu/zo10)-psiu_(zu/l10));
  tsr = -dt*C_VON*C_FDG / (log(zt/zot10)-psit_(zt/l10));
  qsr = -dq*C_VON*C_FDG / (log(zq/zot10)-psit_(zq/l10));

  // then modify Charnock for high wind speeds Chris' data
  charn = .011;
  if(du_wg > 10.) charn = 0.011+(0.018-0.011)*(du_wg-10)/8.;
  if(du_wg > 18.) charn = 0.018;

  // bulk loop
  // {{{
  for (int iter=1; iter<=nits; iter++)
  {
    zl = C_VON*C_GRAV*zu/ta*(tsr+0.61*ta*qsr)/(usr*usr);
    zo = charn*usr*usr/C_GRAV + 0.11*visa/usr; // after Smith 1988
    rr = zo*usr/visa;

    // *** zoq and zot fitted to results from several Chris cruises *****
    zoq = 5.5e-5/pow(rr, 0.63);
    zot = zoq;

    l = zu/zl;
    usr = du_wg*C_VON/ (log(zu/zo) -psiu_(zu/l));
    tsr = -dt*C_VON*C_FDG  / (log(zt/zot)-psit_(zt/l));
    qsr = -dq*C_VON*C_FDG  / (log(zq/zoq)-psit_(zq/l));
    bf = -C_GRAV/ta*usr*(tsr+0.61*ta*qsr);
    wg = (bf>0.) ? C_BETA*pow(bf*C_ZI,.333) : .2;

    // ********** break into coare2.5b code again *************
    // include gustiness in wind speed
    du_wg = sqrt(du*du + wg*wg);
  }
  // }}}

  // compute turbulent flux, sensible heat flux (HF), latent heat flux (EF)
  s     = sqrt(u*u + wg*wg);
  *qh   = -C_CPA * rhoa*usr*tsr;
  *qe   = -xlv   * rhoa*usr*qsr;
  *evap = -3600. * rhoa*usr*qsr;

  // compute transfer coefficients
  *ce = -usr*qsr/(s*dq);
  /*
  *cd = pow( usr/s, 2. );
  *ch = -usr*tsr/(s*dt); 
  */
  
  /* compute neutral transfer coefficients and met variables at standard height
  pout->cd = pow( 0.4/log(zus/zo), 2 );
  pout->ch = 0.4*0.4/( log(zus/zo)*log(zts/zot) );
  pout->ce = 0.4*0.4/( log(zus/zo)*log(zqs/zoq) ); */

  // return to caller
  return (EXIT_SUCCESS);
} // }}}

/* Name
 *    psiu_
 *
 * Description
 *   evaluate stability function for wind speed
 *   matching Kansas and free convection forms with weighting f
 *   convective form follows Fairall et al (1996) with profile constants
 *   from Grachev et al (2000) BLM
 *   stable form from Beljaars and Holtslag (1991)
 */
double psiu_ (  // {{{
  // arguments
  double zl     // height/L where L is the Obukhov length
) {
  // local variables
  static double psiu;                   // function return
  static double psic, psik, c, f, x;

  // unstable
  if (zl < 0.) {
    x = pow (1. - zl * 15., .25);      // Kansas unstable
    psik = log((x+1.)*0.5)*2. + log((x*x + 1.)*0.5) - atan(x)*2. + atan(1.)*2.;
    x = pow (1. - zl * 10.15, .3333);  // Convective

    psic =        1.5 * log((1.+x+x*x) / 3.)
           - sqrt(3.) * atan((1.+2.*x) / sqrt(3.))
           +      4.  * atan(1.) / sqrt(3.);

    f = zl * zl / (zl * zl + 1.);
    psiu = (1.-f) * psik + f * psic;
  }
  // stable
  else
  {
    c = MIN(50.,zl * .35);
    psiu = -(pow(1.+1.*zl, 1.) + .6667*(zl-14.28)/exp(c) + 8.525);
  }

  // return to caller
  return (psiu);
} // }}}

/* Name
 *    psit_
 *
 * Description
 *   evaluate stability function for scalars
 *   matching Kansas and free convection forms with weighting f
 *   convective form follows Fairall et al (1996) with profile constants
 *   from Grachev et al (2000) BLM
 *   stable form from Beljaars and Holtslag (1991)
 */
double psit_ ( // {{{
  // arguments
  double zl    // height/L where L is the Obukhov length
) {
  // local variables
  static double psit;         // function return
  static double psic, psik, c, f, x;

  // unstable
  if (zl < 0.) {
    x = pow (1. - zl * 15., 0.5);     // Kansas unstable
    psik = log ((x + 1.) * 0.5) * 2.;
    x = pow (1. - zl * 34.15, .3333); // Convective
    psic =       1.5  * log((1. + x + x * x) / 3.)
           - sqrt(3.) * atan((x * 2. + 1.) / sqrt(3.))
                 + 4. * atan(1.) / sqrt(3.);
    f = zl * zl / (zl * zl + 1.);
	  psit = (1. - f) * psik + f * psic;
  }

  // stable
  else {
    c = MIN (50., zl * .35);
    psit = -(pow(1.+2.*(zl)/3.,1.5) + .6667*(zl-14.28)/exp(c) + 8.525);
  }

  // return to caller
  return (psit);
} // }}}
