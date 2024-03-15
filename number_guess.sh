#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID="$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")"
# if that username has been used before
if [[ -z $USER_ID ]]; then
  # display message
  echo "Welcome, ${USERNAME}! It looks like this is your first time here."

else
  # get games_played and best_game
  GAMES_PLAYED="$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")"
  BEST_GAME="$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")"
  # display welcome back message
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# start game
ANS=$(( RANDOM % 1000 + 1 ))
COUNT=0

echo $ANS
echo "Guess the secret number between 1 and 1000:"
read GUESS

while [[ $GUESS -ne $ANS ]]; do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    COUNT=$(( COUNT + 1 ))
    read GUESS
  elif [[ $GUESS -gt $ANS ]]; then
    echo "It's lower than that, guess again:"
    COUNT=$(( COUNT + 1 ))
    read GUESS
  elif [[ $GUESS -lt $ANS ]]; then
    echo "It's higher than that, guess again:"
    COUNT=$(( COUNT + 1 ))
    read GUESS
  fi
done
COUNT=$(( COUNT + 1 ))

# update users table
if [[ -z $USER_ID ]]; then
  # insert user data into users
  INSERT_USERS_RESULT="$($PSQL "INSERT INTO users (name, games_played, best_game) VALUES ('$USERNAME', 1, $COUNT)")"
else
  
  # update database
  UPDATE_PLAYED_GAME_RESULT="$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")"

  # if this was the best game, update best_game column
  if [[ $COUNT -lt $BEST_GAME ]]; then
    UPDATE_BEST_GAME_RESULT="$($PSQL "UPDATE users SET best_game = $COUNT WHERE user_id = $USER_ID")"
  fi
fi

# display the result
echo "You guessed it in $COUNT tries. The secret number was $ANS. Nice job!"