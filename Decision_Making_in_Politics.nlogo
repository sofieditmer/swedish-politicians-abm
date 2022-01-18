;;;; Decision Making in light of election polls ;;;


breed [prospect-theorists prospect-theorist]  ; define our 3 breeds of politician with plural and singular
breed [utility-theorists utility-theorist]
breed [random-theorists random-theorist]

turtles-own [
  ideological-stance      ; a constant value reflecting the agents individual alignment on radicalisation. Used to calculate closeness level.
  closeness-to-party      ; a score calculated as the parties radicalisation level minus their individual ideological-stance
  radicalisation-level    ; The calculated level of radicalisation after decision making function
]

prospect-theorists-own[
  weighted-function      ; these parameters are used in the calculation of the weighting and value function
  weighted-closeness
  value-function
  value-weighted-outcome
]

globals [
  party-radicalisation-PT       ; The moving level of radicalisation that is occuring due to agent actions (PROSPECT THEORY)
  party-radicalisation-UT       ; The moving level of radicalisation that is occuring due to agent actions (EXPEXTED UTILITY THEORY)
  party-radicalisation-RT       ; The moving level of radicalisation that is occuring due to agent actions (RANDOM)
  the-prospect                  ; The prospect selected by the user in the interface
  the-alignment                 ; The level of party alignment selected by the user
  electoral-change              ; a number which indicates whether the election goes up or down for this tick (SHOULD ADD GRAPH FOR ELECTORAL CHANGE)
  γ                             ; parameter for calculating the weighting function
  one-over-γ                    ; constant needed for calculating the weighting function
  alpha                         ; parameter for calculating the value function (relates to gains)
  beta                          ; parameter for calculating the value function (relates to loss)
  loss-aversion-coef            ; parameter for calculating the value function (relates to the loss aversion)
  parameter-values              ; linking the interface to the backend
  electoral-poll                ; to keep track of how the poll is changing across the simulation
  rolling-mean-PT               ; to keep track of rolling average radicalisation score (PROSPECT THEORY)
  rolling-mean-UT               ; to keep track of rolling average radicalisation score (EXPEXTED UTILITY THEORY)
  rolling-mean-RT               ; to keep track of rolling average radicalisation score (RANDOM)
]




;;;;;;;;;;;;;;;
;;; SETUPS ;;;;
;;;;;;;;;;;;;;;

; create 124 politicians (real number within Sweden / 10)


to setup
  clear-all                           ; clear all patches and turtles
  create-prospect-theorists 124       ; create 124 turtles who follow prospect theory
  create-utility-theorists 124        ; create 124 turtles who follow utility theory
  create-random-theorists 124         ; create 124 turtles who follow random theory
  setup-patches                       ; Create the background colour for the model
  setup-pts                           ; setup the prospect theorists
  setup-uts                           ; setup the utility theorists
  setup-rts                           ; setup the random theorists
  setup-globals                       ; setup the environment parameters
  reset-ticks
end


to setup-patches                      ; background colour of abm
  ask patches [set pcolor 131.5]
end


to setup-pts
  ask prospect-theorists [
    set shape "person business"                    ;  Give the agents a shape
    setxy random-xcor random-ycor                  ;  Scatter them across the abm environment
    set size 1.5                                   ;  Set their size
    set color 85                                   ;  Set their colour
    set ideological-stance random-float 1          ;  Give them a random ideological stance between 0 and 1
    set closeness-to-party 0                       ;  Set their closeness to party to 0
    set radicalisation-level 0                     ;  Set their radicalisation level to 0
    set weighted-function 0                        ;  Set their weighted function to 0
    set value-function 0                           ;  Set their value function to 0
    set weighted-closeness 0                       ;  Set their weighted closeness value to 0
    set value-weighted-outcome 0                   ;  Set their value weighted outcome to 0
  ]
end

; these agents have the same parameters as defined in setup-pts
to setup-uts
    ask utility-theorists[
    set shape "person student"
    setxy random-xcor random-ycor
    set size 1.5
    set color 129
    set ideological-stance random-float 1
    set closeness-to-party 0
    set radicalisation-level 0
  ]
end

