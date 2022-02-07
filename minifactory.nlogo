; Inpired from http://www.netlogoweb.org/launch#http://ccl.northwestern.edu/netlogo/models/models/Sample%20Models/Computer%20Science/Robotic%20Factory.nlogo
; We now monitor the costs and the gains per tick
; Operations now take time and only one robot can use a machine at the same time. This is achieved by introducing links.
; Operations can now fail and produce defects.
; Defects have to be eliminated by control points. If not, there is penalty instead of a gain.
; Intermediary control points can be supressed, with the risk of piling added value on parts that have a defect.
; The "game" is to adjust the parameters in order to maximize the margin.


; ---------------
; Declarations
; ---------------
breed [ robots robot ]
breed [ materials material ]
breed [ control_materials control_material ]
breed [ forges forge ]
breed [ control_forges control_forge ]
breed [ polishers polisher ]
breed [ control_polishers control_polisher ]
breed [ lathes lathe ]
breed [ control_lathes control_lathe ]
breed [ shipments shipment ]
breed [ sales sold ]
directed-link-breed [operations operation] ; from the machine to the robot

globals [
  costs         ; total costs from the start  (€)
  gains         ; total gains from the start  (€)
  margin        ; total margin from the start (€)
]

robots-own [
  destination  ; next workstation for the robot
]

operations-own [
  duration     ; Number of ticks an operation use
  cost         ; cost per part of the operation
]

; Setup the factory and robots when pressed
to setup
  clear-all
  setup-factory
  setup-robots
  reset-ticks
end

; Settle the workstations on the factory
to setup-factory
  create-materials 1 [
    setxy -10 0
    set color blue
    set shape "square"
    set label (word "material")
    set label-color white
  ]
  create-control_materials 1 [
    setxy -10 -5
    set color blue
    set shape "square"
    set label (word "control")
    set label-color white
  ]
  create-forges 1 [
    setxy -5 0
    set color blue
    set shape "square"
    set label (word "forge")
    set label-color white
  ]
  create-control_forges 1 [
    setxy -5 -5
    set color blue
    set shape "square"
    set label (word "control")
    set label-color white
  ]
  create-polishers 1 [
    setxy 0 0
    set color blue
    set shape "square"
    set label (word "polisher")
    set label-color white
  ]
  create-polishers 1 [
    setxy 0 5
    set color blue
    set shape "square"
    set label (word "polisher")
    set label-color white
  ]
  create-polishers 1 [
    setxy 0 10
    set color blue
    set shape "square"
    set label (word "polisher")
    set label-color white
  ]
  create-control_polishers 1 [
    setxy 0 -5
    set color blue
    set shape "square"
    set label (word "control")
    set label-color white
  ]
  create-lathes 1 [
    setxy 5 0
    set color blue
    set shape "square"
    set label (word "lathe")
    set label-color white
  ]
  create-lathes 1 [
    setxy 5 5
    set color blue
    set shape "square"
    set label (word "lathe")
    set label-color white
  ]
  create-control_lathes 1 [
    setxy 5 -5
    set color blue
    set shape "square"
    set label (word "control")
    set label-color white
  ]
  create-shipments 1 [
    setxy 10 0
    set color blue
    set shape "square"
    set label (word "shipping")
    set label-color white
  ]
  create-sales 1 [
    setxy 10 -5
    set color blue
    set shape "square"
    set label (word "sold")
    set label-color white
  ]
end

; give birth to some robotic crates
to setup-robots
  create-robots crates                  ; crates is the number of robots
  ask robots [
    set destination one-of materials    ; start by going to the materials workstation
    setxy random-xcor random-ycor       ; just point in a random direction at start
    set color green                     ; robots are green by default, parts have no defects
    set shape "box"                     ; it is crates of parts afterall
  ]
end

to go
  route          ; decide the destination
  manufacture    ; manufacture the product (operation)
  compute-margin ; update the total margin per tick KPI
  move           ; move towards destination if no operation is ongoing
  tick
end

