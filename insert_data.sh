#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

csv_file="games.csv" 
first_line=true

while IFS="," read -r year round winner opponent winner_goals opponent_goals; do
  if $first_line; then
    first_line=false
    continue
  fi
  if !$($PSQL "SELECT name FROM teams WHERE name = '$winner'"); then
    $($PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT (name) DO NOTHING")
  fi
  if !$($PSQL "SELECT name FROM teams WHERE name = '$opponent'"); then
    $($PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT (name) DO NOTHING")
  fi

done < "$csv_file"

while IFS="," read -r year round winner opponent winner_goals opponent_goals; do
  if $first_line; then
    first_line=false
    continue
  fi
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")
done < "$csv_file"