
-- Create schema
DROP SCHEMA IF EXISTS example;
CREATE SCHEMA example;
USE example;

DROP TABLE IF EXISTS users;
CREATE TABLE users
(
  id           INT(10) NOT NULL AUTO_INCREMENT,
  name     VARCHAR(40),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- Sample users data
INSERT INTO users (name) VALUES ("Nagaoka");
INSERT INTO users (name) VALUES ("Tanaka");