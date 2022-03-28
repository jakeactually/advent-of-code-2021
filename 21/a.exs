defmodule Game do
  def wrap n do
    if rem(n, 10) == 0 do
      10
    else
      rem(n, 10)
    end
  end

  def game player1, player2, score1, score2, turn, die do
    # IO.inspect([die + 1, die + 2, die + 3], charlists: :as_lists)

    if score1 >= 1000 || score2 >= 1000 do
      {score1, score2, die}
    else
      offset = die + 1 + die + 2 + die + 3
      new_die = die + 3

      if rem(turn, 2) == 0 do
        new_pos = wrap(player1 + offset)
        # IO.inspect([player1, score1, new_pos, score1 + new_pos], charlists: :as_lists)
        game new_pos, player2, score1 + new_pos, score2, turn + 1, new_die
      else
        new_pos = wrap(player2 + offset)
        # IO.inspect([player2, score1, new_pos, score2 + new_pos], charlists: :as_lists)
        game player1, new_pos, score1, score2 + new_pos, turn + 1, new_die
      end
    end
  end
end

{_, loser, die} = Game.game(7, 10, 0, 0, 0, 0)

IO.inspect(loser * die)
