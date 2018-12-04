defmodule ShiftAnalyzer do
    def get_guard_hours([h | t], times) do
        [_, guard_id] = Regex.run(~r/#(\d+)/,h.action)
        get_guard_hours(t, times, guard_id)
    end
    def get_guard_hours([h | t], times, guard_id) do
        if String.contains?(h.action, "Guard") do
            get_guard_hours([h | t], times)
        else
            get_guard_hours(t, times, guard_id, h.time)
        end
    end
    def get_guard_hours([h | t], times, guard_id, start_time) do
        time_slept = trunc(DateTime.diff(h.time, start_time) / 60)
        # IO.puts("#{guard_id} slept #{time_slept}")
        new_time_slept = Map.get(times, guard_id, %{})
            |> Map.update("time_slept", time_slept, &(&1 + time_slept))

        slept_minutes = Map.get(times, guard_id, %{})
            |> Map.get("slept_minutes", %{})    

        new_slept_minutes = get_slept_minutes(start_time, time_slept)
            |> Enum.reduce(slept_minutes, fn(minute, acc) -> 
                Map.update(acc, minute, 1, &(&1 + 1))
            end)

        new_time_slept_with_minutes = Map.put(new_time_slept, "slept_minutes", new_slept_minutes)
        # IO.inspect(new_time_slept_with_minutes)

        # IO.inspect(new_slept_minutes)

        new_times = Map.put(times, guard_id, new_time_slept_with_minutes)
        cond do
            t == [] ->
                new_times    
            hd(t).action == "falls asleep" ->
                get_guard_hours(t, new_times, guard_id)
            String.contains?(hd(t).action, "Guard") ->
                get_guard_hours(t, new_times)
        end
    end

    def get_slept_minutes(start_time, minutes_slept) do
        start_time.minute..start_time.minute + minutes_slept - 1 
            |> Enum.to_list()
    end
end

shifts = File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Enum.to_list()
|> Enum.map(fn(entry) -> 
        [_, date, time, action] = Regex.run(~r/\[(.*) (.*)\] (.*)/, entry) 
        {:ok, date_time, 0} = DateTime.from_iso8601("#{date}T#{time}:00Z")
        %{time: date_time, action: action}
    end)
|> Enum.sort(fn(x, y) -> 
        DateTime.compare(x.time, y.time) == :lt
    end)

# IO.inspect(hd(shifts).time.minute)

times = ShiftAnalyzer.get_guard_hours(shifts, %{})

# IO.inspect(times)


top_sleeper = times
|> Enum.sort(&(elem(&1, 1)["time_slept"] >= elem(&2, 1)["time_slept"]))
|> hd()
|> elem(0)

IO.inspect(top_sleeper)

Map.get(times, top_sleeper)["slept_minutes"]
|> Enum.sort(&(elem(&1, 1) >= elem(&2, 1)))
|> hd()
|> elem(0) 
|> Kernel.*(String.to_integer(top_sleeper))
|> IO.inspect()

top_minute = Enum.sort_by(times, fn(x) -> 
    elem(x, 1)["slept_minutes"]
    |> Enum.max_by(&(elem(&1, 1)))
    |> elem(1)
    # |> IO.inspect()
end, &>=/2)
|> hd()

top_minute
|> elem(1)
|> Map.get("slept_minutes")
|> Map.to_list()
|> Enum.sort_by(&(elem(&1, 1)), &>=/2)
|> hd()
|> elem(0)
|> Kernel.*(String.to_integer(elem(top_minute, 0)))
|> IO.inspect

