# Scape Or Die
A open souce game project


## TODO: 
### Controllers
- [ ] ViewModel
### Classes:
- [ ] JailComponent - Jail physical parts that can be interact
    - [ ] CanBeBroken : boolean - alert polices if it is broken
    - [ ] CanBeFaked : boolean- place a fake item so hide the part broken
    - [ ] SignFakeItem : (iemid) -> (boolean | self) - tell the obj what item is the fake item
    - [ ] PlaceFakeItem : (itemUID) -> (boolean | self) - place the fake 

- [ ] Wall - JailComponent

- [ ] Prisoner - act like a prisoner

- [ ] Polices - act like a police

- [ ] NPC (Prisoner and Polices) - be a prisoner ou a police

- [ ] Vent - JailComponent

### Managers:
- [ ] Alert 
- [ ] ViewModel

### Directory: Child of item Directory
- [ ] UseItem - 2 functions: CanUse, UseItem



##### TODO All
###### Equip/Unequip item, make it physically
###### Change datas that store Players to prisoner qhem prisoner class ready