; these agents have the same parameters as defined in setup-pts
to setup-rts
  ask random-theorists[
    set shape "person"
    setxy random-xcor random-ycor
    set size 1.5
    set color 28
    set ideological-stance random-float 1
    set closeness-to-party 0
    set radicalisation-level 0
  ]
end


to setup-globals
  set party-radicalisation-PT Starting-Radicalisation-Point       ; connect the party radicalisation to the starting point selected by user
  set party-radicalisation-UT Starting-Radicalisation-Point       ; connect the party radicalisation to the starting point selected by user
  set party-radicalisation-RT Starting-Radicalisation-Point       ; connect the party radicalisation to the starting point selected by user
  set the-prospect Electoral-Polling-Trend                        ; set the electoral prospect to the trend selected by the user
  set the-alignment party-alignment                               ; set the party alignment code to trend selected by the user
  define-parameters                                               ; set the prospect theory parameters to the values selected by the user
  set electoral-poll 50                                           ; start the electoral poll at a standardised level of 50 (this is arbitrary)
  set rolling-mean-PT 5                                           ; A mid point * 10 to signify 10 past goes, this will continutously update to create a rolling mean
  set rolling-mean-UT 5                                           ; A mid point * 10 to signify 10 past goes, this will continutously update to create a rolling mean
  set rolling-mean-RT 5                                           ; A mid point * 10 to signify 10 past goes, this will continutously update to create a rolling mean
end

; Aligning parameters with the selected values in the interface
to define-parameters
  if parameter-choice = "Kahneman & Tversky" [ set-KT]
  if parameter-choice = "Harrison and Rutström" [ set-HR]
  if parameter-choice = "Tu" [ set-Tu]
end


to set-KT                                    ; Khaneman and Tversky
  set γ 0.61
  set one-over-γ (1 / 0.61)
  set alpha 0.88
  set beta 0.88
  set loss-aversion-coef -2.25
end

to set-HR                                    ; Harrison and Rutströ
  set γ 0.56
  set one-over-γ (1 / 0.56)
  set alpha 0.71
  set beta 0.72
  set loss-aversion-coef -1.38
end

to set-Tu                                    ; Tu
  set γ 0.71
  set one-over-γ (1 / 0.71)
  set alpha 0.68
  set beta 0.74
  set loss-aversion-coef -3.2
end


;;;;;;;;;;;;;
;;;  Go  ;;;;
;;;;;;;;;;;;;

to go
 get-turtles-moving                       ; facilitate the movement of turtles
 calculate-electoral-prospect             ; based on which prospect is chosen by user
 calculate-closeness-to-party             ; based on how the agents ideology currently differs from party radicalisation score
 calculate-agents-radicalisation-level    ; based on their decision making process
 update-party-radicalisation              ; update each party's radicalisation
 update-electoral-poll                    ; update the electoral poll value
 tick
end


to get-turtles-moving                     ; turtles are asked to move around in a random direction
  ask turtles[
    lt random 40
    rt random 40
    fd 1]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The 5-Step-Process ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Step 1: Electoral Prospect ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to calculate-electoral-prospect
  if the-prospect = "Party poll is on the increase" [calculate-increasing-poll]
  if the-prospect = "Party poll is on the decrease" [calculate-decreasing-poll]
  if the-prospect = "Party poll is slowly increasing" [calculate-moderately-increasing-poll]
  if the-prospect = "Party poll is slowly decreasing" [calculate-moderately-decreasing-poll]
  if the-prospect = "Party poll is rapidly increasing" [calculate-large-increasing-poll]
  if the-prospect = "Party poll is rapidly decreasing" [calculate-large-decreasing-poll]
end

;;; Normal Rates ;;;

to calculate-increasing-poll
  set electoral-change random-float 5                    ; Set the electoral poll to an increase between 0 and 5
  if electoral-change < 0 [set electoral-change 0.1]
end

to calculate-decreasing-poll
  let neg-roll random-float -5                           ; Set the electoral poll to a decrease between 0 and -5
  set electoral-change neg-roll
end

;;; Moderate rates ;;;

to calculate-moderately-increasing-poll
  set electoral-change random-float 2                    ; Set the electoral poll to a small increase between 0 and 2
  if electoral-change < 0 [set electoral-change 0.1]
