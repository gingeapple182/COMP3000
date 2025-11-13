# COMP3000

## Working title : 

## Concept statement
Game elevator pitch
- What the player does
- Why its fun
- Why its useful
In [game name] you are the new office technician and it is your job to fix everything that breaks! You'll solve issues like the printer only working when someone brews coffee, using computing concepts like logic gates and other puzzles to make the systems work properly!

## Genre
 - Puzzle
 - Educational
 - Top-down 3D
 - Absurd comedy

## Target audience
 - Who will play
    - Computing students
    - People who enjoy puzzle games
    - People who enjoy tech humour
 - Why they play
    - challenge themselves with tech puzzles
    - fix the office
 - Age range
    - 8+
 - Accessibility
    - PC players
 - Intended play session duration
    - 10-20 minutes minimum
 - Target age rating
    - PEGI 7

## USP
Specific details WHY my game is unique/good
 - Interactive implementation of AND/NOT/XOR logic gates
 - Puzzles mirroring computing logic
 - Grid based puzzle layout
 - Constant and immediate feedback on puzzle solutions
 - Light physics involved for more *active* environment
 - Humourous/absurd setting making logic concepts more digestible
 - Hybrid presentation (first person + top down) adds visual variety 
 - Scalable by adding extra office environments

## Player experience
Describe intended experience from playing the game
 - Who is the player:   Office tech left to inherit old system
 - Player fantasy:      Feeling like the only person with any sense
 - How its presented:   
    - (Hub): First-person 3D
    - (Puzzles): Top-down 3D
 - What emotions do i want
    - Satisfaction
    - Curiosity
    - Revelations (figuring out difficult puzzles)
 - Why does the player return
    - Progress puzzles
    - Fix office chaos
    - Learn new concepts
    - Player interest
        - Growing absurdity
        - Sense of achievement
        - Variety of puzzles
        - Combination of puzzle types

## Visual/audio style
`For now: describe vibes`
`When ready: concept/actual art`
# Vibes
- Minimalist environment, cluttered design
- Simple textures
- Lights to show puzzles progress (red warning light = incomplete, green light = success)
- Distinct differences in office hub style vs puzzle style
    - Warm colour scheme for office environment (chill+absurd vibes)
    - Cold/ darker colour scheme for puzzle screen (to show in the flow tech vibes)
    - Office audio - (soft background)printer beeps, coffee pot brewing, keyboard typing
    - Puzzle audio - harsher beeps for incorrect, light trills for successes
# References
![alt text](image.png)

## Game world lore
 - why does the world exist - Office tech staff - Future could have different environments (other offices? different types of locations)
 - Basic framing
    - office tech
    - hired after last tech abruptly left for incompetence
    - left with responsibility to make the office function
    - office set up so badly weird problems exist
    Puzzles exist as the inner tech world behind the scenes of the absurd issues
    Progress through different rooms/different office locations

## Monetisation
Initial:
- No monetisation
- Coursework prototype only
Stretch goals:
- Post coursework submission, I may look into publicly releasing the game through Steam as a low cost early access puzzle game
- Possible monetisation through level packs (new offices)

## Tech scope
- Platform: PC
- Engine:   Godot
- Style:    3D top-down
- Scope:    
    - Solo developer
    - 10-20 Levels
        - first person physics enabled hub
        - top down grid system puzzles
    - Custom assets
        - Low polygon assets
        - Simple textures
    - Mouse and keyboard interactivity
- Expected MVP date: Christmas
- Risks
    -Basic risk assessment (not started)

## Core Loop
Primary loop:
 - Hub -> Puzzle -> Hub
Puzzle loop:
 - Assess problem
 - Place/move logic component blocks
 - Test solution
 - Adjust and repeat until solved
 - Hints/resetting available
Why is the loop engaging?
 - Absurd humour
 - Engaging puzzles
 - Completing/fixing the office environments
How it helps learning
 - Teaches core computing concepts in a fun and digestible way that encourages the players to learn through experimentation, and positively reinforced upon correct solutions though direct positive feedback and long term *fixing* of the office environment being satisfying for the players

## Objectives and progression
Players short term goals
Players long term goals
Level flow
    - Tutorial -> Single output challenges -> Multi-layered challenge -> truth table challenges
Every few stages can introduce a new concept/gate
    - first few puzzles use AND gates only
    - next few add in OR gates
    - next few add in NOT gates
    Logic builds slowly across multiple puzzles to not overwhelm players with too many new concepts at once
    End goal: fix the office systems8
Players are able to pick their puzzles from a few available.
    - 4 available puzzles at each stage
    - complete 3 to unlock new mechanic/variation
    - new puzzles unlocked with a noise upon returning to hub
        - New floating warning signs above newly broken objects
    - After enough completed puzzles (75% of total in room) you get a notification from your manager thanking you and telling you about new room with new issues


## Game systems
List all systems for the game - explain each
1) Logic gate system
2) Connector system
3) Puzzle manager
4) Player hub interaction
5) Level manager

## Interactivity
How the player moves in the hub
 - Player moves freely in the office space, can walk between desks/obstacles
 - Player can pick up some physics enabled 3d objects (coffee mug, stack of paper, bucket)
How the player moves in the levels
 - Top down so player can use mouse to select and pick up logic components
Feedback system
 - In hub:
    - Puzzle objects highlighted/glowing - possible just for floating/spinning warning symbol above to show interactivity
 - In puzzles:
    - Moveable objects: lighter colour scheme
    - Inactive objects: darker colour scheme
    - slots for puzzle objects have inner lit red lights?
    - Once objects in slots the corners turn blue/green to show connection
    - Red warning lights in screen corner to show problem zone
    - Warning lights turn green/yellow upon successful completion
- use UI sketches?
