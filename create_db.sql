CREATE TYPE role_enum AS ENUM ('student', 'mentor', 'admin');

-- Створення таблиці користувачів
CREATE TABLE users (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    patronymic TEXT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role role_enum NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    additional_info JSONB -- Додаткові параметри користувача в форматі JSON
);

-- Створення таблиці заявок
CREATE TABLE applications (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    patronymic TEXT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    student_group TEXT NOT NULL,  -- Група студента
    application_text TEXT NOT NULL, -- Опис мотивації або додаткової інформації
    application_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- Створення таблиці тем
CREATE TABLE topics (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE -- Статус теми
);


-- Створення таблиці зв'язку багато до багатьох (студент - тема)
CREATE TABLE user_topics (
    user_id integer REFERENCES users(id) ON DELETE CASCADE,
    topic_id integer REFERENCES topics(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, topic_id)
);

CREATE TYPE chat_type AS ENUM ('general', 'topic');
-- Створення таблиці чатів
CREATE TABLE chats (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    type chat_type NOT NULL,
    topic_id integer REFERENCES topics(id) ON DELETE CASCADE, -- тільки для типу 'topic'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        (type = 'topic' AND topic_id IS NOT NULL)
        OR (type = 'general' AND topic_id IS NULL)
    )
);

-- Створення таблиці повідомлень
CREATE TABLE messages (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    chat_id integer REFERENCES chats(id) ON DELETE CASCADE,
    sender_id integer REFERENCES users(id) ON DELETE SET NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE chat_reads (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    chat_id INTEGER REFERENCES chats(id) ON DELETE CASCADE,
    last_read_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, chat_id)
);


CREATE TABLE refresh_tokens (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    token TEXT NOT NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMP NOT NULL
);

CREATE TABLE news (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL,
    content_html TEXT NOT NULL,
    cover_image TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    author_id integer REFERENCES users(id) ON DELETE SET NULL);

CREATE OR REPLACE FUNCTION create_topic_chat()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO chats (name, type, topic_id)
    VALUES (
        NEW.title,     -- Назва чату = назва теми
        'topic',
        NEW.id         -- Прив'язка до новоствореної теми
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_chat_after_topic
AFTER INSERT ON topics
FOR EACH ROW
EXECUTE FUNCTION create_topic_chat();



CREATE OR REPLACE FUNCTION create_chat_read_on_join()
RETURNS TRIGGER AS $$
DECLARE
    topic_chat_id INTEGER;
BEGIN
    -- Знаходимо чат, прив'язаний до теми
    SELECT id INTO topic_chat_id
    FROM chats
    WHERE topic_id = NEW.topic_id AND type = 'topic';

    -- Якщо знайдено — створюємо запис про прочитане
    IF topic_chat_id IS NOT NULL THEN
        INSERT INTO chat_reads (user_id, chat_id, last_read_at)
        VALUES (NEW.user_id, topic_chat_id, NOW());
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_chat_read_after_user_topic_insert
AFTER INSERT ON user_topics
FOR EACH ROW
EXECUTE FUNCTION create_chat_read_on_join();

CREATE OR REPLACE FUNCTION create_general_chat_read_on_user_create()
RETURNS TRIGGER AS $$
DECLARE
    general_chat_id INTEGER;
BEGIN
    -- Знаходимо чат типу 'general'
    SELECT id INTO general_chat_id
    FROM chats
    WHERE type = 'general'
    LIMIT 1;

    -- Якщо знайдено — додаємо запис про прочитане
    IF general_chat_id IS NOT NULL THEN
        INSERT INTO chat_reads (user_id, chat_id, last_read_at)
        VALUES (NEW.id, general_chat_id, NOW());
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_chat_read_after_user_insert
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION create_general_chat_read_on_user_create();


CREATE OR REPLACE FUNCTION delete_chat_read_on_user_topic_remove()
RETURNS TRIGGER AS $$
DECLARE
    topic_chat_id INTEGER;
BEGIN
    -- Знаходимо чат, привʼязаний до теми
    SELECT id INTO topic_chat_id
    FROM chats
    WHERE type = 'topic' AND topic_id = OLD.topic_id
    LIMIT 1;

    -- Видаляємо запис з chat_reads
    IF topic_chat_id IS NOT NULL THEN
        DELETE FROM chat_reads
        WHERE user_id = OLD.user_id AND chat_id = topic_chat_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_delete_chat_read_after_user_topic_delete
AFTER DELETE ON user_topics
FOR EACH ROW
EXECUTE FUNCTION delete_chat_read_on_user_topic_remove();


CREATE OR REPLACE FUNCTION unsubscribe_users_on_topic_deactivate()
RETURNS TRIGGER AS $$
BEGIN
    -- Перевіряємо, чи статус теми змінився з активного на неактивний
    IF OLD.is_active = TRUE AND NEW.is_active = FALSE THEN
        -- Видаляємо всіх користувачів, підписаних на цю тему
        DELETE FROM user_topics
        WHERE topic_id = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_unsubscribe_on_topic_deactivate
AFTER UPDATE ON topics
FOR EACH ROW
WHEN (OLD.is_active = TRUE AND NEW.is_active = FALSE)
EXECUTE FUNCTION unsubscribe_users_on_topic_deactivate();



INSERT INTO chats (name, type, topic_id) VALUES
('Загальний чат', 'general', NULL);
