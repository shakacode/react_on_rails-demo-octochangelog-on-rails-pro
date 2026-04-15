# frozen_string_literal: true

class CreateAtomicCrmCoreTables < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :sector
      t.string :size
      t.string :website
      t.string :city

      t.timestamps
    end

    create_table :contacts do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :title
      t.string :status, null: false, default: "warm"
      t.datetime :last_seen_at
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    create_table :deals do |t|
      t.string :name, null: false
      t.string :stage, null: false, default: "lead"
      t.integer :amount, null: false, default: 0
      t.datetime :last_seen_at
      t.references :company, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end

    create_table :tasks do |t|
      t.string :title, null: false
      t.date :due_on, null: false
      t.string :status, null: false, default: "open"
      t.string :priority, null: false, default: "medium"
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end

    create_table :notes do |t|
      t.text :body, null: false
      t.references :contact, foreign_key: true
      t.references :deal, foreign_key: true

      t.timestamps
    end

    add_index :contacts, :status
    add_index :contacts, :last_seen_at
    add_index :deals, :stage
    add_index :deals, :last_seen_at
    add_index :tasks, %i[status due_on]
  end
end
