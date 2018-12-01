defmodule SignalAnalyzer do
    def process_list(changes, frequencies, current_frequency, index) do
        case MapSet.member?(frequencies, current_frequency) do
            true ->
                {true, current_frequency}
            false ->
                if index == length(changes) do
                    process_list(changes, MapSet.put(frequencies, current_frequency), 
                    current_frequency + Enum.at(changes, 0), 1)
                else
                    process_list(changes, MapSet.put(frequencies, current_frequency), 
                    current_frequency + Enum.at(changes, index), index + 1)              
                end
        end
    end
end

changes = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Enum.to_list()

{true, double_freq} = SignalAnalyzer.process_list(changes, MapSet.new(), 0, 0)

IO.puts(double_freq)