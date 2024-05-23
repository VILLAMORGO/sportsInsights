class AddBotResponseToResponses < ActiveRecord::Migration[7.1]
  def change
    add_column :responses, :bot_response, :text
  end
end
