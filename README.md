# Hades2BlindAccessibility
Adds blind / low visibility accessibility features to Hades 2. Adapted from PonyWarrior's [base code](https://github.com/PonyWarrior/Hades2BlindAccessibility). Current features include:
* A menu to teleport the player to key points within the crossroads and during flashbacks
    * To access press the key to open boon information while in the crossroads, default controls are:
    * Gamepad: D-pad left
    * Keyboard: B
* A menu to teleport the player to any of the current room's doors 
    * Will highlight the first door, tap up upto 3 times to access information on Melinoe's health, gold count, and armor count
    * Will open automatically when doors unlock
    * To re-access the menu at the end of a room open boon information then inventory, default controls are:
    * Gamepad: D-pad left then D-pad right
    * Keyboard: B then I
* A menu to teleport the player to any of the current room's rewards, harvest points, or if in a charon shop any of the available items in the store
    * Will highlight the first reward, tap up upto 3 times to access information on Melinoe's health, gold count, and armor count
    * To access open the boon information than open the codex (this will work even if the codex is not unlocked), default controls are:
    * Gamepad: D-pad left than D-pad up
    * Keyboard: B then C
* Final Boss's instant kill move instead deals 50 damage (Original creation by PonyWarrior)
* The Arcana Card's descriptions, prices, and whether they are turned on or off are read in the shrine's menu
* Adaptation of the exorcism / tablet minigame, timing values can be changed in config, it is heavily advised to keep time at 2 or above (2 is the default value) as TOLk will be unable to read instructions fast enough before the minigame fails
* Multiple menus are adapted to provide more information when reading TOLk (this includes the Inventory, Gift Menus, Planting Menus, Broker, Cauldron, and more)

# TODO
* Traps
* Keepsake post-boss
* subtitles
* bug fixes
    * Shop not showing gatherable resources
    * Door menu not always opening
    * Pom of power menu / single button menus not reading
    * Oceanus sealed doors
    * Keepsake Names
    * MetaCardPointsCommonBig