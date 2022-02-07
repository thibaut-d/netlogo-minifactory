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

