// adds access point hacking Status effect rewards
// made by rfuzzo
// version 1.0

@wrapMethod(AccessPointControllerPS) 
private final func ProcessLoot(baseMoney: Float, craftingMaterial: Bool, baseShardDropChance: Float, TS: ref<TransactionSystem>) -> Void {
  wrappedMethod(baseMoney, craftingMaterial, baseShardDropChance, TS);

  // tier I: + max RAM
  if baseMoney > 0.0 {
    StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.Access_Point_Buff1", this.GetPlayerMainObject().GetEntityID());
  }
  // tier II: + RAM recovery rate
  if craftingMaterial {
    StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.Access_Point_Buff2", this.GetPlayerMainObject().GetEntityID());
  }
  // tier III: + QH upload speed
  if baseShardDropChance > 0.0 {
    StatusEffectHelper.ApplyStatusEffect(this.GetPlayerMainObject(), t"BaseStatusEffect.Access_Point_Buff3", this.GetPlayerMainObject().GetEntityID());
  }
}