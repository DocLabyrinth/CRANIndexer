class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|

      t.string :name
      t.string :version
      t.datetime :date
      t.string :title

      t.text :description
      t.string :repository
      t.string :licence
      t.datetime :packaged
      t.datetime :publication

      t.string :authors
      t.string :maintainers

      t.timestamps null: false
    end
  end
end
