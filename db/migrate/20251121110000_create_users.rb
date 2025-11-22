class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :shop, null: false, foreign_key: { on_delete: :restrict }
      t.string :email, null: false
      t.string :name, null: false
      t.string :password_digest, null: false
      t.integer :failed_attempts, null: false, default: 0
      t.datetime :locked_at
      t.datetime :last_sign_in_at
      t.string :last_sign_in_ip
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      t.timestamps
    end

    add_index :users, %i[shop_id email], unique: true
    add_index :users, :reset_password_token, unique: true, where: "reset_password_token IS NOT NULL"
    add_check_constraint :users, "failed_attempts >= 0", name: "users_failed_attempts_non_negative"
    add_check_constraint :users, "length(password_digest) >= 60", name: "users_password_digest_length_check"
  end
end