end

to calculate-moderately-decreasing-poll
  set electoral-change random-float -2                   ; Set the electoral poll to a small decrease between 0 and -2
  if electoral-change > 0 [set electoral-change -0.1]
end

;;; Rapid rates ;;;

to calculate-large-increasing-poll
  set electoral-change (random-float 2 + 3)              ; Set the electoral poll to a large increase between 3 and 5
  if electoral-change < 0 [set electoral-change 0.1]
end

to calculate-large-decreasing-poll
  let neg-roll (random-float -2 - 3)                     ; Set the electoral poll to a large decrease between -3 and -5
  set electoral-change neg-roll
end


;;;;;;;;;;;;;;;;;;;;;
; Step 2: Closeness ;
;;;;;;;;;;;;;;;;;;;;;

to calculate-closeness-to-party
  if the-alignment = "Party is operating normally" [calculate-normal-party-closeness]
  if the-alignment = "Party is closely aligned"    [calculate-aligned-party-closeness]
  if the-alignment = "Party is vastly misaligned"  [calculate-misaligned-party-closeness]
end



to calculate-normal-party-closeness                          ; set the closeness to party as party radicalisation - agent's ideological stance
  ask prospect-theorists[
    if ideological-stance < 0 [set ideological-stance 0]   ; a safety check to ensure we're working on the correct scale
    ifelse ideological-stance < party-radicalisation-PT [set closeness-to-party (party-radicalisation-PT - ideological-stance)]
                                                        [set closeness-to-party (ideological-stance - party-radicalisation-PT)]
    if closeness-to-party > 1 [set closeness-to-party 0.99999] ; to ensure closeness is within the necessary scale
    if closeness-to-party < 0 [set closeness-to-party 0.00001]]

  ask utility-theorists[
    if ideological-stance < 0 [set ideological-stance 0]   ; a safety check to ensure we're working on the correct scale
    ifelse ideological-stance < party-radicalisation-UT [set closeness-to-party (party-radicalisation-UT - ideological-stance)]
                                                        [set closeness-to-party (ideological-stance - party-radicalisation-UT)]
    if closeness-to-party > 1 [set closeness-to-party 0.99999] ; to ensure closeness is within the necessary scale
    if closeness-to-party < 0 [set closeness-to-party 0.00001]]

    ask random-theorists[
    if ideological-stance < 0 [set ideological-stance 0]   ; a safety check to ensure we're working on the correct scale
    ifelse ideological-stance < party-radicalisation-RT [set closeness-to-party (party-radicalisation-RT - ideological-stance)]
                                                        [set closeness-to-party (ideological-stance - party-radicalisation-RT)]
    if closeness-to-party > 1 [set closeness-to-party 0.99999] ; to ensure closeness is within the necessary scale
    if closeness-to-party < 0 [set closeness-to-party 0.00001]]
end


to calculate-aligned-party-closeness
  calculate-normal-party-closeness
  ask prospect-theorists [
    if closeness-to-party > 0.2 [set closeness-to-party random-float 0.2]]    ; if the agent's closeness is far away, then force them to be more aligned
  ask utility-theorists [
    if closeness-to-party > 0.2 [set closeness-to-party random-float 0.2]]
  ask random-theorists [
    if closeness-to-party > 0.2 [set closeness-to-party random-float 0.2]]
end


to calculate-misaligned-party-closeness
  calculate-normal-party-closeness
  ask prospect-theorists [
    if closeness-to-party < 0.3 [set closeness-to-party random-float 0.5 + 0.4]] ; if the agent's closeness is close away, then force them to be misaligned
  ask utility-theorists [
    if closeness-to-party < 0.3 [set closeness-to-party random-float 0.5 + 0.4]]
  ask random-theorists [
    if closeness-to-party < 0.3 [set closeness-to-party random-float 0.5 + 0.4]]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;
; Step 3: Radicalisation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to calculate-agents-radicalisation-level
  ask prospect-theorists [calculate-radicalisation-pt]
  ask utility-theorists  [calculate-radicalisation-ut]
  ask random-theorists   [calculate-radicalisation-rt]
end

