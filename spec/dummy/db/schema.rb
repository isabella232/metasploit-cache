# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150107190640) do

  create_table "mc_architectures", :force => true do |t|
    t.integer "bits"
    t.string  "abbreviation", :null => false
    t.string  "endianness"
    t.string  "family"
    t.string  "summary",      :null => false
  end

  add_index "mc_architectures", ["abbreviation"], :name => "index_mc_architectures_on_abbreviation", :unique => true
  add_index "mc_architectures", ["family", "bits", "endianness"], :name => "index_mc_architectures_on_family_and_bits_and_endianness", :unique => true
  add_index "mc_architectures", ["summary"], :name => "index_mc_architectures_on_summary", :unique => true

  create_table "mc_authorities", :force => true do |t|
    t.string  "abbreviation",                    :null => false
    t.boolean "obsolete",     :default => false, :null => false
    t.string  "summary"
    t.text    "url"
  end

  add_index "mc_authorities", ["abbreviation"], :name => "index_mc_authorities_on_abbreviation", :unique => true
  add_index "mc_authorities", ["summary"], :name => "index_mc_authorities_on_summary", :unique => true
  add_index "mc_authorities", ["url"], :name => "index_mc_authorities_on_url", :unique => true

  create_table "mc_authors", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "mc_authors", ["name"], :name => "index_mc_authors_on_name", :unique => true

  create_table "mc_email_addresses", :force => true do |t|
    t.string "domain", :null => false
    t.string "full",   :null => false
    t.string "local",  :null => false
  end

  add_index "mc_email_addresses", ["domain", "local"], :name => "index_mc_email_addresses_on_domain_and_local", :unique => true
  add_index "mc_email_addresses", ["domain"], :name => "index_mc_email_addresses_on_domain"
  add_index "mc_email_addresses", ["full"], :name => "index_mc_email_addresses_on_full", :unique => true
  add_index "mc_email_addresses", ["local"], :name => "index_mc_email_addresses_on_local"

  create_table "mc_module_actions", :force => true do |t|
    t.integer "module_instance_id", :null => false
    t.text    "name",               :null => false
  end

  add_index "mc_module_actions", ["module_instance_id", "name"], :name => "index_mc_module_actions_on_module_instance_id_and_name", :unique => true

  create_table "mc_module_ancestors", :force => true do |t|
    t.text     "full_name",                               :null => false
    t.string   "handler_type"
    t.string   "module_type",                             :null => false
    t.string   "payload_type"
    t.text     "reference_name",                          :null => false
    t.text     "real_path",                               :null => false
    t.datetime "real_path_modified_at",                   :null => false
    t.string   "real_path_sha1_hex_digest", :limit => 40, :null => false
    t.integer  "parent_path_id",                          :null => false
  end

  add_index "mc_module_ancestors", ["full_name"], :name => "index_mc_module_ancestors_on_full_name", :unique => true
  add_index "mc_module_ancestors", ["module_type", "reference_name"], :name => "index_mc_module_ancestors_on_module_type_and_reference_name", :unique => true
  add_index "mc_module_ancestors", ["parent_path_id"], :name => "index_mc_module_ancestors_on_parent_path_id"
  add_index "mc_module_ancestors", ["real_path"], :name => "index_mc_module_ancestors_on_real_path", :unique => true
  add_index "mc_module_ancestors", ["real_path_sha1_hex_digest"], :name => "index_mc_module_ancestors_on_real_path_sha1_hex_digest", :unique => true

  create_table "mc_module_architectures", :force => true do |t|
    t.integer "architecture_id",    :null => false
    t.integer "module_instance_id", :null => false
  end

  add_index "mc_module_architectures", ["module_instance_id", "architecture_id"], :name => "unique_mc_module_architectures", :unique => true

  create_table "mc_module_authors", :force => true do |t|
    t.integer "author_id",          :null => false
    t.integer "email_address_id"
    t.integer "module_instance_id", :null => false
  end

  add_index "mc_module_authors", ["author_id"], :name => "index_mc_module_authors_on_author_id"
  add_index "mc_module_authors", ["email_address_id"], :name => "index_mc_module_authors_on_email_address_id"
  add_index "mc_module_authors", ["module_instance_id", "author_id"], :name => "index_mc_module_authors_on_module_instance_id_and_author_id", :unique => true
  add_index "mc_module_authors", ["module_instance_id"], :name => "index_mc_module_authors_on_module_instance_id"

  create_table "mc_module_classes", :force => true do |t|
    t.text    "full_name",      :null => false
    t.string  "module_type",    :null => false
    t.string  "payload_type"
    t.text    "reference_name", :null => false
    t.integer "rank_id",        :null => false
  end

  add_index "mc_module_classes", ["full_name"], :name => "index_mc_module_classes_on_full_name", :unique => true
  add_index "mc_module_classes", ["module_type", "reference_name"], :name => "index_mc_module_classes_on_module_type_and_reference_name", :unique => true
  add_index "mc_module_classes", ["rank_id"], :name => "index_mc_module_classes_on_rank_id"

  create_table "mc_module_instances", :force => true do |t|
    t.text    "description",       :null => false
    t.date    "disclosed_on"
    t.string  "license",           :null => false
    t.text    "name",              :null => false
    t.boolean "privileged",        :null => false
    t.string  "stance"
    t.integer "default_action_id"
    t.integer "default_target_id"
    t.integer "module_class_id",   :null => false
  end

  add_index "mc_module_instances", ["default_action_id"], :name => "index_mc_module_instances_on_default_action_id", :unique => true
  add_index "mc_module_instances", ["default_target_id"], :name => "index_mc_module_instances_on_default_target_id", :unique => true
  add_index "mc_module_instances", ["module_class_id"], :name => "index_mc_module_instances_on_module_class_id", :unique => true

  create_table "mc_module_paths", :force => true do |t|
    t.string "gem"
    t.string "name"
    t.text   "real_path", :null => false
  end

  add_index "mc_module_paths", ["gem", "name"], :name => "index_mc_module_paths_on_gem_and_name", :unique => true
  add_index "mc_module_paths", ["real_path"], :name => "index_mc_module_paths_on_real_path", :unique => true

  create_table "mc_module_platforms", :force => true do |t|
    t.integer "module_instance_id", :null => false
    t.integer "platform_id",        :null => false
  end

  add_index "mc_module_platforms", ["module_instance_id", "platform_id"], :name => "index_mc_module_platforms_on_module_instance_id_and_platform_id", :unique => true

  create_table "mc_module_ranks", :force => true do |t|
    t.string  "name",   :null => false
    t.integer "number", :null => false
  end

  add_index "mc_module_ranks", ["name"], :name => "index_mc_module_ranks_on_name", :unique => true
  add_index "mc_module_ranks", ["number"], :name => "index_mc_module_ranks_on_number", :unique => true

  create_table "mc_module_references", :force => true do |t|
    t.integer "module_instance_id", :null => false
    t.integer "reference_id",       :null => false
  end

  add_index "mc_module_references", ["module_instance_id", "reference_id"], :name => "unique_mc_module_references", :unique => true

  create_table "mc_module_relationships", :force => true do |t|
    t.integer "ancestor_id",   :null => false
    t.integer "descendant_id", :null => false
  end

  add_index "mc_module_relationships", ["descendant_id", "ancestor_id"], :name => "index_mc_module_relationships_on_descendant_id_and_ancestor_id", :unique => true

  create_table "mc_module_target_architectures", :force => true do |t|
    t.integer "architecture_id",  :null => false
    t.integer "module_target_id", :null => false
  end

  add_index "mc_module_target_architectures", ["module_target_id", "architecture_id"], :name => "unique_mc_module_target_architectures", :unique => true

  create_table "mc_module_target_platforms", :force => true do |t|
    t.integer "module_target_id", :null => false
    t.integer "platform_id",      :null => false
  end

  add_index "mc_module_target_platforms", ["module_target_id", "platform_id"], :name => "unique_mc_module_target_platforms", :unique => true

  create_table "mc_module_targets", :force => true do |t|
    t.integer "index",              :null => false
    t.text    "name",               :null => false
    t.integer "module_instance_id", :null => false
  end

  add_index "mc_module_targets", ["module_instance_id", "index"], :name => "index_mc_module_targets_on_module_instance_id_and_index", :unique => true
  add_index "mc_module_targets", ["module_instance_id", "name"], :name => "index_mc_module_targets_on_module_instance_id_and_name", :unique => true

  create_table "mc_platforms", :force => true do |t|
    t.text    "fully_qualified_name", :null => false
    t.text    "relative_name",        :null => false
    t.integer "parent_id"
    t.integer "right",                :null => false
    t.integer "left",                 :null => false
  end

  add_index "mc_platforms", ["fully_qualified_name"], :name => "index_mc_platforms_on_fully_qualified_name", :unique => true
  add_index "mc_platforms", ["parent_id", "relative_name"], :name => "index_mc_platforms_on_parent_id_and_relative_name", :unique => true

  create_table "mc_references", :force => true do |t|
    t.string  "designation"
    t.text    "url"
    t.integer "authority_id"
  end

  add_index "mc_references", ["authority_id", "designation"], :name => "index_mc_references_on_authority_id_and_designation", :unique => true
  add_index "mc_references", ["url"], :name => "index_mc_references_on_url", :unique => true

end