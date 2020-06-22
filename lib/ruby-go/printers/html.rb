require 'erb'

module RubyGo
  class HTMLPrinter
    LETTERS = ('A'..'Z').to_a.freeze
    COLORS = { black: 'black stone', white: 'white stone', empty: 'liberty' }.freeze
    TEMPLATE = ERB.new(<<~ERB).freeze
      <style>
      .board { max-width: 100%; padding: 16px; }
      .row { display: flex; margin: 0; }
      .intersection { display: inline-block; height: 32px; width: 32px; border-top: 2px solid black; border-left: 2px solid black; }
      .intersection:last-child { border-top-width: 0px; height: 34px; }
      .row:last-child .intersection { border-left-width: 0px; width: 34px; }
      .row:last-child .intersection:last-child { width: 2px; height: 2px; background: black; }
      .stone, .liberty { display: inline-block; width: 30px; height: 30px; border-radius: 100%; margin: 0; position: relative; top: -18px; left: -18px; }
      .stone { border: 2px solid black; }
      .black.stone { background: black; }
      .white.stone { background: white; }
      .liberty:hover { border: 2px solid red; }
      .row-num, .column-num { display: inline-block; width: 34px; height: 34px; margin: 0; position: relative; }
      .row-num { top: -0.5em; }
      .column-num { left: -0.3em; }
      </style>
      <div class="game">
        <div class="board">
          <div class="row">
            <div class="column-num row-num"></div>
            <% size.times do |i| %>
            <div class="column-num"><%= letters[i] %></div>
            <% end %>
          </div>
          <% rows.each_with_index do |row, i| %>
          <div class="row">
            <div class="row-num"><%= letters[i] %></div>
            <% row.each do |stn| %>
              <div class="intersection">
                <div class="<%= colors[stn.color] %>"></div>
              </div>
            <% end %>
          </div>
          <% end %>
        </div>

        <div class="info">
          <table>
            <tbody>
              <tr>
                <th>Prisoners</th>
                <th>White</th>
                <td><%= captures[:black] %></td>
                <th>Black</th>
                <td><%= captures[:white] %></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    ERB

    attr_reader :io

    def initialize(io)
      @io = io
    end

    def print_game(game)
      html = TEMPLATE.result_with_hash(
        size: game.board.size,
        captures: game.captures,
        rows: game.board.rows,
        colors: COLORS, letters: LETTERS
      )
      io.write(html)
    end
  end
end
