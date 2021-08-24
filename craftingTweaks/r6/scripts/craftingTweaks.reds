/// craftingTweaks
/// by rfuzzo


// -- CraftingMainGameController
@replaceMethod(CraftingMainGameController)
protected cb func OnHoldFinished(evt: ref<ProgressBarFinishedProccess>) -> Bool {
    let quantity: Int32;

    // let tags: array<CName>;
    // let i: Int32 = 0;
    // tags = this.m_selectedRecipe.id.Tags();
    // Log("--- fuzzo msg++ ---");
    // while i < ArraySize(tags) {
    //   Log(ToString(i));
    //   Log(ToString(tags[i]));
    //   i += 1;
    // };
    // Log("--- fuzzo msg-- ---");

    switch this.m_mode {
      case CraftingMode.craft:
        if this.m_selectedRecipe.id.TagsContains(n"Grenade") || this.m_selectedRecipe.id.TagsContains(n"Consumable") || this.m_selectedRecipe.id.TagsContains(n"CraftingPart")  || this.m_selectedRecipe.id.TagsContains(n"Ammo") {
          quantity = this.m_craftingSystem.GetMaxCraftingAmount(this.m_dryItemData);
          if quantity > 1 {
            this.OpenQuantityPicker(this.m_dryInventoryItemData, quantity);
          } else {
            if this.m_selectedRecipe.id.TagsContains(n"Ammo") {
              this.CraftItem(1);
            } else {
              this.CraftItem(this.m_selectedRecipe.amount);
            };
          };
        } else {
          if this.m_selectedRecipe.id.TagsContains(n"Ammo") {
            this.CraftItem(1);
          } else {
            this.CraftItem(this.m_selectedRecipe.amount);
          };
          break;
        };
      case CraftingMode.upgrade:
        this.UpgradeItem();
    };
  }