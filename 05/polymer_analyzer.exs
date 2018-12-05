defmodule PolymerAnalyzer do

    def analyze({polymer, :done}) do polymer end
    def analyze(polymer) do
        # IO.puts("rework polymer")
        analyze(run(polymer, [], :fresh))
    end

    def run([first, second, third | t], acc, flag) do
        # IO.inspect("#{first} #{second} #{third} || #{acc} || #{flag}")
        cond do
            reacts?(first, second)->
                # IO.inspect("got first match")
                run([third | t], acc, :reacted)
            reacts?(second, third) ->
                # IO.inspect("got second match")
                run([first | t], acc, :reacted)
            true ->
                # IO.puts("\n")
                run([second, third | t], acc ++ [first], flag)
        end
    end
    def run(rem, acc, :reacted) do acc ++ rem end
    def run([first, second], acc, :fresh) do {acc ++ [first, second], :done} end

    def reacts?(left, right) do
        left != right and String.downcase(left) == String.downcase(right)
    end
end

polymer = File.read!("input.txt")
|> String.graphemes()

# IO.inspect(polymer)

alphabet = for n <- ?a..?z, do: << n :: utf8 >>

alphabet
|> Enum.reduce(%{"count" => length(polymer), "letter" => ""}, fn(letter, acc) -> 
    IO.inspect("Replacing letter #{letter}")
    count = polymer
    |> Enum.filter(fn(element) -> 
        element != letter and String.downcase(element) != letter
    end)
    |> PolymerAnalyzer.analyze()
    |> length

    IO.inspect("Replacement got #{count} letters")

    if count < acc["count"] do
        %{"count" => count, "letter" => letter}
    else 
        acc
    end
end)
|> IO.inspect

# polymer
# # |> String.downcase()
# |> String.graphemes()
# |> PolymerAnalyzer.analyze()
# |> length
# |> Kernel.-(1)
# |> IO.puts