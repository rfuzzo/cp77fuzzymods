// Mod Cycle trigger modes
// by rfuzzo
// v1.1.1

///////////////////////////////////////////////////////////////////////////////////////////////
// InputContextTransitionEvents

// helper method
@addMethod(InputContextTransitionEvents)
private final func GetWeaponTriggerModesNumber(scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
  let triggerModesArray: array<wref<TriggerMode_Record>>;
  let item: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
  let itemID: ItemID = item.GetItemID();
  let weaponRecordData: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(itemID));
  
  weaponRecordData.TriggerModes(triggerModesArray);
  return ArraySize(triggerModesArray);
}
// helper method
@addMethod(InputContextTransitionEvents)
private final func IsTriggerModeActive(const scriptInterface: ref<StateGameScriptInterface>, triggerMode: gamedataTriggerMode) -> Bool {
  let item: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
  let weapon: ref<WeaponObject> = item as WeaponObject;

  if Equals(weapon.GetCurrentTriggerMode().Type(), triggerMode) {
    return true;
  };
  return false;
}

// add input hints
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowRangedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);

  //LocKey#77771
  if !stateContext.GetBoolParameter(n"isCycleTriggerInputHintDisplayed", true) && this.GetWeaponTriggerModesNumber(scriptInterface) > 1 {
    // SemiAuto
    if this.IsTriggerModeActive(scriptInterface, gamedataTriggerMode.SemiAuto) {
      this.ShowInputHint(scriptInterface, n"CycleTrigger", n"Ranged", GetLocalizedTextByKey(n"Mod-CycleWeapons-SemiAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      stateContext.SetPermanentBoolParameter(n"isCycleTriggerInputHintDisplayed", true, true);
    };
    // Burst
    if this.IsTriggerModeActive(scriptInterface, gamedataTriggerMode.Burst) {
      this.ShowInputHint(scriptInterface, n"CycleTrigger", n"Ranged", GetLocalizedTextByKey(n"Mod-CycleWeapons-Burst"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      stateContext.SetPermanentBoolParameter(n"isCycleTriggerInputHintDisplayed", true, true);
    };
    // FullAuto
    if this.IsTriggerModeActive(scriptInterface, gamedataTriggerMode.FullAuto) {
      this.ShowInputHint(scriptInterface, n"CycleTrigger", n"Ranged", GetLocalizedTextByKey(n"Mod-CycleWeapons-FullAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      stateContext.SetPermanentBoolParameter(n"isCycleTriggerInputHintDisplayed", true, true);
    };
  };
}
// add input hints
@wrapMethod(InputContextTransitionEvents)
protected final func RemoveRangedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);

  stateContext.RemovePermanentBoolParameter(n"isCycleTriggerInputHintDisplayed");
}

///////////////////////////////////////////////////////////////////////////////////////////////
// CycleTriggerModeDecisions and CycleTriggerModeEvents, ReadyEvents

// helper method
@addMethod(WeaponEventsTransition)
protected final func GetWeaponTriggerModesNumber(scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
  let triggerModesArray: array<wref<TriggerMode_Record>>;
  let item: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
  let itemID: ItemID = item.GetItemID();
  let weaponRecordData: ref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(itemID));
  
  weaponRecordData.TriggerModes(triggerModesArray);
  return ArraySize(triggerModesArray);
}

// change cycle enter condition from ADS to button press
@replaceMethod(CycleTriggerModeDecisions)
protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  return scriptInterface.IsActionJustPressed(n"CycleTrigger") && this.GetWeaponTriggerModesNumber(scriptInterface) > 1;
}

// refresh button hints
@wrapMethod(CycleTriggerModeEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  
  wrappedMethod(stateContext, scriptInterface);

  // refresh button hints
  PlayerGameplayRestrictions.PushForceRefreshInputHintsEventToPSM(player);
  // play sound
  GameObject.PlaySoundEvent(scriptInterface.executionOwner, n"w_gun_pistol_power_unity_trigger");
}

// refresh button hints
@wrapMethod(ReadyEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let player: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);

  wrappedMethod(stateContext, scriptInterface);

  // refresh button hints
  PlayerGameplayRestrictions.PushForceRefreshInputHintsEventToPSM(player);
  // set weapon trigger mode if is different from last time
  if this.GetWeaponTriggerModesNumber(scriptInterface) > 1 && !Equals(weaponObject.GetCurrentTriggerMode().Type(), weaponObject.m_triggerMode) { 
    this.SwitchTriggerMode(stateContext, scriptInterface);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// WeaponTransition

// make burst settings dependent on current trigger mode
@addMethod(WeaponTransition)
protected final func SetupNextShootingPhase2(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, cycleTime: Float, burstCycleTime: Float, numShotsBurst: Int32) -> Void {
  let currBurstsInSequenceCount: Int32 = stateContext.GetIntParameter(this.GetShootingNumBurstTotalName(), true);
  
  stateContext.SetPermanentFloatParameter(this.GetCycleTimeRemainingName(), cycleTime, true);
  
  // Burst settings
  // TODO chao doesn't work with that system, disable for now
  if scriptInterface.IsTriggerModeActive(gamedataTriggerMode.Burst) {
    stateContext.SetPermanentFloatParameter(this.GetBurstTimeRemainingName(), burstCycleTime, true); 
    stateContext.SetPermanentIntParameter(this.GetBurstShotsRemainingName(), numShotsBurst, true);
    stateContext.SetPermanentIntParameter(this.GetShootingNumBurstTotalName(), currBurstsInSequenceCount + 1, true);
  } 

  stateContext.SetPermanentBoolParameter(this.GetIsDelayFireName(), false, true);
}

// make burst settings dependent on current trigger mode
@replaceMethod(WeaponTransition)
protected final func StartShootingSequence(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, fireDelay: Float, burstCycleTime: Float, numShotsBurst: Int32, isFullChargeFullAuto: Bool) -> Void {
  stateContext.SetPermanentFloatParameter(this.GetCycleTimeRemainingName(), fireDelay, true);
  stateContext.SetPermanentFloatParameter(this.GetCycleTimeName(), fireDelay, true);
  stateContext.SetPermanentFloatParameter(this.GetCycleTimeRemainingName(), fireDelay, true);
  stateContext.SetPermanentBoolParameter(this.GetIsDelayFireName(), fireDelay > 0.00, true);
  
  // Burst settings
  if scriptInterface.IsTriggerModeActive(gamedataTriggerMode.Burst) {
    stateContext.SetPermanentFloatParameter(this.GetBurstTimeRemainingName(), burstCycleTime, true);
    stateContext.SetPermanentFloatParameter(this.GetBurstTimeName(), burstCycleTime, true);
    stateContext.SetPermanentFloatParameter(this.GetBurstCycleTimeName(), burstCycleTime, true);  

    stateContext.SetPermanentIntParameter(this.GetBurstShotsRemainingName(), numShotsBurst, true);
    // hack to play multiple sounds in burst without making new sound files
    this.GetWeaponObject(scriptInterface).SetupBurstFireSound(1);
  } else {
    // TODO chao doesn't work with that system, disable for now
    stateContext.SetPermanentIntParameter(this.GetBurstShotsRemainingName(), 1, true);
    this.GetWeaponObject(scriptInterface).SetupBurstFireSound(1);
    
  }  
  stateContext.SetPermanentIntParameter(this.GetShootingNumBurstTotalName(), 0, true);
  stateContext.SetPermanentFloatParameter(this.GetShootingStartName(), EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())), true);
  stateContext.SetPermanentBoolParameter(this.GetIsChargedFullAutoName(), isFullChargeFullAuto, true);

  this.GetWeaponObject(scriptInterface).SetTriggerDown(true);
  
}
 
///////////////////////////////////////////////////////////////////////////////////////////////
// FullAutoEvents

// use new method
@replaceMethod(FullAutoEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let cycleTimeForShootingPhase: Float;
  let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  
  this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, 8);
  
  if !this.InShootingSequence(stateContext) {
    this.SetupStandardShootingSequence(stateContext, scriptInterface);
  } else {
    cycleTimeForShootingPhase = this.CalculateCycleTime(stateContext, scriptInterface);
    this.SetupNextShootingPhase2(
      stateContext, 
      scriptInterface, 
      cycleTimeForShootingPhase, 
      statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatType.CycleTime_Burst), Cast<Int32>(statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), 
      gamedataStatType.NumShotsInBurst)));
  };
}

///////////////////////////////////////////////////////////////////////////////////////////////
// WeaponObject

@addField(WeaponObject)
let m_triggerMode : gamedataTriggerMode;

@addMethod(WeaponObject)
protected cb func OnWeaponChangeTriggerMode(evt: ref<WeaponChangeTriggerModeEvent>) -> Void {
  this.m_triggerMode = evt.triggerMode;
}

@wrapMethod(WeaponObject)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();

  this.m_triggerMode = this.GetCurrentTriggerMode().Type();
}