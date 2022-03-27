//0 = nothing, 1 = red, 2 = yellow //<>//
int[][] squares;
int[][] alt_squares;
int placing;
boolean game_won = false;
int winner = 2;

boolean remove_easy_win = false;//if true, game starts with yellow in middle row

void setup() {
  size(900, 900);

  squares = new int[7][6];

  if (remove_easy_win) {
    squares[3][5] = 2;
  }
}


void draw() {
  background(255);
  translate(100, 200);

  for (int j = 0; j < 6; j++) {
    for (int i = 0; i < 7; i++) {
      fill(255); //creating the board
      square(i*100, j*100, 100); 
      if (squares[i][j] == 1) {  //placing the chips
        fill(255, 0, 0);
        circle(i*100+50, j*100+50, 80);
      }
      if (squares[i][j] == 2) {
        fill(255, 255, 0);
        circle(i*100+50, j*100+50, 80);
      }
    }
  }

  if (game_won) { //state the winner if game over
    fill(0);
    textSize(50);
    if (winner == 0) {
      text("You both lose!", 100, -100);
    }
    if (winner == 1) {
      text("Red is the winner!", 100, -100);
    }
    if (winner == 2) {
      text("Yellow is the winner!", 100, -100);
    }
    text("Press R to replay!", 100, -50);
  } else {
    fill(255, 0, 0);//hover a chip over the top of the board
    circle((constrain(mouseX/100, 1, 7)) * 100 - 50, -50, 80);
  }
}


void mouseReleased() {
  if (!game_won) {
    placing = constrain(mouseX/100, 1, 7) - 1; //place a chip when mouse pressed
    if (squares[placing][0] == 0) {
      for (int y = 5; y > -1; y--) {
        if (squares[placing][y] == 0) {
          squares[placing][y] = 1;
          break;
        }
      }
    }

    //check if the game is won
    alt_squares = new int[7][6];
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 6; j++) {
        alt_squares[i][j] = squares[i][j];
      }
    }
    winner = check_if_won();
    if (winner != 0) {
      game_won = true;
    }

    if (squares[0][0] != 0 && squares[1][0] != 0 && squares[2][0] != 0 && squares[3][0] != 0 && squares[4][0] != 0 && squares[5][0] != 0 && squares[6][0] != 0) { //check for stalemate
      game_won = true;
      winner = 0;
    } 
    if (!game_won) {
      ai_turn();
    }
  }
}

void keyPressed() {
  if (game_won && key == 'r') { //restart the game
    squares = new int[7][6];
    game_won = false;
    winner = 2;

    if (remove_easy_win) {
      squares[3][5] = 2;
    }
  }
}

int check_if_won() {
  for (int j = 0; j < 6; j++) { //check the horizontals
    for (int i = 0; i < 4; i++) {
      if (alt_squares[i][j] != 0 && alt_squares[i][j] == alt_squares[i+1][j] && alt_squares[i][j] == alt_squares[i+2][j] && alt_squares[i][j] == alt_squares[i+3][j]) {
        if (alt_squares[i][j] == 1) {
          return 1;
        } else {
          return 2;
        }
      }
    }
  }
  for (int j = 0; j < 3; j++) { //check the verticals
    for (int i = 0; i < 7; i++) {
      if (alt_squares[i][j] != 0 && alt_squares[i][j] == alt_squares[i][j+1] && alt_squares[i][j] == alt_squares[i][j+2] && alt_squares[i][j] == alt_squares[i][j+3]) {
        if (alt_squares[i][j] == 1) {
          return 1;
        } else {
          return 2;
        }
      }
    }
  }
  for (int j = 3; j < 6; j++) { //check the positive diagonals
    for (int i = 0; i < 4; i++) {
      if (alt_squares[i][j] != 0 && alt_squares[i][j] == alt_squares[i+1][j-1] && alt_squares[i][j] == alt_squares[i+2][j-2] && alt_squares[i][j] == alt_squares[i+3][j-3]) {
        if (alt_squares[i][j] == 1) {
          return 1;
        } else {
          return 2;
        }
      }
    }
  }
  for (int j = 0; j < 3; j++) { //check the negative diagonals
    for (int i = 0; i < 4; i++) {
      if (alt_squares[i][j] != 0 && alt_squares[i][j] == alt_squares[i+1][j+1] && alt_squares[i][j] == alt_squares[i+2][j+2] && alt_squares[i][j] == alt_squares[i+3][j+3]) {
        if (alt_squares[i][j] == 1) {
          return 1;
        } else {
          return 2;
        }
      }
    }
  }

  return 0;
}


