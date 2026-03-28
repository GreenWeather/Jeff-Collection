import Foundation

// ANSI color codes for black background and white text
let BLACK_BG = "\u{001B}[40m"
let WHITE_TEXT = "\u{001B}[97m"
let RESET = "\u{001B}[0m"
let CLEAR_SCREEN = "\u{001B}[2J\u{001B}[H"

print("\(BLACK_BG)\(CLEAR_SCREEN)", terminator: "")

// Game structures
struct Player {
    var name: String
    var health: Int
    var maxHealth: Int
    var level: Int
    var experience: Int
    var atk: Int
    var defense: Int
    var gold: Int
    var x: Int
    var y: Int
    
    mutating func takeDamage(_ damage: Int) {
        health -= max(1, damage - defense / 2)
        if health < 0 { health = 0 }
    }
    
    mutating func heal(_ amount: Int) {
        health = min(maxHealth, health + amount)
    }
    
    mutating func gainExperience(_ amount: Int) {
        experience += amount
        let expNeeded = level * 100
        if experience >= expNeeded {
            level += 1
            experience = 0
            maxHealth += 20
            health = maxHealth
            atk += 5
            defense += 2
            print("\(BLACK_BG)⭐ LEVEL UP! You are now level \(level)!\(RESET)")
        }
    }
}

struct Enemy {
    var name: String
    var health: Int
    var atk: Int
    var defense: Int
    var expReward: Int
    var goldReward: Int
}

// Enemy factory
func createEnemy(level: Int) -> Enemy {
    let enemies = [
        Enemy(name: "Goblin", health: 20, atk: 8, defense: 2, expReward: 50, goldReward: 30),
        Enemy(name: "Orc", health: 40, atk: 12, defense: 4, expReward: 100, goldReward: 60),
        Enemy(name: "Troll", health: 60, atk: 15, defense: 6, expReward: 150, goldReward: 100),
        Enemy(name: "Dragon", health: 100, atk: 20, defense: 8, expReward: 300, goldReward: 200)
    ]
    
    var enemy = enemies[Int.random(in: 0..<enemies.count)]
    let scaleFactor = Double(level) * 0.5
    enemy.health = Int(Double(enemy.health) * (1.0 + scaleFactor))
    enemy.atk = Int(Double(enemy.atk) * (1.0 + scaleFactor * 0.5))
    enemy.defense = Int(Double(enemy.defense) * (1.0 + scaleFactor * 0.3))
    return enemy
}

// Movement system
func movePlayer(player: inout Player, direction: String) {
    switch direction.lowercased() {
    case "n", "north", "up", "w":
        player.y -= 1
        print("🚶 You move north...")
    case "s", "south", "down", "a":
        player.y += 1
        print("🚶 You move south...")
    case "e", "east", "right", "d":
        player.x += 1
        print("🚶 You move east...")
    case "w", "west", "left", "q":
        player.x -= 1
        print("🚶 You move west...")
    default:
        print("❌ Invalid direction! Use: N(north), S(south), E(east), W(west)")
        return
    }
}

// Combat system
func combat(player: inout Player, enemy: inout Enemy) -> Bool {
    print("\n⚔️  Combat started! You face a \(enemy.name)!")
    print("Enemy Health: \(enemy.health) | Your Health: \(player.health)/\(player.maxHealth)\n")
    
    var turnCount = 0
    while player.health > 0 && enemy.health > 0 {
        turnCount += 1
        print("Turn \(turnCount)")
        print("1. Attack")
        print("2. Defend")
        print("3. Heal (costs 20 gold)")
        print("4. Run away")
        print("Choose action: ", terminator: "")
        fflush(stdout)
        
        guard let choice = readLine() else { continue }
        
        switch choice {
        case "1":
            let damage = Int.random(in: player.atk - 5...player.atk + 5)
            enemy.health -= max(1, damage - enemy.defense / 2)
            print("💥 You deal \(max(1, damage - enemy.defense / 2)) damage!")
            
        case "2":
            print("🛡️  You brace for impact!")
            player.defense += 5
            
        case "3":
            if player.gold >= 20 {
                player.gold -= 20
                player.heal(50)
                print("💊 You heal for 50 HP! (Gold: \(player.gold))")
            } else {
                print("❌ Not enough gold!")
                continue
            }
            
        case "4":
            if Int.random(in: 1...100) > 50 {
                print("✓ You successfully escaped!")
                return true
            } else {
                print("✗ Failed to escape!")
            }
            
        default:
            print("Invalid action!")
            continue
        }
        
        // Enemy attack
        if enemy.health > 0 {
            let enemyDamage = Int.random(in: enemy.atk - 3...enemy.atk + 3)
            player.takeDamage(enemyDamage)
            print("👹 \(enemy.name) deals \(max(1, enemyDamage - player.defense / 2)) damage!")
            player.defense = max(0, player.defense - 2)
        }
        
        print("Enemy HP: \(max(0, enemy.health)) | Your HP: \(player.health)/\(player.maxHealth)\n")
    }
    
    if player.health > 0 {
        print("🎉 Victory! You defeated the \(enemy.name)!")
        player.gainExperience(enemy.expReward)
        player.gold += enemy.goldReward
        print("🎁 Gained \(enemy.expReward) EXP and \(enemy.goldReward) gold!")
        return true
    } else {
        print("💀 You were defeated...")
        return false
    }
}

