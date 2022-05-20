from typing_extensions import Self

initial_matrix = [
    [ int(char) for char in row if char != '\n' ]
    for row in open('input.txt').readlines()
]

size = len(initial_matrix)

def point_at(x, y):
    candidate = initial_matrix[y % size][x % size] + (y // size) + (x // size)
    return candidate if candidate <= 9 else candidate - 9

matrix = [
    [ point_at(i, j) for i in range(size * 5) ]
    for j in range(size * 5)
]

distances = [
    [ 10000 for _ in range(size * 5) ]
    for _ in range(size * 5)
]

distances[0][0] = 0

class Path:
    def __init__(self, x, y) -> None:
        self.x = x
        self.y = y

    def __eq__(self, __o: Self) -> bool:
        return self.x == __o.x and self.y == __o.y

    def __hash__(self) -> int:
        return self.y * 1000 + self.x

def add_point(point):
    candidate = matrix[point.y][point.x] + distances[path.y][path.x]

    if candidate < distances[point.y][point.x]:
        distances[point.y][point.x] = candidate
        new_paths.add(point)

paths = [Path(0, 0)]

for _ in range(size * 5 * 3):
    new_paths = set()
    
    for path in paths:
        if path.x < size * 5 - 1:
            right = Path(path.x + 1, path.y)
            add_point(right)

        if path.y < size * 5 - 1:
            down = Path(path.x, path.y + 1)
            add_point(down)

        if path.x > 0:
            left = Path(path.x - 1, path.y)
            add_point(left)

        if path.y > 0:
            up = Path(path.x, path.y - 1)
            add_point(up)
    
    paths = new_paths

print(distances[size * 5 - 1][size * 5 - 1])
