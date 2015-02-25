class CreateMcModuleAncestors < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The table being created
  TABLE_NAME = :mc_module_ancestors

  #
  # Methods
  #

  # Drops the module_ancestors table
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates the module_ancestors table
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.string :module_type, null: false
      t.text :reference_name, null: false
      t.text :real_path, null: false
      t.datetime :real_path_modified_at, null: false
      t.string :real_path_sha1_hex_digest, limit: 40, null: false

      #
      # References
      #

      t.references :parent_path, null: false
    end

    change_table TABLE_NAME do |t|
      #
      # Foreign Key Indices
      #

      t.index :parent_path_id

      #
      # Unique Indices
      #

      t.index [:module_type, :reference_name], unique: true
      t.index :real_path, unique: true
      t.index :real_path_sha1_hex_digest, unique: true
    end
  end
end
