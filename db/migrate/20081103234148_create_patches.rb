class CreatePatches < ActiveRecord::Migration
  def self.up
    create_table :patches do |t|
      t.string :url
      t.text :html
      t.text :css
      t.text :js
      t.string :path
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :patches
  end
end
