'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { apiUrl } from '@/lib/api';

export default function ProtectedRoute({ children }) {
  const [authorized, setAuthorized] = useState(null);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const res = await fetch(apiUrl('/api/auth/me'), {
          credentials: 'include'
        });

        if (res.ok) {
          setAuthorized(true);
        } else {
          router.push(`${pathname}?loginModal=1`);
        }
      } catch (err) {
        console.error('Auth check failed:', err);
        router.push(`${pathname}?loginModal=1`);
      }
    };

    checkAuth();
  }, []);

  if (authorized === null) return <div style={{ padding: '2rem' }}>⏳ Checking...</div>;
  if (!authorized) return null;

  return children;
}
