@replaceMethod(ScriptedPuppet)
private final func TriggerNewPerkFinisher(evt: ref<InteractionChoiceEvent>, playerPuppet: ref<PlayerPuppet>) -> Void {
    let isFastFinisher: Bool;
    let isInKnockdown: Bool = this.GetHitReactionComponent().IsInKnockdown() || StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.HitReactionStagger");
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    let isOnGround: Bool = bb.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsOnGround);

    if this.BlockWorkspotFinishers() || StatusEffectSystem.ObjectHasStatusEffect(playerPuppet, t"BaseStatusEffect.BlockWorkspotFinisherStatusEffect") || StatusEffectSystem.ObjectHasStatusEffect(playerPuppet, t"BaseStatusEffect.AdvancedBerserkPlayerBuff") || !isOnGround || isInKnockdown {
      isFastFinisher = true;
    } else {
      isFastFinisher = !this.IsInFinisherHealthThreshold(playerPuppet);
    };
    StatusEffectHelper.ApplyStatusEffect(playerPuppet, t"BaseStatusEffect.BlockFinisherStatusEffect", playerPuppet.GetEntityID());
    StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.FinisherActiveStatusEffect");
    this.PushFinisherActionEventToPSM(evt, isFastFinisher);
  }