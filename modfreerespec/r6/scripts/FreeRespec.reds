/// modFreeRespec
/// by rfuzzo
/// Version 1.0


// -- PlayerDevelopmentData
@replaceMethod(PlayerDevelopmentData)
public final const func GetTotalRespecCost() -> Int32 {
    //modFreeRespec++
    //let basePrice: Int32 = Cast(TweakDBInterface.GetConstantStatModifierRecord(t"Price.RespecBase").Value());
    //let singlePerkPrice: Int32 = Cast(TweakDBInterface.GetConstantStatModifierRecord(t"Price.RespecSinglePerk").Value());
    //let cost: Int32 = basePrice + singlePerkPrice * (this.GetSpentPerkPoints() + this.GetSpentTraitPoints());

    return 0;
    //modFreeRespec--
  }