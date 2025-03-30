# Issues
- When jumping multiple times, state machine breaks (should probably switch over to a blendspace)
- Make it so that you can't fullscreen

- Playtest results
- crashes all the time
- crashes on dialogue load

Todo:
	Expand puzzle so that you need to use information from outside
		Switch dialogue out for interactables
	Expand puzzle to use environmental clues
		
	Make ending screen fade on (add it to scene rather than scene change)
	Add more grass

Playtest
	Playtester feels like they're missing context (fair)
		- Mention in the dialogue to just follow the path for now [high]
	Music finishes and doesn't loop [tentatively fixed]
	Restart the game if the player falls in the chasm [tentatively fixed] [needs testing]
	Got the spacebar indicator and it didn't fade off [high]
	Walking between the tower and wall can get you stuck [tentatively fixed]
	Flying with no input makes you go backwards [low]
		- Likely due to loading
	You can still get stuck on the bed [tentatively fixed]
	Add unstuck code to player [low]
		- Just try running against walls, you get stuck often
	You re-get the wasd thing when changing zones [high]
	You can drag calendar elements further than bounds [high]
	
	- pressing 'e' on the dialogue should be the trigger to enter, rather than just walking [tentatively fixed]
	- sundial that explains time format? - they got it pretty much exactly, so unneeded

	Make the invisible walls much closer [low]
	
	Went to see if anything happened if you wnet outside again
	- Dialogue retriggers
	
	Add dialogue explaining that the schedule you pull up is of the guy in the room 
	
	Wanted to see if it was the same inkblot on both
	- Tried to look at the ink pot
	Was looking for non-citizens 
	- Need to make the other points much more obscure and incorigable
	- Need a confirm on the people coming in and people leaving
	- Are the surnames anagrams
	Thought you needed to see all the dialogue
	- Tried to "decode" the names (looking at first letter, etc)
	
	Schedule only goes down to 10:30 pm [high]
	- Fix the gradient [low]
	- Add am, pm text to calendar elements [tentatively fixed]
	- Fix calendar element sizing (it looked a bit cursed with one hour) [high]
	- Stop calendar elements from being 0 in length [tentatively fixed]
	
	Should make 10:30 pm earlier
	- Make this the end time on the calendar [tentatively fixed]
	
	Make intakes not constrained to :15 increments
	Make r input only show up once you interact with dead guy
Todo: 
	Add some sort of post (telephone post) where you can check in to see if you have more to find [high]
	- This should be a reocurring element
	
	Add something outside to the tune of "what's taking so long? I've been waiting almost 30 minutes" [high]
	- Add visible queue
	
	Add more inkblots to the names-obscure unneeded info!!! [high]
