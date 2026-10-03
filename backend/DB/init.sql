CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    x TEXT,
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audio (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    link TEXT NOT NULL,
    description TEXT,
    name TEXT NOT NULL,
    x TEXT,
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (creator_id, link)
);

CREATE TABLE contract (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    link TEXT NOT NULL,
    description TEXT,
    name TEXT NOT NULL,
    x TEXT,
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (creator_id, link)
);

CREATE TABLE transcription (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    link TEXT NOT NULL,
    description TEXT,
    name TEXT NOT NULL,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (creator_id, link)
);

CREATE TABLE corporation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    corp_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    x TEXT,
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
);