// Main game loop
func runGame() {
    print("═══════════════════════════════════════════")
    print("   DUNGEON CRAWLER - TEXT ADVENTURE GAME   ")
    print("═══════════════════════════════════════════\n")
    
    print("Enter your adventurer's name: ", terminator: "")
    fflush(stdout)
    let name = readLine() ?? "Adventurer"
    
    var player = Player(
        name: name,
        health: 100,
        maxHealth: 100,
        level: 1,
        experience: 0,
        atk: 15,
        defense: 5,
        gold: 100,
        x: 0,
        y: 0
    )
    
    print("\nWelcome, \(player.name)! You enter a dark dungeon...\n")
    
    var gameRunning = true
    while gameRunning && player.health > 0 {
        print("╔═══════════════════════════════════════════╗")
        print("║ DUNGEON CRAWLER - Level \(player.level) | HP: \(player.health)/\(player.maxHealth) | Gold: \(player.gold) ║")
        print("╚═══════════════════════════════════════════╝")
        print("\n📍 You're in the dungeon at (\(player.x), \(player.y))")
        print("\n--- MOVEMENT ---")
        print("N/S/E/W - Move north/south/east/west")
        print("\n--- ACTIONS ---")
        print("A - Explore current area")
        print("R - Rest (restore 30 HP, costs 10 gold)")
        print("I - Check inventory")
        print("Q - Exit dungeon")
        print("Enter command: ", terminator: "")
        fflush(stdout)
        
        guard let choice = readLine() else { continue }
        
        switch choice.lowercased() {
        case "n", "s", "e", "w":
            movePlayer(player: &player, direction: choice)
            // Chance for encounter after moving
            if Int.random(in: 1...100) > 50 {
                print("⚠️  You encounter an enemy!")
                var enemy = createEnemy(level: max(1, player.level + (player.y / 5)))
                let _ = combat(player: &player, enemy: &enemy)
            } else {
                print("✓ The area is quiet here. You find some gold!\n")
                let goldFound = Int.random(in: 10...50)
                player.gold += goldFound
                print("💰 Found \(goldFound) gold!")
            }
            
        case "a":
            print("\n🔍 You explore the area...")
            if Int.random(in: 1...100) > 40 {
                var enemy = createEnemy(level: max(1, player.level + (player.y / 5)))
                let _ = combat(player: &player, enemy: &enemy)
            } else {
                print("✓ The dungeon is quiet here. You find some gold!\n")
                let goldFound = Int.random(in: 10...50)
                player.gold += goldFound
                print("💰 Found \(goldFound) gold!")
            }
            
        case "r":
            if player.gold >= 10 {
                player.gold -= 10
                player.heal(30)
                print("😴 You rest and recover 30 HP!\n")
            } else {
                print("❌ Not enough gold to rest!\n")
            }
            
        case "i":
            print("\n📦 INVENTORY")
            print("Health: \(player.health)/\(player.maxHealth)")
            print("Level: \(player.level)")
            print("Experience: \(player.experience)")
            print("Gold: \(player.gold)")
            print("Attack: \(player.atk)")
            print("Defense: \(player.defense)\n")
            
        case "q":
            gameRunning = false
            
        default:
            print("❌ Invalid command!\n")
            continue
        }
    }
    
    print("\n═══════════════════════════════════════════")
    if player.health <= 0 {
        print("   GAME OVER - You fell in the dungeon   ")
    } else {
        print("   Thanks for playing, \(player.name)!   ")
        print("   Final Level: \(player.level) | Final Gold: \(player.gold)")
    }
    print("═══════════════════════════════════════════\n")
}

// Run the game
runGame()
