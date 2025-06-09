#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# No argument given
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Determine the query based on input format
if [[ $1 =~ ^[0-9]+$ ]]; then
  # argument is atomic number
  ELEMENT=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type 
    FROM elements 
    INNER JOIN properties USING(atomic_number) 
    INNER JOIN types USING(type_id) 
    WHERE atomic_number = $1")
else
  # argument is symbol or name
  ELEMENT=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type 
    FROM elements 
    INNER JOIN properties USING(atomic_number) 
    INNER JOIN types USING(type_id) 
    WHERE symbol = INITCAP('$1') OR name = INITCAP('$1')")
fi

# Not found
if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Parse output
IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME MASS MELT BOIL TYPE <<< "$ELEMENT"

# Final output
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