to calculate-radicalisation-pt
  ;;; Weighted function ;;;
  let probability-power-γ (closeness-to-party ^ γ)       ; calculates closeness to the power of theta (should always be positive number)
  set weighted-function (probability-power-γ / (probability-power-γ + (1 - closeness-to-party)^ γ)^ one-over-γ)
  set weighted-closeness (weighted-function * (1 - closeness-to-party))

  ;;; Value function ;;;
  if electoral-change >= 0 [set value-function (electoral-change ^ alpha)]
  if electoral-change < 0  [set value-function (loss-aversion-coef * ((- electoral-change)^ beta))]
  set value-weighted-outcome (value-function * electoral-change)


  ;;; Calculate R ;;;
  let R (weighted-closeness * value-weighted-outcome)
  set radicalisation-level R
end

to calculate-radicalisation-ut
  let R-ut (closeness-to-party * electoral-change)
  set radicalisation-level R-ut
end


; Here we're forcing the agents to pick in bands of numbers and excluding the mid-point 0.5 +/1 0.1 to try to ensure they don't all cluster around 0.5
; It still results in random decisions
to calculate-radicalisation-rt
  if who < 280 [set radicalisation-level random-float 0.2]
  if who < 310  and who >= 280 [set radicalisation-level (random-float 0.4 + 0.2)] ; not totally biasing the results, but allows some results slip into the cutoff zone
  if who < 340 and who >= 310 [set radicalisation-level (random-float 0.8 + 0.4)]
  if who < 400 and who >= 310 [set radicalisation-level random-float 1]
  if radicalisation-level > 1 [set radicalisation-level random-float 1]
end




to update-party-radicalisation
  ;Get the current mean for this simulation
  let this-rounds-mean-PT mean [radicalisation-level] of prospect-theorists
  let this-rounds-mean-UT mean [radicalisation-level] of utility-theorists
  let this-rounds-mean-RT mean [radicalisation-level] of random-theorists

  ; Update radicalisation score based on current radicalisation score, the rolling mean, and the new average radicalisation
  set party-radicalisation-PT ((party-radicalisation-PT + rolling-mean-PT + this-rounds-mean-PT) / 12) ; to get new average, taking into account the old average
  set party-radicalisation-UT ((party-radicalisation-UT + rolling-mean-UT + this-rounds-mean-UT) / 12)
  set party-radicalisation-RT ((party-radicalisation-RT + rolling-mean-RT + this-rounds-mean-RT) / 12)

  ; Update the rolling average
  set rolling-mean-PT ((rolling-mean-PT + this-rounds-mean-PT) - (rolling-mean-PT / 10))
  set rolling-mean-UT ((rolling-mean-UT + this-rounds-mean-UT) - (rolling-mean-UT / 10))
  set rolling-mean-RT ((rolling-mean-RT + this-rounds-mean-RT) - (rolling-mean-RT / 10))
end


; need to ammend with numbers
to update-electoral-poll
  let downsampled-electoral-change (electoral-change / 10)
  set electoral-poll electoral-poll + downsampled-electoral-change
end




; if electoral-change < 0  [let v (loss-aversion-coef * ((- electoral-change)^ beta))]
@#$#@#$#@
GRAPHICS-WINDOW
741
51
1142
453
-1
-1
11.91
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
759
13
930
46
Load up the politicians
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
945
12
1111
45
Let the election begin 
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
9
456
249
501
Starting-Radicalisation-Point
Starting-Radicalisation-Point
0.2 0.4 0.6 0.8
2

TEXTBOX
17
15
354
57
Decision Making in Politics 
26
123.0
1

CHOOSER
10
311
248
356
Electoral-Polling-Trend
Electoral-Polling-Trend
"Party poll is on the increase" "Party poll is on the decrease" "Party poll is slowly increasing" "Party poll is slowly decreasing" "Party poll is rapidly increasing" "Party poll is rapidly decreasing"
1

TEXTBOX
15
290
246
330
How is the party performing?
16
123.0
1

MONITOR
525
334
728
379
Radicalisation with Prospect Theory
party-radicalisation-PT
2
1
11

MONITOR
523
392
728
437
Radicalisation with Utility Theory
party-radicalisation-UT
2
1
11

TEXTBOX
12
435
219
455
How radical is the party?
16
123.0
1

