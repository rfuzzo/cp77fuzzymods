/// modStateBasedAttributes
/// by rfuzzo
/// Version 1.0

// On Skill level up, calculate and assign attributes   :done:
// On Load, calculate and assign attributes             :done:
// hide free attributes                                 :done:
// disable attribute spending                           :done:
// disable skill cap based on attributes                :done:

public static func LogDebug(const str: script_ref<String>) -> Void {
  LogChannel(n"DEBUG", str);
}

// hook OnRestored which is called on save load
@wrapMethod(PlayerDevelopmentData)
public final func OnRestored(gameInstance: GameInstance) -> Void {
    wrappedMethod(gameInstance);

    //LogDebug("[RF] OnRestored");
    this.SafeProcessStateBasedAttributes();
}

// hook ModifyProficiencyLevel method which is called on Skill level up
@wrapMethod(PlayerDevelopmentData)
private final const func ModifyProficiencyLevel(type: gamedataProficiencyType) -> Void {
    wrappedMethod(type);

    let i: Int32 = this.GetProficiencyIndexByType(type);
    if i >= 0 {
        this.SafeProcessStateBasedAttributes();
    } else {
        LogDM("ModifyProficiencyLevel(): Given proficiency type doesn\'t exist !");
    };
}

// null checks
@addMethod(PlayerDevelopmentData)
private final func SafeProcessStateBasedAttributes() {
    let attributes : array<SAttribute> = this.GetAttributes();
    if ArraySize(attributes) <= 0 {

        //LogDebug("[RF] <<<<<<<< attributes <= 0. aborting <<<<<<<<");
        return;
    }
    if this.m_owner.IsPlayerControlled() {
        this.ProcessStateBasedAttributes();
    } else {
        //LogDebug("[RF] <<<<<<<< owner is not PlayerControlled <<<<<<<<");
    }
}

// main logic
@addMethod(PlayerDevelopmentData)
private final func ProcessStateBasedAttributes() {
    
    LogDebug("[RF] >>>>>>>> ProcessStateBasedAttributes >>>>>>>>");

    let type: gamedataProficiencyType;
    let i: Int32;
    let proficiencyRec: ref<Proficiency_Record>;
    let attributeRec: ref<Stat_Record>;
    let attributeType : gamedataStatType;
    let skillLevel : Int32;
    let calculatedAttributeValue : Int32;
    

    // fill empty atribute array
    let attributeValues : array<Int32>;
    i = 0;
    while i < EnumInt(gamedataStatType.Count) {
        ArrayPush(attributeValues, 0);
        i += 1;
    }
    
    // calculate attribute values
    i = 0;
    while i < ArraySize(this.m_proficiencies) {
        type = this.m_proficiencies[i].type;

        attributeRec = RPGManager.GetProficiencyRecord(type).TiedAttribute();
        if IsDefined(attributeRec) {
            attributeType = attributeRec.StatType();
            skillLevel = this.m_proficiencies[i].currentLevel;
            calculatedAttributeValue = this.CalculateStateBasedAttribute(skillLevel);

            //LogDebug("[RF] " + ToString(type) + " " + skillLevel + " > "  + ToString(attributeType) + " "  + calculatedAttributeValue);

            attributeValues[EnumInt(attributeType)] = Max(calculatedAttributeValue, attributeValues[EnumInt(attributeType)]);
        };

        i += 1;
    }

    // set attribute values
    LogDebug("[RF] -------- -------- ");
    let attributes : array<SAttribute> = this.GetAttributes();
    let currentAttributeValue : Int32;
    i = 0;
    while i < ArraySize(attributes) {
        attributeType = attributes[i].attributeName;
        calculatedAttributeValue = attributeValues[EnumInt(attributeType)];
        currentAttributeValue = attributes[i].value;

        if calculatedAttributeValue != currentAttributeValue {
            LogDebug("[RF] Set Attribute: " + ToString(attributeType) + " (" + currentAttributeValue + ") to: " + calculatedAttributeValue);

            this.SetAttribute(attributeType, Cast(calculatedAttributeValue));
        }

        i += 1;
    }



    LogDebug("[RF] <<<<<<<< <<<<<<<<");
}

// calculate new Attribute Value
@addMethod(PlayerDevelopmentData)
private final func CalculateStateBasedAttribute(skillvalue : Int32) -> Int32 {
    let K : Int32 = 3;
    let FLOOR : Int32 = 3;
    let CEIL : Int32 = 20;

    // floor version > Attributes are Max(3, skillvalue );
    // SKL 0 = ATT 3, SKL 1 = ATT 3, SKL 18 = ATT 18, SKL 20 = ATT 20
    return Max(FLOOR, skillvalue);

    // ceiling version > Attributes are Min(skillvalue + 3, 20);
    // SKL 0 = ATT 3, SKL 1 = ATT 4, SKL 18 = ATT 20, SKL 20 = ATT 20
    //return Min(skillvalue + K, CEIL);

    // floor and ceiling version > Attributes are Min(Max(5, skillvalue + 3), 20);
    // SKL 0 = ATT 5, SKL 1 = ATT 5, SKL 12 = ATT 15, SKL 18 = ATT 20, SKL 20 = ATT 20
    //return Min(Max(FLOOR, skillvalue + K), CEIL);
}

// disable attribute requirements for skills 
@wrapMethod(PlayerDevelopmentData)
private final const func GetProficiencyMaxLevel(type: gamedataProficiencyType) -> Int32 {
    wrappedMethod(type);

    let proficiencyRec: ref<Proficiency_Record>;
    proficiencyRec = RPGManager.GetProficiencyRecord(type);
    return proficiencyRec.MaxLevel();
}

// disable attribute point spending
@replaceMethod(PlayerDevelopmentDataManager)
public final func HasAvailableAttributePoints(opt showNotification: Bool) -> Bool {
    return false;
}

// always display 0 free attributes to spend
@wrapMethod(PerksMainGameController)
private final func UpdateAvailablePoints() -> Void {
    wrappedMethod();

    switch this.m_activeScreen {
        case CharacterScreenType.Attributes:
        this.m_pointsDisplayController.SetValues(0, this.m_dataManager.GetPerkPoints());
        this.SetRespecButton(true);
        break;
    };
}