library(tidyverse)

build_dataset <- function(unstructured_data) {
  df <- NULL
  for (GAME in 1:length(unstructured_data)) {
    for (HAND in 1:length(unstructured_data[[GAME]])) {
      df <- rbind(df,store_round(GAME,HAND,unstructured_data,mylogin))
    }
  }
  df
}

load_data <- function(data) {
  full_list <- read_hh(dir(pattern=data))
  loaded <- split_hh(full_list)
  loaded
}

read_hh <- function(arquivos) {
  x<-NULL
  for (i in arquivos){
    x[[i]] <- read.csv(i,header=F,sep='^')
  }
  return(x)
}

split_hh <- function(hh) {
  hands<-NULL
  for (i in 1:(length(hh)+1)) { hands <- add_hh(hands,list())}
  for (i in 1:length(hands)) {
    for (j in 1:length(grep("PokerStars",hh[[i]][[1]]))) {
      hands[[i]]<-add_hh(hands[[i]],data.frame(hand=split_hands(hh,i,j)))
    }
  }
  return(hands)
}

add_hh <- function(data,x) {
  if (is.list(data)) { c(data, list(x)) }
  else { c(data, x, recursive = FALSE) }
}

split_hands <- function(hh,lista,x) {
  if (!is.na(grep("PokerStars", hh[[lista]][[1]])[x+1])) {
    hh[[lista]][[1]][grep("PokerStars",
                          hh[[lista]][[1]])[x]:sum(grep("PokerStars",hh[[lista]][[1]])[x+1],-1)]
    }
    else (hh[[lista]][[1]][grep("PokerStars",
                                hh[[lista]][[1]])[x]:length(hh[[lista]][[1]])])
}

tourn_id <- function(line) {
  r <- str_extract(line,"#[0-9]+,")
  if (is.na(r)) { r <- 0 }
  r <- gsub("#|,","",r)
  r
}

table_number <- function(line) {
 w <- gsub(".*\'(.+)\'.*","\\1",line)
 word(w,2)
}

hand <- function(line) {
  r <- str_extract(line,"#[0-9]+:")
  r <- gsub("#(.+)\\:","\\1",r)
  if (is.na(r)) { r <- 0 }
  r
}

chairs <- function(line) {
  r <- str_extract(line,"[0-9]{1}-max")
  r <- as.integer(gsub(".*([0-9]+).*","\\1",r))
  if (is.na(r)) { r <- 9 }
  r
}

get_board <- function(line) {
  r <- gsub(".*\\[(.+)\\].*","\\1",line)
  if (r == "*** SUMMARY ***"){
    r <- "0"
  }
  r
}

get_combination <- function(line) {
  r <- gsub(".* with ","\\1",line)
  if (grepl("Seat | folded ",r)) {
    r <- ""
  }
  r
}

buyin <- function(line) {
  r <- str_extract(line,"\\$[0-9-.]+\\+\\$[0-9-.]+|[0-9-.]+\\+[0-9-.]+")
  r <- gsub("$","",r,fixed <- T)
  if (is.na(r)) { r <- "---" }
  r
}

get_date_time <- function(line) {
  data <- str_extract(line,"[0-9]{4}/[0-9]{2}/[0-9]{2}")
  hora <- str_extract(line,"[0-9]+:[0-9]+:[0-9]+")
  if (is.na(data)) { data <- "---" }
  if (is.na(hora)) { hora <- "---" }
  c(data,hora)
}

get_button <- function(line) {
  r <- str_extract(line,"#[0-9]{1}")
  r <- gsub("#","",r)
  r <- suppressWarnings(as.integer(r))
  if (is.na(r)) { r <- 0 }
  r
}

level <- function(line) {
  r <- str_extract(line,"Level [I,V,X,L,C]+")
  r <- gsub("Level ","",r,fixed = T)
  r <- as.integer(as.roman(r))
  if (is.na(r)) { r <- 0 }
  r
}

get_cards <- function(line) {
  r <- str_extract(line,pattern = "\\[.*\\]")
  r <- gsub("\\[(.+)\\]","\\1",r)
  if (is.na(r)) { r <- "[---]" }
  r
}

initial_stack <- function(line) {
  r <- str_extract(line,"[0-9]+ in chips")
  r <- as.numeric(gsub(" in chips","",r))
  if (is.na(r)) { r <- 0 }
  r
}

