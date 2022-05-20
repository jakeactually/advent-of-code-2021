from typing_extensions import Self

matrix = [
    [ int(char) for char in row if char != '\n' ]
    for row in open('input.txt').readlines()
]

size = len(matrix)

distances = [
    [ 1000 for _ in range(size) ]
    for _ in range(size)
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

for _ in range(size * 3):
    new_paths = set()
    
    for path in paths:
        if path.x < size - 1:
            right = Path(path.x + 1, path.y)
            add_point(right)

        if path.y < size - 1:
            down = Path(path.x, path.y + 1)
            add_point(down)

        if path.x > 0:
            left = Path(path.x - 1, path.y)
            add_point(left)

        if path.y > 0:
            up = Path(path.x, path.y - 1)
            add_point(up)
    
    paths = new_paths

print(distances[size - 1][size - 1])
