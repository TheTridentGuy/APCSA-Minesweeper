private int board_height = 500;
private int board_width = 500;
private int rows = 10;
private int cols = 10;
private int num_mines = 10;
private int start_time = 0;
private float final_time = 0;
private Space[][] board;

private enum GameState {
    READY,
    PLAYING,
    WON,
    LOST
}

private GameState game_state = GameState.READY;

private class Space {
    boolean is_mine;
    boolean is_flagged;
    boolean is_revealed;
    int adjacent_mines;

    Space() {
        is_mine = false;
        is_flagged = false;
        is_revealed = false;
    }
}

private void setup_game() {
    board = new Space[rows][cols];
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            board[i][j] = new Space();
        }
    }
}

private void draw_square(int x, int y) {
    rect(x * width / rows, y * height / cols, width / rows, height / cols);
}

private void draw_board() {
    stroke(0);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (board[i][j].is_revealed) {
                if (board[i][j].is_mine) {
                    fill(255, 0, 0);
                    draw_square(i, j);
                } else {
                    fill(200, 200, 200);
                    draw_square(i, j);
                    if (board[i][j].adjacent_mines > 0) {
                        fill(0, 0, 255);
                        textSize(15);
                        text(board[i][j].adjacent_mines, i * width / rows + width / rows / 2, j * height / cols + height / cols / 2);
                    }
                }
            } else {
                fill(0, 255, 0);
                draw_square(i, j);
                if (board[i][j].is_flagged) {
                    fill(255, 0, 0);
                    textSize(15);
                    text("F", i * width / rows + width / rows / 2, j * height / cols + height / cols / 2);
                }
            }
        }
    }
    noFill();
    strokeWeight(2);
    rect(mouseX / (width / rows) * (width / rows), mouseY / (height / cols) * (height / cols), width / rows, height / cols);
    strokeWeight(1);
}

private void start_game(int x, int y) {
    int mines = num_mines;
    while (mines > 0) {
        int i = int(random(rows));
        int j = int(random(cols));
        if (!board[i][j].is_mine && (i != x && j != y)) {
            board[i][j].is_mine = true;
            mines--;
        }
    }
    fill_adjacent_mines();
    reveal(x, y);
    start_time = millis();
}

private void fill_adjacent_mines(){
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (board[i][j].is_mine) {
                int[][] neighbors = { { -1, -1 }, { 0, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 } };
                for (int[] neighbor : neighbors) {
                    int x = i + neighbor[0];
                    int y = j + neighbor[1];
                    if (x >= 0 && x < rows && y >= 0 && y < cols) {
                        board[x][y].adjacent_mines++;
                    }
                }
            }
        }
    }
}

private void reveal(int x, int y) {
    if (x < 0 || x >= rows || y < 0 || y >= cols) {
        return;
    }
    if (board[x][y].is_flagged) {
        board[x][y].is_flagged = false;
    }
    if (board[x][y].is_mine) {
        board[x][y].is_revealed = true;
        return;
    }
    if (board[x][y].is_revealed) {
        return;
    }
    board[x][y].is_revealed = true;
    if (board[x][y].adjacent_mines == 0) {
        int[][] neighbors = { { -1, -1 }, { 0, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 } };
        for (int[] neighbor : neighbors) {
            reveal(x + neighbor[0], y + neighbor[1]);
        }
    }
}

private void flag(int x, int y) {
    if (x < 0 || x >= rows || y < 0 || y >= cols) {
        return;
    }
    if (board[x][y].is_revealed) {
        return;
    }
    board[x][y].is_flagged = !board[x][y].is_flagged;
}

private int sum_flagged() {
    int count = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (board[i][j].is_flagged) {
                count++;
            }
        }
    }
    return count;
}

private boolean complete() {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (!board[i][j].is_mine && !board[i][j].is_revealed) {
                return false;
            }
        }
    }
    return true;
}

private void reveal_mines() {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (board[i][j].is_mine) {
                board[i][j].is_revealed = true;
            }
        }
    }
}

private void credit() {
    fill(0, 0, 255);
    textSize(15);
    text("[made by TheTridentGuy: https://plscuddle.me]", 0, height - 30);
    text("[click to restart]", 0, height - 15);
}

void mousePressed() {
    int x = mouseX / (width / rows);
    int y = mouseY / (height / cols);
    if (game_state == GameState.READY) {
        game_state = GameState.PLAYING;
        start_game(x, y);
    } else if (game_state == GameState.PLAYING) {
        if (mouseButton == RIGHT) {
            flag(x, y);
        } else {
            if (board[x][y].is_mine) {
                game_state = GameState.LOST;
                reveal_mines();
            } else {
                reveal(x, y);
            }
        }
    } else if (game_state == GameState.WON || game_state == GameState.LOST) {
        game_state = GameState.READY;
        setup_game();
    }
}

void setup() {
    windowResize(board_width, board_height);
    setup_game();
}

void draw() {
    fill(0);
    draw_board();
    if (game_state == GameState.READY) {
        fill(0, 0, 255);
        textSize(15);
        text("[click a square to start]", 0, 15);
    } else if (game_state == GameState.PLAYING) {
        fill(0, 0, 255);
        textSize(15);
        text("[time: " + ((float) millis() - start_time) / 1000 + "]", 0, 15);
        int flagged = sum_flagged();
        text("[flagged: " + flagged + "/" + num_mines + "]", 0, 30);
        text("[left click: reveal, right click: flag]", 0, height - 15);
        if (complete() && flagged == num_mines) {
            game_state = GameState.WON;
            final_time = ((float) millis() - start_time) / 1000;
        }
    } else if (game_state == GameState.WON) {
        fill(0, 0, 255);
        textSize(15);
        text("[minefield cleared]", 0, 15);
        text("[time: " + final_time + "]", 0, 30);
        credit();
    } else if (game_state == GameState.LOST) {
        fill(0, 0, 255);
        textSize(15);
        text("[you're in the afterlife]", 0, 15);
        credit();
    }
}
