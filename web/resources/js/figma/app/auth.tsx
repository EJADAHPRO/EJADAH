import { createContext, useContext, useState, useEffect } from "react";

export interface EjadahUser {
  firstName: string;
  lastName: string;
  email: string;
  role: string;
  country: string;
  joinedAt: string;
}

interface AuthCtx {
  user: EjadahUser | null;
  login: (u: EjadahUser) => void;
  logout: () => void;
}

const Ctx = createContext<AuthCtx>({ user: null, login: () => {}, logout: () => {} });

const STORAGE_KEY = "ejadah_user";

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<EjadahUser | null>(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch {
      return null;
    }
  });

  const login = (u: EjadahUser) => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(u));
    setUser(u);
  };

  const logout = () => {
    localStorage.removeItem(STORAGE_KEY);
    setUser(null);
  };

  return <Ctx.Provider value={{ user, login, logout }}>{children}</Ctx.Provider>;
}

export function useAuth() {
  return useContext(Ctx);
}

// Derive initials avatar from user
export function userInitials(u: EjadahUser) {
  return `${u.firstName[0] ?? ""}${u.lastName[0] ?? ""}`.toUpperCase();
}

export const roleLabels: Record<string, string> = {
  student: "Dental Student",
  intern: "Intern / House Officer",
  dentist: "General Dentist",
  specialist: "Specialist",
  academic: "Academic / Researcher",
};
