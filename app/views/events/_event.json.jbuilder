json.extract! event, :id, :start_time, :end_time, :airplane_id, :created_at, :updated_at
json.url event_url(event, format: :json)
