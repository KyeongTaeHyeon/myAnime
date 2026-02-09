class CreateInitialSchema < ActiveRecord::Migration[6.1]
  def change
    create_table :anime do |t|
      t.bigint :anilist_id, null: false
      t.string :title_romaji
      t.string :title_english
      t.string :title_native
      t.string :status
      t.string :season
      t.integer :season_year
      t.string :format
      t.integer :episodes
      t.integer :duration
      t.string :source
      t.string :cover_image_url
      t.string :banner_image_url
      t.integer :mean_score
      t.integer :popularity
      t.text :raw_json
      t.timestamps
    end
    add_index :anime, :anilist_id, unique: true
    add_index :anime, %i[season season_year]

    create_table :quotes do |t|
      t.string :source
      t.string :character_name
      t.text :quote_text
      t.references :anime, foreign_key: { to_table: :anime }, index: true
      t.text :raw_json
      t.timestamps
    end

    create_table :news_articles do |t|
      t.string :provider
      t.string :external_id
      t.string :title
      t.text :description
      t.string :url
      t.string :image_url
      t.datetime :published_at
      t.text :raw_json
      t.timestamps
    end
    add_index :news_articles, %i[provider external_id], unique: true
    add_index :news_articles, :published_at
    add_index :news_articles, :provider

    create_table :app_users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :display_name
      t.string :role
      t.timestamps
    end
    add_index :app_users, :email, unique: true

    create_table :anime_likes do |t|
      t.references :user, null: false, foreign_key: { to_table: :app_users }
      t.references :anime, null: false, foreign_key: { to_table: :anime }
      t.timestamps
    end
    add_index :anime_likes, %i[user_id anime_id], unique: true

    create_table :ingestion_states do |t|
      t.string :provider, null: false
      t.datetime :next_allowed_at
      t.string :last_error
      t.timestamps
    end
    add_index :ingestion_states, :provider, unique: true
  end
end
