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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE -- Статус теми
);


-- Створення таблиці зв'язку багато до багатьох (студент - тема)
CREATE TABLE user_topics (
    user_id integer REFERENCES users(id) ON DELETE CASCADE,
    topic_id integer REFERENCES topics(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, topic_id)
);

CREATE TYPE chat_type AS ENUM ('general', 'topic');
-- Створення таблиці чатів
CREATE TABLE chats (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    type chat_type NOT NULL,
    topic_id integer REFERENCES topics(id) ON DELETE CASCADE, -- тільки для типу 'topic'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    token TEXT NOT NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE
);
