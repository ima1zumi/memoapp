# frozen_string_literal: true

require "pg"
require "yaml"

class Memo
  def self.connect
    yaml = YAML.load_file("database.yml")
    conn = PG.connect(
      host: yaml["host"],
      user: yaml["user"],
      password: yaml["password"],
      dbname: yaml["dbname"],
      port: yaml["port"]
      )
    yield conn
    ensure
      conn.close if conn
  end

  def self.memos
    sql = <<~SQL
    SELECT id, message
    FROM Memos
    ORDER BY updated_at DESC;
    SQL
    connect { |conn| conn.exec(sql) }
  end

  def self.has_id?(id)
    sql = <<~SQL
    SELECT id
    FROM Memos
    WHERE id = $1;
    SQL
    result = connect { |conn| conn.exec(sql, [id]) }
    result.ntuples > 0 ? true : false
  end

  def self.message(id)
    sql = <<~SQL
    SELECT message
    FROM Memos
    WHERE id = $1;
    SQL
    # PG::resultは[i]["カラム名"]で返す
    connect { |conn| conn.exec(sql, [id]) }[0]["message"]
  end

  def self.insert(message)
    sql = <<~SQL
    INSERT INTO Memos (message)
    VALUES ($1);
    SQL
    connect { |conn| conn.exec(sql, [message]) }
  end

  def self.update(id, message)
    sql = <<~SQL
    UPDATE Memos
    SET message = $1
    WHERE id = $2;
    SQL
    connect { |conn| conn.exec(sql, [message, id]) }
  end

  def self.delete(id)
    sql = <<~SQL
    DELETE FROM Memos
    WHERE id = $1;
    SQL
    connect { |conn| conn.exec(sql, [id]) }
  end
end
