good_job = fn ->
  Process.sleep(60_000)
  {:ok, []}
end

bad_job = fn ->
  Process.sleep(5_000)
  :error
end

doomed_job = fn ->
  Process.sleep(5_000)
  raise "KaBoom!"
end
