-- USERS COLLECTION
CREATE TABLE Users (
    uid VARCHAR(255) PRIMARY KEY, -- Firebase Auth UID
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- USER_PROGRESS COLLECTION (Tracks algorithm mastery)
CREATE TABLE UserProgress (
    progress_id SERIAL PRIMARY KEY,
    uid VARCHAR(255) REFERENCES Users(uid),
    algorithm_id VARCHAR(50) NOT NULL, -- e.g., 'merge_sort', 'dijkstra'
    completion_percentage INT DEFAULT 0,
    is_mastered BOOLEAN DEFAULT FALSE,
    time_invested_minutes INT DEFAULT 0,
    last_accessed TIMESTAMP
);

-- PREFERENCES COLLECTION (Stores settings for the Kinetic Workspace)
CREATE TABLE UserPreferences (
    pref_id SERIAL PRIMARY KEY,
    uid VARCHAR(255) REFERENCES Users(uid),
    theme_mode VARCHAR(20) DEFAULT 'dark',
    default_animation_speed FLOAT DEFAULT 1.0,
    show_pseudo_code BOOLEAN DEFAULT TRUE
);
