;;; correcting wind speeds [m/s] (below: �uz�) at height z ASL (below: �zh�) to neutral equivalent wind speed (below: �w_corr�) at e.g. 10 m ASL (below: �height�):
;;; IDL code
;;; originally adapted from Karsten Fennig (DWD, KU22), implemented into bias calculations by Julian Kinzel (DWD, Ku22)
;;; status: 01.04.2016


uz=8      ; wind speed at height z
zh=11   ; height of wind speed measurement (original height!)

; keywords
height = 10         ; height of wind speed
use_wg = use_wg     ; use wind gustiness

; parameter
MAX_N = 100          ; maximum # iterations
VK    = 0.40D       ; von karman's constant.
EPS   = 0.001D      ; small number
CHRNK = 0.011D      ; Charnock coefficient
VISC  = 14.5d-6     ; kinematic viscosity of air @ 15C
Wg    = 0.2D        ; wind gustiness

; elements
tcnt = n_elements(uz)                           ; tcnt = total amount of elements in uz (wind speed at height z)

; one height for all obs
if (n_elements(zh) eq 1) $
  then z_ = replicate(zh, tcnt)  $  ; z_ array is equal to a tcnt array filled with only zh's
else z_ = zh[lindgen(tcnt)]     ; creation of integer array z_ with length tcnt, going from 0,1, ..., to tcnt

; first guess of ustar
us  = 0.036D*uz
us2 = 0.D*uz
z0  = 0.D*uz

; check input
pos = where (z_ le 0.D or uz lt 0.D, cnt)  ; find the location where z_ is <= 0 or wind speed is < 0

if (cnt gt 0) then us[pos]  = us2[pos]         ; if this case is given, change us to 0 (i.e. us2)!

; include gustiness in wind spd.
Du = (keyword_set(use_wg)) ? sqrt(uz^2.+Wg^2.) : uz

; modification of charnok after Fairall
charn = replicate(CHRNK, tcnt)
pos = where (Du gt 10.D, cnt)
if (cnt gt 0) then charn[pos] = 0.011D + (0.018D - 0.011D) * (Du[pos]-10.D) / ( 18.D - 10.D )
pos = where (Du gt 18.D, cnt)
if (cnt gt 0) then charn[pos] = 0.018D

; iteration loop
for i=0, MAX_N do begin
  ; check result
  pos = where (abs(us2-us) gt EPS, cnt)
  if (cnt eq 0) then break

  ; next iteration
  us2 = us

  ; calculate roughness length
  z0[pos] = charn[pos]*us[pos]*us[pos]/9.81D + 0.11D*(VISC/us[pos])
  z0[pos] = z0[pos] < z_[pos]*0.5

  ; calculate ustar
  us[pos] = VK * Du[pos] / alog10(z_[pos]/z0[pos])
endfor

; wind speed at new height
if (n_elements(height) eq 1) then begin
  ;message, /info, 'Convert to wind at height '+string(height)
  pos = where (finite(us) and (z0 gt 0.D), cnt)
  if (cnt gt 0) then w_corr = (us[pos] * alog10(height/z0[pos])) / VK
endif

END ; endif wind speed at height z and sensor height is given

;if(insitu_anemh_r(ll) gt '300' or w(ll) le '0' )then begin
;  print,'cannot convert wind speed, as sensor height is not given or wind speed was not measured!'
;  w_corr(ll)='999'
;end 