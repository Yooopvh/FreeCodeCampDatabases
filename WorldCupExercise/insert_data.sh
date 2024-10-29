#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

$($PSQL "TRUNCATE TABLE games, teams")

# Do not change code above this line. Use the PSQL variable above to query your database.
cat "./games.csv" | while IFS=',' read -ra line;
do
  if [ ${line[0]} != "year" ]
  then
    # Get indices of teams names
    WINDEX=$($PSQL "select team_id from teams where name = '${line[2]}'")
    LINDEX=$($PSQL "select team_id from teams where name = '${line[3]}'")

    # If the indices are null, the values are added to the teams database
    if [ -z $WINDEX ]
    then 
      $PSQL "insert into teams(name)  values ('${line[2]}')"
      WINDEX=$($PSQL "select team_id from teams where name = '${line[2]}'")
    fi

    if [ -z $LINDEX ]
    then 
      $PSQL "insert into teams(name)  values ('${line[3]}')"
      LINDEX=$($PSQL "select team_id from teams where name = '${line[3]}'")
    fi
    
    # Add values to the games database
    $PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)  values (${line[0]}, '${line[1]}', $WINDEX, $LINDEX, ${line[4]}, ${line[5]})"

    echo "$WINDEX  |  $LINDEX"
  fi
done

echo "DONE"