#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"
NUMBER=$((1 + $RANDOM % 1000))

echo "Enter your username: "
read USERNAME
GP=$($PSQL "SELECT games_played FROM info WHERE username='$USERNAME'")
BG=$($PSQL "SELECT best_game FROM info WHERE username='$USERNAME'")
echo $GP
echo $BG

if [[ -z $GP ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ($PSQL "INSERT INTO info(username, games_played) VALUES('$USERNAME', 1)" &> /dev/null)
  GP=1
else
  echo "Welcome back, $USERNAME! You have played $GP games, and your best game took $BG guesses."
  GP=$((GP + 1))
  ($PSQL "UPDATE info SET games_played=$GP WHERE username='$USERNAME'" &> /dev/null)
fi

BG=0

CHECK () {

  BG=$((BG + 1))

  if ! [[ $1 =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    CHECK $GUESS
  elif [[ $1 -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    CHECK $GUESS
  elif [[ $1 -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
    CHECK $GUESS
  elif [[ $1 == $NUMBER ]]
  then
    if [[ -z $($PSQL "SELECT best_game FROM info WHERE username='$USERNAME'") ]]
    then
      ($PSQL "UPDATE info SET best_game=$BG WHERE username='$USERNAME'" &> /dev/null)
    elif [[ $BG -lt $($PSQL "SELECT best_game FROM info WHERE username='$USERNAME'") ]]
    then
      ($PSQL "UPDATE info SET best_game=$BG WHERE username='$USERNAME'" &> /dev/null)
    fi
    echo "You guessed it in $BG tries. The secret number was $NUMBER. Nice job!"
  fi
}

echo Guess the secret number between 1 and 1000:
read GUESS
CHECK $GUESS

