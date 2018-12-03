defmodule AreaHandler do
    def addRectangles(area, [h | t]) do
        [_ | values] = Regex.run(~r/(\d+),(\d+): (\d+)x(\d+)/, h)
        [x_offset, y_offset, length, width] = Enum.map(values, fn(v) -> String.to_integer(v) end)
        indexed_area  = Enum.with_index(area)
        new_area = Enum.map(indexed_area, fn({list, x}) ->
            indexed_elements = Enum.with_index(list)
            Enum.map(indexed_elements, fn({element, y}) ->
                if x >= x_offset and y >= y_offset
                and x < x_offset + length and y < y_offset + width do
                    if element == "o" or element == "x" do
                        "x"
                    else 
                        "o"
                    end
                else
                    element
                end
            end)
        end)
        addRectangles(new_area, t)
    end 
    def addRectangles(area, []) do area end

    def countOverlap(area) do
        Enum.reduce(area, 0, fn(list, acc) -> 
            acc + Enum.reduce(list, 0, fn(element, list_acc) -> 
                if element == "x", do: list_acc + 1, else: list_acc
            end)
        end)
    end

    def hasNoOverlap(area, [h | t]) do
        [_ | values] = Regex.run(~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/, h)
        [id, x_offset, y_offset, length, width] = Enum.map(values, fn(v) -> String.to_integer(v) end)
        indexed_area  = Enum.with_index(area)
        overlap = Enum.reduce(indexed_area, 0, fn({list, x}, acc) ->
            indexed_elements = Enum.with_index(list)
            acc + Enum.reduce(indexed_elements, 0, fn({element, y}, list_acc) ->
                if x >= x_offset and y >= y_offset
                and x < x_offset + length and y < y_offset + width do
                    if element == "x" do
                        list_acc + 1
                    else 
                        list_acc
                    end
                else
                    list_acc
                end
            end)
        end)
        if overlap == 0 do
            id
        else
            hasNoOverlap(area, t)
        end
    end
end


side_length = 1000

area = 1..side_length |> Enum.map(fn _ ->
    1..side_length |> Enum.map(fn _ ->
        "."
    end)
end)

# IO.inspect(area)


rectangles = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Enum.to_list()

filled_area = AreaHandler.addRectangles(area, rectangles)

# IO.inspect(filled_area)

IO.inspect(AreaHandler.countOverlap(filled_area))

IO.inspect(AreaHandler.hasNoOverlap(filled_area, rectangles))
