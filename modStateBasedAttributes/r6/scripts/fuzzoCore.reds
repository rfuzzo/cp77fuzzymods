module fuzzocore

// Singleton instance with player lifetime
// by Psiberx
public class FuzzoCore {
    // Game instance lets you get player reference and any system
    // Storing a direct reference to the player can lead to issues
    private let gameInstance: GameInstance;

    private func Initialize(player: ref<PlayerPuppet>) {
    this.gameInstance = player.GetGame();
    }

    public static func CreateInstance(player: ref<PlayerPuppet>) {
    let instance: ref<FuzzoCore> = new FuzzoCore();
    instance.Initialize(player);  

    // This strong reference will tie the lifetime of the singleton 
    // to the lifetime of the player entity
    player.FuzzoCoreInstance = instance;

    // This weak reference is used as a global variable 
    // to access the mod instance anywhere
    GetAllBlackboardDefs().FuzzoCoreInstance = instance;
    }

    public static func GetInstance() -> wref<FuzzoCore> {
    return GetAllBlackboardDefs().FuzzoCoreInstance;
    }


    // -----------------------------

    // public func Init() {
    //   LogDebug("[FUZZOCORE] Init");

    // }

    public func DoSomething() {
      let player: ref<PlayerPuppet> = GetPlayer(this.gameInstance);
        
      Log("Player carries " + FloatToString(player.m_curInventoryWeight) + " KG");
  }
}

@addField(PlayerPuppet)
public let FuzzoCoreInstance: ref<FuzzoCore>; // Must be strong reference

@addField(AllBlackboardDefinitions)
public let FuzzoCoreInstance: wref<FuzzoCore>; // Must be weak reference

@addMethod(QuestTrackerGameController)
protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
  FuzzoCore.CreateInstance(player as PlayerPuppet);
  //FuzzoCore.GetInstance().Init();
}





public static func LogDebug(const str: script_ref<String>) -> Void {
  LogChannel(n"DEBUG", str);
}
