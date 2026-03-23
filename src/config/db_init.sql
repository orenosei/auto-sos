-- USERS
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COMPANIES
CREATE TABLE companies (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address_text TEXT,
    location POINT NOT NULL,
    phone VARCHAR(20) NOT NULL,
    service_area VARCHAR(100),
    license_info TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    rating_avg DECIMAL(3,2) DEFAULT 0.00 CHECK (rating_avg BETWEEN 0 AND 5),
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SERVICES
CREATE TABLE services (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    currency VARCHAR(10) DEFAULT 'VND'
);

-- COMPANY SERVICES
CREATE TABLE company_services (
    company_id BIGINT REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
    service_id BIGINT REFERENCES services(id) ON DELETE CASCADE NOT NULL,
    price DECIMAL(12,2),
    PRIMARY KEY (company_id, service_id)
);

-- RESCUE VEHICLES
CREATE TABLE rescue_vehicles (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    status VARCHAR(30) DEFAULT 'available'
        CHECK (status IN ('available','busy','maintenance')),
    current_location POINT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- RESCUE REQUESTS
CREATE TABLE rescue_requests (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    company_id BIGINT REFERENCES companies(id) ON DELETE SET NULL,
    rescue_vehicle_id BIGINT REFERENCES rescue_vehicles(id) ON DELETE SET NULL,

    incident_location POINT NOT NULL,
    address_description TEXT,
    incident_type TEXT NOT NULL,
    detailed_description TEXT,
    images TEXT[],
    requested_services TEXT[],
    note TEXT,

    status VARCHAR(30) DEFAULT 'pending'
        CHECK (status IN ('pending','accepted','heading','arrived','processing','completed','cancelled')),

    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_time TIMESTAMP,
    estimated_arrival_time TIMESTAMP,
    actual_arrival_time TIMESTAMP,
    completed_time TIMESTAMP,

    estimated_price DECIMAL(12,2),
    actual_price DECIMAL(12,2),

    payment_method VARCHAR(50) DEFAULT 'cash',
    transaction_id VARCHAR(100),
    payment_status VARCHAR(30) DEFAULT 'pending'
        CHECK (payment_status IN ('pending','paid','failed')),

    cancellation_reason TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MESSAGES
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    request_id BIGINT REFERENCES rescue_requests(id) ON DELETE CASCADE NOT NULL,
    sender_type VARCHAR(20) NOT NULL
        CHECK (sender_type IN ('user','company')),
    sender_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- REVIEWS
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    request_id BIGINT REFERENCES rescue_requests(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    company_id BIGINT REFERENCES companies(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5) NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COMMUNITY POSTS
CREATE TABLE community_posts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(255) NOT NULL,
    tag VARCHAR(100),
    content TEXT NOT NULL,
    is_solved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- POST IMAGES
CREATE TABLE community_post_images (
    id BIGSERIAL PRIMARY KEY,
    image_url VARCHAR(2048) NOT NULL,
    post_id BIGINT REFERENCES community_posts(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COMMENTS
CREATE TABLE community_comments (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT REFERENCES community_posts(id) ON DELETE CASCADE NOT NULL,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    parent_comment_id BIGINT REFERENCES community_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- LIKES
CREATE TABLE community_likes (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT REFERENCES community_posts(id) ON DELETE CASCADE,
    comment_id BIGINT REFERENCES community_comments(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_like UNIQUE (post_id, comment_id, user_id)
);

-- INDEXES
CREATE INDEX idx_rescue_requests_user_id ON rescue_requests(user_id);
CREATE INDEX idx_rescue_requests_company_id ON rescue_requests(company_id);
CREATE INDEX idx_rescue_requests_status ON rescue_requests(status);

CREATE INDEX idx_messages_request_created 
ON messages(request_id, created_at DESC);

CREATE INDEX idx_community_posts_user 
ON community_posts(user_id);

CREATE INDEX idx_community_comments_post_created 
ON community_comments(post_id, created_at DESC);

CREATE INDEX idx_companies_location 
ON companies USING GIST (location);

CREATE INDEX idx_requests_location 
ON rescue_requests USING GIST (incident_location);