/// ModAlwaysDismember
/// by rfuzzo
/// Version 1.0

@addMethod(QuestTrackerGameController)
protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
  Log("[RF] OnPlayerAttach");
}

@wrapMethod(ForceDismembermentEffector)
protected func ActionOn(owner: ref<GameObject>) -> Void {
    let rand: Float;
    let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let puppet: wref<ScriptedPuppet> = owner as ScriptedPuppet;
    if !IsDefined(puppet) || !IsDefined(player) {
        return;
    };
    rand = RandF();

    // ModAlwaysDismember++
    this.m_dismembermentChance = 1.0;
    // ModAlwaysDismember--

    if rand <= this.m_dismembermentChance {
        DismembermentComponent.RequestDismemberment(puppet, this.m_bodyPart, this.m_woundType, Vector4.EmptyVector(), this.m_isCritical);
    };
    if this.m_shouldKillNPC || Equals(this.m_bodyPart, gameDismBodyPart.HEAD) {
        StatusEffectHelper.ApplyStatusEffect(puppet, t"BaseStatusEffect.ForceKill", player.GetEntityID());
    };
}


