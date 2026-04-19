import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';
import { apiUrl } from '@/lib/api';

export default function useAuthCheck(redirect = true) {
  const router = useRouter();

  useEffect(() => {
    fetch(apiUrl('/api/check-auth'), {
      credentials: 'include'
    }).then((res) => {
      if (res.status === 401) {
        toast.error('Ви не авторизовані');
        if (redirect) router.push('/');
      }
    });
  }, []);
}
