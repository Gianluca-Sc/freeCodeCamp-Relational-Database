#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ $1 ]]
then
 # if input is not a number
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number from elements WHERE name='$1' OR symbol='$1' ")
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number from elements WHERE atomic_number=$1")
  fi

  # if element doesn't exist
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
    exit
  else
    # get element info
    ELEMENT_INFO=$($PSQL "SELECT atomic_number,symbol,name,atomic_mass,melting_point_celsius,boiling_point_celsius,type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
  fi

# diplay element info
echo $ELEMENT_INFO | while IFS=" |" read ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
done    
else
  echo "Please provide an element as an argument."
fi
