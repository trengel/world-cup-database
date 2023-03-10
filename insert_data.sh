#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Empty tables before reinserting data
echo $($PSQL "TRUNCATE TABLE games, teams;")

# Reset primary key sequences
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1;")

# Main loop
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]] # Skip the first line in the CSV file
  then
    # Insert winning team names with a check to prevent duplicate entries
    WINNER_NAME=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_NAME ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    fi
    # Insert opponent team names with a check to prevent duplicate entries
    OPPONENT_NAME=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_NAME ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    fi
    # Fill in games table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
  fi
done
