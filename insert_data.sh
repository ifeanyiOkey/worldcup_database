#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to insert data from games.csv into worldcup database

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # get team_ID
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' AND name='$OPPONENT'")
    
    # if not found
    if [[ -z $TEAM_ID ]]
    then
      # insert name to teams
      INSERT_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      INSERT_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

      if [[ $INSERT_NAME == "INSERT 0 1" ]]
      then
        echo data inserted into teams
      fi

      # get new team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' AND name='$OPPONENT'")
    fi
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' ")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT' ")
    # insert games
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
    VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        if [[ $INSERT_GAME == "INSERT 0 1" ]]
        then
            echo Inserted into games, $YEAR $ROUND $TEAM_ID $WINNER_GOALS
        fi
  fi
done