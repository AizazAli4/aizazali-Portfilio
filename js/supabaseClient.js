// ==========================================
// SUPABASE CONFIG
// Replace these two values with your own project's
// URL and public anon key (Supabase Dashboard -> Project Settings -> API)
// ==========================================
const SUPABASE_URL = "https://eqpfxbkostsaulwabhjt.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcGZ4Ymtvc3RzYXVsd2FiaGp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU4MjQ1NzAsImV4cCI6MjEwMTQwMDU3MH0.CZjdGNhmvscruCjd1KOE4qNG6hraoyc6YciN9rOKb68";

const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
