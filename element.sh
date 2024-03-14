#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo -e "Please provide an element as an argument."

else

  # check if $1 is a number
  if [[ $1 =~ ^[0-9]+$ ]]; then
    ATOMIC_NUMBER="$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")"
  # check if $1 is a symbol
  elif [[ $1 =~ ^[A-Z][a-zA-Z]?$ ]]; then
    ATOMIC_NUMBER="$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")"
  # check if $1 is a name
  else
    ATOMIC_NUMBER="$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")"
  fi

  # if atomic not found 
  if [[ ! $ATOMIC_NUMBER =~ ^[0-9]+$ ]]; then
    echo "I could not find that element in the database."
  else

    # get element properties
    ATOMIC_PROPERTIES="$($PSQL "SELECT symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING (atomic_number) INNER JOIN types USING (type_id) WHERE atomic_number = $ATOMIC_NUMBER")"
    
    SYMBOL="$(echo $ATOMIC_PROPERTIES | cut -d '|' -f 1)"
    NAME="$(echo $ATOMIC_PROPERTIES | cut -d '|' -f 2)"
    TYPE="$(echo $ATOMIC_PROPERTIES | cut -d '|' -f 3)"
    MASS="$(echo $ATOMIC_PROPERTIES | cut -d '|' -f 4)"
    MELTING_POINT="$(echo $ATOMIC_PROPERTIES | cut -d '|' -f 5)"
    BOILING_POINT="$(echo $ATOMIC_PROPERTIES | cut -d '|' -f 6)"

    # display result
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi
