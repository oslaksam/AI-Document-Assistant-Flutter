-- https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
-- Create a table for public profiles
create table profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  full_name text,
  avatar_url text,
  website text,

  constraint username_length check (char_length(username) >= 3)
);

-- Create a table for documents
create table documents (
  id bigserial primary key,
  user_id uuid references profiles(id) on delete cascade,
  metadata jsonb
);

-- Create a table for chunks
create table chunks (
  id bigserial primary key,
  document_id bigint references documents(id) on delete cascade,
  content text, -- corresponds to Document.pageContent
  metadata jsonb, -- corresponds to Document.metadata
  embedding vector(1536) -- 1536 works for OpenAI embeddings, change if needed
);

-- Set up Row Level Security (RLS)
-- See https://supabase.com/docs/guides/auth/row-level-security for more details.
alter table profiles
  enable row level security;

create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- This trigger automatically creates a profile entry when a new user signs up via Supabase Auth.
-- See https://supabase.com/docs/guides/auth/managing-user-data#using-triggers for more details.
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Set up Storage!
insert into storage.buckets (id, name)
  values ('avatars', 'avatars');

-- Set up access controls for storage.
-- See https://supabase.com/docs/guides/storage#policy-examples for more details.
create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');

create policy "Anyone can update their own avatar." on storage.objects
  for update using (auth.uid() = owner) with check (bucket_id = 'avatars');

-- Enable the pgvector extension to work with embedding vectors
create extension vector;

-- Create a function to search for chunks
create function match_chunks (
  query_embedding vector(1536),
  match_count int
) returns table (
  id bigint,
  content text,
  document_id bigint,
  similarity float
)
language plpgsql
as $$
#variable_conflict use_column
begin
  return query
  select
    id,
    content,
    document_id,
    1 - (chunks.embedding <=> query_embedding) as similarity
  from chunks
  order by chunks.embedding <=> query_embedding
  limit match_count;
end;
$$;

-- Create a function to search for chunks with a specific document_id
create or replace function match_chunks_with_doc_id (
  query_embedding vector(1536),
  match_count int,
  target_document_id bigint
) returns table (
  id bigint,
  content text,
  document_id bigint,
  similarity float
)
language plpgsql
as $$
#variable_conflict use_column
begin
  return query
  select
    id,
    content,
    document_id,
    1 - (chunks.embedding <=> query_embedding) as similarity
  from chunks
  where document_id = target_document_id
  order by chunks.embedding <=> query_embedding
  limit match_count;
end;
$$;


create or replace function match_chunks_with_doc_id_threshold (
  document_id bigint,
  query_embedding vector(1536),
  match_threshold float,
  match_count int
)
returns table (
  id bigint,
  content text,
  similarity float
)
language plpgsql
as $$
begin
  return query
  select
    chunks.id,
    chunks.content,
    1 - (chunks.embedding <=> query_embedding) as similarity
  from chunks
  where chunks.document_id = document_id
    and 1 - (chunks.embedding <=> query_embedding) > match_threshold
  order by similarity desc
  limit match_count;
end;
$$;



-- Create an index to be used by the search function
create index on chunks
  using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);


-- Policies for documents table
create policy "Users can create their own documents." on documents
  for insert with check (auth.uid() = user_id);

create policy "Users can view their own documents." on documents
  for select using (auth.uid() = user_id);

create policy "Users can update their own documents." on documents
  for update using (auth.uid() = user_id);

create policy "Users can delete their own documents." on documents
  for delete using (auth.uid() = user_id);

-- Enable Row Level Security on documents table
alter table documents
  enable row level security;
  
-- Policies for chunks table
create policy "Users can create chunks in their own documents." on chunks
  for insert with check (auth.uid() = (select user_id from documents where id = document_id));

create policy "Users can view chunks in their own documents." on chunks
  for select using (auth.uid() = (select user_id from documents where id = document_id));

create policy "Users can update chunks in their own documents." on chunks
  for update using (auth.uid() = (select user_id from documents where id = document_id));

create policy "Users can delete chunks in their own documents." on chunks
  for delete using (auth.uid() = (select user_id from documents where id = document_id));

-- Enable Row Level Security on chunks table
alter table chunks
  enable row level security;

CREATE POLICY "Enable insert for authenticated users only" ON "public"."chunks"
AS PERMISSIVE FOR INSERT
TO authenticated

WITH CHECK (true)
