# Marathon Skills 2026 — Next.js Web App

Полноценное веб-приложение на Next.js с Google OAuth, Supabase и Serverless API.

---

## Стек

| Компонент       | Технология                          |
|----------------|-------------------------------------|
| Фреймворк      | **Next.js 14** (Pages Router)       |
| Аутентификация | **NextAuth.js** + Google OAuth 2.0  |
| База данных    | **Supabase** (PostgreSQL)           |
| API            | **Vercel Serverless Functions** `/api` |
| Стили          | CSS Modules + глобальный CSS        |
| Деплой         | **Vercel**                          |

---

## Быстрый старт

### 1. Установка зависимостей

```bash
npm install
```

### 2. Google OAuth — настройка

1. Откройте [console.cloud.google.com](https://console.cloud.google.com/)
2. Создайте проект → **APIs & Services** → **Credentials**
3. **Create Credentials** → **OAuth 2.0 Client ID** → **Web application**
4. Добавьте **Authorized redirect URIs**:
   - `http://localhost:3000/api/auth/callback/google` (для разработки)
   - `https://your-domain.vercel.app/api/auth/callback/google` (для продакшна)
5. Скопируйте **Client ID** и **Client Secret**

### 3. Supabase — настройка

1. Зарегистрируйтесь на [supabase.com](https://supabase.com) и создайте проект
2. Откройте **SQL Editor** и выполните содержимое файла `supabase-schema.sql`
3. В **Project Settings → API** скопируйте:
   - **URL** → `NEXT_PUBLIC_SUPABASE_URL`
   - **anon public** → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - **service_role secret** → `SUPABASE_SERVICE_ROLE_KEY`

### 4. Переменные окружения

```bash
cp .env.local.example .env.local
```

Заполните `.env.local`:

```env
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
NEXTAUTH_SECRET=<результат: openssl rand -base64 32>
NEXTAUTH_URL=http://localhost:3000
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
```

### 5. Запуск

```bash
npm run dev
```

Откройте [http://localhost:3000](http://localhost:3000)

---

## Деплой на Vercel

```bash
npm install -g vercel
vercel
```

Добавьте все переменные из `.env.local` в **Vercel → Settings → Environment Variables**.
Обновите `NEXTAUTH_URL` на реальный домен.
Добавьте продакшн-домен в разрешённые URI в Google Console.

---

## Структура проекта

```
marathon-skills/
├── pages/
│   ├── api/
│   │   ├── auth/[...nextauth].ts   # NextAuth — Google OAuth
│   │   ├── participants/
│   │   │   ├── index.ts            # GET (список) / POST (регистрация)
│   │   │   └── me.ts               # GET/PATCH текущего пользователя
│   │   └── admin/
│   │       ├── [id].ts             # PUT / DELETE (только Координаторы)
│   │       └── stats.ts            # GET статистика (только Координаторы)
│   ├── index.tsx                   # О марафоне (защищённая)
│   ├── login.tsx                   # Страница входа
│   ├── register.tsx                # Регистрация участника
│   ├── bmi.tsx                     # BMI калькулятор
│   ├── participants.tsx            # Список участников
│   └── admin.tsx                   # Панель администратора
├── components/
│   ├── Header.tsx                  # Шапка с именем/фото пользователя
│   ├── CountdownBar.tsx            # Таймер обратного отсчёта
│   └── withAuth.tsx                # HOC защиты маршрутов
├── lib/
│   ├── supabase.ts                 # Supabase Admin клиент
│   └── auth.ts                     # Вспомогательные функции auth
├── styles/
│   └── globals.css                 # Глобальные стили (переменные, компоненты)
├── supabase-schema.sql             # SQL для создания таблицы
└── .env.local.example              # Шаблон переменных
```

---

## Безопасность

- Все маршруты (кроме `/login`) защищены через `withAuth` HOC
- Все API-routes проверяют сессию и `user_id` из JWT
- Суперфункции администратора (PUT/DELETE) проверяют роль `Координатор`
- Запросы к БД идут только через Server-Side API с `service_role` ключом
- Клиент никогда не получает `service_role` ключ (он не `NEXT_PUBLIC_`)
- RLS в Supabase блокирует прямой доступ клиентов к таблице

---

## Роли

| Роль          | Возможности                                                    |
|---------------|----------------------------------------------------------------|
| Бегун         | Просмотр информации, регистрация, BMI-калькулятор, список      |
| Координатор   | Всё выше + Панель администратора: редактирование, блокировка, удаление |

Первый Координатор назначается вручную в Supabase (UPDATE participants SET role='Координатор').