; this is the main KPI we want to track
; it represent the total margin per tick
; this value converge over time, enabling comparisons
to compute-margin
  set margin ((gains - costs) / ( ticks + 1))
end

; create link to act the fact that a manufacturing operation is ongoing
to manufacture
  ; we are working on the links that represent the manufacturing operation
  ask operations [
    ; at each tick, decrease the remaning duration
    if duration > 0 [ set duration duration - 1 ]
    ; when the duration reach zero, the link is released
    if duration <= 0 [
      set costs costs + cost
      die
    ]
  ]
end

; decide the direction
; create the operation at the workstation
; create defects
to route
  ask robots [
    (ifelse
    ; ---------------
    ; Step1: Materials
    ; ---------------
      [ breed ] of destination = materials [
        if any? materials-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of materials-here = 0 [
            ; create the link with the machine
            create-operation-from one-of materials-here  [
              set duration time_material
              set cost cost_material * batch
            ]
            ; create a defect if unlucky
            if random 1000 < (10 * defects_material) [ set color red ]
            ; update the destination for the next time the robot will be able to move
            ifelse do_control_material
              [ set destination one-of control_materials ]
              [ set destination one-of forges ]
            ]
          ]
      ]
    ; ---------------
    ; Step1.1: Control material
    ; ---------------
      [ breed ] of destination = control_materials [
        if any? control_materials-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of control_materials-here = 0 [
            ; create the link with the machine
            create-operation-from one-of control_materials-here  [
              set duration time_control_material
              set cost cost_control_material * batch
            ]
            ; update the destination for the next time the robot will be able to move
            ifelse color = red
              ; bad part, trow it to the bin, loose all added value
              [
                set destination one-of materials
                set color green
              ]
              ; good part, keep it
              [ set destination one-of forges ]
            ]
          ]
      ]
    ; ---------------
    ; Step2: Forge
    ; ---------------
      [ breed ] of destination = forges [
        if any? forges-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of forges-here = 0 [
            ; create the link with the machine
            create-operation-from one-of forges-here [
              set duration time_forge
              set cost cost_forge * batch
            ]
            ; create a defect if unlucky
            if random 1000 < (10 * defects_forge) [ set color red ]
            ; update the destination for the next time the robot will be able to move
            ifelse do_control_forge
              [ set destination one-of control_forges ]
              [ set destination one-of polishers ]
            ]
          ]
      ]
    ; ---------------
    ; Step2.1: Control Forges
    ; ---------------
      [ breed ] of destination = control_forges [
        if any? control_forges-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of control_forges-here = 0 [
            ; create the link with the machine
            create-operation-from one-of control_forges-here  [
              set duration time_control_forge
              set cost cost_control_forge * batch
            ]
            ; update the destination for the next time the robot will be able to move
            ifelse color = red
              ; bad part, trow it to the bin, loose all added value
              [
                set destination one-of materials
                set color green
              ]
              ; good part, keep it
              [ set destination one-of polishers ]
            ]
          ]
      ]
    ; ---------------
    ; Step3: Polisher
    ; ---------------
      [ breed ] of destination = polishers [
        if any? polishers-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of polishers-here = 0 [
            ; create the link with the machine
            create-operation-from one-of polishers-here [
              set duration time_polisher
              set cost cost_polisher * batch
            ]
            ; create a defect if unlucky
            if random 1000 < (10 * defects_polisher) [ set color red ]
            ; update the destination for the next time the robot will be able to move
            ; update the destination for the next time the robot will be able to move
            ifelse do_control_polisher
              [ set destination one-of control_polishers ]
              [ set destination one-of lathes ]
            ]
          ]
      ]
    ; ---------------
    ; Step3.1: Control Polishers
    ; ---------------
      [ breed ] of destination = control_polishers [
        if any? control_polishers-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of control_polishers-here = 0 [
            ; create the link with the machine
            create-operation-from one-of control_polishers-here  [
              set duration time_control_polisher
              set cost cost_control_polisher * batch
            ]
            ; update the destination for the next time the robot will be able to move
            ifelse color = red
              ; bad part, trow it to the bin, loose all added value
              [
                set destination one-of materials
                set color green
              ]
              ; good part, keep it
              [ set destination one-of lathes ]
            ]
          ]
      ]
    ; ---------------
    ; Step4: Lathe
    ; ---------------
      [ breed ] of destination = lathes [
        if any? lathes-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of lathes-here = 0 [
            ; create the link with the machine
            create-operation-from one-of lathes-here [
              set duration time_lathe
              set cost cost_lathe * batch
            ]
            ; create a defect if unlucky
            if random 1000 < (10 * defects_lathe) [ set color red ]
            ; update the destination for the next time the robot will be able to move
            ; update the destination for the next time the robot will be able to move
            ifelse do_control_material
              [ set destination one-of control_lathes ]
              [ set destination one-of shipments ]
            ]
          ]
      ]
    ; ---------------
    ; Step4.1: Control lathes
    ; ---------------
      [ breed ] of destination = control_lathes [
        if any? control_lathes-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of control_lathes-here = 0 [
            ; create the link with the machine
            create-operation-from one-of control_lathes-here [
              set duration time_control_lathe
              set cost cost_control_lathe * batch
            ]
            ; update the destination for the next time the robot will be able to move
            ifelse color = red
              ; bad part, trow it to the bin, loose all added value
              [
                set destination one-of materials
                set color green
              ]
              ; good part, keep it
              [ set destination one-of shipments ]
            ]
          ]
      ]
    ; ---------------
    ; Step6: Shipping
    ; ---------------
      [ breed ] of destination = shipments [
        if any? shipments-here
          ; If we are on the machine then link to it
          [
          if [count links] of one-of shipments-here = 0 [
            ; create the link with the machine
            create-operation-from one-of shipments-here [
              set duration 3
              set cost 1
            ]
            ; create a defect if unlucky
            if random 1000 < (10 * defects_shipping) [ set color red ]
            ; update the destination for the next time the robot will be able to move
            set destination one-of sales
            ]
          ]
      ]
    ; ---------------
    ; Step6: Sales
    ; ---------------
      [ breed ] of destination = sales [
        if any? sales-here [
          ; Update the destination for the robot to move next time and avoid doing this twice
          set destination one-of materials
          ; Get some gain if the part is good or a penalty if there is defect.
          ifelse color = red
            [ set gains gains - (penalty * batch) print("The client recieved a part with defects!")]
            [ set gains gains + (price * batch) ]
          ; let the robot become green again ^^
          set color green
        ]
      ]
    ; ---------------
    ; Handle exceptions
    ; ---------------
      [ breed ] of destination = nobody [
        print "ERROR: destination is nobody"
        set destination one-of materials
      ]
    ; ---------------
    ; Else condition
    ; ---------------
      [
        print "ERROR: entered else condition in move"
        set destination one-of materials
      ]
    )
  ]
