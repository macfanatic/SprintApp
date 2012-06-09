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

ActiveRecord::Schema.define(:version => 20120609012603) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "addresses", :force => true do |t|
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "street"
    t.string   "city"
    t.string   "state",            :limit => 2
    t.integer  "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["addressable_type", "addressable_id"], :name => "index_addresses_on_addressable_type_and_addressable_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :default => "",      :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",      :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "role",                                  :default => "admin"
    t.string   "time_zone"
    t.datetime "suspended_at"
    t.string   "suspension_reason"
    t.boolean  "new_user",                              :default => true
    t.boolean  "send_welcome_email",                    :default => true
    t.string   "avatar"
    t.string   "github"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true
  add_index "admin_users", ["role"], :name => "index_admin_users_on_role"

  create_table "admin_users_teams", :id => false, :force => true do |t|
    t.integer "admin_user_id"
    t.integer "team_id"
  end

  add_index "admin_users_teams", ["admin_user_id"], :name => "index_admin_users_teams_on_admin_user_id"
  add_index "admin_users_teams", ["team_id"], :name => "index_admin_users_teams_on_team_id"

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.integer  "addressable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "hourly_rate",    :precision => 10, :scale => 2, :default => 0.0
    t.string   "url"
  end

  add_index "clients", ["addressable_id"], :name => "index_clients_on_addressable_id"
  add_index "clients", ["url"], :name => "index_clients_on_url"

  create_table "contacts", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "addressable_id"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "cell",           :precision => 10, :scale => 0
    t.decimal  "phone",          :precision => 10, :scale => 0
  end

  add_index "contacts", ["addressable_id"], :name => "index_contacts_on_addressable_id"
  add_index "contacts", ["client_id"], :name => "index_contacts_on_client_id"

  create_table "members_projects", :id => false, :force => true do |t|
    t.integer "member_id"
    t.integer "project_id"
  end

  add_index "members_projects", ["member_id"], :name => "index_members_projects_on_member_id"
  add_index "members_projects", ["project_id"], :name => "index_members_projects_on_project_id"

  create_table "milestones", :force => true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "description"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed",   :default => false
    t.string   "url"
  end

  add_index "milestones", ["completed"], :name => "index_milestones_on_completed"
  add_index "milestones", ["project_id"], :name => "index_milestones_on_project_id"
  add_index "milestones", ["url"], :name => "index_milestones_on_url"

  create_table "project_files", :force => true do |t|
    t.string   "file"
    t.string   "description"
    t.integer  "project_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "url"
  end

  add_index "project_files", ["project_id"], :name => "index_project_files_on_project_id"
  add_index "project_files", ["url"], :name => "index_project_files_on_url"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "description"
    t.integer  "client_id"
    t.integer  "product_owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed",                                       :default => false
    t.decimal  "hourly_rate",      :precision => 10, :scale => 2, :default => 0.0
    t.text     "whiteboard"
    t.integer  "number"
    t.string   "url"
  end

  add_index "projects", ["client_id"], :name => "index_projects_on_client_id"
  add_index "projects", ["completed"], :name => "index_projects_on_completed"
  add_index "projects", ["end_date"], :name => "index_projects_on_end_date"
  add_index "projects", ["number"], :name => "index_projects_on_number"
  add_index "projects", ["product_owner_id"], :name => "index_projects_on_product_owner_id"
  add_index "projects", ["start_date"], :name => "index_projects_on_start_date"
  add_index "projects", ["url"], :name => "index_projects_on_url"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticket_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticket_comments", :force => true do |t|
    t.text     "body"
    t.integer  "version_id"
    t.integer  "ticket_id"
    t.decimal  "time",       :precision => 19, :scale => 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ticket_comments", ["ticket_id"], :name => "index_ticket_comments_on_ticket_id"
  add_index "ticket_comments", ["version_id"], :name => "index_ticket_comments_on_version_id"

  create_table "ticket_priorities", :force => true do |t|
    t.string   "name"
    t.string   "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ticket_priorities", ["name"], :name => "index_ticket_priorities_on_name"
  add_index "ticket_priorities", ["weight"], :name => "index_ticket_priorities_on_weight"

  create_table "ticket_statuses", :force => true do |t|
    t.string   "name"
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ticket_statuses", ["active"], :name => "index_ticket_statuses_on_active"

  create_table "ticket_timers", :force => true do |t|
    t.integer  "admin_user_id"
    t.integer  "ticket_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "ticket_timers", ["admin_user_id", "ticket_id"], :name => "index_ticket_timers_on_admin_user_id_and_ticket_id"
  add_index "ticket_timers", ["admin_user_id"], :name => "index_ticket_timers_on_admin_user_id"
  add_index "ticket_timers", ["ticket_id"], :name => "index_ticket_timers_on_ticket_id"

  create_table "tickets", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "ticket_category_id"
    t.integer  "assignee_id"
    t.integer  "milestone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
    t.decimal  "estimated_time",     :precision => 19, :scale => 4, :default => 0.0
    t.decimal  "actual_time",        :precision => 19, :scale => 4, :default => 0.0
    t.boolean  "billable",                                          :default => true
    t.integer  "ticket_priority_id"
    t.integer  "project_id"
    t.string   "url"
    t.integer  "number"
    t.decimal  "budget_progress",    :precision => 19, :scale => 4
  end

  add_index "tickets", ["assignee_id"], :name => "index_tickets_on_assignee_id"
  add_index "tickets", ["billable"], :name => "index_tickets_on_billable"
  add_index "tickets", ["end_date"], :name => "index_tickets_on_end_date"
  add_index "tickets", ["milestone_id"], :name => "index_tickets_on_milestone_id"
  add_index "tickets", ["number"], :name => "index_tickets_on_number"
  add_index "tickets", ["project_id"], :name => "index_tickets_on_project_id"
  add_index "tickets", ["start_date"], :name => "index_tickets_on_start_date"
  add_index "tickets", ["status_id"], :name => "index_tickets_on_status_id"
  add_index "tickets", ["ticket_category_id"], :name => "index_tickets_on_ticket_category_id"
  add_index "tickets", ["ticket_priority_id"], :name => "index_tickets_on_ticket_priority_id"
  add_index "tickets", ["url"], :name => "index_tickets_on_url"

  create_table "tickets_watchers", :id => false, :force => true do |t|
    t.integer "ticket_id"
    t.integer "watcher_id"
  end

  add_index "tickets_watchers", ["ticket_id"], :name => "index_tickets_watchers_on_ticket_id"
  add_index "tickets_watchers", ["watcher_id"], :name => "index_tickets_watchers_on_watcher_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"
  add_index "versions", ["whodunnit"], :name => "index_versions_on_whodunnit"

end
