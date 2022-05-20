from path import Path

initial_matrix = [
    [ int(char) for char in row if char != '\n' ]
    for row in open('input.txt').readlines()
]

initial_size = len(initial_matrix)
size = initial_size * 5

def point_at(x, y):
    candidate = initial_matrix[y % initial_size][x % initial_size] + (y // initial_size) + (x // initial_size)
    return candidate if candidate <= 9 else candidate - 9

matrix = [
    [ point_at(i, j) for i in range(size) ]
    for j in range(size)
]

distances = [
    [ 10000 for _ in range(size) ]
    for _ in range(size)
]

distances[0][0] = 0

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
