class CreateMcDirectClasses < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of the table being created
  TABLE_NAME = :mc_direct_classes

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
      #
      # STI
      #

      t.string :type, null: false

      #
      # Foreign Keys
      #

      t.references :ancestor, null: false
      t.references :rank, null: false
    end

    change_table TABLE_NAME do |t|
      t.index :ancestor_id,
              name: 'unique_mc_direct_classes',
              unique: true
    end
  end
end
