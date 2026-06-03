import { createClient } from '@supabase/supabase-js'

// Server-side client (Service Role — обходит RLS, только для API routes)
export function getSupabaseAdmin() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL!
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY!
  if (!url || !key) throw new Error('Supabase env vars missing')
  return createClient(url, key)
}
