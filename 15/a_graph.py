from typing_extensions import Self
import heapq

matrix = [
    [ int(char) for char in row if char != '\n' ]
    for row in open('input.txt').readlines()
]

dirs = [(0, 1), (0, -1), (1, 0), (-1, 0)]

class Path:
    def __init__(self, x, y, sum, node_set, track) -> None:
        self.x = x
        self.y = y
        self.sum = sum
        self.node_set = node_set
        self.track = track

    def __str__(self) -> str:
        return f'Path({self.x} {self.y} {self.sum})'

    def __gt__(self, __o: Self) -> bool:
        return self.sum > __o.sum

    def out(self):
        result = []

        for (x, y) in dirs:
            ay = self.y + y
            ax = self.x + x

            if 10 > ay >= 0 and 10 > ax >= 0 and (ax, ay) not in self.node_set:
                path = Path(
                    ax,
                    ay,
                    self.sum + matrix[ay][ax],
                    self.node_set | {(ax, ay)},
                    [(ax, ay), *self.track]
                )
                
                result.append(path)
        
        return result

h = []
heapq.heappush(h, Path(0, 0, 0, set(), []))

while True:
    current = heapq.heappop(h)

    for node in current.out():
        if node.x == 9 and node.y == 9:
            print(node)
            quit()

        heapq.heappush(h, node)
