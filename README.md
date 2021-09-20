# datasetbuilding
Data engineering project aimed to build a dataset of online poker games.  

I wrote this code last year (July 2020) when I started to get into the data world. It was mainly developed to study Spin & Go tournaments, but it might work generally. It performs well, but regex can certainly be improved. Also, today I wouldn’t use so many conditions and loops that take a lot of time to process. Finally, some older poker players have logins with special characters and this might affect data. I usually find about 2% of corrupt data because of that.  
<br> 
<br> 


# Data dictionary
<br> 

### buyin (character)  
Amount paid (USD) to play the tournament  
<br> 
### tourn_id (character)  
Tournament id  
<br> 
### table_id (character)  
Table  id  
<br> 
### hand_id (character)  
Hand id  
<br> 
### date (double)
Date of played hand  
<br> 
### time (character)
Time of played hand  
<br> 
### table_size (integer)  
Maximum number of players per table  
<br> 
### level (integer)  
Blinds levels  
<br> 
### playing (integer)  
Number of players in the table  
<br> 
### seat (integer)  
Seat number of each player  
<br> 
### name (character)  
Player logins  
<br> 
### initial_stack (double)  
Initial stack of each player  
<br> 
### position (double)  
Position of each player  
<br> 
### action_pre, action_flop, action_turn, action_river (character)  
Action of each player per round stage  
<br> 
### all_in (logical)  
Informs if a player did an all-in bet    
<br> 
### cards (character)  
Hand of each player  
<br> 
### board_flop, board_turn, board_river (character)  
Board cards per round stage  
<br> 
### combination (character)  
Cards combination of each player  
<br> 
### pot_pre, pot_flop, pot_turn, pot_river (double)
Pot size per round stage  
<br> 
### ante (double)  
Ante paid  
<br> 
### blinds (double)  
Blinds paid  
<br> 
### bet_pre, bet_flop, bet_turn, bet_river (double)  
Bet done per round stage  
<br> 
### result (character)  
won: player went to showdown and won  
lost: player went to showdown and lost  
gave up: player folded at some point  
took chips: player took chips without going to showdown  
<br> 
### balance (double)  
Win/loss chips per hand  
<br> 
