defmodule ChecksumProcessor do
    def has_n_occurence(id, n) do
        chars = String.graphemes(id)
        occurences = Enum.reduce(chars, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
        case Enum.any?(occurences, fn {_, v} -> v == n end) do
            true ->
                1
            false -> 
                0
        end
    end

    def getValues([h | t], touplets, triplets) do
        touplet_occurence = ChecksumProcessor.has_n_occurence(h, 2)
        triplet_occurence = ChecksumProcessor.has_n_occurence(h, 3)
        getValues(t, touplets + touplet_occurence, triplets + triplet_occurence)
    end
    def getValues([], touplets, triplets) do
        {touplets, triplets}
    end
end

defmodule IDFinder do
    def process_list(ids, [h | t], max_same_chars) do
        same_chars = IDFinder.process_id(h, ids, [])
        cond do
            length(same_chars) >= length(max_same_chars) ->
                process_list(ids, t, same_chars)
            length(same_chars) < length(max_same_chars) ->
                process_list(ids, t, max_same_chars)
        end
    end
    def process_list(ids, [], max_same_chars) do max_same_chars end

    def process_id(id, [h | t], max_same_chars) do
        same_chars = IDFinder.get_same_chars(id, h)
        cond do
            id == h ->
                process_id(id, t, max_same_chars)
            length(same_chars) >= length(max_same_chars) ->
                process_id(id, t, same_chars)
            length(same_chars) < length(max_same_chars) ->
                process_id(id, t, max_same_chars)
        end
    end
    def process_id(id, [], max_same_chars) do max_same_chars end

    def get_same_chars(id1, id2) do
        chars1 = String.graphemes(id1)
        chars2 = String.graphemes(id2)
        get_same_chars(chars1, chars2, [])
    end
    def get_same_chars([h1 | chars1], [h2 | chars2], acc) do
        if h1 == h2 do
            get_same_chars(chars1, chars2, [h1 | acc])
        else 
            get_same_chars(chars1, chars2, acc)
        end
    end
    def get_same_chars([], [], acc) do Enum.reverse(acc) end
end

ids = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Enum.to_list()

{touplets, triplets} = ChecksumProcessor.getValues(ids, 0, 0)

IO.puts(touplets * triplets)

max_same_chars = IDFinder.process_list(ids, ids, [])

IO.puts(max_same_chars)