## Dataset building

### Description  
This is a data engineering project aimed to build a dataset of online poker games.  I wrote this code in July 2020, when I started to get into the data world. It was mainly developed to study _Spin & Go tournaments_, but it might work generally. It performs well, but _Regex_ can certainly be improved. Also, today I wouldn’t use so many conditionals and loops that take a lot of time to process.  
<br>
### Limitations
Some older poker players have logins with special characters that used to be allowed in the past, and this might affect data. I usually find about 2% of corrupt data because of that and I just ignore them. It might possible to scape special characters at some stage of the process and keep this data, but I have not been free time these days to improve this point.  
<br>
### Usage 
Download all files and run the _functions.R_ file in your RStudio. Then, open the _execute.R_, set the directory of your hand history files and the other variables demanded. After running, you will get a _result.csv_, with the structure described below in the *Data Dictionary*.  
<br>
### References  
Please go to [kaggle.com/murilogmamaral/online-poker-games](https://www.kaggle.com/murilogmamaral/online-poker-games) if you want to see the generated dataset from my online poker games.  
<br>
___
### Data dictionary
<br>

#### buyin (character)  
Amount paid (USD) to play the tournament  
<br> 
#### tourn_id (character)  
Tournament id  
<br> 
#### table (character)  
Table number reference in the tournament  
<br> 
#### hand_id (character)  
Hand id  
<br> 
#### date (double)
Date of played hand  
<br> 
#### time (character)
Time of played hand  
<br> 
#### table_size (integer)  
Maximum number of players per table  
<br> 
#### level (integer)  
Blinds levels  
<br> 
#### playing (integer)  
Number of players in the table  
<br> 
#### seat (integer)  
Seat number of each player  
<br> 
#### name (character)  
Player logins  
<br> 
#### initial_stack (double)  
Initial stack of each player  
<br> 
#### position (double)  
Position of each player  
<br> 
#### action_pre, action_flop, action_turn, action_river (character)  
Action of each player per round stage  
<br> 
#### all_in (logical)  
Informs if a player did an all-in bet    
<br> 
#### cards (character)  
Hand of each player  
<br> 
#### board_flop, board_turn, board_river (character)  
Board cards per round stage  
<br> 
#### combination (character)  
Cards combination of each player  
<br> 
#### pot_pre, pot_flop, pot_turn, pot_river (double)
Pot size per round stage  
<br> 
#### ante (double)  
Ante paid  
<br> 
#### blinds (double)  
Blinds paid  
<br> 
#### bet_pre, bet_flop, bet_turn, bet_river (double)  
Bet done per round stage  
<br> 
#### result (character)  
won: player went to showdown and won  
lost: player went to showdown and lost  
gave up: player folded at some point  
took chips: player took chips without going to showdown  
<br> 
#### balance (double)  
Win/loss chips per hand  
<br> 
