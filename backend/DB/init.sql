CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    status TEXT DEFAULT 'DEFAULT',
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audio (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    link TEXT NOT NULL UNIQUE,
    description TEXT,
    name TEXT NOT NULL,
    x TEXT,
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE contract (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    audio_id UUID NOT NULL REFERENCES audio(id) ON DELETE CASCADE,
    link TEXT NOT NULL UNIQUE,
    description TEXT,
    name TEXT NOT NULL,
    x TEXT,
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE transcription (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    audio_id UUID NOT NULL REFERENCES audio(id) ON DELETE CASCADE,
    link TEXT NOT NULL UNIQUE,
    description TEXT,
    name TEXT NOT NULL,
    x TEXT,
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE corporation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    corp_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'DEFAULT',
    y TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

