#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$((1 + $RANDOM % 1000))

MAIN_MENU() {
  echo "Enter your username: "
  read NAME

  USERNAME=$(echo $($PSQL "SELECT user_id FROM users WHERE username='$NAME'") | sed 's/ //g')
  if [[ -z $USERNAME ]]
  then
    CREATE_USER $NAME
  else
    OLD_USER $NAME
  fi

  PLAY_GAME $NAME
}

CREATE_USER() {
  USERNAME=$1
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  # create user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
}

OLD_USER() {
  USERNAME=$1
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_COUNT=$($PSQL "SELECT COUNT(user_id) FROM games")
  BEST_GAME=$($PSQL "SELECT MIN(guess) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_COUNT, and your best game took $BEST_GAME guesses."
}

PLAY_GAME() {
  USERNAME=$1
  echo "Guess the secret number between 1 and 1000:"
  GUESS_COUNT=0
  GUESS=0;
  while [ $GUESS != $RANDOM_NUMBER ]
  do
    read GUESS
    if [[  ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      ((GUESS_COUNT++))
      if [[ $GUESS -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi
    fi
  done
  echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
  
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(user_id, guess) VALUES($USER_ID, $GUESS_COUNT)")
}

MAIN_MENU