end

; make the robots moving
to move
  ask robots [
    ; move only if there is no link to a machine
    if count operation-neighbors = 0 [
        if can-move? 1 [forward 1 face destination]
    ]
  ]
end



@#$#@#$#@
GRAPHICS-WINDOW
238
10
675
448
-1
-1
13.0
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
0
0
1
ticks
30.0

BUTTON
35
37
155
70
setup
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
33
90
155
123
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
684
11
1085
241
Costs vs Gains per tick
Time
Euros
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"costs" 1.0 0 -2674135 true "" "plot costs / (ticks + 1)"
"gains" 1.0 0 -13840069 true "" "plot gains / (ticks + 1)"

SLIDER
685
247
857
280
cost_material
cost_material
0
5
1.5
0.1
1
€
HORIZONTAL

SLIDER
887
248
1059
281
cost_forge
cost_forge
0
5
0.5
0.1
1
€
HORIZONTAL

SLIDER
1077
243
1249
276
cost_polisher
cost_polisher
0
5
0.1
0.1
1
€
HORIZONTAL

SLIDER
29
180
201
213
batch
batch
0
10000
9236.0
1
1
parts
HORIZONTAL

SLIDER
1272
244
1444
277
cost_lathe
cost_lathe
0
5
2.0
0.1
1
€
HORIZONTAL