bets <- function(line) {
  r <- suppressWarnings( as.numeric( str_split(line," ")[[1]]) )
  r <- r[!is.na(r)]
  l <- length(r)
  if (l > 0) {
    r[l]
  }
  else { 0 }
}

uncalled <- function(line) {
  r <- str_extract(line,pattern = "\\([0-9]+\\)")
  r <- gsub("\\((.+)\\)","\\1",r)
  r <- suppressWarnings(as.numeric(r))
  if(is.na(r)){
    r <- 0
  }
  r
}

store_round <- function(GAME,HAND,unstructured_data,mylogin) {
  
  base <- unstructured_data[[GAME]][[HAND]][[1]]
  
  # Catching lines to filter data and make searches faster
  line_hole_cards <- grep("\\*\\*\\* HOLE CARDS \\*\\*\\*", base)
  line_flop <- grep("\\*\\*\\* FLOP \\*\\*\\*", base)
  line_turn <- grep("\\*\\*\\* TURN \\*\\*\\*", base)
  line_river <- grep("\\*\\*\\* RIVER \\*\\*\\*", base)
  line_final <- grep("\\*\\*\\* SUMMARY \\*\\*\\*", base)
  line_show_down <- grep("\\*\\*\\* SHOW DOWN \\*\\*\\*", base)
  
  if(length(line_flop) == 0) {
    line_flop <- line_final
  }
  if(length(line_turn) == 0) {
    line_turn <- line_final
  }
  if(length(line_river) == 0) {
    line_river <- line_final
  }
  
  players <- NULL
  seat <- NULL
  stacks <- NULL
  max <- as.integer(chairs(base[2]))
  
  for (i in 1:max) {
    # Catch players
    n <- grep(paste0("Seat ",i,":"),base[1:line_hole_cards],fixed = T)[1]
    player <- gsub(".*: (.+) \\([0-9]+ in chips.*","\\1",base[n])
    players <- append(players,player)
    stacks <- append(stacks,initial_stack(base[n]))
    seat <- append(seat,i)
  }
  
  #max_9 <- c("BTN","SB","BB","UTG-1","UTG-2","MP-1","MP-2","MP-3","CO")
  #max_6 <- c("BTN","SB","BB","UTG","MP","CO")
  
  dt <- get_date_time(base[1])
  date <- as.Date(dt[1])
  time <- dt[2]
  
  line_text_ante <- grep(" posts ante",base[3:line_hole_cards],fixed = T,value = T)
  
  pot <- NULL
  for (l in line_text_ante){
    pot <- append(pot,bets(l))
  }
  
  total_pot <- sum(pot)
  
  playing <- sum(!is.na(players))
  
  n <- length(players)
   
  df_round <- data.frame(buyin = rep(buyin(base[1]),n),
                          tourn_id = rep(tourn_id(base[1]),n),
                          table = rep(table_number(base[2]),n),
                          hand_id = rep(hand(base[1]),n),
                          date = rep(date,n),
                          time = rep(time,n),
                          table_size = rep(max,n),
                          
                          level = rep(level(base[1]),n),
                          playing = rep(playing,n),
                          
                          seat = seat,
                          name = players,
                          stack = stacks,
                          position = rep('x',n),
                          
                          action_pre = rep("-",n),
                          action_flop = rep("-",n),
                          action_turn = rep("-",n),
                          action_river = rep("-",n),
                          all_in = rep(F,n),
                          
                          # range = rep(0,n),
                          cards = rep("--",n),
                          
                          board_flop = rep(get_board(base[line_flop]),n),
                          board_turn = rep(get_board(base[line_turn]),n),
                          board_river = rep(get_board(base[line_river]),n),
                          combination = rep("",n),
                          
                          pot_pre = rep(total_pot,n),
                          pot_flop = rep(0,n),
                          pot_turn = rep(0,n),
                          pot_river = rep(0,n),
                          
                          ante = rep(0,n),
                          blinds = rep(0,n),
                          
                          bet_pre = rep(0,n),
                          bet_flop = rep(0,n),
                          bet_turn = rep(0,n),
                          bet_river = rep(0,n),
                          
                          result = rep(0,n),
                          balance = rep(0,n))
  
  # Get my hand
  i <- match(mylogin,players)
  my_hand <- grep(paste0("Dealt to ",mylogin),base[line_hole_cards:(line_hole_cards+3)],value = T,fixed = T)
  my_hand <- get_cards(my_hand)
  df_round$cards[i] <- my_hand
  
  # Get show down cards
  for (p in 1:length(players)){
    line_text_cards <- grep(paste0("Seat ",seat[p],":"),
                            base[line_final:length(base)],value = T)[1]
    if (!is.na(line_text_cards)) {
      if (grepl("mucked|showed",line_text_cards)) {
        df_round$cards[p] <- get_cards(line_text_cards)
        df_round$combination[p] <- get_combination(line_text_cards)
      }
    }
  }
  
  button <- get_button(base[2])
  
  ### Initial actions
  for (j in 1:n) {
    player <- players[j]
    filtered <- base[3:line_hole_cards]
    line <- filtered[startsWith(filtered,paste0(player,": posts ante"))]
    if (length(line) > 0) {
      df_round$ante[j] <- bets(line[1])
    }
    
    if (button == df_round$seat[j]) {
      df_round$position[j] <- "BTN"
      }
    
    test_sb <- grep(paste0(player,": posts small"),base[3:line_hole_cards],fixed = T,value = T)
    if (length(test_sb) > 0) {
      df_round$position[j] <- "SB"
      df_round$blinds[j] <- bets(test_sb)
    }
    
    test_bb <- grep(paste0(player,": posts big"),base[3:line_hole_cards],fixed = T,value = T)
    if (length(test_bb) > 0) {
      df_round$position[j] <- "BB"
      df_round$blinds[j] <- bets(test_bb)
    }
    
    if (sum(grepl("all-in",line, fixed = T)) > 0) {
      df_round$all_in[j] <- T
    }
  }
  
  ### Preflop actions
  for (j in 1:n) {
    player <- players[j]
    filtered <- base[line_hole_cards:line_flop]
    line <- filtered[startsWith(filtered,paste0(player,":"))]
    
    if (sum(grepl("all-in",line, fixed = T)) > 0) {
      df_round$all_in[j] <- T
    }
    
    if (length(line) != 0) {
      action <- str_extract(line,": [calls|raises|checks|folds|bets|shows|mucks|doesn't]+")
      action <- gsub(": ","",action)
      action[is.na(action)] <- "ERROR"
      action <- paste(action,collapse = "-")
      b <- df_round$blinds[j]
      for (l in line){
        if (grepl(" raises ",l,fixed=T)) {
          b <- bets(l)
        }
        else { b <- append(b,bets(l)) }
      }
      df_round$bet_pre[j] <- sum(b)
    }
    else { action <- "x"
    df_round$bet_pre[j] <- df_round$blinds[j]
    }
    df_round$action_pre[j] <- action # estoca a action
  }
  
  ### Flop actions
  for (j in 1:n) {
    player <- players[j]
    filtered <- base[line_flop:line_turn]
    line <- filtered[startsWith(filtered,paste0(player,":"))]
    
    if (sum(grepl("all-in",line, fixed = T)) > 0) {
      df_round$all_in[j] <- T
    }
    
    if (length(line) != 0) {
      action <- str_extract(line,": [calls|raises|checks|folds|bets|shows|mucks|doesn't]+")
      action <- gsub(": ","",action)
      action[is.na(action)] <- "ERROR"
      action <- paste(action,collapse = "-")
      b <- NULL
      for (l in line){
        if (grepl(" raises ",l,fixed=T)){
          b <- bets(l)
        }
        else { b <- append(b,bets(l)) }
      }
      df_round$bet_flop[j] <- sum(b)
    }
    else { action <- "x" }
    df_round$action_flop[j] <- action
  }
  
  ### Turn actions
  for (j in 1:n) {
    player <- players[j]
    filtered <- base[line_turn:line_river]
    line <- filtered[startsWith(filtered,paste0(player,":"))]
    
    if (sum(grepl("all-in",line, fixed = T)) > 0) {
      df_round$all_in[j] <- T
    }
    
    if (length(line) != 0) {
      action <- str_extract(line,": [calls|raises|checks|folds|bets|shows|mucks|doesn't]+")
      action <- gsub(": ","",action)
      action[is.na(action)] <- "ERROR"
      action <- paste(action,collapse = "-")
      b <- NULL
      for (l in line){
        if (grepl(" raises ",l,fixed=T)){
          b <- bets(l)
        }
        else { b <- append(b,bets(l)) }
      }
      df_round$bet_turn[j] <- sum(b)
    }
    else { action <- "x" }
    df_round$action_turn[j] <- action
  }
  
  ### River actions
  for (j in 1:n) {
    player <- players[j]
    filtered <- base[line_river:line_final]
    line <- filtered[startsWith(filtered,paste0(player,":"))]
    
    if (sum(grepl("all-in",line, fixed = T))>0) {
      df_round$all_in[j] <- T
    }
    
    if (length(line) != 0) {
      action <- str_extract(line,": [calls|raises|checks|folds|bets|shows|mucks|doesn't]+")
      action <- gsub(": ","",action)
      action[is.na(action)] <- "ERROR"
      action <- paste(action,collapse = "-")
      b <- NULL
      for (l in line){
        if (grepl(" raises ",l,fixed=T)){
          b <- bets(l)
        }
        else { b <- append(b,bets(l)) }
      }
      df_round$bet_river[j] <- sum(b)
    }
    else { action <- "x" }
    df_round$action_river[j] <- action
  }
  
  # result
  for (j in 1:n) {
    player <- players[j]
    action <- "gave up"
    
    df_round$balance[j] <- -sum(df_round$ante[j],
                                 df_round$bet_pre[j],
                                 df_round$bet_flop[j],
                                 df_round$bet_turn[j],
                                 df_round$bet_river[j])
    
    if (length(line_show_down)==0){
      line <- grep(paste0(player," collected"),
                   base[line_hole_cards:line_final],value = T, fixed = T)
      if (length(line) > 0) {
        soma <- NULL
        for (i in line) {
         soma <- append(soma,bets(i)) 
        }
        soma <- sum(soma)
        action <- "took chips"
        df_round$balance[j] <- soma
      }
    }
    if (length(line_show_down)>0){
      line <- grep(paste0(player," collected"),
                   base[line_hole_cards:line_final],value = T, fixed = T)
      unc <- grep(paste0("returned to ",player),
                  base[line_hole_cards:line_final],value = T, fixed = T)
      if (length(line)>0) {

        soma <- NULL
        for (i in line) {
          soma <- append(soma,bets(i)) 
        }
        soma <- sum(soma)
        
        returnedto <- NULL
        for (i in unc) {
          returnedto <- append(returnedto,uncalled(i)) 
        }
        
        returnedto <- sum(returnedto)
        action <- "won"
        
        df_round$balance[j] <- soma - (sum(df_round$ante[j],
                                            df_round$bet_pre[j],
                                            df_round$bet_flop[j],
                                            df_round$bet_turn[j],
                                            df_round$bet_river[j]) - returnedto)
        
        cards <- strsplit(df_round$cards[j]," ")[[1]]
        flop <- strsplit(df_round$board_flop[j]," ")[[1]]
      }
    }
    
    df_round$result[j] <- action
    
    # The "gave up" is defined by default.
    # If the following two conditions are satisfied, it means that the player went to showdown and lost.
    if (sum(grepl("doesn't|mucks|shows",df_round$action_river[j])) > 0 & action == "gave up") {
    
      df_round$result[j] <- "lost"
      
      unc <- grep(paste0(" returned to ",player),base[line_hole_cards:line_final],value = T, fixed = T)
      
      returnedto <- NULL
      
      for (i in unc) {
        returnedto <- append(returnedto,uncalled(i)) 
      }
      returnedto <- sum(returnedto)
      
      df_round$balance[j] <- -sum(df_round$ante[j],
                                  df_round$bet_pre[j],
                                  df_round$bet_flop[j],
                                  df_round$bet_turn[j],
                                  df_round$bet_river[j]) + returnedto
      
      cards <- strsplit(df_round$cards[j]," ")[[1]]
      flop <- strsplit(df_round$board_flop[j]," ")[[1]]
    }
  }
  
  n <- grep("took chips",df_round$result)
  
  if(length(n) > 0) {
    df_round$balance[n] <- df_round$balance[n] - sum(df_round$balance)
  }
  
  df_round$pot_pre <- sum(df_round$bet_pre)
  
  if (df_round$board_flop[1] != "-") {
    df_round$pot_flop <- sum(df_round$bet_flop) + sum(df_round$bet_pre)
  }
  else { df_round$pot_flop <- 0 }
  
  if (df_round$board_turn[1] != "-") {
    df_round$pot_turn <- sum(df_round$bet_turn) + sum(df_round$bet_flop) + sum(df_round$bet_pre)
  }
  else { df_round$pot_turn <- 0 }
  
  if (df_round$board_river[1] != "-") {
    df_round$pot_river <- sum(df_round$bet_river) + sum(df_round$bet_turn) + sum(df_round$bet_flop) + sum(df_round$bet_pre)
  }
  else { df_round$pot_river <- 0 }
  
  df_round
}