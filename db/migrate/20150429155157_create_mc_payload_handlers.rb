class CreateMcPayloadHandlers < ActiveRecord::Migration
  #
  # CONSTANTS
  #
  # Name of the table being created
  TABLE_NAME = :mc_payload_handlers

  #
  # Instance Methods
  #

  # Drop {TABLE_NAME}.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create {TABLE_NAME}.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :general_handler_type,
               null: false
      t.string :handler_type,
               null: false
      t.string :name,
               null: false
    end

    change_table TABLE_NAME do |t|
      t.index :name,
              unique: true
    end
  end
end