//---------------------------------------------------------------------------------------
//AI stuff
//checking max 3 moves ahead (ai 3 moves + player 3 moves), if the ai wins in one move add 3 points, 3 moves add 1 point
//if player wins in one move take 3 points, 3 moves take one point
//end up with final score for each move and make best move

int depth = 7;
int[] move_scores;
IntList move_list;
int max_score;
IntList possible_moves;
boolean cont;


void ai_turn() {
  cont = true;
  alt_squares = new int[7][6];
  for (int a = 0; a < 7; a++) { //check if ai can win
    if (squares[a][0] == 0) {
      for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 6; j++) {
          alt_squares[i][j] = squares[i][j];
        }
      }

      for (int y = 5; y > -1; y--) {
        if (alt_squares[a][y] == 0) {
          alt_squares[a][y] = 2;
          break;
        }
      }

      if (check_if_won() == 2) {
        for (int i = 0; i < 7; i++) {
          for (int j = 0; j < 6; j++) {
            squares[i][j] = alt_squares[i][j];
          }
        }
        game_won = true;
        winner = 2;
        cont = false;
        break;
      }
    }
  }

  if (cont) { //if not, find a good move
    move_scores = new int[7];
    for (int i = 0; i < 7; i++) {
      if (squares[i][0] != 0) {
        move_scores[i] = -1000000;
      }
    }

    move_list = new IntList();
    for (int i = 0; i < 7; i++) {
      if (move_scores[i] == 0) {
        move_list.append(i);
        break;
      }
    }

    //section calculates move_scores
    while (true) {
      alt_squares = new int[7][6];
      for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 6; j++) {
          alt_squares[i][j] = squares[i][j];
        }
      }
      for (int i = 0; i < move_list.size(); i++) { //place each move in the list
        for (int y = 5; y > -1; y--) {
          if (alt_squares[move_list.get(i)][y] == 0) {
            if (i % 2 == 0) {
              alt_squares[move_list.get(i)][y] = 2;
            } else {
              alt_squares[move_list.get(i)][y] = 1;
            }
            break;
          }
        }
      }

      if (check_if_won() == 2) { //change move score based on who wins
        move_scores[move_list.get(0)] += pow(2, (depth - move_list.size()));
      } else if (check_if_won() == 1) {
        move_scores[move_list.get(0)] -= pow(3, (depth - move_list.size()));
      }

      //if game over, increment last value, else, try to add another value or increment last value
      if (check_if_won() == 0) {
        if (move_list.size() == depth) {
          move_list.increment(move_list.size() - 1);
        } else {
          for (int i = 0; i < 7; i++) {
            if (alt_squares[i][0] == 0) {
              move_list.append(i);
              break;
            }
            if (i == 6 && alt_squares[6][0] != 0) {
              move_list.increment(move_list.size() - 1);
            }
          }
        }
      } else {
        move_list.increment(move_list.size() - 1);
      }

      while (true) {
        if (move_list.get(move_list.size() - 1) == 7) {
          move_list.remove(move_list.size() - 1);
          if (move_list.size() == 0) {
            break;
          }
        } else {
          break;
        }

        move_list.increment(move_list.size() - 1);
      }

      if (move_list.size() == 0) {
        break;
      }
      
      if(move_list.size() == 1){
        println(move_list);
      }
    }

    //println(move_scores);

    max_score = -10000000;
    for (int i = 0; i < 7; i++) {
      if (move_scores[i] > max_score) {
        max_score = move_scores[i];
      }
    }

    possible_moves = new IntList();
    for (int i = 0; i < 7; i++) {
      if (move_scores[i] == max_score) {
        possible_moves.append(i);
      }
    }

    possible_moves.shuffle();
    for (int y = 5; y > -1; y--) {
      if (squares[possible_moves.get(0)][y] == 0) {
        squares[possible_moves.get(0)][y] = 2;
        break;
      }
    }
  }
}
