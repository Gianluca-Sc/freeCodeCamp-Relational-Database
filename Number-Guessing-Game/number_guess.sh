#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~Number guessing game~~~~~\n"

# get username
echo "Enter your username:"
read USERNAME


USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# if user doesn't exist
if [[ -z $USER_ID ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert user into db
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  
  # get user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # get user data
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) GROUP BY user_id HAVING(user_id=$USER_ID)")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games INNER JOIN users USING(user_id) WHERE user_id=$USER_ID")
  
  # display data
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


SECRET_NUMBER=$((($RANDOM % 1000) + 1))
TRIES=0

echo  "Guess the secret number between 1 and 1000:"

while [ TRUE ]
do
  read NUM
  ((TRIES++))

  # if NUM is not interger
  if [[ ! $NUM =~ ^[0-9]+$ ]]
  then
    echo  "That is not an integer, guess again:"
    continue
  fi

  # if NUM > SECRET_NUMBER
  if [[ $NUM -gt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"

  # IF NUM < SECRET_NUMBER
  elif [[ $NUM -lt $SECRET_NUMBER  ]]
  then 
    echo "It's lower than that, guess again:"
  
  # if NUM = SECRET_NUMBER
  else
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    
    # insert game into db
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id,number_of_guesses) VALUES($USER_ID,$TRIES)")
    break
  fi
done


