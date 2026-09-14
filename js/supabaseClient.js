// ============================================================
// CONFIGURACIÓN DE SUPABASE
// Estos valores ya están conectados a tu proyecto real.
// ============================================================
const SUPABASE_URL = "https://cppunumoinkobprdukqw.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_O4jAgjeqW4cqD7VmpqgsEA_R5mYT7_6";

// En modo privado de Safari (y en algunos navegadores con storage
// bloqueado), localStorage existe pero lanza un error al escribir.
// Sin este resguardo, eso rompe la creación del cliente y ningún
// botón de la app llega a responder. Si falla, usamos memoria
// temporal en su lugar (la sesión no persiste al cerrar la pestaña,
// pero la app funciona con normalidad mientras la usas).
const memoryStorage = {};
const safeStorage = {
  getItem: (key) => {
    try { return window.localStorage.getItem(key); }
    catch { return memoryStorage[key] ?? null; }
  },
  setItem: (key, value) => {
    try { window.localStorage.setItem(key, value); }
    catch { memoryStorage[key] = value; }
  },
  removeItem: (key) => {
    try { window.localStorage.removeItem(key); }
    catch { delete memoryStorage[key]; }
  },
};

export const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { storage: safeStorage, persistSession: true, autoRefreshToken: true },
});