SLIDER
1275
411
1447
444
cost_control_lathe
cost_control_lathe
0
2
0.3
0.1
1
€
HORIZONTAL

SWITCH
1273
369
1422
402
do_control_lathe
do_control_lathe
0
1
-1000

SLIDER
1272
285
1444
318
time_lathe
time_lathe
0
50
37.0
1
1
ticks
HORIZONTAL

SLIDER
1273
324
1445
357
defects_lathe
defects_lathe
0
20
2.4
0.1
1
%
HORIZONTAL

SLIDER
1452
244
1624
277
cost_shipping
cost_shipping
0
5
0.1
0.1
1
€
HORIZONTAL

SLIDER
29
223
201
256
price
price
0
50
11.8
0.1
1
€
HORIZONTAL

SLIDER
685
288
857
321
time_material
time_material
0
50
8.0
1
1
ticks
HORIZONTAL

SLIDER
886
289
1058
322
time_forge
time_forge
0
50
23.0
1
1
ticks
HORIZONTAL

SLIDER
1077
284
1249
317
time_polisher
time_polisher
0
50
50.0
1
1
ticks
HORIZONTAL

SLIDER
28
266
200
299
penalty
penalty
0
50
50.0
0.1
1
€
HORIZONTAL

SLIDER
1453
285
1625
318
time_shipping
time_shipping
0
50
10.0
1
1
ticks
HORIZONTAL

SLIDER
685
330
857
363
defects_material
defects_material
0
20
1.1
0.1
1
%
HORIZONTAL

SLIDER
1079
324
1251
357
defects_polisher
defects_polisher
0
20
1.3
0.1
1
%
HORIZONTAL

SLIDER
887
330
1059
363
defects_forge
defects_forge
0
20
1.1
0.1
1
%
HORIZONTAL

SWITCH
684
370
849
403
do_control_material
do_control_material
1
1
-1000

SWITCH
887
370
1038
403
do_control_forge
do_control_forge
1
1
-1000

SWITCH
1078
370
1242
403
do_control_polisher
do_control_polisher
1
1
-1000

SLIDER
1276
451
1456
484
time_control_lathe
time_control_lathe
0
10
4.0
1
1
ticks
HORIZONTAL

SLIDER
1454
326
1626
359
defects_shipping
defects_shipping
0
20
0.0
0.1
1
%
HORIZONTAL

SLIDER
1076
410
1254
443
cost_control_polisher
cost_control_polisher
0
2
0.1
0.1
1
€
HORIZONTAL

SLIDER
886
408
1058
441
cost_control_forge
cost_control_forge
0
2
0.3
0.1
1
€
HORIZONTAL

SLIDER
681
409
860
442
cost_control_material
cost_control_material
0
2
0.3
0.1
1
€
HORIZONTAL

SLIDER
887
451
1069
484
time_control_forge
time_control_forge
0
10
2.0
1
1
ticks
HORIZONTAL

SLIDER
1078
452
1273
485
time_control_polisher
time_control_polisher
0
10
2.0
1
1
ticks
HORIZONTAL

SLIDER
682
451
878
484
time_control_material
time_control_material
0
10
2.0
1
1
ticks
HORIZONTAL

SLIDER
29
138
201
171
crates
crates
0
50
20.0
1
1
NIL
HORIZONTAL

PLOT
1093
13
1480
239
Margin per tick
Time
Euros
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"margin" 1.0 0 -16777216 true "" "plot margin"

MONITOR
1405
168
1462
213
NIL
margin
0
1
11

@#$#@#$#@
## WHAT IS IT?

This model simulate a factory.

Mechanisms are partially inspired from:

> Martin, K. and Wilensky, U. (2021). NetLogo Robotic Factory model.
> http://ccl.northwestern.edu/netlogo/models/RoboticFactory
> Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Moving agents are robotic crates with parts inside.

Static agents are workstations. Manufacturing machines, control posts, shipping and sales.

The following mechanisms have been implemented:

