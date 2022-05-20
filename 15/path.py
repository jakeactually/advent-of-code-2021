from typing_extensions import Self

class Path:
    def __init__(self, x, y) -> None:
        self.x = x
        self.y = y

    def __eq__(self, __o: Self) -> bool:
        return self.x == __o.x and self.y == __o.y

    def __hash__(self) -> int:
        return self.y * 1000 + self.x
