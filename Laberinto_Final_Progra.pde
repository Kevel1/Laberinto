import java.util.ArrayList;
import java.util.Stack;

int cols, rows;
int w = 40; // Tamaño de cada celda
Cell[][] grid;
Player player;

void setup() {
  size(400, 400);
  cols = width / w;
  rows = height / w;

  grid = new Cell[cols][rows];

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j] = new Cell(i, j);
    }
  }

  // Generar laberinto
  generateMaze();

  // Establecer punto de inicio y final
  grid[0][0].visited = true;
  grid[cols - 1][rows - 1].visited = true;
  grid[cols - 1][rows - 1].isGoal = true; // Marcar la celda de la meta

  player = new Player();
}

void draw() {
  background(255);

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].show();
    }
  }

  player.show();
  player.move();
}

void keyPressed() {
  player.handleKeyPress(key);
}

class Cell {
  int i, j;
  boolean[] walls = { true, true, true, true };
  boolean visited = false;
  boolean isGoal = false; // Indicador de celda de la meta

  Cell(int i, int j) {
    this.i = i;
    this.j = j;
  }

  void show() {
    int x = i * w;
    int y = j * w;

    stroke(0);
    strokeWeight(2);
    noFill();

    if (walls[0]) line(x, y, x + w, y);
    if (walls[1]) line(x + w, y, x + w, y + w);
    if (walls[2]) line(x + w, y + w, x, y + w);
    if (walls[3]) line(x, y + w, x, y);

    if (visited) {
      noStroke();
      fill(255);
      rect(x, y, w, w);
    }

    // Mostrar la palabra "Meta" en la celda de la meta
    if (isGoal) {
      textSize(16);
      fill(0);
      textAlign(CENTER, CENTER);
      text("Meta", x + w / 2, y + w / 2);
    }
  }

  Cell checkNeighbors() {
    ArrayList<Cell> neighbors = new ArrayList<Cell>();

    Cell top = index(i, j - 1);
    Cell right = index(i + 1, j);
    Cell bottom = index(i, j + 1);
    Cell left = index(i - 1, j);

    if (top != null && !top.visited) {
      neighbors.add(top);
    }
    if (right != null && !right.visited) {
      neighbors.add(right);
    }
    if (bottom != null && !bottom.visited) {
      neighbors.add(bottom);
    }
    if (left != null && !left.visited) {
      neighbors.add(left);
    }

    if (neighbors.size() > 0) {
      int rand = floor(random(0, neighbors.size()));
      return neighbors.get(rand);
    } else {
      return null;
    }
  }
}

class Player {
  float x, y;
  int gridX, gridY;

  Player() {
    x = w / 2;
    y = w / 2;
    gridX = 0;
    gridY = 0;
  }

  void show() {
    fill(255, 0, 0);
    noStroke();
    ellipse(x, y, w / 2, w / 2);
  }

  void handleKeyPress(char key) {
    int dx = 0;
    int dy = 0;

    if (key == 'w' || key == 'W') {
      dy = -1;
    } else if (key == 's' || key == 'S') {
      dy = 1;
    } else if (key == 'a' || key == 'A') {
      dx = -1;
    } else if (key == 'd' || key == 'D') {
      dx = 1;
    }

    move(dx, dy);
  }

  void move(int dx, int dy) {
    int nextGridX = gridX + dx;
    int nextGridY = gridY + dy;

    if (nextGridX >= 0 && nextGridX < cols && nextGridY >= 0 && nextGridY < rows) {
      if (!grid[gridX][gridY].walls[(dy + 1) / 2 * 2 + (dx + 1) / 2]) {
        gridX = nextGridX;
        gridY = nextGridY;
        x = gridX * w + w / 2;
        y = gridY * w + w / 2;
      }
    }
  }

  void move() {
    float targetX = gridX * w + w / 2;
    float targetY = gridY * w + w / 2;

    float dx = targetX - x;
    float dy = targetY - y;

    float speed = 2;
    float distance = sqrt(dx * dx + dy * dy);

    if (distance > speed) {
      dx = dx / distance * speed;
      dy = dy / distance * speed;
    }

    x += dx;
    y += dy;
  }
}

void generateMaze() {
  Stack<Cell> stack = new Stack<Cell>();
  Cell current = grid[0][0];

  while (true) {
    current.visited = true;
    Cell next = current.checkNeighbors();

    if (next != null) {
      next.visited = true;

      stack.push(current);

      removeWalls(current, next);

      current = next;
    } else if (!stack.isEmpty()) {
      current = stack.pop();
    } else {
      break;
    }
  }
  grid[cols - 1][rows - 1].walls[1] = false; // Abrir el final del laberinto
}

void removeWalls(Cell a, Cell b) {
  int x = a.i - b.i;
  if (x == 1) {
    a.walls[3] = false;
    b.walls[1] = false;
  } else if (x == -1) {
    a.walls[1] = false;
    b.walls[3] = false;
  }

  int y = a.j - b.j;
  if (y == 1) {
    a.walls[0] = false;
    b.walls[2] = false;
  } else if (y == -1) {
    a.walls[2] = false;
    b.walls[0] = false;
  }
}

Cell index(int i, int j) {
  if (i < 0 || j < 0 || i >= cols || j >= rows) {
    return null;
  }
  return grid[i][j];
}
