-- Таблиця users
INSERT INTO users (first_name, last_name, patronymic, email, password, role) VALUES
('Іван', 'Іваненко', 'Іванович', 'ivan@example.com', 'hashed_pass1', 'student'),
('Олена', 'Петренко', 'Олександрівна', 'olena@example.com', 'hashed_pass2', 'student'),
('Микола', 'Сидоренко', 'Павлович', 'mykola@example.com', 'hashed_pass3', 'mentor'),
('Юлія', 'Коваль', 'Андріївна', 'yulia@example.com', 'hashed_pass4', 'student'),
('Олег', 'Ткачук', 'Віталійович', 'oleh@example.com', 'hashed_pass5', 'mentor'),
('Адмін', 'Адміненко', '', 'admin@example.com', 'hashed_admin', 'admin');

-- Таблиця applications
INSERT INTO applications (first_name, last_name, patronymic, email, password, student_group, application_text) VALUES
('Іван', 'Шевченко', 'Ілліч', 'shevchenko1@example.com', 'pass123', 'КН-21', 'Хочу навчатися у вас.'),
('Олена', 'Гончар', 'Сергіївна', 'gonchar2@example.com', 'pass123', 'КН-22', 'Маю інтерес до ІТ.'),
('Марія', 'Кириленко', 'Андріївна', 'maria3@example.com', 'pass123', 'КН-23', 'Досвід у Python.'),
('Андрій', 'Мельник', 'Юрійович', 'andriy4@example.com', 'pass123', 'КН-24', 'Хочу працювати в команді.'),
('Катерина', 'Бондар', 'Вікторівна', 'katya5@example.com', 'pass123', 'КН-25', 'Маю мотивацію до навчання.'),
('Тарас', 'Дмитрук', 'Богданович', 'taras6@example.com', 'pass123', 'КН-26', 'Готовий до викликів.');

-- Таблиця topics
INSERT INTO topics (title, description) VALUES
('Штучний інтелект', 'Все про AI.'),
('Веб-розробка', 'React, Node.js, HTML/CSS.'),
('Інтернет речей', 'IoT, Raspberry Pi, сенсори.'),
('Кібербезпека', 'Захист систем, мережі.'),
('Бази даних', 'SQL, NoSQL, ORM.'),
('Мобільна розробка', 'Android, iOS, Flutter.');

-- Таблиця user_topics
INSERT INTO user_topics (user_id, topic_id) VALUES
(1, 1),
(2, 2),
(4, 3),
(1, 4),
(2, 5),
(4, 6);

-- Таблиця chats
INSERT INTO chats (name, type, topic_id) VALUES
('Загальний чат', 'general', NULL),
('AI Talk', 'topic', 1),
('Web Dev', 'topic', 2),
('IoT Чат', 'topic', 3),
('Security Chat', 'topic', 4),
('DB Talk', 'topic', 5);

-- Таблиця messages
INSERT INTO messages (chat_id, sender_id, message) VALUES
(1, 1, 'Привіт усім!'),
(2, 2, 'Що нового в AI?'),
(3, 4, 'Люблю React!'),
(4, 1, 'IoT крута тема!'),
(5, 2, 'Як ви захищаєте свої проєкти?'),
(6, 4, 'MongoDB чи PostgreSQL?');
