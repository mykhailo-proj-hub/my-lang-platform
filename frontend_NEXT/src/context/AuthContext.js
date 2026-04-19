'use client';

import { createContext, useContext, useEffect, useState } from 'react';
import { initSocket, disconnectSocket } from '../../socket';
import { apiUrl } from '@/lib/api';

export const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchUser = async () => {
    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 5000);

      const res = await fetch(apiUrl('/api/auth/me'), {
        credentials: 'include',
        signal: controller.signal,
      });

      clearTimeout(timeout);

      if (res.ok) {
        const data = await res.json();
        if (data?.id) {
          setUser(data);
          initSocket(data.id); // ✅ передаємо userId для socket
        } else {
          setUser(null);
          disconnectSocket();
        }
      } else {
        setUser(null);
        disconnectSocket();
      }
    } catch (err) {
      if (err.name === 'AbortError') {
        console.error('Fetch user request timed out');
      } else {
        console.error('Failed to fetch user:', err);
      }
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUser();
  }, []);

  const login = async () => {
    await fetchUser();
  };

  const logout = async () => {
    try {
      await fetch(apiUrl('/api/auth/logout'), {
        method: 'POST',
        credentials: 'include',
      });
      setUser(null);
      disconnectSocket();
    } catch (err) {
      console.error('Failed to logout:', err);
    }
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
