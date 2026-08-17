-- Run once in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,email text not null,full_name text not null default 'Reader',role text not null default 'reader' check(role in('owner','reader')),status text not null default 'pending' check(status in('pending','approved','denied')),requested_at timestamptz not null default now(),approved_at timestamptz);
create table if not exists public.documents(id uuid primary key default gen_random_uuid(),title text not null,collection text not null default 'General',description text not null default '',chapter_count integer not null default 0,content_type text not null default 'text/plain',file_path text,text_content text,created_by uuid not null references auth.users(id),created_at timestamptz not null default now());
create or replace function public.new_user_profile()returns trigger language plpgsql security definer set search_path=public as $$declare first_owner boolean;begin select not exists(select 1 from profiles where role='owner')into first_owner;insert into profiles(id,email,full_name,role,status,approved_at)values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name','Reader'),case when first_owner then'owner'else'reader'end,case when first_owner then'approved'else'pending'end,case when first_owner then now()else null end);return new;end$$;
drop trigger if exists on_auth_user_created on auth.users;create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.new_user_profile();
create or replace function public.is_owner()returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from profiles where id=auth.uid()and role='owner'and status='approved')$$;
create or replace function public.is_approved()returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from profiles where id=auth.uid()and status='approved')$$;
alter table profiles enable row level security;alter table documents enable row level security;
create policy "profile visibility" on profiles for select using(id=auth.uid()or is_owner());
create policy "owner profile updates" on profiles for update using(is_owner())with check(is_owner());
create policy "approved document reading" on documents for select using(is_approved());
create policy "owner document uploads" on documents for insert with check(is_owner()and created_by=auth.uid());
create policy "owner document updates" on documents for update using(is_owner())with check(is_owner());
create policy "owner document deletion" on documents for delete using(is_owner());
insert into storage.buckets(id,name,public)values('documents','documents',false)on conflict(id)do update set public=false;
create policy "approved file reading" on storage.objects for select using(bucket_id='documents'and is_approved());
create policy "owner file uploads" on storage.objects for insert with check(bucket_id='documents'and is_owner());
create policy "owner file deletion" on storage.objects for delete using(bucket_id='documents'and is_owner());
