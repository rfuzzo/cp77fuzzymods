/// modNoEncumbarance
/// by rfuzzo
/// Version 1.3

// -- PlayerPuppet
@replaceMethod(PlayerPuppet)
public final func EvaluateEncumbrance() -> Void {
    let carryCapacity: Float;
    let hasEncumbranceEffect: Bool;
    let isApplyingRestricted: Bool;
    let overweightEffectID: TweakDBID;
    let ses: ref<StatusEffectSystem>;
    if this.m_curInventoryWeight < 0.00 {
      this.m_curInventoryWeight = 0.00;
    };
    ses = GameInstance.GetStatusEffectSystem(this.GetGame());
    overweightEffectID = t"BaseStatusEffect.Encumbered";
    hasEncumbranceEffect = ses.HasStatusEffect(this.GetEntityID(), overweightEffectID);
    isApplyingRestricted = StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"NoEncumbrance");

    //modNoEncumbarance++
    isApplyingRestricted = true;
    //modNoEncumbarance--

    carryCapacity = GameInstance.GetStatsSystem(this.GetGame()).GetStatValue(Cast(this.GetEntityID()), gamedataStatType.CarryCapacity);
    if this.m_curInventoryWeight > carryCapacity && !isApplyingRestricted {
      this.SetWarningMessage(GetLocalizedText("UI-Notifications-Overburden"));
    };
    if this.m_curInventoryWeight > carryCapacity && !hasEncumbranceEffect && !isApplyingRestricted {
      ses.ApplyStatusEffect(this.GetEntityID(), overweightEffectID);
    } else {
      if this.m_curInventoryWeight <= carryCapacity && hasEncumbranceEffect || hasEncumbranceEffect && isApplyingRestricted {
        ses.RemoveStatusEffect(this.GetEntityID(), overweightEffectID);
      };
    };
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerStats).SetFloat(GetAllBlackboardDefs().UI_PlayerStats.currentInventoryWeight, this.m_curInventoryWeight, true);
  }