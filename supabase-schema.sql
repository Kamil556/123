-- ═══════════════════════════════════════════════════════════════
--  Marathon Skills 2026 — Supabase Schema
--  Выполните этот SQL в Supabase → SQL Editor
-- ═══════════════════════════════════════════════════════════════

-- Участники марафона
CREATE TABLE IF NOT EXISTS participants (
  id          BIGSERIAL PRIMARY KEY,
  user_id     TEXT NOT NULL,                      -- Google sub из NextAuth session
  email       TEXT NOT NULL,
  name        TEXT NOT NULL,
  surname     TEXT NOT NULL,
  gender      TEXT NOT NULL DEFAULT 'Мужской',
  dob         DATE,
  country     TEXT DEFAULT 'Казахстан',
  photo_url   TEXT,
  role        TEXT NOT NULL DEFAULT 'Бегун',      -- 'Бегун' | 'Координатор'
  bmi         NUMERIC(5,2),
  active      BOOLEAN NOT NULL DEFAULT TRUE,
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_participants_user_id ON participants(user_id);
CREATE INDEX IF NOT EXISTS idx_participants_email   ON participants(email);
CREATE INDEX IF NOT EXISTS idx_participants_role    ON participants(role);
CREATE INDEX IF NOT EXISTS idx_participants_active  ON participants(active);

-- Автообновление updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_participants_updated_at
  BEFORE UPDATE ON participants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ─── Row Level Security ──────────────────────────────────────────
-- Включаем RLS, но все запросы идут через Service Role ключ (server-side),
-- поэтому RLS для client-side заблокирован полностью.
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;

-- Только service_role (сервер) имеет доступ
CREATE POLICY "service_role_only" ON participants
  USING (auth.role() = 'service_role');