CHOOSER
298
346
488
391
parameter-choice
parameter-choice
"Kahneman & Tversky" "Harrison and Rutström" "Tu"
0

MONITOR
300
395
357
440
NIL
alpha
17
1
11

MONITOR
363
395
420
440
NIL
beta
17
1
11

MONITOR
428
395
485
440
NIL
γ
17
1
11

MONITOR
300
446
485
491
NIL
loss-aversion-coef
17
1
11

TEXTBOX
317
320
484
348
Who's parameters? 
16
123.0
1

PLOT
458
52
726
282
Tracking the electoral change 
Ticks
Electoral poll 
0.0
500.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -5298144 true "" "plot electoral-poll"

PLOT
18
52
446
283
Radicalisation of Party
NIL
Radicalisation level
0.0
10.0
0.0
10.0
true
true
"" "\n"
PENS
"Prospect Theorists" 1.0 0 -11221820 true "" "plot party-radicalisation-PT"
"Utility Theorists" 1.0 0 -2064490 true "" "plot party-radicalisation-UT"
"Random Theorists" 1.0 0 -817084 true "" "plot party-radicalisation-RT"

MONITOR
522
448
729
493
Radicalisation with Random Theory
party-radicalisation-RT
2
1
11

CHOOSER
10
383
249
428
party-alignment
party-alignment
"Party is operating normally" "Party is closely aligned" "Party is vastly misaligned"
0

TEXTBOX
12
362
224
393
How is the party aligned?
16
123.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>party-radicalisation-PT</metric>
    <metric>party-radicalisation-UT</metric>
    <metric>party-radicalisation-RT</metric>
    <enumeratedValueSet variable="Starting-Radicalisation-Point">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Electoral-Polling-Trend">
      <value value="&quot;Party poll is on the decrease&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="party-alignment">
      <value value="&quot;Party is vastly misaligned&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parameter-choice">
      <value value="&quot;Kahneman &amp; Tversky&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>party-radicalisation-PT</metric>
    <metric>party-radicalisation-UT</metric>
    <metric>party-radicalisation-RT</metric>
    <enumeratedValueSet variable="Starting-Radicalisation-Point">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Electoral-Polling-Trend">
      <value value="&quot;Party poll is on the increase&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="party-alignment">
      <value value="&quot;Party is vastly misaligned&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parameter-choice">
      <value value="&quot;Kahneman &amp; Tversky&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>party-radicalisation-PT</metric>
    <metric>party-radicalisation-UT</metric>
    <metric>party-radicalisation-RT</metric>
    <enumeratedValueSet variable="Starting-Radicalisation-Point">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Electoral-Polling-Trend">
      <value value="&quot;Party poll is on the increase&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="party-alignment">
      <value value="&quot;Party is closely aligned&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parameter-choice">
      <value value="&quot;Kahneman &amp; Tversky&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>party-radicalisation-PT</metric>
    <metric>party-radicalisation-UT</metric>
    <metric>party-radicalisation-RT</metric>
    <enumeratedValueSet variable="Starting-Radicalisation-Point">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Electoral-Polling-Trend">
      <value value="&quot;Party poll is on the decrease&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="party-alignment">
      <value value="&quot;Party is closely aligned&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parameter-choice">
      <value value="&quot;Kahneman &amp; Tversky&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>party-radicalisation-PT</metric>
    <metric>party-radicalisation-UT</metric>
    <metric>party-radicalisation-RT</metric>
    <enumeratedValueSet variable="Starting-Radicalisation-Point">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Electoral-Polling-Trend">
      <value value="&quot;Party poll is on the increase&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="party-alignment">
      <value value="&quot;Party is operating normally&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parameter-choice">
      <value value="&quot;Kahneman &amp; Tversky&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>party-radicalisation-PT</metric>
    <metric>party-radicalisation-UT</metric>
    <metric>party-radicalisation-RT</metric>
    <enumeratedValueSet variable="Starting-Radicalisation-Point">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Electoral-Polling-Trend">
      <value value="&quot;Party poll is on the decrease&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="party-alignment">
      <value value="&quot;Party is operating normally&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parameter-choice">
      <value value="&quot;Kahneman &amp; Tversky&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