- Operations now take time and only one operation can be achieved at the same time. This is done by relying on decaying links.
- Defects can appear during the manufacturing operations.
- Control operations delet the defective crates
- We monitor the margin
- All production parameters can be modified by sliders
- There are also switches that bypass controls

## HOW IT WORKS

Robots move toward a destination.

The destination is fixed workstation per workstation.

Each time a robot come a workstation, it recieve a next destination.

Howerver, when they are at a workstation, the robots are linked to it.

The duration of the link represent the duration of the manufacturing, shipping or control operation. Links also infer a cost.

There are different types of operations:

- Get and cut the material. A steel rod.
- Forge the steel rod by stamping, it create the raw shape of the part.
- The deburring operation is not included for simplicity reasons. Let's say it is part of the forge.
- Polish the part to make it shine.
- Machine tool the parts on a CNC Lathe
- Ship the part
- Gain money if the shipped part is conform.
- If there is a defect however, the gain is negative. 

I wrote a detailled tutorial, so you can refer to it for more information:

- English: [Introduction to simulation with NetLogo: how to create a small factory?](https://thibaut-deveraux.medium.com/introduction-to-simulation-with-netlogo-how-to-create-a-small-factory-2955d45076b)
- French : [Introduction à la simulation avec NetLogo : comment créer une petite usine ?](https://thibaut-deveraux.medium.com/introduction-%C3%A0-la-simulation-avec-netlogo-comment-cr%C3%A9er-une-petite-usine-b723a87aa002)

## HOW TO USE IT

### Base

* **setup** Install the workstations and robots inside the factory
* **go** launch the simulation


### Global parameters

* **crates** defines the number of robotic crates
* **batch** defines the number of parts in each crate
* **price** defines the gain from a part sale (minus costs not related to manufacturing)
* **penaly** defines the money lost from shipping a crate with defects

### Per workstation

* **cost_...** defines the cost of the operation (monetary)
* **time_...** define the time taken by the operation
* **defects_...** define the proportion of crates becoming defective at this workstation
* **do_control_...** allow to test the effect of bypassing a control post


## THINGS TO NOTICE

** /!\ This model is not meant to simulate an actual factory.**

The autor will take no liability. This is a simplified simulation for learning. It may be used as an extendable base if you know what you are doing and why. Then, you are responsible from what you do with this model.

## THINGS TO TRY

Try to deleted intermediary controls. Except the last one.

If there is a relatively high amout of defects and/or the controls are economic, you will lose money.

With a small amount of defects and/or a economic controls, you may have a positive income.


## EXTENDING THE MODEL

We are far from a realistic manufacturing process. In the real world:

- it is probable that only x% of a crate has defects.
- we loose some parts at each step du to quality issues
- industrial processes are permantly being improved or modified
- defects rates are higher at the start, so there is more controls on new parts
- there are several types of control. Dimensional, visual, tensil strengh...
- some controls are made on a part of the crate, so some defects can still go trough controls
- ...


## NETLOGO FEATURES

- agents
- links

## Licence

This model is relaseased under a [CC BY SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) licence.

## How to cite

> Thibaut DEVERAUX (2022). Small Factory.
> https://thibaut-deveraux.medium.com/introduction-to-simulation-with-netlogo-how-to-create-a-small-factory-2955d45076b
> Released under CC BY SA 4.0


## RELATED MODELS

With inspirations from:

> Martin, K. and Wilensky, U. (2021). NetLogo Robotic Factory model.
> http://ccl.northwestern.edu/netlogo/models/RoboticFactory
> Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## CREDITS AND REFERENCES

- English: [Introduction to simulation with NetLogo: how to create a small factory?](https://thibaut-deveraux.medium.com/introduction-to-simulation-with-netlogo-how-to-create-a-small-factory-2955d45076b)
- French : [Introduction à la simulation avec NetLogo : comment créer une petite usine ?](https://thibaut-deveraux.medium.com/introduction-%C3%A0-la-simulation-avec-netlogo-comment-cr%C3%A9er-une-petite-usine-b723a87aa002)
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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
