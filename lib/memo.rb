# frozen_string_literal: true

require "pg"
require "yaml"

class Memo
  def connect
    yaml = YAML.load_file("database.yml")
    @conn = PG.connect(
      host: yaml["host"],
      user: yaml["user"],
      password: yaml["password"],
      dbname: yaml["dbname"],
      port: yaml["port"]
      )
    yield
  rescue PG::Error => e
    puts e.message
  ensure
    @conn.close if @conn
end

  def ids
    connect { @conn.exec(
      "SELECT * FROM Memos
        ORDER BY updated_at DESC;"
      ) }.map { |result| result["id"] }
  end

  def count_id(id)
    count = 0
    connect do
      result = @conn.exec("SELECT * FROM Memos WHERE id = $1;", [id])
      count = result.ntuples
    end
    count
  end

  def texts(id)
    texts = ""
    connect do
      @conn.exec("SELECT texts FROM Memos WHERE id = $1;", [id]).each do |result|
        texts = result["texts"]
      end
    end
    texts
  end

  def title(id)
    texts(id).chomp.split("\n")&.first || "タイトルなし"
  end

  def insert(message)
    connect { @conn.exec(
      "INSERT INTO Memos (texts) VALUES ($1);", [message]
      ) }
  end

  def update(id, message)
    connect { @conn.exec(
      "UPDATE Memos
        SET texts = $1
        WHERE id = $2;",
        [message, id]
        ) }
  end

  def delete(id)
    connect { @conn.exec(
      "DELETE FROM Memos
        WHERE id = $1;" [id]
    ) }
  end
end
