json.array!(@tasks) do |task|
  json.extract! task, :id, :title, :body, :format
  json.url task_url(task, format: :json)
end