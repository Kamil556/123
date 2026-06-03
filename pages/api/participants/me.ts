import type { NextApiRequest, NextApiResponse } from 'next'
import { getServerSession } from 'next-auth/next'
import { authOptions } from '../auth/[...nextauth]'
import { getSupabaseAdmin } from '../../../lib/supabase'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const session = await getServerSession(req, res, authOptions)
  if (!session?.user) return res.status(401).json({ error: 'Unauthorized' })

  const userId = (session.user as any).id as string
  const db = getSupabaseAdmin()

  // ── PATCH: обновить BMI текущего пользователя ────────────────────
  if (req.method === 'PATCH') {
    const { bmi } = req.body
    const bmiVal = bmi !== undefined && bmi !== null ? parseFloat(bmi) : null

    const { data, error } = await db
      .from('participants')
      .update({ bmi: bmiVal })
      .eq('user_id', userId)
      .select()
      .single()

    if (error) return res.status(500).json({ error: error.message })
    return res.status(200).json(data)
  }

  // ── GET: получить запись текущего пользователя ───────────────────
  if (req.method === 'GET') {
    const { data, error } = await db
      .from('participants')
      .select('*')
      .eq('user_id', userId)
      .single()

    if (error && error.code !== 'PGRST116') return res.status(500).json({ error: error.message })
    return res.status(200).json(data || null)
  }

  res.setHeader('Allow', ['GET', 'PATCH'])
  res.status(405).end(`Method ${req.method} Not Allowed`)
}
