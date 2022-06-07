/// modAttributeRespec
/// by rfuzzo
/// Version 1.0


// --------------- Debug

// public static func LogDebug(const str: script_ref<String>) -> Void {
//   LogChannel(n"DEBUG", str);
// }

// --------------- PlayerDevelopmentData
@wrapMethod(PlayerDevelopmentData)
public final const func RemoveAllPerks(free: Bool) -> Void {
  wrappedMethod(free);

  this.RemoveAllAttributes();
}

// add a new method to check if type is attribute
// the vanilla method adds gunslinger
@addMethod(PlayerDevelopmentData)
public final static func rf_IsAttribute(type: gamedataStatType) -> Bool {
    switch type {
      case gamedataStatType.Strength:
        return true;
      case gamedataStatType.Reflexes:
        return true;
       case gamedataStatType.Intelligence:
        return true;
      case gamedataStatType.TechnicalAbility:
        return true;
       case gamedataStatType.Cool:
        return true;      
      default:
        return false;
    };
  }

@addMethod(PlayerDevelopmentData)
public final const func GetDevPointsSpent(type: gamedataDevelopmentPointType) -> Int32 {
  return this.m_devPoints[this.GetDevPointsIndex(type)].spent;
}

// -- Respec Attributes
@addMethod(PlayerDevelopmentData)
private final func RemoveAllAttributes() {
  let i: Int32;
  let attVal: Float;
  let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_owner.GetGame());
  let type: gamedataStatType;
  
  i = 0;
  while i < EnumInt(gamedataStatType.Count) {
      type = IntEnum(i);
      if PlayerDevelopmentData.rf_IsAttribute(type) {
        if IsDefined(this.m_owner) {
          attVal = ss.GetStatValue(Cast(this.m_owner.GetEntityID()), IntEnum(i));
        } else {
          attVal = 3.00;
        };
        
        //LogDebug("[AR] GetStatValue " + type + " value: "  + ToString(attVal));

        this.SetAttribute(type, 3.00);
        
      };
      i += 1;
    };

  let dIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Attribute);  
  let statSys: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_owner.GetGame());
  let available : Int32 = RoundF(statSys.GetStatValue(Cast(this.m_ownerID), gamedataStatType.Level)) + 6; // + 6 because player level -1 plus 7 starting attribute points 

  this.m_devPoints[dIndex].unspent = available;
  this.m_devPoints[dIndex].spent = 0;

  this.UpdateUIBB();
}

// --------------- PlayerDevelopmentSystem
@addMethod(PlayerDevelopmentSystem)
public final const func GetDevPointsSpent(owner: ref<GameObject>, type: gamedataDevelopmentPointType) -> Int32 {
  let developmentData: ref<PlayerDevelopmentData> = this.GetDevelopmentData(owner);
  return developmentData.GetDevPointsSpent(type);
}

// --------------- PlayerDevelopmentDataManager
@addMethod(PlayerDevelopmentDataManager)
public final func GetSpentAttributePoints() -> Int32 {
  return this.m_playerDevSystem.GetDevPointsSpent(this.m_player, gamedataDevelopmentPointType.Attribute);
}

// --------------- PerksMainGameController
// Always display respec button
@replaceMethod(PerksMainGameController)
public final func SetRespecButton(visible: Bool) -> Void {
    let spentPerkPoints: Int32;
    if !visible {
      inkWidgetRef.SetVisible(this.m_respecButtonContainer, false);
      return;
    };
    spentPerkPoints = this.m_dataManager.GetSpentPerkPoints() + this.m_dataManager.GetSpentTraitPoints();

    //modAttributeRespec++
    let spentAttributePoints: Int32 = this.m_dataManager.GetSpentAttributePoints();
    let canShowRespecButton : Bool = spentPerkPoints > 0 || spentAttributePoints > 0;

    //LogDebug("[AR] spentPerkPoints " + spentPerkPoints + " spentAttributePoints: "  + spentAttributePoints);
    //modAttributeRespec--

    inkWidgetRef.SetVisible(this.m_respecButtonContainer, canShowRespecButton); //modAttributeRespec
    inkTextRef.SetText(this.m_spentPerks, IntToString(spentPerkPoints));
    inkTextRef.SetText(this.m_resetPrice, IntToString(this.m_dataManager.GetTotalRespecCost()));
    this.enoughMoneyForRespec = this.m_dataManager.CheckRespecCost();
    if this.m_inCombat || !this.enoughMoneyForRespec {
      inkWidgetRef.SetState(this.m_respecButtonContainer, n"Disable");
    } else {
      inkWidgetRef.SetState(this.m_respecButtonContainer, n"Default");
    };
  }

// Update UI with reset attributes
@wrapMethod(PerksMainGameController)
protected cb func OnPerkResetEvent(evt: ref<PerkResetEvent>) -> Bool {
  wrappedMethod(evt);

  this.RefreshAttributeControllers(); 
}

@addMethod(PerksMainGameController)
private final func RefreshAttributeControllers() {
  let attributes: array<ref<AttributeData>>;
  let i: Int32;
  let j: Int32;

  attributes = this.m_dataManager.GetAttributes();
  i = 0;
  while i < ArraySize(attributes) {
    j = 0;
    while j < ArraySize(this.m_attributesControllersList) {
      if Equals(this.m_attributesControllersList[j].GetStatType(), attributes[i].type) {
        this.m_attributesControllersList[j].UpdateData(attributes[i]);
      }
      j += 1;
    };
    i += 1;
  };
  this.m_tooltipsManager.RefreshTooltip(0);
  this.m_tooltipsManager.RefreshTooltip(n"perkTooltip");
}